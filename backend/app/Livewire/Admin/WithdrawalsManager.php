<?php

namespace App\Livewire\Admin;

use App\Models\WithdrawalRequest;
use App\Services\WalletService;
use Livewire\Component;
use Livewire\WithPagination;

class WithdrawalsManager extends Component
{
    use WithPagination;

    public string $search = '';
    public string $statusFilter = '';
    public bool $showCompleteModal = false;
    public bool $showRejectModal   = false;
    public int $selectedRequestId  = 0;
    public string $transferReference = '';
    public string $rejectionReason  = '';

    public function updatingSearch(): void        { $this->resetPage(); }
    public function updatingStatusFilter(): void  { $this->resetPage(); }

    public function render()
    {
        $withdrawals = WithdrawalRequest::with('captainProfile.user')
            ->when($this->search, fn($q) => $q->whereHas('captainProfile.user',
                fn($u) => $u->where('name', 'like', "%{$this->search}%")
            ))
            ->when($this->statusFilter, fn($q) => $q->where('status', $this->statusFilter))
            ->latest()
            ->paginate(15);

        return view('livewire.admin.withdrawals-manager', compact('withdrawals'));
    }

    public function openCompleteModal(int $id): void
    {
        $this->selectedRequestId = $id;
        $this->transferReference = '';
        $this->showCompleteModal  = true;
    }

    public function openRejectModal(int $id): void
    {
        $this->selectedRequestId = $id;
        $this->rejectionReason   = '';
        $this->showRejectModal   = true;
    }

    public function confirmComplete(): void
    {
        try {
            app(WalletService::class)->completePayout(
                $this->selectedRequestId,
                auth()->id(),
                $this->transferReference ?: null
            );
            session()->flash('success', 'تم إكمال طلب السحب وتأكيد التحويل بنجاح.');
        } catch (\Exception $e) {
            session()->flash('error', 'خطأ: ' . $e->getMessage());
        }
        $this->showCompleteModal  = false;
        $this->selectedRequestId  = 0;
        $this->transferReference  = '';
    }

    public function confirmReject(): void
    {
        if (empty(trim($this->rejectionReason))) {
            session()->flash('error', 'يرجى كتابة سبب الرفض لإشعار الكابتن وإعادة رصيده تلقائياً.');
            return;
        }

        try {
            app(WalletService::class)->rejectPayout(
                $this->selectedRequestId,
                auth()->id(),
                $this->rejectionReason
            );
            session()->flash('success', 'تم رفض الطلب وتمت إعادة المبلغ تلقائياً إلى محفظة الكابتن.');
        } catch (\Exception $e) {
            session()->flash('error', 'خطأ: ' . $e->getMessage());
        }
        $this->showRejectModal   = false;
        $this->selectedRequestId = 0;
        $this->rejectionReason   = '';
    }

    public function closeModals(): void
    {
        $this->showCompleteModal = false;
        $this->showRejectModal   = false;
        $this->selectedRequestId = 0;
        $this->transferReference = '';
        $this->rejectionReason   = '';
    }
}