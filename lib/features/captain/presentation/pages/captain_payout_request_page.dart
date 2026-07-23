import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

/// Enum representing the status of a payout transaction
enum PayoutStatus {
  completed,   // تم التحويل بنجاح
  pending,     // قيد المراجعة والتحقق
  processing,  // جاري إرسال الحوالة
  failed,      // فشل الإرسال / مرفوض
}

/// Model class representing a payout method
class PayoutMethod {
  final String id;
  final String name;
  final String logoText;
  final String description;
  final IconData icon;
  final String feeDescription;

  PayoutMethod({
    required this.id,
    required this.name,
    required this.logoText,
    required this.description,
    required this.icon,
    required this.feeDescription,
  });
}

/// Model class representing a transaction log
class PayoutTransaction {
  final String referenceId;
  final double amount;
  final double fee;
  final DateTime date;
  final PayoutStatus status;
  final String methodName;
  final String accountDetails;
  final String? rejectionReason;

  PayoutTransaction({
    required this.referenceId,
    required this.amount,
    required this.fee,
    required this.date,
    required this.status,
    required this.methodName,
    required this.accountDetails,
    this.rejectionReason,
  });
}

/// CaptainPayoutRequestPage - Premium, high-fidelity payout and balance management screen
/// for Laffah (لفّة) Captains in Yemen (focused on Sana'a metropolitan operations).
/// Implements full RTL layout, IBM Plex Sans Arabic typography, and advanced dark/light styling.
class CaptainPayoutRequestPage extends StatefulWidget {
  const CaptainPayoutRequestPage({super.key});

  @override
  State<CaptainPayoutRequestPage> createState() => _CaptainPayoutRequestPageState();
}

class _CaptainPayoutRequestPageState extends State<CaptainPayoutRequestPage> {
  // Mock account balances
  final double _availableBalance = 68450.0; // YER
  final double _pendingBalance = 12500.0;   // YER
  final double _totalEarned = 345000.0;     // YER
  final double _platformCommissionRate = 0.15; // 15% Laffah core commission
  final double _withdrawnAmount = 264050.0; // YER

  late List<PayoutMethod> _payoutMethods;
  late List<PayoutTransaction> _transactions;
  
  PayoutMethod? _selectedMethod;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializePayoutMethods();
    _initializeTransactions();
    _selectedMethod = _payoutMethods.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  void _initializePayoutMethods() {
    _payoutMethods = [
      PayoutMethod(
        id: 'kuraimi',
        name: 'الكريمي إكسبرس / حساب الكريمي',
        logoText: 'K',
        description: 'تحويل مباشر إلى حسابك في بنك الكريمي الإسلامي أو استلام كحوالة عبر الهوية.',
        icon: Icons.account_balance_rounded,
        feeDescription: 'رسوم التحويل: 1% (حد أدنى 100 ريال)',
      ),
      PayoutMethod(
        id: 'floos',
        name: 'خدمة فلوس موبايل (Floos)',
        logoText: 'F',
        description: 'إرسال سريع ومباشر إلى محفظة فلوس الإلكترونية المرتبطة برقم هاتفك.',
        icon: Icons.phone_android_rounded,
        feeDescription: 'بدون رسوم تحويل إضافية',
      ),
      PayoutMethod(
        id: 'al_najm',
        name: 'النجم إكسبرس للشبكات',
        logoText: 'N',
        description: 'إرسال حوالة فورية بالاسم ورقم الهاتف قابلة للاستلام من أي فرع في صنعاء وبقية المحافظات.',
        icon: Icons.alt_route_rounded,
        feeDescription: 'رسوم الشبكة: 1.5%',
      ),
      PayoutMethod(
        id: 'jeeb',
        name: 'محفظة جيب الإلكترونية (Jeeb)',
        logoText: 'J',
        description: 'سحب فوري ومجاني لمحفظتك الرقمية جيب التابعة لكاك بنك.',
        icon: Icons.wallet_giftcard_rounded,
        feeDescription: 'بدون رسوم',
      ),
    ];
  }

