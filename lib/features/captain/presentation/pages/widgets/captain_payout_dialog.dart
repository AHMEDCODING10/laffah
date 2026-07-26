import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// CaptainPayoutDialog — Interactive Glassmorphic Payout Request Modal for Yemeni Captains.
/// Allows selecting payment provider (الكريمي, جوالي, ون كاش), quick amount selection,
/// entering account/phone numbers, and executing real balance deductions.
class CaptainPayoutDialog extends StatefulWidget {
  final double availableBalance;
  final Function(double amount, String method, String accountNumber) onConfirmPayout;

  const CaptainPayoutDialog({
    super.key,
    required this.availableBalance,
    required this.onConfirmPayout,
  });

  static void show({
    required BuildContext context,
    required double availableBalance,
    required Function(double amount, String method, String accountNumber) onConfirmPayout,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CaptainPayoutDialog(
        availableBalance: availableBalance,
        onConfirmPayout: onConfirmPayout,
      ),
    );
  }

  @override
  State<CaptainPayoutDialog> createState() => _CaptainPayoutDialogState();
}

class _CaptainPayoutDialogState extends State<CaptainPayoutDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController(text: '771234567');
  String _selectedMethod = 'صرافة الكريمي (أم فلوس)';
  String? _errorMessage;

  final List<Map<String, String>> _payoutMethods = const [
    {
      'id': 'صرافة الكريمي (أم فلوس)',
      'name': 'صرافة الكريمي Express (أم فلوس)',
      'desc': 'إرسال حوالة سحب نقدية فورية برقم الهوية',
      'icon': 'kuraimi',
    },
    {
      'id': 'محفظة جيب',
      'name': 'محفظة جيب (Jeeb Wallet - بنك اليمن والكويت)',
      'desc': 'تحويل إلكتروني فوري لحساب محفظة جيب الرقمية',
      'icon': 'jeeb',
    },
    {
      'id': 'محفظة فلوسك',
      'name': 'محفظة فلوسك (Floosak - بنك اليمن الدولي)',
      'desc': 'سحب فوري إلى حساب محفظة فلوسك الرقمية',
      'icon': 'floosak',
    },
    {
      'id': 'محفظة جوالي',
      'name': 'محفظة جوالي (Jwali Wallet)',
      'desc': 'تحويل مباشر لحساب محفظة جوالي المسجل',
      'icon': 'jwali',
    },
    {
      'id': 'محفظة ون كاش',
      'name': 'محفظة ون كاش (OneCash)',
      'desc': 'تحويل فوري إلى حساب محفظة ون كاش',
      'icon': 'onecash',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  void _applyQuickAmount(double val) {
    HapticFeedback.selectionClick();
    if (val > widget.availableBalance) {
      val = widget.availableBalance;
    }
    setState(() {
      _amountController.text = val.toStringAsFixed(0);
      _errorMessage = null;
    });
  }

  void _submitPayout() {
    final double? requestedAmount = double.tryParse(_amountController.text.trim());
    final String accountNum = _accountController.text.trim();

    if (requestedAmount == null || requestedAmount <= 0) {
      setState(() {
        _errorMessage = 'يرجى إدخال مبلغ سحب صحيح بالريال اليمني';
      });
      return;
    }

    if (requestedAmount > widget.availableBalance) {
      setState(() {
        _errorMessage = 'المبلغ المطلوب أكثر من الرصيد المتاح (${widget.availableBalance.toStringAsFixed(0)} ر.ي)';
      });
      return;
    }

    if (accountNum.isEmpty || accountNum.length < 7) {
      setState(() {
        _errorMessage = 'يرجى إدخال رقم الهاتف أو رقم الحساب البنكي بشكل صحيح';
      });
      return;
    }

    HapticFeedback.heavyImpact();
    Navigator.pop(context);
    widget.onConfirmPayout(requestedAmount, _selectedMethod, accountNum);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141822).withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.96),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag Handle Bar
                      Center(
                        child: Container(
                          width: 44,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      AppSpacing.h16,

                      // Dialog Title & Balance Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Color(0xFFFF6B00),
                                  size: 22,
                                ),
                              ),
                              AppSpacing.w10,
                              Text(
                                'طلب تحويل الأرباح',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: isDark ? Colors.white : AppColors.gray900,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'المتاح: ${widget.availableBalance.toStringAsFixed(0)} ر.ي',
                              style: const TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),

                      AppSpacing.h20,

                      // Method Picker Title
                      const Text(
                        'اختر جهة وسيلة التحويل المحلي',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: AppColors.gray500,
                        ),
                      ),

                      AppSpacing.h8,

                      // Method Options List
                      ..._payoutMethods.map((method) {
                        final bool isSelected = method['id'] == _selectedMethod;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedMethod = method['id']!;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF6B00).withValues(alpha: 0.12)
                                  : (isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFFF6B00)
                                    : (isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.gray200),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFF6B00)
                                        : (isDark ? Colors.white12 : AppColors.gray200),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    method['icon'] == 'kuraimi'
                                        ? Icons.account_balance_rounded
                                        : Icons.wallet_rounded,
                                    size: 18,
                                    color: isSelected ? Colors.white : AppColors.gray600,
                                  ),
                                ),
                                AppSpacing.w12,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method['name']!,
                                        style: TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: isDark ? Colors.white : AppColors.gray900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        method['desc']!,
                                        style: const TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontSize: 10.5,
                                          color: AppColors.gray500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<String>(
                                  value: method['id']!,
                                  groupValue: _selectedMethod,
                                  activeColor: const Color(0xFFFF6B00),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedMethod = val;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      AppSpacing.h16,

                      // Amount Input Field
                      const Text(
                        'المبلغ المراد تحويله (بالريال اليمني)',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: AppColors.gray500,
                        ),
                      ),

                      AppSpacing.h8,

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.gray50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _errorMessage != null
                                ? AppColors.danger
                                : (isDark ? Colors.white12 : AppColors.gray300),
                          ),
                        ),
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: isDark ? Colors.white : AppColors.gray900,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'أدخل المبلغ هنا (مثال: 2000)',
                            hintStyle: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 13,
                              color: AppColors.gray500,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            suffixText: 'ر.ي',
                            suffixStyle: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B00),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      // Quick Chips Bar (1000, 2000, Full Balance)
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildQuickChip('1,000 ر.ي', 1000.0, isDark),
                          const SizedBox(width: 8),
                          _buildQuickChip('2,000 ر.ي', 2000.0, isDark),
                          const SizedBox(width: 8),
                          _buildQuickChip('كامل الرصيد', widget.availableBalance, isDark, isFull: true),
                        ],
                      ),

                      AppSpacing.h16,

                      // Account / Phone Number Input
                      const Text(
                        'رقم الهاتف أو رقم حساب المحفظة',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: AppColors.gray500,
                        ),
                      ),

                      AppSpacing.h8,

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.gray50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white12 : AppColors.gray300,
                          ),
                        ),
                        child: TextField(
                          controller: _accountController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : AppColors.gray900,
                          ),
                          decoration: const InputDecoration(
                            hintText: '77XXXXXXX',
                            border: InputBorder.none,
                            icon: Icon(Icons.phone_android_rounded, size: 20, color: Color(0xFFFF6B00)),
                          ),
                        ),
                      ),

                      // Error message string display if present
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11.5,
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      AppSpacing.h24,

                      // Confirm Action Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _submitPayout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B00),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color(0xFFFF6B00).withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(Icons.send_rounded, size: 20),
                          label: const Text(
                            'تأكيد طلب التحويل الآن ⚡',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      AppSpacing.h16,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, double value, bool isDark, {bool isFull = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _applyQuickAmount(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFull
                ? const Color(0xFFFF6B00).withValues(alpha: 0.15)
                : (isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.gray100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFull
                  ? const Color(0xFFFF6B00)
                  : (isDark ? Colors.white12 : AppColors.gray200),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isFull
                  ? const Color(0xFFFF6B00)
                  : (isDark ? AppColors.gray300 : AppColors.gray700),
            ),
          ),
        ),
      ),
    );
  }
}
