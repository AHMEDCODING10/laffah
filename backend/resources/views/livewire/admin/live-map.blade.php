<div>
    <!-- Leaflet Assets -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

    <style>
        .leaflet-container {
            width: 100%;
            height: 100%;
            min-height: 560px;
            font-family: inherit;
            background: #1a1d2e;
            border-radius: 16px;
        }
        @keyframes captainPulse {
            0% { box-shadow: 0 0 0 0 rgba(255, 152, 0, 0.7); transform: scale(1); }
            70% { box-shadow: 0 0 0 14px rgba(255, 152, 0, 0); transform: scale(1.05); }
            100% { box-shadow: 0 0 0 0 rgba(255, 152, 0, 0); transform: scale(1); }
        }
        @keyframes tripPulse {
            0% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.7); }
            70% { box-shadow: 0 0 0 14px rgba(59, 130, 246, 0); }
            100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0); }
        }
        .captain-map-pin {
            width: 36px;
            height: 36px;
            background: linear-gradient(135deg, #FFB74D, #FF6D00);
            border: 2.5px solid #ffffff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
            animation: captainPulse 2s infinite;
            cursor: pointer;
        }
        .trip-map-pin {
            width: 36px;
            height: 36px;
            background: linear-gradient(135deg, #60A5FA, #2563EB);
            border: 2.5px solid #ffffff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
            animation: tripPulse 2s infinite;
            cursor: pointer;
        }
        .leaflet-popup-content-wrapper {
            background: var(--color-surface, #ffffff);
            color: var(--color-text-primary, #111827);
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.25);
            font-family: inherit;
            padding: 4px;
        }
        .leaflet-popup-tip {
            background: var(--color-surface, #ffffff);
        }
        [data-theme="dark"] .leaflet-popup-content-wrapper {
            background: #1e2235;
            color: #ffffff;
            border: 1px solid rgba(255,255,255,0.1);
        }
        [data-theme="dark"] .leaflet-popup-tip {
            background: #1e2235;
        }
    </style>

    <!-- Page Header -->
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;margin-bottom:16px;">
        <div>
            <h2 class="page-title">الخريطة الحية (Live Dispatch)</h2>
            <p class="page-subtitle">متابعة أماكن الكباتن المتصلين والرحلات النشطة في الوقت الفعلي</p>
        </div>
        <button wire:click="getMapData" class="btn btn-primary btn-sm" id="refreshBtn" style="display:inline-flex;align-items:center;gap:8px;">
            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>
            </svg>
            تحديث البيانات
        </button>
    </div>

    <div style="display:grid; grid-template-columns: 320px 1fr; gap:20px; min-height: 600px; height: calc(100vh - 190px);">
        
        <!-- Sidebar Panel -->
        <div class="card gradient-top" style="display:flex; flex-direction:column; overflow:hidden; border-radius:16px;">
            <div class="card-header" style="border-bottom:1px solid var(--color-border); padding:16px;">
                <span class="card-title" style="font-weight:700;">📡 إحصائيات مباشرة</span>
            </div>
            
            <div class="card-body" style="padding:16px; overflow-y:auto; flex:1;">
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:20px;">
                    <div style="background:var(--color-surface, rgba(255,255,255,0.05)); padding:16px 12px; border-radius:12px; text-align:center; border:1px solid var(--color-border);">
                        <div style="font-size:26px; font-weight:800; color:#FF9800;" id="onlineCaptainsCount">0</div>
                        <div style="font-size:12px; color:var(--color-text-muted); font-weight:600; margin-top:4px;">كابتن متصل</div>
                    </div>
                    <div style="background:var(--color-surface, rgba(255,255,255,0.05)); padding:16px 12px; border-radius:12px; text-align:center; border:1px solid var(--color-border);">
                        <div style="font-size:26px; font-weight:800; color:#3B82F6;" id="activeTripsCount">0</div>
                        <div style="font-size:12px; color:var(--color-text-muted); font-weight:600; margin-top:4px;">رحلة نشطة</div>
                    </div>
                </div>

                <div style="font-weight:700; font-size:14px; margin-bottom:12px; color:var(--color-text-primary); display:flex; align-items:center; justify-content:space-between;">
                    <span>الرحلات الجارية الآن</span>
                    <span style="font-size:11px; padding:2px 8px; background:rgba(59,130,246,0.1); color:#3B82F6; border-radius:10px;">مباشر</span>
                </div>
                
                <div id="activeTripsList" style="display:flex; flex-direction:column; gap:10px;">
                    <div style="text-align:center; font-size:13px; color:var(--color-text-muted); padding:30px 10px;">جاري تحميل البيانات...</div>
                </div>
            </div>
        </div>

        <!-- Map Container -->
        <div class="card" style="padding:0; overflow:hidden; border:1px solid var(--color-border); position:relative; border-radius:16px; min-height: 560px;">
            <div id="mapContainer" style="width:100%; height:100%; min-height:560px;"></div>
            
            <!-- Map Legend -->
            <div style="position:absolute; bottom:20px; left:20px; z-index:999; background:rgba(20,20,30,0.85); backdrop-filter:blur(10px); color:white; padding:10px 16px; border-radius:12px; border:1px solid rgba(255,255,255,0.15); box-shadow:0 8px 20px rgba(0,0,0,0.3); display:flex; gap:18px; font-size:12px; font-weight:600;">
                <div style="display:flex; align-items:center; gap:8px;">
                    <span style="width:12px; height:12px; border-radius:50%; background:#FF9800; display:inline-block; box-shadow:0 0 6px #FF9800;"></span>
                    كابتن متاح
                </div>
                <div style="display:flex; align-items:center; gap:8px;">
                    <span style="width:12px; height:12px; border-radius:50%; background:#3B82F6; display:inline-block; box-shadow:0 0 6px #3B82F6;"></span>
                    في رحلة
                </div>
            </div>
        </div>

    </div>

    @script
    <script>
        let mapInstance = null;
        let activeTileLayer = null;
        let markersGroup = null;

        // Coordinates for Sana'a, Yemen
        const DEFAULT_LAT = 15.3694;
        const DEFAULT_LNG = 44.1910;

        function getTileUrl(isDark) {
            return isDark 
                ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
        }

        function createMap() {
            const container = document.getElementById('mapContainer');
            if (!container) return;

            if (container._leaflet_id) {
                container._leaflet_id = null;
            }

            if (mapInstance !== null) {
                try {
                    mapInstance.remove();
                } catch(e) {}
                mapInstance = null;
            }

            const isDark = document.documentElement.getAttribute('data-theme') === 'dark';

            mapInstance = L.map('mapContainer', {
                center: [DEFAULT_LAT, DEFAULT_LNG],
                zoom: 13,
                zoomControl: true,
                attributionControl: false
            });

            activeTileLayer = L.tileLayer(getTileUrl(isDark), {
                maxZoom: 19,
                subdomains: 'abcd'
            }).addTo(mapInstance);

            markersGroup = L.layerGroup().addTo(mapInstance);

            // Listen for Dark/Light theme changes
            const observer = new MutationObserver(() => {
                if (mapInstance && activeTileLayer) {
                    const currentDark = document.documentElement.getAttribute('data-theme') === 'dark';
                    mapInstance.removeLayer(activeTileLayer);
                    activeTileLayer = L.tileLayer(getTileUrl(currentDark), { maxZoom: 19, subdomains: 'abcd' }).addTo(mapInstance);
                }
            });
            observer.observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });

            // Trigger multiple size invalidations to ensure full rendering
            [50, 200, 500, 1000, 2000].forEach(delay => {
                setTimeout(() => {
                    if (mapInstance) mapInstance.invalidateSize();
                }, delay);
            });

            // Load initial map data
            if (typeof $wire !== 'undefined' && $wire.getMapData) {
                $wire.getMapData();
            }

            // Setup WebSocket listener if Laravel Echo is active
            if (window.Echo) {
                try {
                    window.Echo.channel('captains-locations')
                        .listen('.CaptainLocationUpdated', (e) => {
                            if ($wire && $wire.getMapData) $wire.getMapData();
                        });
                } catch(err) {
                    console.log('Echo map listener note:', err);
                }
            }
        }

        // Handle updated data from Livewire
        Livewire.on('mapDataRefreshed', (data) => {
            if (!mapInstance || !markersGroup) return;

            let captains = [], trips = [], onlineCount = 0, activeTrips = 0;
            try {
                const payload = Array.isArray(data) ? data[0] : data;
                captains    = payload.captains    || [];
                trips       = payload.trips       || [];
                onlineCount = payload.onlineCount ?? captains.length;
                activeTrips = payload.activeTrips ?? trips.length;
            } catch(e) {
                console.error('mapDataRefreshed parse error:', e);
            }

            // Update statistics
            const onlineEl = document.getElementById('onlineCaptainsCount');
            const tripsEl  = document.getElementById('activeTripsCount');
            if (onlineEl) onlineEl.innerText = onlineCount;
            if (tripsEl)  tripsEl.innerText  = activeTrips;

            // Clear previous markers
            markersGroup.clearLayers();

            const bounds = [];

            // Add Captain Markers
            captains.forEach(captain => {
                if (captain.lat && captain.lng) {
                    const captainIcon = L.divIcon({
                        html: `<div class="captain-map-pin" title="${captain.name}">🏍️</div>`,
                        className: 'custom-leaflet-marker',
                        iconSize: [36, 36],
                        iconAnchor: [18, 18],
                        popupAnchor: [0, -18]
                    });

                    const marker = L.marker([captain.lat, captain.lng], { icon: captainIcon })
                        .bindPopup(`
                            <div style="text-align:right; padding:6px; min-width:140px;">
                                <div style="font-weight:700; font-size:14px; margin-bottom:4px; color:#FF9800;">🏍️ ${captain.name}</div>
                                <div style="font-size:12px; color:gray;">كابتن متصل ومتاح</div>
                            </div>
                        `);

                    markersGroup.addLayer(marker);
                    bounds.push([captain.lat, captain.lng]);
                }
            });

            // Update sidebar list of active trips
            const tripsList = document.getElementById('activeTripsList');
            if (tripsList) {
                if (trips.length > 0) {
                    let html = '';
                    trips.forEach(trip => {
                        html += `
                        <div style="background:var(--color-surface, rgba(255,255,255,0.05)); padding:12px; border-radius:10px; border:1px solid var(--color-border); font-size:12px;">
                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                                <span style="font-weight:700; color:#FF9800; font-size:13px;">رحلة #${trip.id}</span>
                                <span style="background:rgba(59,130,246,0.15); color:#3B82F6; padding:2px 8px; border-radius:6px; font-weight:600; font-size:11px;">
                                    ${trip.status === 'started' ? 'جارية' : (trip.status === 'accepted' ? 'مقبولة' : trip.status)}
                                </span>
                            </div>
                            <div style="display:flex; align-items:center; gap:6px; margin-bottom:4px; color:var(--color-text-primary);">
                                <span>👤</span> <span>الراكب: <strong>${trip.passenger}</strong></span>
                            </div>
                            <div style="display:flex; align-items:center; gap:6px; margin-bottom:6px; color:var(--color-text-primary);">
                                <span>🏍️</span> <span>الكابتن: <strong>${trip.captain}</strong></span>
                            </div>
                            ${trip.pickup ? `<div style="font-size:11px; color:var(--color-text-muted); margin-bottom:2px;">📍 من: ${trip.pickup}</div>` : ''}
                            ${trip.dropoff ? `<div style="font-size:11px; color:var(--color-text-muted);">🏁 إلى: ${trip.dropoff}</div>` : ''}
                        </div>`;
                    });
                    tripsList.innerHTML = html;
                } else {
                    tripsList.innerHTML = `<div style="text-align:center; font-size:13px; color:var(--color-text-muted); padding:30px 10px;">لا توجد رحلات نشطة حالياً</div>`;
                }
            }

            // Adjust view if markers exist
            if (bounds.length > 0) {
                mapInstance.fitBounds(bounds, { maxZoom: 15, padding: [40, 40] });
            }
        });

        // Initialize when Leaflet is ready
        function ensureInit() {
            if (typeof L !== 'undefined') {
                createMap();
            } else {
                setTimeout(ensureInit, 100);
            }
        }

        setTimeout(ensureInit, 100);
        document.addEventListener('livewire:navigated', () => setTimeout(ensureInit, 100));

        // Auto-refresh periodically
        setInterval(() => {
            if (typeof $wire !== 'undefined' && $wire.getMapData) {
                $wire.getMapData();
            }
        }, 30000);
    </script>
    @endscript
</div>
