<div>
    <!-- Page Header -->
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
        <div>
            <h2 class="page-title">إدارة المستندات</h2>
            <p class="page-subtitle">مراجعة وإدارة مستندات الكباتن (رخصة، هوية، تأمين...)</p>
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
        <div class="alert alert-danger" style="background:#FEE2E2;color:#991B1B;border:1px solid #F87171;padding:10px 16px;border-radius:8px;margin-bottom:16px;">
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
                <div class="form-group" style="max-width:180px;">
                    <select wire:model.live="statusFilter" class="form-control">
                        <option value="">كل الحالات</option>
                        <option value="pending">في الانتظار</option>
                        <option value="approved">مقبول</option>
                        <option value="rejected">مرفوض</option>
                    </select>
                </div>
                <div class="form-group" style="max-width:180px;">
                    <select wire:model.live="typeFilter" class="form-control">
                        <option value="">كل الأنواع</option>
                        <option value="id_card">بطاقة الهوية</option>
                        <option value="driving_license">رخصة القيادة</option>
                        <option value="bike_license">رخصة الدراجة / المركبة</option>
                        <option value="criminal_record">فيش وتشبيه</option>
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

    <!-- Documents Table -->
    <div class="card" wire:loading.class="opacity-50">
        <div class="card-header">
            <span class="card-title">📄 المستندات ({{ $documents->total() }})</span>
        </div>

        <div class="table-responsive">
            @if($documents->count())
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>الكابتن</th>
                        <th>نوع المستند</th>
                        <th>الحالة</th>
                        <th>سبب الرفض</th>
                        <th>تاريخ الرفع</th>
                        <th>إجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($documents as $document)
                    <tr>
                        <td style="color:var(--color-text-muted);font-size:12px;">{{ $document->id }}</td>

                        <td>
                            <div class="user-cell">
                                <div class="avatar-sm" style="background:linear-gradient(135deg,#3B82F6,#1D4ED8);">
                                    {{ mb_substr($document->captainProfile?->user?->name ?? '?', 0, 1) }}
                                </div>
                                <div>
                                    <div class="user-cell-name">{{ $document->captainProfile?->user?->name ?? 'غير معروف' }}</div>
                                    <div class="user-cell-sub">{{ $document->captainProfile?->user?->phone ?? '' }}</div>
                                </div>
                            </div>
                        </td>

                        <td>
                            @php
                                $docTypes = [
                                    'id_card' => 'بطاقة الهوية',
                                    'driving_license' => 'رخصة القيادة',
                                    'bike_license' => 'رخصة الدراجة',
                                    'criminal_record' => 'فيش وتشبيه',
                                    'license' => 'رخصة القيادة',
                                    'identity' => 'بطاقة الهوية',
                                ];
                            @endphp
                            <span style="font-size:13px;font-weight:600;">{{ $docTypes[$document->type] ?? $document->type }}</span>
                        </td>

                        <td>
                            @php
                                $docStatusMap = [
                                    'pending'  => ['label' => 'في الانتظار', 'class' => 'badge-warning'],
                                    'approved' => ['label' => 'مقبول',       'class' => 'badge-success'],
                                    'rejected' => ['label' => 'مرفوض',       'class' => 'badge-danger'],
                                ];
                                $ds = $docStatusMap[$document->status] ?? ['label' => $document->status, 'class' => 'badge-muted'];
                            @endphp
                            <span class="badge {{ $ds['class'] }}">{{ $ds['label'] }}</span>
                        </td>

                        <td style="max-width:200px;font-size:12px;color:var(--color-text-muted);">
                            {{ $document->rejection_reason ?? '—' }}
                        </td>

                        <td style="color:var(--color-text-muted);font-size:12px;white-space:nowrap;">
                            {{ $document->created_at->format('Y/m/d') }}
                        </td>

                        <td>
                            <div class="action-group">
                                @if($document->file_path)
                                    <a href="{{ asset('storage/' . $document->file_path) }}" target="_blank" class="btn btn-secondary btn-sm btn-icon" title="عرض الملف">
                                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                    </a>
                                @endif

                                @if($document->status === 'pending')
                                    <button
                                        wire:click="approve({{ $document->id }})"
                                        class="btn btn-success btn-sm btn-icon"
                                        title="قبول المستند وتوثيق الحساب"
                                    >
                                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                                    </button>
                                    <button
                                        wire:click="openRejectModal({{ $document->id }})"
                                        class="btn btn-danger btn-sm btn-icon"
                                        title="رفض المستند مع كتابة السبب"
                                    >
                                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                    </button>
                                @endif
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
            @else
                <div class="empty-state">
                    <div class="empty-state-icon">📂</div>
                    <div class="empty-state-title">لا توجد مستندات</div>
                    <div class="empty-state-desc">لم يتم العثور على مستندات مطابقة لبحثك</div>
                </div>
            @endif
        </div>

        @if($documents->hasPages())
        <div class="pagination-wrapper">
            <div class="pagination-info">
                عرض {{ $documents->firstItem() }} - {{ $documents->lastItem() }} من {{ $documents->total() }}
            </div>
            <div>
                {{ $documents->links() }}
            </div>
        </div>
        @endif
    </div>

    <!-- Rejection Modal -->
    @if($showRejectModal)
    <div style="position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:9999;display:flex;align-items:center;justify-content:center;padding:16px;">
        <div class="card" style="width:100%;max-width:480px;box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;">
                <span class="card-title">رفض المستند #{{ $selectedDocId }}</span>
                <button wire:click="closeModal" style="background:none;border:none;cursor:pointer;font-size:20px;">&times;</button>
            </div>
            <div class="card-body" style="padding:20px;">
                <p style="font-size:13px;color:var(--color-text-muted);margin-bottom:12px;">
                    يرجى كتابة سبب الرفض بوضوح ليتم إرساله كإشعار فوري للكابتن وإرشاده لإعادة رفع المستند الصحيح:
                </p>
                <div class="form-group" style="margin-bottom:16px;">
                    <textarea wire:model="rejectionReason" class="form-control" rows="4" placeholder="مثال: الصورة غير واضحة / تاريخ الانتهاء منتهي / الوثيقة غير مطابقة..."></textarea>
                </div>
                <div style="display:flex;justify-content:flex-end;gap:10px;">
                    <button wire:click="closeModal" class="btn btn-secondary btn-sm">إلغاء</button>
                    <button wire:click="confirmReject" class="btn btn-danger btn-sm">تأكيد الرفض والإشعار</button>
                </div>
            </div>
        </div>
    </div>
    @endif
</div>