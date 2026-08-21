<div>
    <!-- Page Header -->
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
        <div>
            <h2 class="page-title">طلبات سحب الأرباح</h2>
            <p class="page-subtitle">مراجعة ومعالجة طلبات السحب المقدمة من الكباتن</p>
        </div>
    </div>

    <!-- Session Messages -->
    @if (session('success'))
        <div class="alert alert-success">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            {{ session('success') }}
        </div>
    @endif
    @if (session('error'))
        <div class="alert alert-danger">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            {{ session('error') }}
        </div>
    @endif

    <!-- Filters -->
    <div class="card" style="margin-bottom:20px;">
        <div class="card-body" style="padding:14px 20px;">
            <div class="filters-row">
                <div class="form-group" style="flex:2;max-width:360px;">
                    <div class="search-bar">
                        <span class="search-icon">
                            <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        </span>
                        <input type="text" wire:model.live.debounce.300ms="search" class="form-control" placeholder="بحث باسم الكابتن...">
                    </div>
                </div>
                <div class="form-group" style="max-width:200px;">
                    <select wire:model.live="statusFilter" class="form-control">
                        <option value="">كل الحالات</option>
                        <option value="pending">في الانتظار (جديدة)</option>
                        <option value="approved">مقبولة (قيد التحويل)</option>
                        <option value="completed">مكتملة (تم التحويل)</option>
                        <option value="rejected">مرفوضة</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <!-- Loading -->
    <div wire:loading.delay class="alert" style="background:var(--color-primary-50);color:var(--color-primary-dark);border:1px solid var(--color-primary-100);">
        <div class="spinner"></div>
        جاري التحميل...
    </div>

    <!-- Withdrawals Table -->
    <div class="card" wire:loading.class="opacity-50">
        <div class="card-header">
            <span class="card-title">💸 طلبات السحب ({{ $withdrawals->total() }})</span>
        </div>

        <div class="table-responsive">
            @if($withdrawals->count())
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>الكابتن</th>
                        <th>المبلغ</th>
                        <th>وجهة التحويل</th>
                        <th>رقم الحساب / المحفظة</th>
                        <th>اسم المستفيد</th>
                        <th>الحالة</th>
                        <th>مرجع / سبب</th>
                        <th>تاريخ الطلب</th>
                        <th>إجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($withdrawals as $request)
                    <tr>
                        <td style="color:var(--color-text-muted);font-size:12px;">#{{ $request->id }}</td>

                        <td>
                            <div class="user-cell">
                                <div class="avatar-sm" style="background:linear-gradient(135deg,#3B82F6,#1D4ED8);">
                                    {{ mb_substr($request->captainProfile?->user?->name ?? '?', 0, 1) }}
                                </div>
                                <div>
                                    <div class="user-cell-name">{{ $request->captainProfile?->user?->name ?? 'غير محدد' }}</div>
                                    <div class="user-cell-sub">{{ $request->captainProfile?->user?->phone ?? '' }}</div>
                                </div>
                            </div>
                        </td>

                        <td>
                            <span style="font-weight:700;color:var(--color-danger);font-size:14px;">
                                {{ number_format($request->amount, 0) }} ر.ي
                            </span>
                        </td>

                        <td>
                            @php
                                $channels = [
                                    'onecash'  => 'ون كاش',
                                    'kuraimi'  => 'الكريمي',
                                    'jawali'   => 'جوالي',
                                    'jeeb'     => 'جيب',
                                    'tadhamon' => 'التضامن',
                                    'cac'      => 'كاك بنك',
                                    'floosak'  => 'فلوسك',
                                    'cash'     => 'نقداً',
                                ];
                                $methodName = $channels[$request->payment_method] ?? ($request->payment_method ?? 'محفظة إلكترونية');
                            @endphp
                            <span class="badge badge-info" style="font-size:12px;">{{ $methodName }}</span>
                        </td>

                        <td style="direction:ltr;text-align:right;font-weight:600;font-size:13px;">
                            {{ $request->account_number ?? '—' }}
                        </td>

                        <td style="font-size:13px;">
                            {{ $request->account_name ?? '—' }}
                        </td>

                        <td>
                            @php
                                $statusMap = [
                                    'pending'   => ['label' => 'قيد الانتظار', 'class' => 'badge-warning'],
                                    'approved'  => ['label' => 'قيد التحويل', 'class' => 'badge-info'],
                                    'completed' => ['label' => 'مكتملة',       'class' => 'badge-success'],
                                    'rejected'  => ['label' => 'مرفوضة',       'class' => 'badge-danger'],
                                ];
                                $s = $statusMap[$request->status] ?? ['label' => $request->status, 'class' => 'badge-muted'];
                            @endphp
                            <span class="badge {{ $s['class'] }}">{{ $s['label'] }}</span>
                        </td>

                        <td style="max-width:160px;font-size:12px;color:var(--color-text-muted);">
                            @if($request->status === 'completed' && $request->transfer_reference)
                                <span style="color:var(--color-success);font-weight:600;">رقم الحوالة: {{ $request->transfer_reference }}</span>
                            @elseif($request->status === 'rejected' && $request->rejection_reason)
                                <span style="color:var(--color-danger);">السبب: {{ $request->rejection_reason }}</span>
                            @else
                                —
                            @endif
                        </td>

                        <td style="color:var(--color-text-muted);font-size:12px;white-space:nowrap;">
                            {{ $request->created_at->format('Y/m/d') }}<br>
                            <span style="font-size:11px;">{{ $request->created_at->format('h:i A') }}</span>
                        </td>

                        <td>
                            <div class="action-group">
                                @if($request->status === 'pending')
                                    <button wire:click="openCompleteModal({{ $request->id }})" class="btn btn-success btn-sm" title="تأكيد التحويل وإكمال الطلب">
                                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:2px;"><polyline points="20 6 9 17 4 12"/></svg>
                                        إكمال
                                    </button>
                                    <button wire:click="openRejectModal({{ $request->id }})" class="btn btn-danger btn-sm" title="رفض الطلب واستعادة الرصيد للمحفظة">
                                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:2px;"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                        رفض
                                    </button>
                                @else
                                    <span style="color:var(--color-text-muted);font-size:12px;">تمت المعالجة</span>
                                @endif
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
            @else
                <div class="empty-state">
                    <div class="empty-state-icon">💸</div>
                    <div class="empty-state-title">لا توجد طلبات سحب</div>
                    <div class="empty-state-desc">لم يتم العثور على طلبات مطابقة للبحث</div>
                </div>
            @endif
        </div>

        @if($withdrawals->hasPages())
        <div class="pagination-wrapper">
            <div class="pagination-info">
                عرض {{ $withdrawals->firstItem() }} - {{ $withdrawals->lastItem() }} من {{ $withdrawals->total() }}
            </div>
            <div>
                {{ $withdrawals->links() }}
            </div>
        </div>
        @endif
    </div>

    <!-- Complete Transfer Modal -->
    @if($showCompleteModal)
    <div style="position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:9999;display:flex;align-items:center;justify-content:center;padding:16px;">
        <div class="card" style="width:100%;max-width:480px;box-shadow:0 20px 25px -5px rgba(0,0,0,0.3);">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;">
                <span class="card-title">تأكيد تحويل مبلغ السحب #{{ $selectedRequestId }}</span>
                <button wire:click="closeModals" style="background:none;border:none;cursor:pointer;font-size:20px;color:var(--color-text-muted);">&times;</button>
            </div>
            <div class="card-body" style="padding:20px;">
                <p style="font-size:13px;color:var(--color-text-secondary);margin-bottom:14px;">
                    يرجى إدخال رقم الحوالة أو الرقم المرجعي للعملية بعد تحويل المبلغ للكابتن:
                </p>
                <div class="form-group" style="margin-bottom:16px;">
                    <label class="form-label">رقم الحوالة / العملية (اختياري)</label>
                    <input type="text" wire:model="transferReference" class="form-control" placeholder="مثال: 987654321 أو TXN-1029">
                </div>
                <div style="display:flex;justify-content:flex-end;gap:10px;">
                    <button wire:click="closeModals" class="btn btn-secondary btn-sm">إلغاء</button>
                    <button wire:click="confirmComplete" class="btn btn-success btn-sm">تأكيد التحويل وإغلاق الطلب</button>
                </div>
            </div>
        </div>
    </div>
    @endif

    <!-- Rejection Modal -->
    @if($showRejectModal)
    <div style="position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:9999;display:flex;align-items:center;justify-content:center;padding:16px;">
        <div class="card" style="width:100%;max-width:480px;box-shadow:0 20px 25px -5px rgba(0,0,0,0.3);">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;">
                <span class="card-title">رفض طلب السحب #{{ $selectedRequestId }}</span>
                <button wire:click="closeModals" style="background:none;border:none;cursor:pointer;font-size:20px;color:var(--color-text-muted);">&times;</button>
            </div>
            <div class="card-body" style="padding:20px;">
                <p style="font-size:13px;color:var(--color-text-secondary);margin-bottom:14px;">
                    عند رفض الطلب، <strong>سيتم إعادة المبلغ تلقائياً وفورياً إلى محفظة الكابتن</strong> وإشعاره بالسبب:
                </p>
                <div class="form-group" style="margin-bottom:16px;">
                    <label class="form-label">سبب الرفض <span style="color:var(--color-danger);">*</span></label>
                    <textarea wire:model="rejectionReason" class="form-control" rows="3" placeholder="مثال: رقم الحساب المدخل غير صحيح / الاسم غير مطابق..."></textarea>
                </div>
                <div style="display:flex;justify-content:flex-end;gap:10px;">
                    <button wire:click="closeModals" class="btn btn-secondary btn-sm">إلغاء</button>
                    <button wire:click="confirmReject" class="btn btn-danger btn-sm">تأكيد الرفض وإعادة الرصيد</button>
                </div>
            </div>
        </div>
    </div>
    @endif
</div>
