<div>
    <!-- Page Header -->
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
        <div>
            <h2 class="page-title">إدارة الكباتن</h2>
            <p class="page-subtitle">عرض وإدارة جميع الكباتن المسجلين في التطبيق</p>
        </div>
    </div>

    <!-- Session Messages -->
    @if (session('success'))
        <div class="alert alert-success">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            {{ session('success') }}
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
                        <input type="text" wire:model.live.debounce.300ms="search" class="form-control" placeholder="بحث بالاسم...">
                    </div>
                </div>
                <div class="form-group" style="max-width:200px;">
                    <select wire:model.live="statusFilter" class="form-control">
                        <option value="">كل الحالات</option>
                        <option value="verified">موثق</option>
                        <option value="unverified">غير موثق</option>
                        <option value="online">متصل الآن</option>
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

    <!-- Captains Table -->
    <div class="card" wire:loading.class="opacity-50">
        <div class="card-header">
            <span class="card-title">🏍️ قائمة الكباتن ({{ $captains->total() }})</span>
        </div>

        <div class="table-responsive">
            @if($captains->count())
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>الكابتن</th>
                        <th>نوع الدراجة</th>
                        <th>موديل الدراجة</th>
                        <th>رقم اللوحة</th>
                        <th>لون الدراجة</th>
                        <th>التقييم</th>
                        <th>الحالة</th>
                        <th>التوثيق</th>
                        <th>إجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($captains as $captain)
                    <tr>
                        <td style="color:var(--color-text-muted);font-size:12px;">{{ $captain->id }}</td>
                        <td>
                            <div class="user-cell">
                                <div class="avatar-sm" style="background:linear-gradient(135deg,#3B82F6,#1D4ED8);">
                                    {{ mb_substr($captain->user?->name ?? '?', 0, 1) }}
                                </div>
                                <div>
                                    <div class="user-cell-name">{{ $captain->user?->name ?? 'غير معروف' }}</div>
                                    <div class="user-cell-sub">{{ $captain->user?->phone ?? '—' }}</div>
                                </div>
                            </div>
                        </td>
                        <td>{{ $captain->vehicle_type ?? '—' }}</td>
                        <td>{{ $captain->vehicle_model ?? '—' }}</td>
                        <td>
                            <span style="background:var(--color-surface);padding:3px 8px;border-radius:4px;font-size:12px;font-weight:600;direction:ltr;display:inline-block;">
                                {{ $captain->plate_number ?? '—' }}
                            </span>
                        </td>
                        <td>{{ $captain->vehicle_color ?? '—' }}</td>
                        <td>
                            @if($captain->rating)
                                <span style="color:var(--color-warning);font-weight:700;">★</span>
                                <span style="font-weight:600;font-size:13px;">{{ number_format($captain->rating, 1) }}</span>
                            @else
                                <span style="color:var(--color-text-muted);">—</span>
                            @endif
                        </td>
                        <td>
                            @if($captain->is_online)
                                <span class="badge badge-success">متصل</span>
                            @else
                                <span class="badge badge-muted">غير متصل</span>
                            @endif
                        </td>
                        <td>
                            <label class="toggle" title="{{ $captain->is_verified ? 'موثق' : 'غير موثق' }}">
                                <input type="checkbox" {{ $captain->is_verified ? 'checked' : '' }} wire:click="toggleVerified({{ $captain->id }})">
                                <span class="toggle-slider"></span>
                            </label>
                        </td>
                        <td>
                            <div class="action-group">
                                <a href="{{ route('admin.captains.show', $captain->id) }}" class="btn btn-secondary btn-sm btn-icon" title="عرض الملف">
                                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                </a>
                                <button
                                    wire:click="deleteCaptain({{ $captain->id }})"
                                    wire:confirm="هل أنت متأكد من حذف هذا الكابتن؟"
                                    class="btn btn-danger btn-sm btn-icon"
                                    title="حذف"
                                >
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
                    <div class="empty-state-icon">🚗</div>
                    <div class="empty-state-title">لا يوجد كباتن</div>
                    <div class="empty-state-desc">لم يتم العثور على نتائج مطابقة لبحثك</div>
                </div>
            @endif
        </div>

        @if($captains->hasPages())
        <div class="pagination-wrapper">
            <div class="pagination-info">
                عرض {{ $captains->firstItem() }} - {{ $captains->lastItem() }} من {{ $captains->total() }}
            </div>
            <div>
                {{ $captains->links() }}
            </div>
        </div>
        @endif
    </div>
</div>
