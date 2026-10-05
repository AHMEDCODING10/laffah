<div>
    <!-- Page Header -->
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
        <div>
            <h2 class="page-title">المعاملات المالية والشحن</h2>
            <p class="page-subtitle">إدارة ومطابقة عمليات الشحن الإلكتروني والتحويلات وسحب الأرباح</p>
        </div>
        <div style="display:flex;gap:10px;align-items:center;">
            @if(isset($pendingCount) && $pendingCount > 0)
                <button wire:click="$set('statusFilter', 'pending')" class="btn btn-warning btn-sm" style="font-weight:700;">
                    ⏳ طلبات معلقة بانتظار الاعتماد ({{ $pendingCount }})
                </button>
            @endif
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
                        <input type="text" wire:model.live.debounce.300ms="search" class="form-control" placeholder="بحث برقم السند، المرجع، المحول منه، اسم المستخدم...">
                    </div>
                </div>
                <div class="form-group" style="min-width:130px;margin-bottom:0;">
                    <select wire:model.live="statusFilter" class="form-control">
                        <option value="">كل الحالات</option>
                        <option value="pending">⏳ قيد المراجعة</option>
                        <option value="completed">✅ معتمد / مكتمل</option>
                        <option value="rejected">❌ مرفوض</option>
                    </select>
                </div>
                <div class="form-group" style="min-width:130px;margin-bottom:0;">
                    <select wire:model.live="typeFilter" class="form-control">
                        <option value="">كل العمليات</option>
                        <option value="deposit">إيداع / شحن</option>
                        <option value="withdrawal">سحب أرباح</option>
                        <option value="commission">عمولة</option>
                        <option value="deduction">خصم</option>
                    </select>
                </div>
                <div class="form-group" style="min-width:130px;margin-bottom:0;">
                    <input type="date" wire:model.live="startDate" class="form-control" placeholder="من تاريخ">
                </div>
                <div class="form-group" style="min-width:130px;margin-bottom:0;">
                    <input type="date" wire:model.live="endDate" class="form-control" placeholder="إلى تاريخ">
                </div>
                <div class="form-group" style="min-width:90px;margin-bottom:0;">
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
        جاري تحديث المعاملات...
    </div>

    <!-- Transactions Table -->
    <div class="card" wire:loading.class="opacity-50">
        <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;">
            <span class="card-title">💳 سجل المعاملات المالية ({{ $transactions->total() }})</span>
            <div style="font-size:12px;color:var(--color-text-muted);">
                تحديث لحظي لحسابات المحافظ والعمولات
            </div>
        </div>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>المستخدم / الحساب</th>
                        <th>قناة الدفع / المحفظة</th>
                        <th>المبلغ</th>
                        <th>الحالة</th>
                        <th>رقم السند / المرجع</th>
                        <th>التاريخ</th>
                        <th style="text-align:center;">الإجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($transactions as $tx)
                        <tr style="{{ $tx->status === 'pending' ? 'background:rgba(255,152,0,0.04);' : '' }}">
                            <td class="font-mono text-muted">#{{ $tx->id }}</td>
                            <td>
                                @if($tx->wallet && $tx->wallet->user)
                                    <div style="font-weight:700;">{{ $tx->wallet->user->name }}</div>
                                    <div class="text-muted" style="font-size:12px;direction:ltr;text-align:right;">{{ $tx->wallet->user->phone ?? '—' }}</div>
                                @else
                                    <span class="text-muted">مستخدم غير متوفر</span>
                                @endif
                            </td>
                            <td>
                                @php
                                    $channelNames = [
                                        'kuraimi'  => 'الكريمي (حاسب / إم فلوس)',
                                        'onecash'  => 'ون كاش (OneCash)',
                                        'jawali'   => 'جوالي (WeCash)',
                                        'jeeb'     => 'محفظة جيب',
                                        'tadhamon' => 'محفظتي (التضامن)',
                                        'cac'      => 'كاك بنك (السريع)',
                                        'cash'     => 'نقداً / إيداع مباشر',
                                    ];
                                    $channel = $channelNames[$tx->payment_method] ?? ($tx->payment_method ?: '—');
                                @endphp
                                <div style="font-weight:600;font-size:13px;">{{ $channel }}</div>
                                @if($tx->sender_account)
                                    <div class="text-muted" style="font-size:11px;">من: {{ $tx->sender_account }}</div>
                                @endif
                            </td>
                            <td class="font-mono" style="font-weight:800;font-size:14px;{{ in_array($tx->type, ['deposit']) ? 'color:var(--color-success);' : 'color:var(--color-danger);' }}">
                                {{ in_array($tx->type, ['deposit']) ? '+' : '-' }}{{ number_format($tx->amount, 0) }} ر.ي
                            </td>
                            <td>
                                @if($tx->status === 'pending')
                                    <span class="badge badge-warning" style="animation:pulse 2s infinite;">⏳ قيد المراجعة</span>
                                @elseif($tx->status === 'completed')
                                    <span class="badge badge-success">✅ معتمد</span>
                                @elseif($tx->status === 'rejected')
                                    <span class="badge badge-danger">❌ مرفوض</span>
                                @else
                                    <span class="badge badge-secondary">{{ $tx->status }}</span>
                                @endif
                            </td>
                            <td class="font-mono">
                                <div style="font-size:12px;font-weight:600;">{{ $tx->reference_id ?: '—' }}</div>
                                @if($tx->receipt_url)
                                    <a href="{{ $tx->receipt_url }}" target="_blank" class="badge badge-info" style="text-decoration:none;display:inline-flex;align-items:center;gap:4px;margin-top:4px;">
                                        📄 فتح صورة السند
                                    </a>
                                @endif
                                @if($tx->trip_id)
                                    <span class="badge badge-primary" style="margin-top:4px;display:inline-block;">رحلة #{{ $tx->trip_id }}</span>
                                @endif
                            </td>
                            <td class="text-muted" style="font-size:12px;white-space:nowrap;">
                                {{ $tx->created_at->format('Y-m-d H:i') }}
                            </td>
                            <td style="text-align:center;white-space:nowrap;">
                                @if($tx->status === 'pending' && $tx->type === 'deposit')
                                    <div style="display:inline-flex;gap:6px;">
                                        <button wire:click="openApproveModal({{ $tx->id }})" class="btn btn-success btn-sm" style="padding:4px 10px;font-size:12px;font-weight:700;">
                                            اعتماد ✅
                                        </button>
                                        <button wire:click="openRejectModal({{ $tx->id }})" class="btn btn-danger btn-sm" style="padding:4px 10px;font-size:12px;font-weight:700;">
                                            رفض ❌
                                        </button>
                                    </div>
                                @elseif($tx->status === 'completed')
                                    <span class="text-muted" style="font-size:11px;">
                                        {{ $tx->approver ? 'بواسطة: ' . $tx->approver->name : 'معتمد آلياً' }}
                                    </span>
                                @elseif($tx->status === 'rejected')
                                    <span class="text-danger" style="font-size:11px;" title="{{ $tx->admin_notes }}">
                                        {{ $tx->admin_notes ? Str::limit($tx->admin_notes, 20) : 'مرفوض' }}
                                    </span>
                                @else
                                    <span class="text-muted">—</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="text-center text-muted" style="padding:40px;">
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

    <!-- Approve Recharge Confirmation Modal -->
    @if($showApproveModal && $selectedTransaction)
    <div style="position:fixed;inset:0;background:rgba(0,0,0,0.65);z-index:9999;display:flex;align-items:center;justify-content:center;padding:16px;backdrop-filter:blur(4px);">
        <div class="card" style="width:100%;max-width:480px;box-shadow:0 25px 50px -12px rgba(0,0,0,0.5);border-radius:16px;">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;background:rgba(34,197,94,0.1);">
                <span class="card-title" style="color:var(--color-success);font-weight:800;display:flex;align-items:center;gap:8px;">
                    ✅ اعتماد شحن رصيد وإيداعه في المحفظة
                </span>
                <button wire:click="closeModals" style="background:none;border:none;cursor:pointer;font-size:22px;color:var(--color-text-muted);">&times;</button>
            </div>
            <div class="card-body" style="padding:20px;">
                <p style="font-size:14px;color:var(--color-text-muted);margin-bottom:16px;">
                    يرجى التحقق من مطابقة رقم السند مع حساب الشركة البنكي قبل التأكيد. سيتم إيداع المبلغ فوراً في محفظة المستخدم وإشعاره بالعملية:
                </p>

                <div style="background:var(--color-bg);padding:14px;border-radius:12px;margin-bottom:16px;font-size:13.5px;line-height:1.8;">
                    <div><strong>المستخدم:</strong> {{ $selectedTransaction->wallet->user->name ?? '—' }} ({{ $selectedTransaction->wallet->user->phone ?? '—' }})</div>
                    <div><strong>المبلغ المطلوب شحنه:</strong> <span style="font-weight:800;color:var(--color-success);font-size:16px;">{{ number_format($selectedTransaction->amount, 0) }} ر.ي</span></div>
                    <div><strong>قناة الدفع:</strong> {{ $selectedTransaction->payment_method ?: '—' }}</div>
                    <div><strong>رقم الحوالة / السند:</strong> <code style="font-weight:700;font-size:14px;">{{ $selectedTransaction->reference_id }}</code></div>
                    @if($selectedTransaction->sender_account)
                        <div><strong>الحساب المحول منه:</strong> {{ $selectedTransaction->sender_account }}</div>
                    @endif
                    @if($selectedTransaction->receipt_url)
                        <div style="margin-top:10px;">
                            <strong>صورة السند المرفقة:</strong><br>
                            <a href="{{ $selectedTransaction->receipt_url }}" target="_blank">
                                <img src="{{ $selectedTransaction->receipt_url }}" alt="السند" style="max-height:180px;border-radius:8px;border:1px solid #ddd;margin-top:6px;object-fit:contain;">
                            </a>
                        </div>
                    @endif
                </div>

                <div style="display:flex;justify-content:flex-end;gap:10px;">
                    <button type="button" wire:click="closeModals" class="btn btn-secondary btn-sm">إلغاء</button>
                    <button type="button" wire:click="confirmApprove" class="btn btn-success btn-sm" style="font-weight:800;padding:8px 16px;">
                        تأكيد الاعتماد وإيداع الرصيد
                    </button>
                </div>
            </div>
        </div>
    </div>
    @endif

    <!-- Reject Recharge Modal -->
    @if($showRejectModal && $selectedTransaction)
    <div style="position:fixed;inset:0;background:rgba(0,0,0,0.65);z-index:9999;display:flex;align-items:center;justify-content:center;padding:16px;backdrop-filter:blur(4px);">
        <div class="card" style="width:100%;max-width:480px;box-shadow:0 25px 50px -12px rgba(0,0,0,0.5);border-radius:16px;">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;background:rgba(239,68,68,0.1);">
                <span class="card-title" style="color:var(--color-danger);font-weight:800;display:flex;align-items:center;gap:8px;">
                    ❌ رفض طلب شحن الرصيد
                </span>
                <button wire:click="closeModals" style="background:none;border:none;cursor:pointer;font-size:22px;color:var(--color-text-muted);">&times;</button>
            </div>
            <div class="card-body" style="padding:20px;">
                <p style="font-size:13.5px;color:var(--color-text-muted);margin-bottom:14px;">
                    يرجى توضيح سبب الرفض (مثال: رقم الحوالة غير صحيح، المبلغ غير مطابق، لم يتم استلام الإشعار البنكي) لإشعار المستخدم به:
                </p>

                <div style="margin-bottom:16px;">
                    <label class="form-label">سبب الرفض <span style="color:var(--color-danger);">*</span></label>
                    <textarea wire:model="rejectionReason" class="form-control" rows="3" placeholder="اكتب سبب الرفض هنا..."></textarea>
                    @error('rejectionReason') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                </div>

                <div style="display:flex;justify-content:flex-end;gap:10px;">
                    <button type="button" wire:click="closeModals" class="btn btn-secondary btn-sm">إلغاء</button>
                    <button type="button" wire:click="confirmReject" class="btn btn-danger btn-sm" style="font-weight:800;padding:8px 16px;">
                        تأكيد الرفض
                    </button>
                </div>
            </div>
        </div>
    </div>
    @endif

    <!-- Manual Wallet Adjustment Modal -->
    @if($showAdjustModal)
    <div style="position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:9999;display:flex;align-items:center;justify-content:center;padding:16px;">
        <div class="card" style="width:100%;max-width:480px;box-shadow:0 20px 25px -5px rgba(0,0,0,0.3);">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;">
                <span class="card-title">تعديل رصيد محفظة / شحن يدوي مباشر</span>
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