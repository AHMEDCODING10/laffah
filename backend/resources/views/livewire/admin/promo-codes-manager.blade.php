<div>
    <!-- Page Header -->
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
        <div>
            <h2 class="page-title">أكواد الخصم الترويجية</h2>
            <p class="page-subtitle">إنشاء وإدارة أكواد الخصم والعروض التسويقية للمستخدمين</p>
        </div>
    </div>

    <!-- Session Messages -->
    @if (session('success'))
        <div class="alert alert-success">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            {{ session('success') }}
        </div>
    @endif

    <div style="display:flex; gap:20px; flex-wrap:wrap; align-items:flex-start;">
        
        <!-- Left Column: Form -->
        <div class="card gradient-top" style="flex:1; min-width:300px; max-width:400px; position:sticky; top:20px;">
            <div class="card-header">
                <span class="card-title">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="display:inline;vertical-align:middle;margin-left:6px;">
                        <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line>
                    </svg>
                    {{ $isEditing ? 'تعديل كود خصم' : 'إضافة كود جديد' }}
                </span>
                @if($isEditing)
                    <button wire:click="resetForm" class="btn btn-secondary btn-sm">إلغاء التعديل</button>
                @endif
            </div>
            
            <div class="card-body">
                <form wire:submit="save">
                    <div class="form-group">
                        <label class="form-label">كود الخصم (Promo Code)</label>
                        <input type="text" wire:model="code" class="form-control" placeholder="مثال: LAFFAH2026" style="text-transform:uppercase;direction:ltr;text-align:left;">
                        @error('code') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>

                    <div class="form-group">
                        <label class="form-label">نوع الخصم</label>
                        <select wire:model.live="discount_type" class="form-control">
                            <option value="percentage">نسبة مئوية (%)</option>
                            <option value="fixed">مبلغ ثابت (ر.ي)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">قيمة الخصم</label>
                        <input type="number" wire:model="discount_value" class="form-control" placeholder="{{ $discount_type === 'percentage' ? 'مثال: 15' : 'مثال: 500' }}" min="0" step="0.5">
                        @error('discount_value') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>

                    @if($discount_type === 'percentage')
                    <div class="form-group">
                        <label class="form-label">الحد الأقصى للخصم (ر.ي) <span style="color:var(--color-text-muted);font-weight:normal;">(اختياري)</span></label>
                        <input type="number" wire:model="max_discount_amount" class="form-control" placeholder="مثال: 1000" min="0">
                        @error('max_discount_amount') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>
                    @endif

                    <div class="form-group">
                        <label class="form-label">الحد الأقصى للاستخدام <span style="color:var(--color-text-muted);font-weight:normal;">(اختياري)</span></label>
                        <input type="number" wire:model="usage_limit" class="form-control" placeholder="عدد مرات الاستخدام الإجمالية" min="1">
                        @error('usage_limit') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>

                    <div class="form-group">
                        <label class="form-label">تاريخ الانتهاء <span style="color:var(--color-text-muted);font-weight:normal;">(اختياري)</span></label>
                        <input type="datetime-local" wire:model="expires_at" class="form-control">
                        @error('expires_at') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>

                    <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                        <label class="toggle">
                            <input type="checkbox" wire:model="is_active">
                            <span class="toggle-slider"></span>
                        </label>
                        <span class="form-label" style="margin:0;">تفعيل الكود فوراً</span>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width:100%;margin-top:10px;">
                        {{ $isEditing ? 'حفظ التعديلات' : 'إضافة الكود' }}
                    </button>
                </form>
            </div>
        </div>

        <!-- Right Column: List -->
        <div class="card" style="flex:2; min-width:300px;">
            <div class="card-header">
                <span class="card-title">قائمة الأكواد الترويجية ({{ $promoCodes->total() }})</span>
                <div style="display:flex;gap:10px;">
                    <input type="text" wire:model.live.debounce.300ms="search" class="form-control" placeholder="بحث بالكود..." style="height:36px;font-size:13px;max-width:150px;">
                    <select wire:model.live="statusFilter" class="form-control" style="height:36px;font-size:13px;width:120px;">
                        <option value="">كل الحالات</option>
                        <option value="1">نشط</option>
                        <option value="0">معطل</option>
                    </select>
                </div>
            </div>

            <div class="table-responsive" style="position:relative;">
                <div wire:loading.delay class="alert" style="position:absolute;top:0;left:0;right:0;background:var(--color-primary-50);color:var(--color-primary-dark);z-index:10;margin:10px;">
                    <div class="spinner"></div> جاري التحميل...
                </div>
                
                @if($promoCodes->count())
                <table wire:loading.class="opacity-50">
                    <thead>
                        <tr>
                            <th>الكود</th>
                            <th>الخصم</th>
                            <th>الاستخدام</th>
                            <th>الانتهاء</th>
                            <th>الحالة</th>
                            <th>إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($promoCodes as $promo)
                        <tr>
                            <td>
                                <span style="background:var(--color-surface);padding:4px 10px;border-radius:6px;font-size:14px;font-weight:700;direction:ltr;display:inline-block;letter-spacing:1px;border:1px dashed var(--color-border);color:var(--color-text-primary);">
                                    {{ $promo->code }}
                                </span>
                            </td>
                            <td>
                                @if($promo->discount_type === 'percentage')
                                    <span style="font-weight:700;color:var(--color-primary);">%{{ $promo->discount_value }}</span>
                                    @if($promo->max_discount_amount)
                                        <div style="font-size:11px;color:var(--color-text-muted);">بحد أقصى {{ number_format($promo->max_discount_amount, 0) }} ر.ي</div>
                                    @endif
                                @else
                                    <span style="font-weight:700;color:var(--color-primary);">{{ number_format($promo->discount_value, 0) }} ر.ي</span>
                                @endif
                            </td>
                            <td>
                                <div style="font-size:13px;font-weight:600;">{{ $promo->used_count }} <span style="color:var(--color-text-muted);font-weight:normal;">/ {{ $promo->usage_limit ?? '∞' }}</span></div>
                                @if($promo->usage_limit && $promo->used_count >= $promo->usage_limit)
                                    <span style="font-size:11px;color:var(--color-danger);">مكتمل</span>
                                @endif
                            </td>
                            <td>
                                @if($promo->expires_at)
                                    @php $isExpired = $promo->expires_at->isPast(); @endphp
                                    <span style="font-size:12px;color:{{ $isExpired ? 'var(--color-danger)' : 'var(--color-text-muted)' }};">
                                        {{ $promo->expires_at->format('Y-m-d H:i') }}
                                    </span>
                                @else
                                    <span style="font-size:12px;color:var(--color-text-muted);">لا ينتهي</span>
                                @endif
                            </td>
                            <td>
                                <label class="toggle" title="{{ $promo->is_active ? 'نشط' : 'معطل' }}">
                                    <input type="checkbox" {{ $promo->is_active ? 'checked' : '' }} wire:click="toggleActive({{ $promo->id }})">
                                    <span class="toggle-slider"></span>
                                </label>
                            </td>
                            <td>
                                <div class="action-group">
                                    <button wire:click="edit({{ $promo->id }})" class="btn btn-secondary btn-sm btn-icon" title="تعديل">
                                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                    </button>
                                    <button wire:click="delete({{ $promo->id }})" wire:confirm="هل أنت متأكد من حذف هذا الكود؟" class="btn btn-danger btn-sm btn-icon" title="حذف">
                                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
                @else
                    <div class="empty-state">
                        <div class="empty-state-icon">🎟️</div>
                        <div class="empty-state-title">لا توجد أكواد خصم</div>
                        <div class="empty-state-desc">لم يتم العثور على أي كود خصم، قم بإضافة كود جديد من القائمة.</div>
                    </div>
                @endif
            </div>

            @if($promoCodes->hasPages())
            <div class="pagination-wrapper" style="border-top:1px solid var(--color-border);padding:14px 20px;">
                {{ $promoCodes->links() }}
            </div>
            @endif
        </div>
    </div>
</div>
