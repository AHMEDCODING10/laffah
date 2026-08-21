<div>
    <!-- Page Header -->
    <div class="page-header">
        <h2 class="page-title">الإعدادات</h2>
        <p class="page-subtitle">إدارة تسعيرة المشاوير والطرود وقواعد التشغيل</p>
    </div>

    <!-- Session Messages -->
    @if (session('success'))
        <div class="alert alert-success">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            {{ session('success') }}
        </div>
    @endif

    <!-- Validation Errors -->
    @if($errors->any())
        <div class="alert alert-danger">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div>
                @foreach($errors->all() as $error)
                    <div>{{ $error }}</div>
                @endforeach
            </div>
        </div>
    @endif

    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(400px,1fr));gap:20px;">

        <!-- Pricing Settings -->
        <div class="card gradient-top">
            <div class="card-header">
                <span class="card-title">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="display:inline;vertical-align:middle;margin-left:6px;">
                        <line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
                    </svg>
                    إعدادات التسعير (المسافة والطرود)
                </span>
            </div>
            <div class="card-body">
                <form wire:submit="savePricing">

                    <div class="form-group">
                        <label for="pricePerKm" class="form-label">سعر الكيلومتر الواحد (ر.ي) <span style="color:var(--color-primary);font-weight:700;">*</span></label>
                        <input type="number" wire:model="pricePerKm" id="pricePerKm" class="form-control" placeholder="175" min="1" step="5">
                        <span style="font-size:11px;color:var(--color-text-muted);display:block;margin-top:4px;">السعر الأساسي المعتمد: يُضرب مباشرة في المسافة المقطوعة للرحلة دون أي أجرة انطلاق إضافية.</span>
                    </div>

                    <div class="form-group">
                        <label for="multiStopFee" class="form-label">رسوم الوقفة الإضافية (ر.ي)</label>
                        <input type="number" wire:model="multiStopFee" id="multiStopFee" class="form-control" placeholder="300" min="0" step="50">
                        <span style="font-size:11px;color:var(--color-text-muted);display:block;margin-top:4px;">المبلغ المضاف عن كل نقطة توقف إضافية يحددها الراكب في المشوار.</span>
                    </div>

                    <div class="form-group">
                        <label for="commissionPercent" class="form-label">نسبة العمولة (%)</label>
                        <input type="number" wire:model="commissionPercent" id="commissionPercent" class="form-control" placeholder="15" min="0" max="100" step="0.5">
                        <span style="font-size:11px;color:var(--color-text-muted);display:block;margin-top:4px;">النسبة المقتطعة من أرباح الكابتن لكل رحلة.</span>
                    </div>

                    <div style="border-top:1px solid var(--color-border);padding-top:14px;margin-top:14px;margin-bottom:14px;">
                        <span style="font-size:13px;font-weight:700;color:var(--color-primary);display:block;margin-bottom:6px;">📦 نسبة زيادة تسعير توصيل الطرود (حسب الحجم)</span>
                        <span style="font-size:11px;color:var(--color-text-muted);display:block;margin-bottom:12px;">يُحسب سعر الطرد بضرب المسافة في سعر الكيلومتر مع إضافة النسبة المئوية لحجم الطرد.</span>
                        <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;">
                            <div class="form-group">
                                <label for="parcelPercentSmall" class="form-label" style="font-size:11px;">طرد صغير (%)</label>
                                <input type="number" wire:model="parcelPercentSmall" id="parcelPercentSmall" class="form-control" placeholder="10" min="0" max="100" step="1">
                            </div>
                            <div class="form-group">
                                <label for="parcelPercentMedium" class="form-label" style="font-size:11px;">طرد متوسط (%)</label>
                                <input type="number" wire:model="parcelPercentMedium" id="parcelPercentMedium" class="form-control" placeholder="15" min="0" max="100" step="1">
                            </div>
                            <div class="form-group">
                                <label for="parcelPercentLarge" class="form-label" style="font-size:11px;">طرد كبير (%)</label>
                                <input type="number" wire:model="parcelPercentLarge" id="parcelPercentLarge" class="form-control" placeholder="20" min="0" max="100" step="1">
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width:100%;margin-top:8px;">
                        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                        حفظ إعدادات التسعير
                    </button>

                </form>
            </div>
        </div>

        <!-- General Settings -->
        <div class="card gradient-top">
            <div class="card-header">
                <span class="card-title">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="display:inline;vertical-align:middle;margin-left:6px;">
                        <circle cx="12" cy="12" r="3"/>
                        <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4"/>
                    </svg>
                    الإعدادات العامة والتشغيلية
                </span>
            </div>
            <div class="card-body">
                <form wire:submit="saveGeneral">

                    <div class="form-group">
                        <label for="appName" class="form-label">اسم التطبيق</label>
                        <input type="text" wire:model="appName" id="appName" class="form-control" placeholder="لَفَّة">
                    </div>

                    <div class="form-group">
                        <label for="supportPhone" class="form-label">رقم الدعم الفني</label>
                        <input type="text" wire:model="supportPhone" id="supportPhone" class="form-control" placeholder="+967..." style="direction:ltr;text-align:right;">
                    </div>

                    <div class="form-group">
                        <label for="searchRadius" class="form-label">نصف قطر البحث عن الكباتن (كم)</label>
                        <input type="number" wire:model="searchRadius" id="searchRadius" class="form-control" placeholder="10" min="1" max="100">
                        <span style="font-size:11px;color:var(--color-text-muted);display:block;margin-top:4px;">أقصى مسافة للبحث عن كابتن متاح لطلب المشوار أو الطرد.</span>
                    </div>

                    <div class="form-group">
                        <label for="minWithdrawal" class="form-label">الحد الأدنى لطلب سحب الأرباح (ر.ي)</label>
                        <input type="number" wire:model="minWithdrawal" id="minWithdrawal" class="form-control" placeholder="1000" min="100" step="100">
                        <span style="font-size:11px;color:var(--color-text-muted);display:block;margin-top:4px;">أقل مبلغ يمكن للكابتن طلب تحويله إلى حسابه البنكي/الكريمي.</span>
                    </div>

                    <div style="padding:12px;background:var(--color-surface-elevated);border:1px solid var(--color-border);border-radius:var(--radius-md);margin-bottom:16px;">
                        <span style="font-size:12px;color:var(--color-text-secondary);display:flex;align-items:center;gap:6px;">
                            🛡️ <strong>سياسة المديونية:</strong> نظام لَفَّة يمنع المديونية بالكامل (Zero Debt) — لا يمكن لأي كابتن العمل أو قبول رحلات في حال كان رصيده سالباً.
                        </span>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width:100%;margin-top:8px;">
                        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                        حفظ الإعدادات العامة والتشغيلية
                    </button>

                </form>
            </div>
        </div>

    </div>

</div>
