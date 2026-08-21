<div>
    <!-- Page Header -->
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
        <div>
            <h2 class="page-title">الإشعارات الموجهة</h2>
            <p class="page-subtitle">إرسال إشعارات (Push Notifications) مخصصة للكباتن والركاب</p>
        </div>
    </div>

    <!-- Session Messages -->
    @if (session('success'))
        <div class="alert alert-success">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            {{ session('success') }}
        </div>
    @endif

    <div style="display:flex; gap:20px; flex-wrap:wrap; align-items:flex-start;">
        
        <!-- Left Column: Form -->
        <div class="card gradient-top" style="flex:1; min-width:300px; max-width:450px;">
            <div class="card-header">
                <span class="card-title">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="display:inline;vertical-align:middle;margin-left:6px;">
                        <path d="M22 17H2a3 3 0 0 0 3-3V9a7 7 0 0 1 14 0v5a3 3 0 0 0 3 3zm-8.27 4a2 2 0 0 1-3.46 0"></path>
                    </svg>
                    إرسال إشعار جديد
                </span>
            </div>
            
            <div class="card-body">
                <form wire:submit="sendNotification">
                    <div class="form-group">
                        <label class="form-label">عنوان الإشعار</label>
                        <input type="text" wire:model="title" class="form-control" placeholder="مثال: خصم خاص اليوم!">
                        @error('title') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>

                    <div class="form-group">
                        <label class="form-label">محتوى الإشعار</label>
                        <textarea wire:model="body" class="form-control" rows="3" placeholder="اكتب تفاصيل الإشعار هنا..."></textarea>
                        @error('body') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>

                    <div class="form-group">
                        <label class="form-label">الجمهور المستهدف</label>
                        <select wire:model.live="targetType" class="form-control">
                            <option value="all">الجميع (ركاب وكباتن)</option>
                            <option value="users">الركاب فقط</option>
                            <option value="captains">الكباتن فقط</option>
                            <option value="specific">مستخدم محدد (عبر رقم الـ ID)</option>
                        </select>
                        @error('targetType') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>

                    @if($targetType === 'specific')
                    <div class="form-group">
                        <label class="form-label">رقم المستخدم (ID)</label>
                        <input type="number" wire:model="specificUserId" class="form-control" placeholder="أدخل رقم الـ ID للمستخدم أو الكابتن">
                        @error('specificUserId') <span style="color:var(--color-danger);font-size:12px;">{{ $message }}</span> @enderror
                    </div>
                    @endif

                    <!-- Phone Preview Simulation -->
                    <div style="background:var(--color-surface-elevated); border-radius:16px; padding:16px; margin-top:20px; border:3px solid var(--color-border); position:relative;">
                        <div style="width:40px;height:4px;background:var(--color-border);border-radius:4px;margin:0 auto 12px auto;"></div>
                        <div style="background:var(--color-surface); border:1px solid var(--color-border); border-radius:12px; padding:12px; box-shadow:var(--shadow-card); display:flex; gap:12px; align-items:flex-start;">
                            <div style="width:36px;height:36px;border-radius:8px;background:var(--color-primary);display:flex;align-items:center;justify-content:center;color:white;font-weight:bold;font-size:18px;flex-shrink:0;">L</div>
                            <div>
                                <div style="font-weight:700; font-size:13px; color:var(--color-text-primary); margin-bottom:4px;">{{ $title ?: 'عنوان الإشعار' }}</div>
                                <div style="font-size:12px; color:var(--color-text-secondary); line-height:1.4;">{{ $body ?: 'محتوى الإشعار سيظهر هنا...' }}</div>
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width:100%;margin-top:20px;">
                        إرسال الإشعار
                        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="margin-right:6px; transform:rotate(-45deg);"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                    </button>
                    
                    <div wire:loading wire:target="sendNotification" style="text-align:center; margin-top:10px; font-size:12px; color:var(--color-text-muted);">
                        جاري الإرسال...
                    </div>
                </form>
            </div>
        </div>

        <!-- Right Column: History -->
        <div class="card" style="flex:2; min-width:300px;">
            <div class="card-header">
                <span class="card-title">سجل الإشعارات المرسلة</span>
            </div>

            <div class="table-responsive">
                @if(count($history))
                <table>
                    <thead>
                        <tr>
                            <th>العنوان</th>
                            <th>المحتوى</th>
                            <th>المستهدفون</th>
                            <th>تاريخ الإرسال</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($history as $item)
                        <tr>
                            <td style="font-weight:700; color:var(--color-text-primary); max-width:150px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                                {{ $item->title }}
                            </td>
                            <td style="font-size:12px; color:var(--color-text-secondary); max-width:200px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                                {{ $item->body }}
                            </td>
                            <td>
                                <span class="badge badge-info">{{ $item->target }}</span>
                            </td>
                            <td style="font-size:12px; color:var(--color-text-muted);">
                                {{ $item->created_at->format('Y-m-d H:i') }}
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
                @else
                    <div class="empty-state" style="padding:32px 16px;">
                        <div class="empty-state-icon">🔔</div>
                        <div class="empty-state-title">لا توجد إشعارات مسجلة</div>
                        <div class="empty-state-desc">يمكنك إرسال أول إشعار مخصص عبر النموذج المقابل</div>
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>
