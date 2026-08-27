<x-admin-layout title="الرئيسية">

    <!-- Page Header -->
    <div class="page-header">
        <h2 class="page-title">مرحباً، {{ auth()->user()->name }}</h2>
        <p class="page-subtitle">إليك نظرة عامة على نشاط تطبيق لَفَّة اليوم</p>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid">

        <div class="stat-card" style="--stat-color:#FF9800; --stat-bg:rgba(255,152,0,0.1);">
            <div class="stat-icon">
                <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                </svg>
            </div>
            <div class="stat-info">
                <div class="stat-value">{{ number_format($stats['total_users']) }}</div>
                <div class="stat-label">إجمالي الركاب</div>
            </div>
        </div>

        <div class="stat-card" style="--stat-color:#3B82F6; --stat-bg:rgba(59,130,246,0.1);">
            <div class="stat-icon">
                <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"/>
                    <path d="M12 8v4l3 3"/>
                </svg>
            </div>
            <div class="stat-info">
                <div class="stat-value">{{ number_format($stats['total_captains']) }}</div>
                <div class="stat-label">إجمالي الكباتن</div>
            </div>
        </div>

        <div class="stat-card" style="--stat-color:#22C55E; --stat-bg:rgba(34,197,94,0.1);">
            <div class="stat-icon">
                <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                    <polyline points="22 4 12 14.01 9 11.01"/>
                </svg>
            </div>
            <div class="stat-info">
                <div class="stat-value">{{ number_format($stats['completed_trips']) }}</div>
                <div class="stat-label">الرحلات المكتملة</div>
            </div>
        </div>

        <div class="stat-card" style="--stat-color:#FACC15; --stat-bg:rgba(250,204,21,0.1);">
            <div class="stat-icon">
                <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/>
                    <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>
                </svg>
            </div>
            <div class="stat-info">
                <div class="stat-value">{{ number_format($stats['active_trips']) }}</div>
                <div class="stat-label">الرحلات النشطة</div>
            </div>
        </div>

        <div class="stat-card" style="--stat-color:#EF4444; --stat-bg:rgba(239,68,68,0.1);">
            <div class="stat-icon">
                <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
                </svg>
            </div>
            <div class="stat-info">
                <div class="stat-value">{{ number_format($stats['total_earnings'], 0) }}</div>
                <div class="stat-label">إجمالي الإيرادات (ر.ي)</div>
            </div>
        </div>

        <div class="stat-card" style="--stat-color:#10B981; --stat-bg:rgba(16,185,129,0.1);">
            <div class="stat-icon">
                <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10" fill="rgba(16,185,129,0.2)"/>
                    <polyline points="12 6 12 12 16 14"/>
                </svg>
            </div>
            <div class="stat-info">
                <div class="stat-value">{{ number_format($stats['online_captains']) }}</div>
                <div class="stat-label">الكباتن المتصلون الآن</div>
            </div>
        </div>

    </div>

    <!-- Charts Section -->
    <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(400px, 1fr)); gap:20px; margin-bottom:20px;">
        <div class="card gradient-top">
            <div class="card-header"><span class="card-title">
                <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="display:inline-block;vertical-align:middle;margin-left:6px;"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
                الرحلات خلال 7 أيام</span></div>
            <div class="card-body">
                <canvas id="tripsChart" height="250"></canvas>
            </div>
        </div>
        <div class="card gradient-top">
            <div class="card-header"><span class="card-title">
                <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="display:inline-block;vertical-align:middle;margin-left:6px;"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                الإيرادات خلال 7 أيام</span></div>
            <div class="card-body">
                <canvas id="earningsChart" height="250"></canvas>
            </div>
        </div>
    </div>

    <!-- Latest Trips Table -->
    <div class="card gradient-top">
        <div class="card-header">
            <span class="card-title">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="display:inline-block;vertical-align:middle;margin-left:6px;">
                    <path d="M3 12h18M3 6h18M3 18h18"/>
                </svg>
                آخر الرحلات
            </span>
            <a href="{{ route('admin.trips') }}" class="btn btn-secondary btn-sm">عرض الكل</a>
        </div>

        <div class="table-responsive">
            @if($latest_trips->count())
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>الراكب</th>
                        <th>الكابتن</th>
                        <th>من</th>
                        <th>إلى</th>
                        <th>السعر</th>
                        <th>الحالة</th>
                        <th>التاريخ</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($latest_trips as $trip)
                    <tr>
                        <td style="color:var(--color-text-muted);font-size:12px;">#{{ $trip->id }}</td>

                        <td>
                            <div class="user-cell">
                                <div class="avatar-sm">{{ mb_substr($trip->passenger?->name ?? '?', 0, 1) }}</div>
                                <div>
                                    <div class="user-cell-name">{{ $trip->passenger?->name ?? 'غير محدد' }}</div>
                                </div>
                            </div>
                        </td>

                        <td>
                            <div class="user-cell">
                                <div class="avatar-sm" style="background:linear-gradient(135deg,#3B82F6,#1D4ED8);">
                                    {{ mb_substr($trip->captain?->user?->name ?? '?', 0, 1) }}
                                </div>
                                <div>
                                    <div class="user-cell-name">{{ $trip->captain?->user?->name ?? 'لم يُحدد' }}</div>
                                </div>
                            </div>
                        </td>

                        <td style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                            {{ $trip->pickup_address ?? '—' }}
                        </td>
                        <td style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                            {{ $trip->dropoff_address ?? '—' }}
                        </td>

                        <td>
                            @if($trip->final_price)
                                <span style="font-weight:700;color:var(--color-success);">
                                    {{ number_format($trip->final_price, 0) }} ر.ي
                                </span>
                            @elseif($trip->estimated_price)
                                <span style="color:var(--color-text-muted);">
                                    ~{{ number_format($trip->estimated_price, 0) }} ر.ي
                                </span>
                            @else
                                <span style="color:var(--color-text-muted);">—</span>
                            @endif
                        </td>

                        <td>
                            @php
                                $statusMap = [
                                    'pending'   => ['label'=>'انتظار',   'class'=>'badge-warning'],
                                    'accepted'  => ['label'=>'مقبولة',   'class'=>'badge-info'],
                                    'started'   => ['label'=>'جارية',    'class'=>'badge-info'],
                                    'completed' => ['label'=>'مكتملة',   'class'=>'badge-success'],
                                    'cancelled' => ['label'=>'ملغاة',    'class'=>'badge-danger'],
                                ];
                                $s = $statusMap[$trip->status] ?? ['label'=>$trip->status, 'class'=>'badge-muted'];
                            @endphp
                            <span class="badge {{ $s['class'] }}">{{ $s['label'] }}</span>
                        </td>

                        <td style="color:var(--color-text-muted);font-size:12px;white-space:nowrap;">
                            {{ $trip->created_at->diffForHumans() }}
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
            @else
                <div class="empty-state">
                    <div class="empty-state-icon">🗺️</div>
                    <div class="empty-state-title">لا توجد رحلات بعد</div>
                    <div class="empty-state-desc">ستظهر هنا الرحلات فور إنشائها</div>
                </div>
            @endif
        </div>
    </div>

    <!-- Include Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const chartData = @json($chartData ?? ['labels'=>[], 'trips'=>[], 'earnings'=>[]]);

        const labels = chartData.labels;
        const trips = chartData.trips;
        const earnings = chartData.earnings;

        // Trips Chart
        const ctxTrips = document.getElementById('tripsChart').getContext('2d');
        new Chart(ctxTrips, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'عدد الرحلات',
                    data: trips,
                    borderColor: '#3B82F6',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
            }
        });

        // Earnings Chart
        const ctxEarnings = document.getElementById('earningsChart').getContext('2d');
        new Chart(ctxEarnings, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'الإيرادات (ر.ي)',
                    data: earnings,
                    backgroundColor: '#FF9800',
                    borderRadius: 4,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true } }
            }
        });
    </script>
</x-admin-layout>