  void _initializeTransactions() {
    _transactions = [
      PayoutTransaction(
        referenceId: 'TXN-9021-YER',
        amount: 25000.0,
        fee: 250.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: PayoutStatus.completed,
        methodName: 'الكريمي إكسبرس',
        accountDetails: 'حساب رقم: 30129485',
      ),
      PayoutTransaction(
        referenceId: 'TXN-8742-YER',
        amount: 15000.0,
        fee: 0.0,
        date: DateTime.now().subtract(const Duration(days: 8)),
        status: PayoutStatus.completed,
        methodName: 'خدمة فلوس موبايل',
        accountDetails: 'رقم المحفظة: 777123456',
      ),
      PayoutTransaction(
        referenceId: 'TXN-8110-YER',
        amount: 32000.0,
        fee: 480.0,
        date: DateTime.now().subtract(const Duration(days: 14)),
        status: PayoutStatus.failed,
        methodName: 'النجم إكسبرس للشبكات',
        accountDetails: 'حوالة باسم: علي صالح ناصر',
        rejectionReason: 'الاسم رباعي غير متطابق تماماً مع بيانات البطاقة الشخصية المرفوعة في قسم التوثيق.',
      ),
      PayoutTransaction(
        referenceId: 'TXN-7945-YER',
        amount: 20000.0,
        fee: 0.0,
        date: DateTime.now().subtract(const Duration(days: 21)),
        status: PayoutStatus.completed,
        methodName: 'محفظة جيب الإلكترونية',
        accountDetails: 'حساب رقم: 777123456',
      ),
    ];
  }

