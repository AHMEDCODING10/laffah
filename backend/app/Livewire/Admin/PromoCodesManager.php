<?php

namespace App\Livewire\Admin;

use App\Models\PromoCode;
use Livewire\Component;
use Livewire\WithPagination;

class PromoCodesManager extends Component
{
    use WithPagination;

    public string $search = '';
    public string $statusFilter = '';
    
    // Form fields for creating/editing
    public $isEditing = false;
    public $promoCodeId;
    public $code = '';
    public $discount_type = 'percentage';
    public $discount_value = '';
    public $max_discount_amount = '';
    public $usage_limit = '';
    public $expires_at = '';
    public $is_active = true;

    public function updatingSearch(): void { $this->resetPage(); }
    public function updatingStatusFilter(): void { $this->resetPage(); }

    public function rules()
    {
        return [
            'code' => 'required|string|max:50|unique:promo_codes,code,' . $this->promoCodeId,
            'discount_type' => 'required|in:percentage,fixed',
            'discount_value' => 'required|numeric|min:0',
            'max_discount_amount' => 'nullable|numeric|min:0',
            'usage_limit' => 'nullable|integer|min:1',
            'expires_at' => 'nullable|date',
            'is_active' => 'boolean',
        ];
    }

    public function render()
    {
        $promoCodes = PromoCode::query()
            ->when($this->search, fn($q) => $q->where('code', 'like', "%{$this->search}%"))
            ->when($this->statusFilter !== '', function($q) {
                if ($this->statusFilter == '1') return $q->where('is_active', true);
                if ($this->statusFilter == '0') return $q->where('is_active', false);
            })
            ->latest()
            ->paginate(15);

        return view('livewire.admin.promo-codes-manager', compact('promoCodes'));
    }

    public function save()
    {
        $this->validate();

        PromoCode::updateOrCreate(
            ['id' => $this->promoCodeId],
            [
                'code' => strtoupper($this->code),
                'discount_type' => $this->discount_type,
                'discount_value' => $this->discount_value,
                'max_discount_amount' => $this->discount_type === 'percentage' ? $this->max_discount_amount : null,
                'usage_limit' => $this->usage_limit ?: null,
                'expires_at' => $this->expires_at ?: null,
                'is_active' => $this->is_active,
            ]
        );

        session()->flash('success', $this->isEditing ? 'تم تحديث كود الخصم بنجاح.' : 'تم إضافة كود الخصم بنجاح.');
        $this->resetForm();
    }

    public function edit(int $id)
    {
        $promo = PromoCode::findOrFail($id);
        $this->promoCodeId = $promo->id;
        $this->code = $promo->code;
        $this->discount_type = $promo->discount_type;
        $this->discount_value = $promo->discount_value;
        $this->max_discount_amount = $promo->max_discount_amount;
        $this->usage_limit = $promo->usage_limit;
        $this->expires_at = $promo->expires_at ? $promo->expires_at->format('Y-m-d\TH:i') : '';
        $this->is_active = $promo->is_active;
        $this->isEditing = true;
    }

    public function delete(int $id)
    {
        PromoCode::findOrFail($id)->delete();
        session()->flash('success', 'تم حذف كود الخصم بنجاح.');
    }

    public function toggleActive(int $id)
    {
        $promo = PromoCode::findOrFail($id);
        $promo->update(['is_active' => !$promo->is_active]);
        session()->flash('success', 'تم تحديث حالة كود الخصم.');
    }

    public function resetForm()
    {
        $this->reset(['promoCodeId', 'code', 'discount_type', 'discount_value', 'max_discount_amount', 'usage_limit', 'expires_at', 'is_active', 'isEditing']);
        $this->resetValidation();
    }
}
