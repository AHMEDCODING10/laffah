<div wire:poll.10s>
    <!-- Page Header -->
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
        <div>
            <h2 class="page-title">إدارة الرحلات</h2>
            <p class="page-subtitle">متابعة وإدارة جميع الرحلات في التطبيق</p>
        </div>
    </div>

    <!-- Filters -->
    <div class="card" style="margin-bottom:20px;">
        <div class="card-body" style="padding:14px 20px;">
            <div class="filters-row">
                <div class="form-group" style="flex:2;max-width:360px;">
                    <div class="search-bar">
                        <span class="search-icon">
                            <svg width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        </span>
                        <input type="text" wire:model.live.debounce.300ms="search" class="form-control" placeholder="بحث بعنوان الانطلاق أو الوصول...">
                    </div>
                </div>
                <div class="form-group" style="max-width:200px;">
                    <select wire:model.live="statusFilter" class="form-control">
                        <option value="">كل الحالات</option>
                        <option value="pending">في الانتظار</option>
                        <option value="accepted">مقبولة</option>
                        <option value="arrived">وصل الكابتن</option>
                        <option value="in_transit">في الطريق (جارية)</option>
                        <option value="completed">مكتملة</option>
                        <option value="cancelled">ملغاة</option>
                    </select>
                </div>
                <div class="form-group" style="max-width:200px;">
                    <input type="date" wire:model.live="dateFilter" class="form-control">
                </div>
                <div class="form-group" style="max-width:150px;">
                    <button wire:click="exportCsv" class="btn btn-secondary" style="width:100%;height:38px;padding:0;">
                        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:4px;display:inline-block;vertical-align:middle;"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
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

    <!-- Trips Table -->
    <div class="card" wire:loading.class="opacity-50">
        <div class="card-header">
            <span class="card-title">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="display:inline;vertical-align:middle;margin-left:4px;">
                    <path d="M3 12h18M3 6h18M3 18h18"/>
                </svg>
                سجل الرحلات ({{ $trips->total() }})
            </span>
        </div>

        <div class="table-responsive">
            @if($trips->count())
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>الراكب</th>
                        <th>الكابتن</th>
                        <th>نقطة الانطلاق</th>
                        <th>الوجهة</th>
                        <th>المسافة</th>
                        <th>السعر النهائي</th>
                        <th>النوع</th>
                        <th>الحالة</th>
                        <th>التاريخ</th>
                        <th>إجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($trips as $trip)
                    <tr>
                        <td style="color:var(--color-text-muted);font-size:12px;">#{{ $trip->id }}</td>

                        <!-- Passenger -->
                        <td>
                            <div class="user-cell">
                                <div class="avatar-sm">{{ mb_substr($trip->passenger?->name ?? '?', 0, 1) }}</div>
                                <div>
                                    <div class="user-cell-name">{{ $trip->passenger?->name ?? 'غير محدد' }}</div>
                                    <div class="user-cell-sub">{{ $trip->passenger?->phone ?? '' }}</div>
                                </div>
                            </div>
                        </td>

                        <!-- Captain -->
                        <td>
                            @if($trip->captain?->user)
                            <div class="user-cell">
                                <div class="avatar-sm" style="background:linear-gradient(135deg,#3B82F6,#1D4ED8);">
                                    {{ mb_substr($trip->captain->user->name, 0, 1) }}
                                </div>
                                <div>
                                    <div class="user-cell-name">{{ $trip->captain->user->name }}</div>
                                    <div class="user-cell-sub">{{ $trip->captain->user->phone ?? '' }}</div>
                                </div>
                            </div>
                            @else
                                <span style="color:var(--color-text-muted);font-size:12px;">لم يُحدد بعد</span>
                            @endif
                        </td>

                        <!-- Addresses -->
                        <td style="max-width:140px;">
                            <div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:12px;" title="{{ $trip->pickup_address }}">
                                📍 {{ $trip->pickup_address ?? '—' }}
                            </div>
                        </td>
                        <td style="max-width:140px;">
                            <div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:12px;" title="{{ $trip->dropoff_address }}">
                                🏁 {{ $trip->dropoff_address ?? '—' }}
                            </div>
                        </td>

                        <!-- Distance -->
                        <td>
                            @if($trip->distance_km)
                                <span style="font-weight:600;font-size:13px;">{{ number_format($trip->distance_km, 1) }} كم</span>
                            @else
                                <span style="color:var(--color-text-muted);">—</span>
                            @endif
                        </td>

                        <!-- Price -->
                        <td>
                            @if($trip->final_price)
                                <span style="font-weight:700;color:var(--color-success);">{{ number_format($trip->final_price, 0) }} ر.ي</span>
                            @elseif($trip->estimated_price)
                                <span style="color:var(--color-text-secondary);font-size:13px;">{{ number_format($trip->estimated_price, 0) }} ر.ي</span>
                            @else
                                <span style="color:var(--color-text-muted);">—</span>
                            @endif
                        </td>

                        <!-- Type -->
                        <td>
                            @if($trip->is_multi_stop)
                                <span class="badge badge-info">متعددة التوقفات</span>
                            @else
                                <span class="badge badge-muted">عادية</span>
                            @endif
                        </td>

                        <!-- Status -->
                        <td>
                            @php
                                $statusMap = [
                                    'pending'    => ['label' => 'انتظار',      'class' => 'badge-warning'],
                                    'accepted'   => ['label' => 'مقبولة',      'class' => 'badge-info'],
                                    'arrived'    => ['label' => 'وصل الكابتن', 'class' => 'badge-info'],
                                    'started'    => ['label' => 'في الطريق',   'class' => 'badge-info'],
                                    'in_transit' => ['label' => 'في الطريق',   'class' => 'badge-info'],
                                    'completed'  => ['label' => 'مكتملة',      'class' => 'badge-success'],
                                    'cancelled'  => ['label' => 'ملغاة',       'class' => 'badge-danger'],
                                ];
                                $s = $statusMap[$trip->status] ?? ['label' => $trip->status, 'class' => 'badge-muted'];
                            @endphp
                            <span class="badge {{ $s['class'] }}">{{ $s['label'] }}</span>
                        </td>

                        <!-- Date -->
                        <td style="color:var(--color-text-muted);font-size:12px;white-space:nowrap;">
                            {{ $trip->created_at->format('Y/m/d') }}<br>
                            <span style="font-size:11px;">{{ $trip->created_at->format('h:i A') }}</span>
                        </td>

                        <!-- Actions -->
                        <td>
                            <button wire:click="openTripModal({{ $trip->id }})" class="btn btn-secondary btn-sm btn-icon" title="عرض تفاصيل الرحلة كاملة">
                                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
            @else
                <div class="empty-state">
                    <div class="empty-state-icon">🗺️</div>
                    <div class="empty-state-title">لا توجد رحلات</div>
                    <div class="empty-state-desc">لم يتم العثور على رحلات مطابقة لبحثك</div>
                </div>
            @endif
        </div>

        @if($trips->hasPages())
        <div class="pagination-wrapper">
            <div class="pagination-info">
                عرض {{ $trips->firstItem() }} - {{ $trips->lastItem() }} من {{ $trips->total() }}
            </div>
            <div>
                {{ $trips->links() }}
            </div>
        </div>
        @endif
    </div>

    <!-- Trip Details Modal -->
    @if($showTripModal && $selectedTrip)
    <div style="position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:9999;display:flex;align-items:center;justify-content:center;padding:16px;">
        <div class="card" style="width:100%;max-width:640px;max-height:90vh;overflow-y:auto;box-shadow:0 20px 25px -5px rgba(0,0,0,0.3);">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;position:sticky;top:0;background:var(--color-surface);z-index:10;">
                <span class="card-title">تفاصيل الرحلة #{{ $selectedTrip->id }}</span>
                <button wire:click="closeTripModal" style="background:none;border:none;cursor:pointer;font-size:22px;color:var(--color-text-muted);">&times;</button>
            </div>
            <div class="card-body" style="padding:20px;">
                <!-- Parties -->
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:20px;padding:14px;background:var(--color-bg);border-radius:var(--radius-md);border:1px solid var(--color-border);">
                    <div>
                        <div style="font-size:11px;color:var(--color-text-muted);margin-bottom:4px;font-weight:600;">الراكب</div>
                        <div style="font-weight:700;font-size:14px;">{{ $selectedTrip->passenger?->name ?? 'غير محدد' }}</div>
                        <div style="font-size:12px;color:var(--color-text-secondary);direction:ltr;text-align:right;">{{ $selectedTrip->passenger?->phone ?? '—' }}</div>
                    </div>
                    <div>
                        <div style="font-size:11px;color:var(--color-text-muted);margin-bottom:4px;font-weight:600;">الكابتن</div>
                        <div style="font-weight:700;font-size:14px;">{{ $selectedTrip->captain?->user?->name ?? 'لم يُحدد كابتن بعد' }}</div>
                        <div style="font-size:12px;color:var(--color-text-secondary);direction:ltr;text-align:right;">{{ $selectedTrip->captain?->user?->phone ?? '—' }}</div>
                    </div>
                </div>

                <!-- Locations -->
                <div style="margin-bottom:20px;">
                    <div style="margin-bottom:10px;">
                        <span style="font-size:12px;font-weight:700;color:var(--color-primary);">📍 نقطة الانطلاق:</span>
                        <div style="font-size:13px;margin-top:2px;">{{ $selectedTrip->pickup_address ?? '—' }}</div>
                    </div>
                    @if($selectedTrip->stops && $selectedTrip->stops->count())
                        <div style="margin-bottom:10px;padding-right:12px;border-right:2px dashed var(--color-primary);">
                            <span style="font-size:11px;font-weight:600;color:var(--color-text-muted);">نقاط التوقف الإضافية:</span>
                            @foreach($selectedTrip->stops as $stop)
                                <div style="font-size:12px;margin-top:2px;">🚩 {{ $stop->stop_address }}</div>
                            @endforeach
                        </div>
                    @endif
                    <div>
                        <span style="font-size:12px;font-weight:700;color:var(--color-success);">🏁 الوجهة النهائية:</span>
                        <div style="font-size:13px;margin-top:2px;">{{ $selectedTrip->dropoff_address ?? '—' }}</div>
                    </div>
                </div>

                <!-- Pricing Breakdown -->
                <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:10px;margin-bottom:20px;padding:14px;background:var(--color-bg);border-radius:var(--radius-md);border:1px solid var(--color-border);text-align:center;">
                    <div>
                        <div style="font-size:11px;color:var(--color-text-muted);">المسافة</div>
                        <div style="font-weight:700;font-size:14px;">{{ number_format($selectedTrip->distance_km ?? 0, 1) }} كم</div>
                    </div>
                    <div>
                        <div style="font-size:11px;color:var(--color-text-muted);">السعر الإجمالي</div>
                        <div style="font-weight:700;font-size:14px;color:var(--color-success);">{{ number_format($selectedTrip->final_price ?? $selectedTrip->estimated_price ?? 0, 0) }} ر.ي</div>
                    </div>
                    <div>
                        <div style="font-size:11px;color:var(--color-text-muted);">عمولة المنصة</div>
                        <div style="font-weight:700;font-size:14px;color:var(--color-primary);">{{ number_format($selectedTrip->commission_amount ?? 0, 0) }} ر.ي</div>
                    </div>
                    <div>
                        <div style="font-size:11px;color:var(--color-text-muted);">أرباح الكابتن</div>
                        <div style="font-weight:700;font-size:14px;color:#10B981;">{{ number_format($selectedTrip->captain_earnings ?? 0, 0) }} ر.ي</div>
                    </div>
                </div>

                <!-- Rating & Cancellation info -->
                @if($selectedTrip->rating_by_user)
                    <div style="margin-bottom:12px;padding:10px 14px;background:rgba(250,204,21,0.1);border-radius:var(--radius-sm);border:1px solid rgba(250,204,21,0.2);">
                        <span style="font-size:12px;font-weight:700;color:var(--color-warning);">⭐ تقييم الراكب للكابتن: {{ $selectedTrip->rating_by_user }}/5</span>
                        @if($selectedTrip->review_by_user)
                            <div style="font-size:12px;margin-top:4px;">"{{ $selectedTrip->review_by_user }}"</div>
                        @endif
                    </div>
                @endif

                @if($selectedTrip->status === 'cancelled')
                    <div style="margin-bottom:12px;padding:10px 14px;background:var(--color-danger-bg);border-radius:var(--radius-sm);border:1px solid rgba(239,68,68,0.2);color:var(--color-danger-text);">
                        <span style="font-size:12px;font-weight:700;">⚠️ تم إلغاء الرحلة</span>
                        <div style="font-size:12px;margin-top:2px;">الجهة الملغية: {{ $selectedTrip->cancelled_by === 'captain' ? 'الكابتن' : 'الراكب' }}</div>
                        @if($selectedTrip->cancellation_reason)
                            <div style="font-size:12px;margin-top:2px;">السبب: {{ $selectedTrip->cancellation_reason }}</div>
                        @endif
                    </div>
                @endif

                <div style="display:flex;justify-content:flex-end;margin-top:16px;">
                    <button wire:click="closeTripModal" class="btn btn-secondary btn-sm">إغلاق النافذة</button>
                </div>
            </div>
        </div>
    </div>
    @endif
</div>
