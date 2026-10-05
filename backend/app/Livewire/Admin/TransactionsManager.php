<?php

namespace App\Livewire\Admin;

use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use App\Services\WalletService;
use Illuminate\Support\Facades\DB;
use Livewire\Component;
use Livewire\WithPagination;

class TransactionsManager extends Component
{
    use WithPagination;

    public string $search = '';
    public string $typeFilter = '';
    public string $statusFilter = '';
    public string $startDate = '';
    public string $endDate = '';

    // Adjustment Modal
    public bool $showAdjustModal = false;
    public string $targetUserId = '';
    public string $adjustType = 'deposit'; // 'deposit' or 'deduction'
    public string $adjustAmount = '';
    public string $adjustReason = '';

    // Approve / Reject Modals
    public bool $showApproveModal = false;
    public bool $showRejectModal = false;
    public int $selectedTransactionId = 0;
    public string $rejectionReason = '';
    public ?Transaction $selectedTransaction = null;

    public function updatingSearch(): void       { $this->resetPage(); }
    public function updatingTypeFilter(): void   { $this->resetPage(); }
    public function updatingStatusFilter(): void { $this->resetPage(); }
    public function updatingStartDate(): void    { $this->resetPage(); }
    public function updatingEndDate(): void      { $this->resetPage(); }

    public function render()
    {
        $transactions = Transaction::with(['wallet.user', 'trip', 'approver'])
            ->when($this->search, function($q) {
                $q->where('reference_id', 'like', "%{$this->search}%")
                  ->orWhere('description', 'like', "%{$this->search}%")
                  ->orWhere('sender_account', 'like', "%{$this->search}%")
                  ->orWhereHas('wallet.user', fn($u) => $u->where('name', 'like', "%{$this->search}%")->orWhere('phone', 'like', "%{$this->search}%"));
            })
            ->when($this->typeFilter, fn($q) => $q->where('type', $this->typeFilter))
            ->when($this->statusFilter, fn($q) => $q->where('status', $this->statusFilter))
            ->when($this->startDate, fn($q) => $q->where('created_at', '>=', \Carbon\Carbon::parse($this->startDate)->startOfDay()))
            ->when($this->endDate, fn($q) => $q->where('created_at', '<=', \Carbon\Carbon::parse($this->endDate)->endOfDay()))
            ->latest()
            ->paginate(15);

        $pendingCount = Transaction::where('type', 'deposit')->where('status', 'pending')->count();

        return view('livewire.admin.transactions-manager', compact('transactions', 'pendingCount'));
    }

    public function openAdjustModal(): void
    {
        $this->targetUserId = '';
        $this->adjustType = 'deposit';
        $this->adjustAmount = '';
        $this->adjustReason = '';
        $this->showAdjustModal = true;
    }

    public function closeAdjustModal(): void
    {
        $this->showAdjustModal = false;
        $this->targetUserId = '';
        $this->adjustAmount = '';
        $this->adjustReason = '';
    }

    public function submitAdjustment(): void
    {
        $this->validate([
            'targetUserId' => 'required|exists:users,id',
            'adjustType'   => 'required|in:deposit,deduction',
            'adjustAmount' => 'required|numeric|min:1',
            'adjustReason' => 'required|string|min:3|max:255',
        ], [
            'targetUserId.required' => 'يرجى إدخال رقم المستخدم (ID)',
            'targetUserId.exists'   => 'رقم المستخدم غير موجود في النظام',
            'adjustAmount.required' => 'يرجى إدخال المبلغ',
            'adjustAmount.min'      => 'المبلغ يجب أن يكون أكبر من صفر',
            'adjustReason.required' => 'يرجى كتابة سبب التعديل',
        ]);

        DB::transaction(function () {
            $user = User::findOrFail($this->targetUserId);
            $wallet = Wallet::firstOrCreate(
                ['user_id' => $user->id],
                ['balance' => 0.0, 'held_balance' => 0.0, 'currency' => 'YER']
            );

            // Acquire pessimistic row lock on wallet
            $lockedWallet = Wallet::where('id', $wallet->id)->lockForUpdate()->firstOrFail();
            $amount = (float) $this->adjustAmount;

            if ($this->adjustType === 'deposit') {
                $lockedWallet->balance += $amount;
                $ref = 'ADM-DEP-' . strtoupper(bin2hex(random_bytes(3)));
                $desc = 'شحن يدوي من الإدارة: ' . $this->adjustReason;
            } else {
                $lockedWallet->balance -= $amount;
                $ref = 'ADM-DED-' . strtoupper(bin2hex(random_bytes(3)));
                $desc = 'خصم يدوي من الإدارة: ' . $this->adjustReason;
            }
            $lockedWallet->save();

            $tx = Transaction::create([
                'wallet_id'    => $wallet->id,
                'type'         => $this->adjustType,
                'amount'       => $amount,
                'status'       => 'completed',
                'description'  => $desc,
                'reference_id' => $ref,
                'approved_by'  => auth()->id(),
                'approved_at'  => now(),
            ]);

            try {
                event(new \App\Events\WalletBalanceUpdated($lockedWallet, $tx, $desc));
            } catch (\Exception $e) {}
        });

        session()->flash('success', 'تم تعديل رصيد المحفظة وتسجيل المعاملة بنجاح.');
        $this->closeAdjustModal();
    }

