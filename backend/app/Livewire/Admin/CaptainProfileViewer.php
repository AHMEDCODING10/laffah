<?php

namespace App\Livewire\Admin;

use App\Models\CaptainProfile;
use App\Models\Trip;
use App\Models\Transaction;
use Livewire\Component;

class CaptainProfileViewer extends Component
{
    public $captain;

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

    public function verifyCaptain()
    {
        // Require documents: id_card and vehicle_registration
        $hasIdCard = $this->captain->documents()->where('type', 'id_card')->exists();
        $hasVehicleRegistration = $this->captain->documents()->where('type', 'vehicle_registration')->exists();

        if (!$hasIdCard || !$hasVehicleRegistration) {
            $this->addError('verification', 'يجب أن يرفع الكابتن بطاقة الهوية وتسجيل المركبة ليتم توثيقه.');
            return;
        }

        $this->captain->update(['is_verified' => true]);
        
        // Update documents status
        $this->captain->documents()->whereIn('type', ['id_card', 'vehicle_registration'])->update(['status' => 'approved']);
        
        session()->flash('success', 'تم توثيق الحساب والموافقة على المستندات بنجاح.');
        $this->captain->refresh();
    }
}
