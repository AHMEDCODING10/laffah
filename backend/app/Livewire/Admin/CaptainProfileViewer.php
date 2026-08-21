<?php

namespace App\Livewire\Admin;

use App\Models\CaptainProfile;
use App\Models\Document;
use App\Models\Trip;
use App\Models\Transaction;
use Livewire\Component;

class CaptainProfileViewer extends Component
{
    public $captain;
    public bool $showDocModal = false;
    public ?Document $selectedDoc = null;

    public function mount($id)
    {
        $this->captain = CaptainProfile::with(['user.wallet', 'documents'])->findOrFail($id);
    }

    public function render()
    {
        // Get recent trips
        $recentTrips = Trip::where('captain_profile_id', $this->captain->id)
                           ->with('passenger')
                           ->latest()
                           ->take(5)
                           ->get();

        // Get recent transactions from their wallet
        $recentTransactions = collect();
        if ($this->captain->user && $this->captain->user->wallet) {
            $recentTransactions = Transaction::where('wallet_id', $this->captain->user->wallet->id)
                                             ->latest()
                                             ->take(5)
                                             ->get();
        }

        return view('livewire.admin.captain-profile-viewer', [
            'recentTrips' => $recentTrips,
            'recentTransactions' => $recentTransactions,
        ])->layout('components.admin-layout', ['title' => 'ملف الكابتن: ' . ($this->captain->user->name ?? 'غير معروف')]);
    }

    public function toggleVerification(): void
    {
        $newStatus = !$this->captain->is_verified;
        $this->captain->update(['is_verified' => $newStatus]);

        if ($newStatus) {
            $this->captain->documents()->where('status', 'pending')->update(['status' => 'approved']);
            session()->flash('success', 'تم توثيق حساب الكابتن بنجاح ✅');
        } else {
            session()->flash('success', 'تم إلغاء توثيق حساب الكابتن ⚠️');
        }

        $this->captain->refresh();
    }

    public function openDocModal(int $docId): void
    {
        $this->selectedDoc = Document::with('captainProfile.user')->findOrFail($docId);
        $this->showDocModal = true;
    }

    public function closeDocModal(): void
    {
        $this->showDocModal = false;
        $this->selectedDoc = null;
    }

    public function approveDoc(int $docId): void
    {
        $doc = Document::findOrFail($docId);
        $doc->update(['status' => 'approved', 'rejection_reason' => null]);
        session()->flash('success', 'تمت الموافقة على الوثيقة بنجاح ✅');
        $this->captain->refresh();
        if ($this->selectedDoc && $this->selectedDoc->id === $docId) {
            $this->selectedDoc = $doc;
        }
    }

    public function rejectDoc(int $docId): void
    {
        $doc = Document::findOrFail($docId);
        $doc->update(['status' => 'rejected', 'rejection_reason' => 'الوثيقة غير واضحة أو غير مطابقة للبيانات']);
        session()->flash('success', 'تم رفض الوثيقة وتحديث الحالة ⚠️');
        $this->captain->refresh();
        if ($this->selectedDoc && $this->selectedDoc->id === $docId) {
            $this->selectedDoc = $doc;
        }
    }
}
