import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// CaptainTopUpSheet — Allows Yemeni Captains to recharge their wallet or pay platform commissions
/// via local e-wallets (الكريمي, ون كاش, جوالي, محفظة جيب).
class CaptainTopUpSheet extends StatefulWidget {
  final bool isDark;
  final VoidCallback onRechargeSuccess;

  const CaptainTopUpSheet({
    super.key,
    required this.isDark,
    required this.onRechargeSuccess,
  });

  static void show(
    BuildContext context,
    bool isDark,
    VoidCallback onSuccess,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: CaptainTopUpSheet(
          isDark: isDark,
          onRechargeSuccess: onSuccess,
        ),
      ),
    );
  }

  @override
  State<CaptainTopUpSheet> createState() => _CaptainTopUpSheetState();
}

class _CaptainTopUpSheetState extends State<CaptainTopUpSheet> {
  final _amountController = TextEditingController(text: '1000');
  final _refController = TextEditingController();
  final _senderAccountController = TextEditingController();
  File? _receiptImage;

  int _selectedMethodIndex = 0;
  bool _isSubmitting = false;

  final List<int> _presetAmounts = [1000, 2000, 5000, 10000];

  final List<Map<String, dynamic>> _wallets = [
    {
      'id': 'kuraimi',
      'name': 'الكريمي (حاسب / إم فلوس)',
      'shortName': 'الكريمي',
      'account': '3001234567',
      'accountName': 'مؤسسة لَفَّة للخدمات اللوجستية',
      'scheme': 'kuraimi://',
      'icon': Icons.account_balance_rounded,
    },
    {
      'id': 'onecash',
      'name': 'ون كاش (OneCash)',
      'shortName': 'ون كاش',
      'account': '770291452',
      'accountName': 'منصة لَفَّة للنقل الذكي',
      'scheme': 'onecash://',
      'icon': Icons.phone_android_rounded,
    },
    {
      'id': 'jawali',
      'name': 'جوالي (WeCash)',
      'shortName': 'جوالي',
      'account': '770291452',
      'accountName': 'منصة لَفَّة - صنعاء',
      'scheme': 'wecash://',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'id': 'jeeb',
      'name': 'محفظة جيب (اليمن والبحرين)',
      'shortName': 'محفظة جيب',
      'account': '770291452',
      'accountName': 'شركة لَفَّة المحدودة',
      'scheme': 'jeeb://',
      'icon': Icons.wallet_giftcard_rounded,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _senderAccountController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _receiptImage = File(picked.path);
        });
        HapticFeedback.selectionClick();
      }
    } catch (_) {
      _showError('تعذر فتح معرض الصور');
    }
  }

  void _removeReceiptImage() {
    setState(() {
      _receiptImage = null;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _submitRecharge() async {
    final amountText = _amountController.text.trim();
    final refText = _refController.text.trim();

    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      _showError('يرجى إدخال مبلغ صحيح');
      return;
    }

    final double amount = double.parse(amountText);
    if (amount < 500) {
      _showError('الحد الأدنى للشحن هو 500 ريال');
      return;
    }

    if (refText.isEmpty) {
      _showError('يرجى إدخال رقم السند / الإشعار الصادر من المحفظة');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dio = sl<DioClient>().dio;
      final selected = _wallets[_selectedMethodIndex];

      dynamic postData;
      if (_receiptImage != null) {
        postData = FormData.fromMap({
          'amount': amount,
          'payment_method': selected['id'],
          'reference_id': refText,
          if (_senderAccountController.text.trim().isNotEmpty)
            'sender_account': _senderAccountController.text.trim(),
          'receipt_image': await MultipartFile.fromFile(
            _receiptImage!.path,
            filename: 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        });
      } else {
        postData = {
          'amount': amount,
          'payment_method': selected['id'],
          'reference_id': refText,
          'sender_account': _senderAccountController.text.trim().isNotEmpty
              ? _senderAccountController.text.trim()
              : null,
        };
      }

      await dio.post(
        ApiEndpoints.walletRecharge,
        data: postData,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onRechargeSuccess();
        _showSuccessDialog(amount, refText, selected['name']);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError('فشل إرسال طلب الشحن، يرجى التحقق من الاتصال والمحاولة ثانية');
      }
    }
  }

  void _showError(String msg) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(double amount, String ref, String walletName) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: widget.isDark ? const Color(0xFF141822) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFFD97706),
                  size: 34,
                ),
              ),
              AppSpacing.h16,
              Text(
                'تم استلام طلب الشحن بنجاح',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: widget.isDark ? Colors.white : AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.h10,
              Text(
                'تم تسجيل طلب شحن وسداد عمولات بمبلغ ${amount.toStringAsFixed(0)} ريال عبر $walletName (سند #$ref). طلبك قيد المطابقة وسيظهر برصيدك فور اعتماده.',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12.5,
                  color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.h20,
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'العودة للمحفظة',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openWalletApp(String scheme) async {
    try {
      final uri = Uri.parse(scheme);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'يرجى فتح تطبيق المحفظة على هاتفك وإجراء التحويل لحساب لَفَّة',
                style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
              ),
              backgroundColor: AppColors.primary500,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _pasteReference() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _refController.text = data.text!.trim();
      });
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedWallet = _wallets[_selectedMethodIndex];
    final currentAmount = int.tryParse(_amountController.text.trim());

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.s20,
        right: AppSpacing.s20,
        top: AppSpacing.s16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s24,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF141822) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top drag indicator
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            AppSpacing.h16,

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'شحن المحفظة وسداد العمولات',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: widget.isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined,
                          color: AppColors.success, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'تسوية فورية وآمنة',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'حول المبلغ لحساب لَفَّة وسجل رقم السند لتسوية العمولات وبقاء حسابك نشطاً',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 11.5,
                color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),

            AppSpacing.h16,

            // STEP 1: Amount Selection
            Text(
              '1. حدد مبلغ الشحن / السداد:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: widget.isDark ? AppColors.gray200 : AppColors.gray800,
              ),
            ),
            AppSpacing.h8,

            // Quick Preset Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presetAmounts.map((preset) {
                  final isSelected = currentAmount == preset;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text('$preset ريال'),
                      selected: isSelected,
                      selectedColor: AppColors.primary500,
                      backgroundColor: widget.isDark
                          ? const Color(0xFF1E2433)
                          : AppColors.gray100,
                      labelStyle: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (widget.isDark
                                ? AppColors.gray300
                                : AppColors.gray700),
                      ),
                      onSelected: (val) {
                        if (val) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _amountController.text = preset.toString();
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            AppSpacing.h8,

            // Amount Custom TextField
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : AppColors.gray900,
              ),
              decoration: InputDecoration(
                labelText: 'المبلغ المراد شحنه *',
                hintText: 'مثال: 1000',
                prefixIcon: const Icon(Icons.payments_outlined,
                    size: 20, color: AppColors.primary500),
                suffixText: 'ريال يمني',
                suffixStyle: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),

            AppSpacing.h16,

            // STEP 2: Wallet Selection
            Text(
              '2. اختر محفظة التحويل:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: widget.isDark ? AppColors.gray200 : AppColors.gray800,
              ),
            ),
            AppSpacing.h8,
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _wallets.length,
                separatorBuilder: (_, __) => AppSpacing.w8,
                itemBuilder: (ctx, index) {
                  final w = _wallets[index];
                  final isSelected = _selectedMethodIndex == index;
                  return ChoiceChip(
                    avatar: Icon(
                      w['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primary500,
                    ),
                    label: Text(w['shortName'] as String),
                    selected: isSelected,
                    selectedColor: AppColors.primary500,
                    backgroundColor: widget.isDark
                        ? const Color(0xFF1E2433)
                        : AppColors.gray100,
                    labelStyle: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (widget.isDark
                              ? AppColors.gray300
                              : AppColors.gray700),
                    ),
                    onSelected: (val) {
                      if (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedMethodIndex = index);
                      }
                    },
                  );
                },
              ),
            ),

            AppSpacing.h16,

            // STEP 3: Company Account Details Box
            Container(
              padding: const EdgeInsets.all(AppSpacing.s14),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary500.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'حول لحساب لَفَّة في ${selectedWallet['name']}:',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary500,
                        ),
                      ),
                      InkWell(
                        onTap: () => _openWalletApp(selectedWallet['scheme']),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary500,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.open_in_new_rounded,
                                  color: Colors.white, size: 12),
                              AppSpacing.w4,
                              Text(
                                'فتح التطبيق',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedWallet['account'],
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: 1.5,
                          color: widget.isDark
                              ? Colors.white
                              : AppColors.gray900,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: selectedWallet['account']));
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ رقم الحساب بنجاح',
                                  style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic')),
                              duration: Duration(seconds: 1),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary500,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.primary500),
                          ),
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 14),
                        label: const Text(
                          'نسخ الرقم',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اسم الحساب: ${selectedWallet['accountName']}',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      color:
                          widget.isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.h16,

            // STEP 4: Transfer Details Form
            Text(
              '3. بيانات السند للتأكيد والتسوية:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: widget.isDark ? AppColors.gray200 : AppColors.gray800,
              ),
            ),
            AppSpacing.h8,

            // Reference Field
            TextField(
              controller: _refController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'رقم السند / رقم الإشعار *',
                hintText: 'مثال: 874773',
                prefixIcon: const Icon(Icons.receipt_long_outlined,
                    size: 20, color: AppColors.primary500),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste_rounded,
                      size: 18, color: AppColors.primary500),
                  tooltip: 'لصق',
                  onPressed: _pasteReference,
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            AppSpacing.h10,

            // Sender Account / Phone Field
            TextField(
              controller: _senderAccountController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم حسابك أو هاتفك المحول منه (اختياري)',
                hintText: 'مثال: 775906034',
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            const SizedBox(height: 14),

            // Receipt Image Attachment Box
            Text(
              '4. صورة السند / إشعار التحويل (اختياري لتسريع الاعتماد):',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
                color: widget.isDark ? AppColors.gray200 : AppColors.gray800,
              ),
            ),
            AppSpacing.h8,
            if (_receiptImage == null)
              InkWell(
                onTap: _pickReceiptImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF1E2433) : AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isDark ? Colors.white12 : AppColors.gray300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 20,
                        color: AppColors.primary500,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'إرفاق صورة السند من الاستوديو',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark ? AppColors.gray300 : AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _receiptImage!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                              SizedBox(width: 4),
                              Text(
                                'تم إرفاق صورة السند',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _receiptImage!.path.split(Platform.pathSeparator).last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                      tooltip: 'حذف الصورة',
                      onPressed: _removeReceiptImage,
                    ),
                  ],
                ),
              ),

            AppSpacing.h20,

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRecharge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          AppSpacing.w8,
                          Text(
                            'تأكيد وإرسال طلب الشحن',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