  double _calculateTransactionFee(double amount) {
    if (_selectedMethod == null) return 0.0;
    if (_selectedMethod!.id == 'kuraimi') {
      double calculated = amount * 0.01;
      return calculated < 100 ? 100 : calculated;
    } else if (_selectedMethod!.id == 'al_najm') {
      return amount * 0.015;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Text(
            'طلب سحب الرصيد والمحفظة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s16),
            children: [
              // ==========================================
              // MODULE 1: Elegant Balance Summary Dashboard
              // ==========================================
              _buildBalanceDashboard(isDark),

              AppSpacing.h24,

              // ==========================================
              // MODULE 2: Interactive Payout Request Form
              // ==========================================
              _buildPayoutFormSection(isDark),

              AppSpacing.h24,

              // ==========================================
              // MODULE 3: Historical Transactions Log
              // ==========================================
              _buildTransactionsLogSection(isDark),

              AppSpacing.h32,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceDashboard(bool isDark) {
    return GlassBox(
      borderRadius: AppSpacing.radiusXL,
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الرصيد الحالي القابل للسحب',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.gray500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.success, size: 12),
                    AppSpacing.w4,
                    Text(
                      'رصيد آمن',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          AppSpacing.h8,

          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                _formatCurrency(_availableBalance),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 34,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.w6,
              const Text(
                'ريال يمني',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),

          AppSpacing.h16,
          const Divider(height: 1, thickness: 0.8),
          AppSpacing.h16,

          // Row of metrics: Pending vs Total Earned
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.w6,
                        const Text(
                          'رصيد قيد التسوية والتحقق',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h6,
                    Text(
                      '${_formatCurrency(_pendingBalance)} ريال',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: isDark ? AppColors.white.withOpacity(0.06) : AppColors.gray200,
              ),
              AppSpacing.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.w6,
                        const Text(
                          'إجمالي الأرباح التاريخية',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h6,
                    Text(
                      '${_formatCurrency(_totalEarned)} ريال',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.h16,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
              borderRadius: AppSpacing.borderSM,
              border: Border.all(
                color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'عمولة منصة لَفَّة المستقطعة (15%):',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray500,
                  ),
                ),
                Text(
                  '- ${_formatCurrency(_totalEarned * _platformCommissionRate)} ريال',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutFormSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withOpacity(0.6) : AppColors.white.withOpacity(0.9),
        borderRadius: AppSpacing.borderXL,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طلب سحب دفعة جديدة',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h16,

            // Select Payout Method Dropdown Button
            const Text(
              'اختر وسيلة السحب المفضلة لديك:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.h8,
            _buildPayoutMethodSelector(isDark),

            AppSpacing.h16,

            // Input: Amount
            const Text(
              'مبلغ السحب (بالريال اليمني):',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.h8,
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                prefixText: 'YER  ',
                prefixStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary500,
                ),
                hintText: 'مثال: 15000',
                hintStyle: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
                filled: true,
                fillColor: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.primary500,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 1.5,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال مبلغ السحب';
                }
                final amt = double.tryParse(value);
                if (amt == null) {
                  return 'يرجى إدخال رقم صحيح';
                }
                if (amt < 5000) {
                  return 'الحد الأدنى للسحب هو 5,000 ريال';
                }
                if (amt > _availableBalance) {
                  return 'المبلغ يتجاوز رصيدك الحالي القابل للسحب';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),

            AppSpacing.h16,

            // Input: Account details or Name
            const Text(
              'تفاصيل الحساب أو رقم المحفظة / اسم المستلم الرباعي:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.h8,
            TextFormField(
              controller: _accountController,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontFamily: _selectedMethod?.id == 'floos' || _selectedMethod?.id == 'jeeb' ? 'monospace' : 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: _selectedMethod?.id == 'kuraimi'
                    ? 'أدخل رقم حساب الكريمي المكون من 8 أو 9 خانات'
                    : (_selectedMethod?.id == 'floos'
                        ? 'أدخل رقم الهاتف المرتبط بمحفظة فلوس (77xxxxxxx)'
                        : 'أدخل اسم المستلم الرباعي المطابق للبطاقة الشخصية'),
                hintStyle: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
                filled: true,
                fillColor: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.primary500,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 1.5,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال تفاصيل الحساب أو اسم المستلم';
                }
                if (value.trim().length < 6) {
                  return 'التفاصيل قصيرة جداً وغير صالحة للاعتماد';
                }
                return null;
              },
            ),

            AppSpacing.h20,

            // Dynamic Receipt Calculation Box
            _buildReceiptCalculationBox(isDark),

            AppSpacing.h24,

            // Submit Button
            _isSubmitting
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handlePayoutSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderMD,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'تأكيد وتقديم طلب السحب المالي',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          AppSpacing.w8,
                          Icon(Icons.arrow_back, size: 18), // Left because of RTL
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutMethodSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
        borderRadius: AppSpacing.borderSM,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PayoutMethod>(
          value: _selectedMethod,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary500),
          dropdownColor: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
          borderRadius: AppSpacing.borderMD,
          items: _payoutMethods.map((PayoutMethod method) {
            return DropdownMenuItem<PayoutMethod>(
              value: method,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      method.logoText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          method.name,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                        Text(
                          method.feeDescription,
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 9,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (PayoutMethod? newValue) {
            setState(() {
              _selectedMethod = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildReceiptCalculationBox(bool isDark) {
    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    final fee = _calculateTransactionFee(enteredAmount);
    final totalDeducted = enteredAmount;
    final netPayout = enteredAmount - fee;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.primary500.withOpacity(0.04),
        borderRadius: AppSpacing.borderSM,
        border: Border.all(
          color: AppColors.primary500.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إجمالي المبلغ المطلوب سحبه:',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: AppColors.gray600,
                ),
              ),
              Text(
                '${_formatCurrency(enteredAmount)} ريال',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
          AppSpacing.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رسوم التحويل الخاصة بـ (${_selectedMethod?.name.split(' ').first}):',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: AppColors.gray600,
                ),
              ),
              Text(
                '${_formatCurrency(fee)} ريال',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          AppSpacing.h8,
          const Divider(height: 1, thickness: 0.5),
          AppSpacing.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'صافي المبلغ المستلم الفعلي:',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: AppColors.primary500,
                ),
              ),
              Text(
                '${_formatCurrency(netPayout > 0 ? netPayout : 0.0)} ريال يمني',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
          AppSpacing.h12,
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: AppColors.primary500,
                size: 13,
              ),
              AppSpacing.w6,
              Expanded(
                child: Text(
                  _selectedMethod?.id == 'floos' || _selectedMethod?.id == 'jeeb'
                      ? 'وقت معالجة الطلب: فوري وتلقائي على مدار 24 ساعة.'
                      : 'وقت معالجة الطلب: خلال ساعتين عمل (مواعيد المطابقة والتحويل من 8:00 صباحاً وحتى 10:00 مساءً).',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsLogSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'سجل طلبات السحب والحوالات',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            Text(
              '(${_transactions.length}) معاملات',
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 11,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        AppSpacing.h12,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _transactions.length,
          separatorBuilder: (context, index) => AppSpacing.h12,
          itemBuilder: (context, index) {
            return _buildTransactionCard(isDark, _transactions[index]);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionCard(bool isDark, PayoutTransaction txn) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (txn.status) {
      case PayoutStatus.completed:
        statusColor = AppColors.success;
        statusText = 'تم التحويل بنجاح';
        statusIcon = Icons.check_circle_rounded;
        break;
      case PayoutStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'قيد المراجعة والتحقق';
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case PayoutStatus.processing:
        statusColor = AppColors.info;
        statusText = 'جاري الإرسال والمعالجة';
        statusIcon = Icons.autorenew_rounded;
        break;
      case PayoutStatus.failed:
        statusColor = AppColors.danger;
        statusText = 'مرفوض ومردود';
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withOpacity(0.6) : AppColors.white.withOpacity(0.8),
        borderRadius: AppSpacing.borderLG,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                txn.methodName,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              Text(
                '${_formatCurrency(txn.amount)} ريال',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: txn.status == PayoutStatus.failed ? AppColors.danger : AppColors.primary500,
                ),
              ),
            ],
          ),
          
          AppSpacing.h8,
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                txn.accountDetails,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: AppColors.gray500,
                ),
              ),
              Text(
                'الرسوم المستقطعة: ${_formatCurrency(txn.fee)} ريال',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 10,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),

          AppSpacing.h10,
          const Divider(height: 1, thickness: 0.5),
          AppSpacing.h10,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    statusIcon,
                    color: statusColor,
                    size: 14,
                  ),
                  AppSpacing.w6,
                  Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Text(
                _formatDate(txn.date),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),

          if (txn.rejectionReason != null) ...[
            AppSpacing.h10,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s8),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.05),
                borderRadius: AppSpacing.borderSM,
                border: Border.all(color: AppColors.danger.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سبب رفض الحوالة واسترداد الرصيد للمحفظة:',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: AppColors.danger,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    txn.rejectionReason!,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 10,
                      height: 1.4,
                      color: isDark ? AppColors.gray300 : AppColors.gray800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handlePayoutSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulation of a payment request submission
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          final amt = double.parse(_amountController.text);
          setState(() {
            _isSubmitting = false;
            // Add new transaction to top of logs
            _transactions.insert(
              0,
              PayoutTransaction(
                referenceId: 'TXN-NEW-${(1000 + (DateTime.now().millisecond)).toString()}-YER',
                amount: amt,
                fee: _calculateTransactionFee(amt),
                date: DateTime.now(),
                status: _selectedMethod?.id == 'floos' || _selectedMethod?.id == 'jeeb'
                    ? PayoutStatus.completed
                    : PayoutStatus.pending,
                methodName: _selectedMethod!.name,
                accountDetails: _accountController.text,
              ),
            );
          });

          // Show success bottom sheet or dialog
          _showPayoutSuccessDialog(amt);
          _amountController.clear();
          _accountController.clear();
        }
      });
    }
  }

  void _showPayoutSuccessDialog(double amt) {
    final isInstant = _selectedMethod?.id == 'floos' || _selectedMethod?.id == 'jeeb';
    
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderLG,
          ),
          icon: Icon(
            isInstant ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
            color: AppColors.success,
            size: 50,
          ),
          title: Text(
            isInstant ? 'تم التحويل الفوري بنجاح' : 'تم استلام طلب السحب المالي',
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          content: Text(
            isInstant
                ? 'لقد تم إرسال مبلغ (${_formatCurrency(amt)} ريال) بالكامل وبشكل فوري إلى حساب محفظتك الرقمية المحددة. يرجى مراجعة إشعار محفظتك للتحقق من الاستلام.'
                : 'لقد تم تسجيل طلب سحب مبلغ (${_formatCurrency(amt)} ريال) بنجاح وتحت الرقم المرجعي التابع لفريق المراجعة.\n\nسيقوم قسم الدعم والمالية في لَفَّة بمطابقة طلبك وتنفيذ الحوالة وإرسال الكود فوراً.',
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 13,
              height: 1.5,
              color: AppColors.gray600,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderXS,
                ),
              ),
              child: const Text(
                'موافق، العودة',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Return formatted number like 15,000 without using external dependency
    final String str = amount.toInt().toString();
    if (str.length <= 3) return str;
    
    final List<String> parts = [];
    int end = str.length;
    while (end > 0) {
      final int start = end - 3 > 0 ? end - 3 : 0;
      parts.insert(0, str.substring(start, end));
      end = start;
    }
    return parts.join(',');
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$year/$month/$day $hour:$min';
  }
}
