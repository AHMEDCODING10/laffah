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
                                    'vehicle_registration' => 'كرت ملكية / رخصة الدراجة',
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
                                <button
                                    wire:click="openViewModal({{ $document->id }})"
                                    class="btn btn-secondary btn-sm btn-icon"
                                    title="معاينة الوثيقة في نفس الصفحة"
                                >
                                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                </button>

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

    <!-- In-Page Document Preview Modal -->
    @if($showViewModal && $viewingDoc)
    <div class="modal-backdrop" wire:click.self="closeViewModal">
        <div class="modal-content" style="max-width:720px;">
            <div class="modal-header">
                <span class="modal-title">
                    <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
                    </svg>
                    معاينة الوثيقة: {{ $docTypes[$viewingDoc->type] ?? $viewingDoc->type }} #{{ $viewingDoc->id }}
                </span>
                <button wire:click="closeViewModal" class="modal-close">&times;</button>
            </div>
            <div class="modal-body" style="padding:18px;">
                <!-- Captain details header -->
                <div style="display:flex;justify-content:space-between;align-items:center;padding:12px 16px;background:var(--color-bg);border:1px solid var(--color-border);border-radius:var(--radius-md);margin-bottom:16px;flex-wrap:wrap;gap:10px;">
                    <div class="user-cell">
                        <div class="avatar-sm" style="background:linear-gradient(135deg,#3B82F6,#1D4ED8);">
                            {{ mb_substr($viewingDoc->captainProfile?->user?->name ?? '?', 0, 1) }}
                        </div>
                        <div>
                            <div class="user-cell-name" style="font-size:14px;font-weight:700;">{{ $viewingDoc->captainProfile?->user?->name ?? 'غير معروف' }}</div>
                            <div class="user-cell-sub">{{ $viewingDoc->captainProfile?->user?->phone ?? '—' }} | {{ $viewingDoc->captainProfile?->vehicle_model ?? 'دراجة نارية' }} ({{ $viewingDoc->captainProfile?->plate_number ?? '—' }})</div>
                        </div>
                    </div>
                    <div style="display:flex;align-items:center;gap:8px;">
                        @if($viewingDoc->captainProfile?->is_verified)
                            <button wire:click="toggleCaptainVerification({{ $viewingDoc->captain_profile_id }})" class="btn btn-secondary btn-sm" style="color:var(--color-danger);font-size:12px;" title="إلغاء توثيق حساب الكابتن">
                                ⚠️ حساب موثق (إلغاء)
                            </button>
                        @else
                            <button wire:click="toggleCaptainVerification({{ $viewingDoc->captain_profile_id }})" class="btn btn-success btn-sm" style="font-size:12px;" title="توثيق حساب الكابتن مباشرة">
                                ✅ توثيق الكابتن الآن
                            </button>
                        @endif

                        @php
                            $ds = $docStatusMap[$viewingDoc->status] ?? ['label' => $viewingDoc->status, 'class' => 'badge-muted'];
                        @endphp
                        <span class="badge {{ $ds['class'] }}" style="font-size:13px;padding:6px 12px;">{{ $ds['label'] }}</span>
                    </div>
                </div>

                <!-- Document Image / Visual Container -->
                <div style="background:#0B0E14;border-radius:var(--radius-md);border:1px solid var(--color-border);overflow:hidden;display:flex;align-items:center;justify-content:center;min-height:300px;max-height:480px;position:relative;">
                    <img src="{{ route('admin.documents.file', $viewingDoc->id) }}" 
                         alt="{{ $docTypes[$viewingDoc->type] ?? $viewingDoc->type }}" 
                         style="max-width:100%;max-height:460px;object-fit:contain;border-radius:var(--radius-md);" />
                </div>

                @if($viewingDoc->status === 'rejected' && $viewingDoc->rejection_reason)
                    <div style="margin-top:14px;padding:12px;background:var(--color-danger-bg);color:var(--color-danger-text);border-radius:var(--radius-sm);font-size:13px;border:1px solid rgba(239,68,68,0.2);">
                        <strong>سبب الرفض:</strong> {{ $viewingDoc->rejection_reason }}
                    </div>
                @endif
            </div>
            <div class="modal-footer">
                <a href="{{ route('admin.documents.file', $viewingDoc->id) }}" target="_blank" class="btn btn-secondary btn-sm" title="فتح الصورة بحجمها الكامل في تبويب منفصل">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:4px;"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                    فتح بحجم كامل
                </a>
                @if($viewingDoc->status === 'pending')
                    <button wire:click="approve({{ $viewingDoc->id }})" class="btn btn-success btn-sm">
                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:4px;"><polyline points="20 6 9 17 4 12"/></svg>
                        قبول وتوثيق
                    </button>
                    <button wire:click="openRejectModal({{ $viewingDoc->id }})" class="btn btn-danger btn-sm">
                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:4px;"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                        رفض مع السبب
                    </button>
                @endif
                <button wire:click="closeViewModal" class="btn btn-secondary btn-sm">إغلاق</button>
            </div>
        </div>
    </div>
    @endif

    <!-- Rejection Modal -->
    @if($showRejectModal)
    <div class="modal-backdrop" wire:click.self="closeModal">
        <div class="modal-content" style="max-width:480px;">
            <div class="modal-header">
                <span class="modal-title">رفض المستند #{{ $selectedDocId }}</span>
                <button wire:click="closeModal" class="modal-close">&times;</button>
            </div>
            <div class="modal-body" style="padding:20px;">
                <p style="font-size:13px;color:var(--color-text-secondary);margin-bottom:12px;">
                    يرجى كتابة سبب الرفض بوضوح ليتم إرساله كإشعار فوري للكابتن وإرشاده لإعادة رفع المستند الصحيح:
                </p>
                <div class="form-group" style="margin-bottom:16px;">
                    <textarea wire:model="rejectionReason" class="form-control" rows="4" placeholder="مثال: الصورة غير واضحة / تاريخ الانتهاء منتهي / الوثيقة غير مطابقة..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button wire:click="closeModal" class="btn btn-secondary btn-sm">إلغاء</button>
                <button wire:click="confirmReject" class="btn btn-danger btn-sm">تأكيد الرفض والإشعار</button>
            </div>
        </div>
    </div>
    @endif
</div>