    public function openApproveModal(int $id): void
    {
        $this->selectedTransactionId = $id;
        $this->selectedTransaction = Transaction::with('wallet.user')->find($id);
        $this->showApproveModal = true;
    }

    public function confirmApprove(): void
    {
        try {
            app(WalletService::class)->approveRecharge($this->selectedTransactionId, auth()->id());
            session()->flash('success', 'تم اعتماد طلب الشحن وإيداع الرصيد بنجاح في محفظة المستخدم.');
        } catch (\Exception $e) {
            session()->flash('error', 'خطأ: ' . $e->getMessage());
        }
        $this->closeModals();
    }

    public function openRejectModal(int $id): void
    {
        $this->selectedTransactionId = $id;
        $this->selectedTransaction = Transaction::with('wallet.user')->find($id);
        $this->rejectionReason = '';
        $this->showRejectModal = true;
    }

    public function confirmReject(): void
    {
        if (empty(trim($this->rejectionReason))) {
            session()->flash('error', 'يرجى كتابة سبب رفض طلب الشحن لإشعار المستخدم.');
            return;
        }

        try {
            app(WalletService::class)->rejectRecharge($this->selectedTransactionId, auth()->id(), $this->rejectionReason);
            session()->flash('success', 'تم رفض طلب الشحن وإشعار المستخدم بنجاح.');
        } catch (\Exception $e) {
            session()->flash('error', 'خطأ: ' . $e->getMessage());
        }
        $this->closeModals();
    }

    public function closeModals(): void
    {
        $this->showApproveModal = false;
        $this->showRejectModal = false;
        $this->selectedTransactionId = 0;
        $this->selectedTransaction = null;
        $this->rejectionReason = '';
    }

    public function exportCsv()
    {
        $transactions = Transaction::with(['wallet.user', 'trip'])
            ->when($this->search, function($q) {
                $q->where('reference_id', 'like', "%{$this->search}%")
                  ->orWhere('description', 'like', "%{$this->search}%")
                  ->orWhere('sender_account', 'like', "%{$this->search}%")
                  ->orWhereHas('wallet.user', fn($u) => $u->where('name', 'like', "%{$this->search}%")->orWhere('phone', 'like', "%{$this->search}%"));
            })
            ->when($this->typeFilter, fn($q) => $q->where('type', $this->typeFilter))
            ->when($this->statusFilter, fn($q) => $q->where('status', $this->statusFilter))
            ->when($this->startDate, fn($q) => $q->where('created_at', '>=', \Carbon\Carbon::parse($this->startDate)->startOfDay()))
            ->when($this->endDate, fn($q) => $q->where('created_at', '<=', \Carbon\Carbon::parse($this->endDate)->endOfDay()))
            ->latest()
            ->get();

        $csvData = "رقم المعاملة,المستخدم,النوع,المبلغ,الحالة,المرجع,البيان,التاريخ\n";
        foreach ($transactions as $transaction) {
            $user = $transaction->wallet->user->name ?? 'غير محدد';
            $typeMap = [
                'deposit'    => 'إيداع / شحن',
                'withdrawal' => 'سحب أرباح',
                'commission' => 'عمولة',
                'deduction'  => 'خصم',
            ];
            $type = $typeMap[$transaction->type] ?? $transaction->type;
            $statusMap = [
                'pending'   => 'قيد المراجعة',
                'completed' => 'مكتمل',
                'rejected'  => 'مرفوض',
            ];
            $status = $statusMap[$transaction->status] ?? $transaction->status;
            $desc = str_replace('"', '""', $transaction->description ?? '');
            $ref = $transaction->reference_id ?? '—';
            $date = $transaction->created_at->format('Y-m-d H:i');
            
            $csvData .= "{$transaction->id},\"{$user}\",{$type},{$transaction->amount},{$status},{$ref},\"{$desc}\",{$date}\n";
        }

        return response()->streamDownload(function () use ($csvData) {
            echo chr(0xEF) . chr(0xBB) . chr(0xBF);
            echo $csvData;
        }, 'transactions_export_' . date('Y-m-d') . '.csv');
    }
}