<div>
    <!-- Page Header -->
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
        <div>
            <h2 class="page-title">المعاملات المالية</h2>
            <p class="page-subtitle">عرض وتتبع جميع المعاملات المالية والشحن في التطبيق</p>
        </div>
        <div>
            <button wire:click="openAdjustModal" class="btn btn-primary btn-sm">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:4px;"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                تعديل رصيد / شحن يدوي
            </button>
        </div>
    </div>

    <!-- Session Messages -->
    @if (session('success'))
        <div class="alert alert-success" style="margin-bottom:16px;">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            {{ session('success') }}
        </div>
    @endif
    @if (session('error'))
        <div class="alert alert-danger" style="margin-bottom:16px;">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            {{ session('error') }}
        </div>
    @endif

    <!-- Filters -->
    <div class="card" style="margin-bottom:20px;">
        <div class="card-body" style="padding:14px 20px;">
            <div class="filters-row" style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;">
                <div class="form-group" style="flex:2;min-width:240px;margin-bottom:0;">
                    <div class="search-bar">
                        <span class="search-icon">
                            <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        </span>
                        <input type="text" wire:model.live.debounce.300ms="search" class="form-control" placeholder="بحث برقم المرجع أو اسم المستخدم أو الوصف...">
                    </div>
                </div>
                <div class="form-group" style="min-width:140px;margin-bottom:0;">
                    <select wire:model.live="typeFilter" class="form-control">
                        <option value="">كل الأنواع</option>
                        <option value="deposit">إيداع / شحن</option>
                        <option value="withdrawal">سحب أرباح</option>
                        <option value="commission">عمولة</option>
                        <option value="deduction">خصم</option>
                    </select>
                </div>
                <div class="form-group" style="min-width:140px;margin-bottom:0;">
                    <input type="date" wire:model.live="startDate" class="form-control" placeholder="من تاريخ">
                </div>
                <div class="form-group" style="min-width:140px;margin-bottom:0;">
                    <input type="date" wire:model.live="endDate" class="form-control" placeholder="إلى تاريخ">
                </div>
                <div class="form-group" style="min-width:100px;margin-bottom:0;">
                    <button wire:click="exportCsv" class="btn btn-secondary" style="width:100%;height:38px;padding:0 12px;display:flex;align-items:center;justify-content:center;gap:6px;">
                        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                        تصدير
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Loading -->
    <div wire:loading.delay class="alert" style="background:var(--color-primary-50);color:var(--color-primary-dark);border:1px solid var(--color-primary-100);">
        <div class="spinner"></div>
        جاري التحميل...
    </div>

    <!-- Transactions Table -->
    <div class="card" wire:loading.class="opacity-50">
        <div class="card-header">
            <span class="card-title">💳 سجل المعاملات ({{ $transactions->total() }})</span>
        </div>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>المستخدم</th>
                        <th>النوع</th>
                        <th>المبلغ</th>
                        <th>رقم المرجع / الرحلة</th>
                        <th>الوصف</th>
                        <th>التاريخ</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($transactions as $tx)
                        <tr>
                            <td class="font-mono text-muted">#{{ $tx->id }}</td>
                            <td>
                                @if($tx->wallet && $tx->wallet->user)
                                    <div style="font-weight:600;">{{ $tx->wallet->user->name }}</div>
                                    <div class="text-muted" style="font-size:12px;direction:ltr;text-align:right;">{{ $tx->wallet->user->phone ?? '—' }}</div>
                                @else
                                    <span class="text-muted">مستخدم غير متوفر</span>
                                @endif
                            </td>
                            <td>
                                @if($tx->type === 'deposit')
                                    <span class="badge badge-success">إيداع / شحن</span>
                                @elseif($tx->type === 'withdrawal')
                                    <span class="badge badge-danger">سحب أرباح</span>
                                @elseif($tx->type === 'commission')
                                    <span class="badge badge-warning">عمولة</span>
                                @elseif($tx->type === 'deduction')
                                    <span class="badge badge-danger">خصم</span>
                                @elseif($tx->type === 'payment')
                                    <span class="badge badge-info">دفع رحلة</span>
                                @else
                                    <span class="badge badge-secondary">{{ $tx->type }}</span>
                                @endif
                            </td>
                            <td class="font-mono" style="font-weight:700;{{ in_array($tx->type, ['deposit']) ? 'color:var(--color-success);' : 'color:var(--color-danger);' }}">
                                {{ in_array($tx->type, ['deposit']) ? '+' : '-' }}{{ number_format($tx->amount, 0) }} ر.ي
                            </td>
                            <td class="font-mono text-muted">
                                @if($tx->trip_id)
                                    <span class="badge badge-primary">رحلة #{{ $tx->trip_id }}</span>
                                @else
                                    <span style="font-size:12px;">{{ $tx->reference_id ?: '—' }}</span>
                                @endif
                            </td>
                            <td style="max-width:240px;font-size:13px;">{{ $tx->description ?: '—' }}</td>
                            <td class="text-muted" style="font-size:12px;white-space:nowrap;">{{ $tx->created_at->format('Y-m-d H:i') }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="text-center text-muted" style="padding:40px;">
                                لا توجد معاملات مالية مطابقة للفلاتر المحددة.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($transactions->hasPages())
            <div class="card-footer" style="padding:16px 20px;">
                {{ $transactions->links() }}
            </div>
        @endif
    </div>

    <!-- Manual Wallet Adjustment Modal -->
    @if($showAdjustModal)
    <div style="position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:9999;display:flex;align-items:center;justify-content:center;padding:16px;">
        <div class="card" style="width:100%;max-width:480px;box-shadow:0 20px 25px -5px rgba(0,0,0,0.3);">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;">
                <span class="card-title">تعديل رصيد محفظة / شحن يدوي</span>
                <button wire:click="closeAdjustModal" style="background:none;border:none;cursor:pointer;font-size:20px;color:var(--color-text-muted);">&times;</button>
            </div>
            <div class="card-body" style="padding:20px;">
                <form wire:submit="submitAdjustment">
                    <div class="form-group" style="margin-bottom:14px;">
                        <label class="form-label">رقم المستخدم في النظام (User ID) <span style="color:var(--color-danger);">*</span></label>
                        <input type="number" wire:model="targetUserId" class="form-control" placeholder="أدخل رقم الـ ID للمستخدم أو الكابتن">
                        @error('targetUserId') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>

                    <div class="form-group" style="margin-bottom:14px;">
                        <label class="form-label">نوع العملية <span style="color:var(--color-danger);">*</span></label>
                        <select wire:model="adjustType" class="form-control">
                            <option value="deposit">➕ إيداع / شحن رصيد / مكافأة</option>
                            <option value="deduction">➖ خصم من الرصيد / تسوية</option>
                        </select>
                    </div>

                    <div class="form-group" style="margin-bottom:14px;">
                        <label class="form-label">المبلغ (ر.ي) <span style="color:var(--color-danger);">*</span></label>
                        <input type="number" wire:model="adjustAmount" class="form-control" placeholder="مثال: 5000" min="1" step="50">
                        @error('adjustAmount') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>

                    <div class="form-group" style="margin-bottom:16px;">
                        <label class="form-label">السبب / البيان <span style="color:var(--color-danger);">*</span></label>
                        <input type="text" wire:model="adjustReason" class="form-control" placeholder="مثال: مكافأة شهرية / شحن يدوي مباشر / تسوية حساب">
                        @error('adjustReason') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>

                    <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:20px;">
                        <button type="button" wire:click="closeAdjustModal" class="btn btn-secondary btn-sm">إلغاء</button>
                        <button type="submit" class="btn btn-primary btn-sm">تنفيذ العملية وتحديث المحفظة</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    @endif
</div>