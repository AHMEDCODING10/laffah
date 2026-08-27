<?php

namespace App\Livewire\Admin;

use App\Models\Document;
use App\Services\NotificationService;
use Livewire\Component;
use Livewire\WithPagination;

class DocumentsManager extends Component
{
    use WithPagination;

    public string $search = '';
    public string $statusFilter = '';
    public string $typeFilter = '';

    public bool $showRejectModal = false;
    public ?int $selectedDocId = null;
    public string $rejectionReason = '';

    public bool $showViewModal = false;
    public ?Document $viewingDoc = null;

    public function updatingSearch(): void { $this->resetPage(); }
    public function updatingStatusFilter(): void { $this->resetPage(); }
    public function updatingTypeFilter(): void { $this->resetPage(); }

    public function openViewModal(int $id): void
    {
        $this->viewingDoc = Document::with('captainProfile.user')->findOrFail($id);
        $this->showViewModal = true;
    }

    public function closeViewModal(): void
    {
        $this->showViewModal = false;
        $this->viewingDoc = null;
    }

    public function render()
    {
        $documents = Document::with('captainProfile.user')
            ->when($this->search, fn($q) => $q->whereHas('captainProfile.user',
                fn($u) => $u->where('name', 'like', "%{$this->search}%")
            ))
            ->when($this->statusFilter, fn($q) => $q->where('status', $this->statusFilter))
            ->when($this->typeFilter, fn($q) => $q->where('type', $this->typeFilter))
            ->latest()
            ->paginate(15);

        return view('livewire.admin.documents-manager', compact('documents'));
    }

    public function approve(int $id): void
    {
        $doc = Document::with('captainProfile.user')->findOrFail($id);
        $doc->update(['status' => 'approved', 'rejection_reason' => null]);

        $captain = $doc->captainProfile;
        if ($captain) {
            // Check if all captain documents are approved
            $pendingCount = Document::where('captain_profile_id', $captain->id)
                ->where('status', '!=', 'approved')
                ->count();
            if ($pendingCount === 0) {
                $captain->update(['is_verified' => true]);
            }

            if ($captain->user) {
                try {
                    app(NotificationService::class)->sendToUser(
                        $captain->user,
                        'تمت الموافقة على الوثيقة ✅',
                        "تم قبول وثيقتك ({$doc->type}) وتوثيق حسابك بنجاح.",
                        ['type' => 'document_approved', 'document_id' => (string) $doc->id]
                    );
                } catch (\Exception $e) {}
            }
        }

        session()->flash('success', 'تم قبول المستند وتحديث حالة الكابتن بنجاح.');
    }

    public function openRejectModal(int $id): void
    {
        $this->selectedDocId = $id;
        $this->rejectionReason = '';
        $this->showRejectModal = true;
    }

    public function confirmReject(): void
    {
        if (empty(trim($this->rejectionReason))) {
            session()->flash('error', 'يرجى إدخال سبب الرفض لتوضيحه للكابتن.');
            return;
        }

        $doc = Document::with('captainProfile.user')->findOrFail($this->selectedDocId);
        $doc->update([
            'status' => 'rejected',
            'rejection_reason' => $this->rejectionReason,
        ]);

        if ($doc->captainProfile && $doc->captainProfile->user) {
            try {
                app(NotificationService::class)->sendToUser(
                    $doc->captainProfile->user,
                    'تم رفض المستند ⚠️',
                    "تم رفض وثيقة ({$doc->type}). السبب: {$this->rejectionReason}",
                    ['type' => 'document_rejected', 'document_id' => (string) $doc->id]
                );
            } catch (\Exception $e) {}
        }

        session()->flash('success', 'تم رفض المستند وإشعار الكابتن بالسبب.');
        $this->closeModal();
    }

    public function toggleCaptainVerification(int $captainProfileId): void
    {
        $captain = \App\Models\CaptainProfile::findOrFail($captainProfileId);
        $newStatus = !$captain->is_verified;
        $captain->update(['is_verified' => $newStatus]);

        if ($newStatus) {
            session()->flash('success', 'تم توثيق حساب الكابتن بنجاح ✅');
        } else {
            session()->flash('success', 'تم إلغاء توثيق حساب الكابتن ⚠️');
        }

        if ($this->viewingDoc && $this->viewingDoc->captain_profile_id == $captainProfileId) {
            $this->viewingDoc->load('captainProfile.user');
        }
    }

    public function closeModal(): void
    {
        $this->showRejectModal = false;
        $this->selectedDocId = null;
        $this->rejectionReason = '';
    }
}