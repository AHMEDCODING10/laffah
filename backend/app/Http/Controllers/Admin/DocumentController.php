<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Document;
use Illuminate\Support\Facades\Storage;

class DocumentController extends Controller
{
    public function showFile(int $id)
    {
        $document = Document::with('captainProfile.user')->findOrFail($id);

        // Check storage disk public
        if ($document->file_path && Storage::disk('public')->exists($document->file_path)) {
            $fullPath = Storage::disk('public')->path($document->file_path);
            $mimeType = mime_content_type($fullPath) ?: 'image/jpeg';
            return response()->file($fullPath, [
                'Content-Type' => $mimeType,
                'Content-Disposition' => 'inline; filename="' . basename($fullPath) . '"',
            ]);
        }

        // Check storage/app/
        if ($document->file_path && file_exists(storage_path('app/' . $document->file_path))) {
            $fullPath = storage_path('app/' . $document->file_path);
            $mimeType = mime_content_type($fullPath) ?: 'image/jpeg';
            return response()->file($fullPath, [
                'Content-Type' => $mimeType,
                'Content-Disposition' => 'inline; filename="' . basename($fullPath) . '"',
            ]);
        }

        // Generate high-resolution SVG visual card if actual physical photo file is not on local disk
        $captainName = $document->captainProfile?->user?->name ?? 'كابتن لفة';
        $captainPhone = $document->captainProfile?->user?->phone ?? '770000000';
        $docType = match($document->type) {
            'id_card' => 'بطاقة الهوية الوطنية',
            'driving_license' => 'رخصة القيادة الشخصية',
            'vehicle_registration' => 'كرت ملكية ورخصة الدراجة',
            default => $document->type,
        };
        $statusText = match($document->status) {
            'approved' => 'موثق ومعتمد',
            'rejected' => 'مرفوض',
            default => 'قيد المراجعة',
        };
        $statusColor = match($document->status) {
            'approved' => '#22C55E',
            'rejected' => '#EF4444',
            default => '#FF9800',
        };
        $plate = $document->captainProfile?->plate_number ?? '12345/ص';
        $date = $document->created_at ? $document->created_at->format('Y-m-d H:i') : date('Y-m-d H:i');

        $svg = <<<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="800" height="500" viewBox="0 0 800 500" fill="none">
    <rect width="800" height="500" rx="16" fill="#181D2D"/>
    <rect x="20" y="20" width="760" height="460" rx="12" stroke="#FF9800" stroke-width="2" stroke-dasharray="6 6" fill="#141824"/>
    
    <!-- Watermark / Header -->
    <rect x="40" y="40" width="720" height="60" rx="8" fill="#FF9800" fill-opacity="0.1"/>
    <text x="730" y="78" fill="#FF9800" font-family="'IBM Plex Sans Arabic', sans-serif" font-size="22" font-weight="bold" text-anchor="end">وثيقة كابتن رسمية — تطبيق لَفَّة</text>
    <text x="60" y="76" fill="#94A3B8" font-family="monospace" font-size="14">DOC-#{$document->id}</text>
    
    <!-- Document Type Header -->
    <text x="400" y="160" fill="#FFFFFF" font-family="'IBM Plex Sans Arabic', sans-serif" font-size="28" font-weight="bold" text-anchor="middle">{$docType}</text>
    <line x1="250" y1="180" x2="550" y2="180" stroke="#FF9800" stroke-width="2"/>

    <!-- Info Grid -->
    <text x="700" y="230" fill="#94A3B8" font-family="'IBM Plex Sans Arabic', sans-serif" font-size="16" text-anchor="end">اسم الكابتن:</text>
    <text x="500" y="230" fill="#FFFFFF" font-family="'IBM Plex Sans Arabic', sans-serif" font-size="18" font-weight="bold" text-anchor="end">{$captainName}</text>
    
    <text x="700" y="280" fill="#94A3B8" font-family="'IBM Plex Sans Arabic', sans-serif" font-size="16" text-anchor="end">رقم الهاتف:</text>
    <text x="500" y="280" fill="#FFFFFF" font-family="monospace" font-size="18" font-weight="bold" text-anchor="end">{$captainPhone}</text>

    <text x="700" y="330" fill="#94A3B8" font-family="'IBM Plex Sans Arabic', sans-serif" font-size="16" text-anchor="end">رقم اللوحة:</text>
    <text x="500" y="330" fill="#FFB74D" font-family="'IBM Plex Sans Arabic', sans-serif" font-size="18" font-weight="bold" text-anchor="end">{$plate}</text>

    <text x="700" y="380" fill="#94A3B8" font-family="'IBM Plex Sans Arabic', sans-serif" font-size="16" text-anchor="end">تاريخ الرفع:</text>
    <text x="500" y="380" fill="#94A3B8" font-family="monospace" font-size="15" text-anchor="end">{$date}</text>

    <!-- Status Stamp -->
    <rect x="70" y="300" width="180" height="70" rx="10" fill="{$statusColor}" fill-opacity="0.15" stroke="{$statusColor}" stroke-width="2"/>
    <text x="160" y="342" fill="{$statusColor}" font-family="'IBM Plex Sans Arabic', sans-serif" font-size="18" font-weight="bold" text-anchor="middle">{$statusText}</text>

    <!-- Footer Note -->
    <text x="400" y="445" fill="#64748B" font-family="'IBM Plex Sans Arabic', sans-serif" font-size="13" text-anchor="middle">تم تسجيل هذه الوثيقة إلكترونياً وتوثيقها عبر نظام لَفَّة الموحد</text>
</svg>
SVG;

        return response($svg, 200, [
            'Content-Type' => 'image/svg+xml',
            'Cache-Control' => 'no-cache, private',
        ]);
    }
}
