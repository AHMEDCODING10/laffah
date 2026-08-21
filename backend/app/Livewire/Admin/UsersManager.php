<?php

namespace App\Livewire\Admin;

use App\Models\User;
use App\Models\Trip;
use Livewire\Component;
use Livewire\WithPagination;

class UsersManager extends Component
{
    use WithPagination;

    public string $search = '';
    public string $roleFilter = '';

    public function updatingSearch(): void { $this->resetPage(); }
    public function updatingRoleFilter(): void { $this->resetPage(); }

    public function render()
    {
        $users = User::with(['roles', 'passengerTrips'])
            ->when($this->search, fn($q) => $q->where('name', 'like', "%{$this->search}%")
                ->orWhere('email', 'like', "%{$this->search}%")
                ->orWhere('phone', 'like', "%{$this->search}%"))
            ->when($this->roleFilter, fn($q) => $q->whereHas('roles', fn($r) => $r->where('name', $this->roleFilter)))
            ->latest()
            ->paginate(15);

        return view('livewire.admin.users-manager', compact('users'));
    }

    public function toggleActive(int $id): void
    {
        $user = User::findOrFail($id);
        $user->update(['is_active' => !$user->is_active]);
        session()->flash('success', 'تم تحديث حالة المستخدم بنجاح.');
    }

    public function deleteUser(int $id): void
    {
        $user = User::findOrFail($id);

        // Check if user is a captain with active trips
        if ($user->captainProfile) {
            $hasActiveTrips = Trip::where('captain_profile_id', $user->captainProfile->id)
                ->whereIn('status', ['accepted', 'arrived', 'in_transit'])
                ->exists();

            if ($hasActiveTrips) {
                session()->flash('error', 'لا يمكن حذف المستخدم لوجود رحلات جارية ومباشرة لهذا الحساب.');
                return;
            }

            // Clean up captain location and documents
            $user->captainProfile->location()?->delete();
            $user->captainProfile->documents()->delete();
            $user->captainProfile->delete();
        }

        // Check active passenger trips
        $hasActivePassengerTrips = Trip::where('user_id', $user->id)
            ->whereIn('status', ['pending', 'accepted', 'arrived', 'in_transit'])
            ->exists();

        if ($hasActivePassengerTrips) {
            session()->flash('error', 'لا يمكن حذف الراكب لوجود طلب رحلة قيد التنفيذ.');
            return;
        }

        $user->delete();
        session()->flash('success', 'تم حذف المستخدم بنجاح.');
    }
}