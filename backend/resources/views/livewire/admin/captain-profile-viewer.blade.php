<div>
    @php
        $docTypes = [
            'id_card' => 'بطاقة الهوية الوطنية',
            'driving_license' => 'رخصة القيادة الشخصية',
            'vehicle_registration' => 'كرت ملكية ورخصة الدراجة',
            'bike_license' => 'رخصة الدراجة النارية',
            'criminal_record' => 'صحيفة الحالة الجنائية (فيش وتشبيه)',
            'license' => 'رخصة القيادة',
            'identity' => 'بطاقة الهوية',
        ];

        $docStatusMap = [
            'pending'  => ['label' => 'قيد الانتظار', 'c' => 'var(--color-warning)'],
            'approved' => ['label' => 'مقبول وموثق',  'c' => 'var(--color-success)'],
            'rejected' => ['label' => 'مرفوض',       'c' => 'var(--color-danger)'],
        ];
    @endphp

    <!-- Header -->
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; flex-wrap:wrap; gap:16px;">
        <div style="display:flex; align-items:center; gap:20px;">
            <div style="width:80px; height:80px; border-radius:var(--radius-xl); background:linear-gradient(135deg, #FF9800, #FF6D00); display:flex; align-items:center; justify-content:center; font-size:32px; color:white; font-weight:700; box-shadow:0 8px 24px rgba(255,152,0,0.3);">
                {{ mb_substr($captain->user?->name ?? '?', 0, 1) }}
            </div>
            <div>
                <h2 style="font-size:24px; font-weight:700; color:var(--color-text-primary); margin-bottom:4px;">{{ $captain->user?->name ?? 'مجهول' }}</h2>
                <div style="font-size:14px; color:var(--color-text-secondary); display:flex; gap:16px; flex-wrap:wrap;">
                    <span>📞 {{ $captain->user?->phone ?? 'لا يوجد رقم' }}</span>
                    <span>✉️ {{ $captain->user?->email ?? 'لا يوجد بريد' }}</span>
                </div>
            </div>
        </div>
        <div style="display:flex; align-items:center; gap:12px;">
            @if($captain->is_verified)
                <span class="badge badge-success" style="font-size:14px; padding:6px 14px;">✅ موثق</span>
                <button wire:click="toggleVerification" class="btn btn-secondary btn-sm" style="color:var(--color-danger); border-color:var(--color-danger); font-size:13px;" wire:confirm="هل أنت متأكد من إلغاء توثيق هذا الكابتن؟">
                    ⚠️ إلغاء التوثيق
                </button>
            @else
                <span class="badge badge-warning" style="font-size:14px; padding:6px 14px;">⏳ غير موثق</span>
                <button wire:click="toggleVerification" class="btn btn-success btn-sm" style="font-size:13px;">
                    ✅ توثيق الحساب والموافقة
                </button>
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
                        <div style="font-size:14px; font-weight:600;">{{ $captain->vehicle_type ?? 'دراجة نارية' }}</div>
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
            <div class="card-header"><span class="card-title">📁 المستندات والوثائق</span></div>
            <div class="card-body" style="padding:0;">
                @if($captain->documents && $captain->documents->count())
                    <div style="display:flex; flex-direction:column;">
                        @foreach($captain->documents as $doc)
                            <div style="padding:12px 20px; border-bottom:1px solid var(--color-border); display:flex; justify-content:space-between; align-items:center;">
                                <div>
                                    <div style="font-size:14px; font-weight:600; color:var(--color-text-primary);">{{ $docTypes[$doc->type] ?? $doc->type }}</div>
                                    @php
                                        $ds = $docStatusMap[$doc->status] ?? ['label' => $doc->status, 'c' => 'var(--color-text-muted)'];
                                    @endphp
                                    <span style="font-size:11px; color:{{ $ds['c'] }}; font-weight:600;">● {{ $ds['label'] }}</span>
                                </div>
                                <button wire:click="openDocModal({{ $doc->id }})" class="btn btn-secondary btn-sm" style="font-size:12px;">
                                    <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:3px;"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                    معاينة
                                </button>
                            </div>
                        @endforeach
                    </div>
                @else
                    <div style="padding:20px; text-align:center; color:var(--color-text-muted); font-size:13px;">لا توجد مستندات مرفوعة</div>
                @endif
            </div>
            @if(!$captain->is_verified)
                <div class="card-footer" style="padding:16px; border-top:1px solid var(--color-border); text-align:center;">
                    <button wire:click="toggleVerification" class="btn btn-primary" style="width:100%;">
                        ✅ توثيق الحساب واعتماد الوثائق
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

    <!-- In-Page Document Preview Modal -->
    @if($showDocModal && $selectedDoc)
    <div class="modal-backdrop" wire:click.self="closeDocModal">
        <div class="modal-content" style="max-width:720px;">
            <div class="modal-header">
                <span class="modal-title">
                    <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
                    </svg>
                    معاينة الوثيقة: {{ $docTypes[$selectedDoc->type] ?? $selectedDoc->type }}
                </span>
                <button wire:click="closeDocModal" class="modal-close">&times;</button>
            </div>
            <div class="modal-body" style="padding:18px;">
                <!-- Details bar -->
                <div style="display:flex;justify-content:space-between;align-items:center;padding:12px 16px;background:var(--color-bg);border:1px solid var(--color-border);border-radius:var(--radius-md);margin-bottom:16px;">
                    <div>
                        <div style="font-size:14px;font-weight:700;color:var(--color-text-primary);">{{ $docTypes[$selectedDoc->type] ?? $selectedDoc->type }}</div>
                        <div style="font-size:12px;color:var(--color-text-muted);">تاريخ الرفع: {{ $selectedDoc->created_at ? $selectedDoc->created_at->format('Y/m/d H:i') : '—' }}</div>
                    </div>
                    <div>
                        @php
                            $ds = $docStatusMap[$selectedDoc->status] ?? ['label' => $selectedDoc->status, 'c' => 'var(--color-text-muted)'];
                        @endphp
                        <span class="badge" style="background:var(--color-surface-elevated);color:{{ $ds['c'] }};border:1px solid {{ $ds['c'] }};font-size:13px;padding:6px 12px;">{{ $ds['label'] }}</span>
                    </div>
                </div>

                <!-- Document Image -->
                <div style="background:#0B0E14;border-radius:var(--radius-md);border:1px solid var(--color-border);overflow:hidden;display:flex;align-items:center;justify-content:center;min-height:300px;max-height:480px;">
                    <img src="{{ route('admin.documents.file', $selectedDoc->id) }}" 
                         alt="{{ $docTypes[$selectedDoc->type] ?? $selectedDoc->type }}" 
                         style="max-width:100%;max-height:460px;object-fit:contain;border-radius:var(--radius-md);" />
                </div>

                @if($selectedDoc->status === 'rejected' && $selectedDoc->rejection_reason)
                    <div style="margin-top:14px;padding:12px;background:var(--color-danger-bg);color:var(--color-danger-text);border-radius:var(--radius-sm);font-size:13px;border:1px solid rgba(239,68,68,0.2);">
                        <strong>سبب الرفض:</strong> {{ $selectedDoc->rejection_reason }}
                    </div>
                @endif
            </div>
            <div class="modal-footer">
                <a href="{{ route('admin.documents.file', $selectedDoc->id) }}" target="_blank" class="btn btn-secondary btn-sm" title="فتح الصورة بحجمها الأصلي">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:4px;"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                    فتح بحجم كامل
                </a>
                @if($selectedDoc->status !== 'approved')
                    <button wire:click="approveDoc({{ $selectedDoc->id }})" class="btn btn-success btn-sm">
                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:4px;"><polyline points="20 6 9 17 4 12"/></svg>
                        اعتماد الوثيقة
                    </button>
                @endif
                @if($selectedDoc->status !== 'rejected')
                    <button wire:click="rejectDoc({{ $selectedDoc->id }})" class="btn btn-danger btn-sm">
                        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-left:4px;"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                        رفض الوثيقة
                    </button>
                @endif
                <button wire:click="closeDocModal" class="btn btn-secondary btn-sm">إغلاق</button>
            </div>
        </div>
    </div>
    @endif
</div>
