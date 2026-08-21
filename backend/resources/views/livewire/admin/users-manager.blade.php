<div>
    <!-- Page Header -->
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
        <div>
            <h2 class="page-title">إدارة المستخدمين</h2>
            <p class="page-subtitle">عرض وإدارة جميع مستخدمي تطبيق لَفَّة</p>
        </div>
    </div>

    <!-- Session Messages -->
    @if (session('success'))
        <div class="alert alert-success">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            {{ session('success') }}
        </div>
    @endif

    <!-- Filters Card -->
    <div class="card" style="margin-bottom:20px;">
        <div class="card-body" style="padding:14px 20px;">
            <div class="filters-row">
                <div class="form-group" style="flex:2;max-width:360px;">
                    <div class="search-bar">
                        <span class="search-icon">
                            <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        </span>
                        <input type="text" wire:model.live.debounce.300ms="search" class="form-control" placeholder="بحث بالاسم أو الإيميل أو الهاتف...">
                    </div>
                </div>
                <div class="form-group" style="max-width:200px;">
                    <select wire:model.live="roleFilter" class="form-control">
                        <option value="">كل الأدوار</option>
                        <option value="passenger">راكب</option>
                        <option value="captain">كابتن</option>
                        <option value="admin">مدير</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <!-- Loading Indicator -->
    <div wire:loading.delay class="alert" style="background:var(--color-primary-50);color:var(--color-primary-dark);border:1px solid var(--color-primary-100);">
        <div class="spinner"></div>
        جاري التحميل...
    </div>

    <!-- Users Table -->
    <div class="card" wire:loading.class="opacity-50">
        <div class="card-header">
            <span class="card-title">👥 قائمة المستخدمين ({{ $users->total() }})</span>
        </div>

        <div class="table-responsive">
            @if($users->count())
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>المستخدم</th>
                        <th>الهاتف</th>
                        <th>الأدوار</th>
                        <th>الحالة</th>
                        <th>تاريخ التسجيل</th>
                        <th>إجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($users as $user)
                    <tr>
                        <td style="color:var(--color-text-muted);font-size:12px;">{{ $user->id }}</td>
                        <td>
                            <div class="user-cell">
                                <div class="avatar-sm">{{ mb_substr($user->name, 0, 1) }}</div>
                                <div>
                                    <div class="user-cell-name">{{ $user->name }}</div>
                                    <div class="user-cell-sub">{{ $user->email ?? '—' }}</div>
                                </div>
                            </div>
                        </td>
                        <td style="direction:ltr;text-align:right;font-size:13px;">{{ $user->phone ?? '—' }}</td>
                        <td>
                            @foreach($user->roles as $role)
                                @php
                                    $roleBadge = match($role->name) {
                                        'admin'     => 'badge-danger',
                                        'captain'   => 'badge-info',
                                        'passenger' => 'badge-success',
                                        default     => 'badge-muted',
                                    };
                                    $roleLabel = match($role->name) {
                                        'admin'     => 'مدير',
                                        'captain'   => 'كابتن',
                                        'passenger' => 'راكب',
                                        'user'      => 'مستخدم',
                                        default     => $role->name,
                                    };
                                @endphp
                                <span class="badge {{ $roleBadge }}">{{ $roleLabel }}</span>
                            @endforeach
                        </td>
                        <td>
                            <label class="toggle" title="{{ $user->is_active ? 'نشط' : 'معطل' }}">
                                <input type="checkbox" {{ $user->is_active ? 'checked' : '' }} wire:click="toggleActive({{ $user->id }})">
                                <span class="toggle-slider"></span>
                            </label>
                        </td>
                        <td style="color:var(--color-text-muted);font-size:12px;white-space:nowrap;">
                            {{ $user->created_at?->format('Y/m/d') }}
                        </td>
                        <td>
                            <div class="action-group">
                                <button
                                    wire:click="deleteUser({{ $user->id }})"
                                    wire:confirm="هل أنت متأكد من حذف هذا المستخدم؟"
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
                    <div class="empty-state-icon">👤</div>
                    <div class="empty-state-title">لا يوجد مستخدمون</div>
                    <div class="empty-state-desc">لم يتم العثور على نتائج مطابقة لبحثك</div>
                </div>
            @endif
        </div>

        <!-- Pagination -->
        @if($users->hasPages())
        <div class="pagination-wrapper">
            <div class="pagination-info">
                عرض {{ $users->firstItem() }} - {{ $users->lastItem() }} من {{ $users->total() }}
            </div>
            <div>
                {{ $users->links() }}
            </div>
        </div>
        @endif
    </div>
</div>
