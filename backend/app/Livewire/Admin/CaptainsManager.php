<?php

namespace App\Livewire\Admin;

use App\Models\CaptainProfile;
use App\Models\Trip;
use Livewire\Component;
use Livewire\WithPagination;

class CaptainsManager extends Component
{
    use WithPagination;

    public string $search = '';
    public string $statusFilter = '';

    public function updatingSearch(): void { $this->resetPage(); }
    public function updatingStatusFilter(): void { $this->resetPage(); }

    public function render()
    {
        $captains = CaptainProfile::with('user')
            ->when($this->search, fn($q) => $q->whereHas('user', fn($u) => $u->where('name', 'like', "%{$this->search}%")))
            ->when($this->statusFilter === 'verified', fn($q) => $q->where('is_verified', true))
            ->when($this->statusFilter === 'unverified', fn($q) => $q->where('is_verified', false))
            ->when($this->statusFilter === 'online', fn($q) => $q->where('is_online', true))
            ->latest()
            ->paginate(15);

        return view('livewire.admin.captains-manager', compact('captains'));
    }

    public function toggleVerified(int $id): void
    {
        $captain = CaptainProfile::findOrFail($id);
        $captain->update(['is_verified' => !$captain->is_verified]);
        session()->flash('success', 'تم تحديث حالة التوثيق بنجاح.');
    }

    public function deleteCaptain(int $id): void
    {
        $captain = CaptainProfile::with('user')->findOrFail($id);

        $hasActiveTrips = Trip::where('captain_profile_id', $captain->id)
            ->whereIn('status', ['accepted', 'started', 'on_the_way', 'arrived'])
            ->exists();

        $hasActiveParcels = \App\Models\Parcel::where('captain_profile_id', $captain->id)
            ->whereIn('status', ['accepted', 'arrived_at_pickup', 'picked_up', 'in_transit'])
            ->exists();

        if ($hasActiveTrips || $hasActiveParcels) {
            session()->flash('error', 'لا يمكن حذف الكابتن لوجود مشاوير أو طرود نشطة جارية حالياً.');
            return;
        }

        $user = $captain->user;
        $captain->delete();
        if ($user) {
            $user->delete();
        }

        session()->flash('success', 'تم حذف الكابتن وحسابه بنجاح.');
    }
}