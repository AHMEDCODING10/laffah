<?php

namespace App\Livewire\Admin;

use App\Models\Trip;
use Livewire\Component;
use Livewire\WithPagination;

class TripsManager extends Component
{
    use WithPagination;

    public string $search = '';
    public string $statusFilter = '';
    public string $dateFilter = '';
    public bool $showTripModal = false;
    public ?Trip $selectedTrip = null;

    public function updatingSearch(): void { $this->resetPage(); }
    public function updatingStatusFilter(): void { $this->resetPage(); }
    public function updatingDateFilter(): void { $this->resetPage(); }

    public function render()
    {
        $trips = Trip::with(['passenger', 'captain.user', 'stops'])
            ->when($this->search, function($q) {
                $q->where('pickup_address', 'like', "%{$this->search}%")
                  ->orWhere('dropoff_address', 'like', "%{$this->search}%")
                  ->orWhere('id', 'like', "%{$this->search}%")
                  ->orWhereHas('passenger', fn($u) => $u->where('name', 'like', "%{$this->search}%")->orWhere('phone', 'like', "%{$this->search}%"))
                  ->orWhereHas('captain.user', fn($u) => $u->where('name', 'like', "%{$this->search}%")->orWhere('phone', 'like', "%{$this->search}%"));
            })
            ->when($this->statusFilter, function($q) {
                if ($this->statusFilter === 'in_transit') {
                    $q->whereIn('status', ['in_transit', 'started']);
                } else {
                    $q->where('status', $this->statusFilter);
                }
            })
            ->when($this->dateFilter, fn($q) => $q->whereDate('created_at', $this->dateFilter))
            ->latest()
            ->paginate(15);

        return view('livewire.admin.trips-manager', compact('trips'));
    }

    public function openTripModal(int $id): void
    {
        $this->selectedTrip = Trip::with(['passenger', 'captain.user', 'stops', 'promoCode'])->findOrFail($id);
        $this->showTripModal = true;
    }

    public function closeTripModal(): void
    {
        $this->showTripModal = false;
        $this->selectedTrip = null;
    }

    public function exportCsv()
    {
        $trips = Trip::with(['passenger', 'captain.user'])
            ->when($this->search, function($q) {
                $q->where('pickup_address', 'like', "%{$this->search}%")
                  ->orWhere('dropoff_address', 'like', "%{$this->search}%")
                  ->orWhere('id', 'like', "%{$this->search}%")
                  ->orWhereHas('passenger', fn($u) => $u->where('name', 'like', "%{$this->search}%")->orWhere('phone', 'like', "%{$this->search}%"))
                  ->orWhereHas('captain.user', fn($u) => $u->where('name', 'like', "%{$this->search}%")->orWhere('phone', 'like', "%{$this->search}%"));
            })
            ->when($this->statusFilter, function($q) {
                if ($this->statusFilter === 'in_transit') {
                    $q->whereIn('status', ['in_transit', 'started']);
                } else {
                    $q->where('status', $this->statusFilter);
                }
            })
            ->when($this->dateFilter, fn($q) => $q->whereDate('created_at', $this->dateFilter))
            ->latest()
            ->get();

        $csvData = "رقم الرحلة,الراكب,هاتف الراكب,الكابتن,هاتف الكابتن,حالة الرحلة,الانطلاق,الوصول,المسافة (كم),السعر النهائي,العمولة,أرباح الكابتن,تاريخ الرحلة\n";
        foreach ($trips as $trip) {
            $passengerName  = $trip->passenger->name ?? 'غير محدد';
            $passengerPhone = $trip->passenger->phone ?? '';
            $captainName    = $trip->captain->user->name ?? 'غير محدد';
            $captainPhone   = $trip->captain->user->phone ?? '';
            $price          = $trip->final_price ?? $trip->estimated_price ?? 0;
            $commission     = $trip->commission_amount ?? 0;
            $earnings       = $trip->captain_earnings ?? ($price - $commission);
            $date           = $trip->created_at->format('Y-m-d H:i');
            
            $csvData .= "{$trip->id},\"{$passengerName}\",\"{$passengerPhone}\",\"{$captainName}\",\"{$captainPhone}\",{$trip->status},\"{$trip->pickup_address}\",\"{$trip->dropoff_address}\",{$trip->distance_km},{$price},{$commission},{$earnings},{$date}\n";
        }

        return response()->streamDownload(function () use ($csvData) {
            echo chr(0xEF) . chr(0xBB) . chr(0xBF); // UTF-8 BOM for Arabic support in Excel
            echo $csvData;
        }, 'trips_export_' . date('Y-m-d') . '.csv');
    }
}