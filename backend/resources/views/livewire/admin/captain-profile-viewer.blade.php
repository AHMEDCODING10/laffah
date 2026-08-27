<div>
    <!-- Header -->
    <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:24px;">
        <div style="display:flex; align-items:center; gap:20px;">
            <div style="width:80px; height:80px; border-radius:var(--radius-xl); background:linear-gradient(135deg, #FF9800, #FF6D00); display:flex; align-items:center; justify-content:center; font-size:32px; color:white; font-weight:700; box-shadow:0 8px 24px rgba(255,152,0,0.3);">
                {{ mb_substr($captain->user?->name ?? '?', 0, 1) }}
            </div>
            <div>
                <h2 style="font-size:24px; font-weight:700; color:var(--color-text-primary); margin-bottom:4px;">{{ $captain->user?->name ?? 'مجهول' }}</h2>
                <div style="font-size:14px; color:var(--color-text-secondary); display:flex; gap:16px;">
                    <span>📞 {{ $captain->user?->phone ?? 'لا يوجد رقم' }}</span>
                    <span>✉️ {{ $captain->user?->email ?? 'لا يوجد بريد' }}</span>
                </div>
            </div>
        </div>
        <div>
            @if($captain->is_verified)
                <span class="badge badge-success" style="font-size:14px; padding:6px 12px;">موثق</span>
            @else
                <span class="badge badge-warning" style="font-size:14px; padding:6px 12px;">غير موثق</span>
            @endif
        </div>
    </div>

    <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(300px, 1fr)); gap:20px;">

        <!-- Vehicle Info -->
        <div class="card gradient-top">
            <div class="card-header"><span class="card-title">🏍️ بيانات الدراجة النارية</span></div>
            <div class="card-body">
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px;">
                    <div>
                        <div style="font-size:12px; color:var(--color-text-muted); margin-bottom:4px;">النوع</div>
                        <div style="font-size:14px; font-weight:600;">{{ $captain->vehicle_type ?? '—' }}</div>
                    </div>
                    <div>
                        <div style="font-size:12px; color:var(--color-text-muted); margin-bottom:4px;">الموديل</div>
                        <div style="font-size:14px; font-weight:600;">{{ $captain->vehicle_model ?? '—' }}</div>
                    </div>
                    <div>
                        <div style="font-size:12px; color:var(--color-text-muted); margin-bottom:4px;">اللون</div>
                        <div style="font-size:14px; font-weight:600;">{{ $captain->vehicle_color ?? '—' }}</div>
                    </div>
                    <div>
                        <div style="font-size:12px; color:var(--color-text-muted); margin-bottom:4px;">رقم اللوحة</div>
                        <div style="background:var(--color-surface); padding:4px 8px; border-radius:4px; font-size:14px; font-weight:700; direction:ltr; display:inline-block; border:1px solid var(--color-border);">
                            {{ $captain->plate_number ?? '—' }}
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Wallet Info -->
        <div class="card gradient-top">
            <div class="card-header"><span class="card-title">💰 المحفظة والأرباح</span></div>
            <div class="card-body">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
                    <div>
                        <div style="font-size:13px; color:var(--color-text-muted);">الرصيد الحالي</div>
                        <div style="font-size:24px; font-weight:700; color:var(--color-success);">
                            {{ number_format($captain->user?->wallet?->balance ?? 0, 0) }} ر.ي
                        </div>
                    </div>
                    <div style="text-align:left;">
                        <div style="font-size:13px; color:var(--color-text-muted);">التقييم</div>
                        <div style="font-size:20px; font-weight:700; color:var(--color-warning);">
                            ⭐ {{ number_format($captain->rating ?? 0, 1) }}
                        </div>
                    </div>
                </div>

                <a href="{{ route('admin.transactions') }}?search={{ $captain->user?->name }}" class="btn btn-secondary" style="width:100%; text-align:center;">عرض كل المعاملات</a>
            </div>
        </div>

        <!-- Documents -->
        <div class="card gradient-top">
            <div class="card-header"><span class="card-title">📁 المستندات</span></div>
            <div class="card-body" style="padding:0;">
                @if($captain->documents && $captain->documents->count())
                    <div style="display:flex; flex-direction:column;">
                        @foreach($captain->documents as $doc)
                            <div style="padding:12px 20px; border-bottom:1px solid var(--color-border); display:flex; justify-content:space-between; align-items:center;">
                                <div>
                                    @php
                                        $docTypes = [
                                            'id_card' => 'بطاقة الهوية',
                                            'vehicle_registration' => 'تسجيل المركبة',
                                        ];
                                    @endphp
                                    <div style="font-size:14px; font-weight:600;">{{ $docTypes[$doc->type] ?? $doc->type }}</div>
                                    @php
                                        $docStatusMap = [
                                            'pending'  => ['label' => 'انتظار', 'c' => 'var(--color-warning)'],
                                            'approved' => ['label' => 'مقبول',  'c' => 'var(--color-success)'],
                                            'rejected' => ['label' => 'مرفوض',  'c' => 'var(--color-danger)'],
                                        ];
                                        $ds = $docStatusMap[$doc->status] ?? ['label' => $doc->status, 'c' => 'var(--color-text-muted)'];
                                    @endphp
                                    <span style="font-size:11px; color:{{ $ds['c'] }};">{{ $ds['label'] }}</span>
                                </div>
                                @if($doc->file_path)
                                    <a href="{{ asset('storage/' . $doc->file_path) }}" target="_blank" class="btn btn-secondary btn-sm" style="font-size:12px;">عرض</a>
                                @endif
                            </div>
                        @endforeach
                    </div>
                @else
                    <div style="padding:20px; text-align:center; color:var(--color-text-muted); font-size:13px;">لا توجد مستندات مرفوعة</div>
                @endif
            </div>
            @if(!$captain->is_verified)
                <div class="card-footer" style="padding:16px; border-top:1px solid var(--color-border); text-align:center;">
                    @error('verification')
                        <div style="color:var(--color-danger); font-size:12px; margin-bottom:8px;">{{ $message }}</div>
                    @enderror
                    <button wire:click="verifyCaptain" class="btn btn-primary" style="width:100%;">
                        ✅ توثيق الحساب والموافقة
                    </button>
                </div>
            @endif
        </div>

    </div>

    <!-- Recent Trips -->
    <div class="card" style="margin-top:20px;">
        <div class="card-header">
            <span class="card-title">🗺️ أحدث الرحلات</span>
            <a href="{{ route('admin.trips') }}?search={{ $captain->user?->name }}" class="btn btn-secondary btn-sm">عرض الكل</a>
        </div>
        <div class="table-responsive">
            @if($recentTrips->count())
                <table>
                    <thead>
                        <tr>
                            <th>الرقم</th>
                            <th>الراكب</th>
                            <th>نقطة الانطلاق</th>
                            <th>الوجهة</th>
                            <th>السعر</th>
                            <th>الحالة</th>
                            <th>التاريخ</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($recentTrips as $trip)
                            <tr>
                                <td style="color:var(--color-text-muted);font-size:12px;">#{{ $trip->id }}</td>
                                <td>{{ $trip->passenger?->name ?? 'غير محدد' }}</td>
                                <td style="max-width:150px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:12px;">📍 {{ $trip->pickup_address ?? '—' }}</td>
                                <td style="max-width:150px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:12px;">🏁 {{ $trip->dropoff_address ?? '—' }}</td>
                                <td style="font-weight:700;">{{ number_format($trip->final_price ?? $trip->estimated_price, 0) }} ر.ي</td>
                                <td>
                                    @php
                                        $sMap = [
                                            'pending'   => 'badge-warning',
                                            'accepted'  => 'badge-info',
                                            'started'   => 'badge-info',
                                            'completed' => 'badge-success',
                                            'cancelled' => 'badge-danger',
                                        ];
                                    @endphp
                                    <span class="badge {{ $sMap[$trip->status] ?? 'badge-muted' }}">{{ $trip->status }}</span>
                                </td>
                                <td style="color:var(--color-text-muted);font-size:12px;">{{ $trip->created_at->format('Y/m/d') }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @else
                <div style="padding:40px; text-align:center; color:var(--color-text-muted);">لا توجد رحلات مسجلة لهذا الكابتن بعد.</div>
            @endif
        </div>
    </div>
</div>
