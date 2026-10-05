import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_app_bar.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../domain/entities/wallet_entity.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/transaction_list_tile.dart';
import '../widgets/wallet_balance_card.dart';

/// WalletPage — يعرض محفظة الراكب بتجربة واقعية واحترافية مطابقة لأوبر وكريم
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<WalletBloc>().add(GetWalletBalanceEvent());
    return const _WalletView();
  }
}

class _WalletView extends StatefulWidget {
  const _WalletView();

  @override
  State<_WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<_WalletView> {
  // Transaction filter: 'ALL', 'DEPOSIT', 'TRIP'
  String _selectedFilter = 'ALL';

  void _showTopUpBottomSheet(BuildContext parentContext, bool isDark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: parentContext.read<WalletBloc>(),
        child: _RechargeModalContent(isDark: isDark),
      ),
    );
  }

  void _showRechargeResultDialog(
      BuildContext context, WalletRechargeSuccess state, bool isDark) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (state.isPending
                          ? const Color(0xFFF59E0B)
                          : AppColors.success)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  state.isPending
                      ? Icons.hourglass_top_rounded
                      : Icons.check_circle_rounded,
                  color: state.isPending
                      ? const Color(0xFFD97706)
                      : AppColors.success,
                  size: 36,
                ),
              ),
              AppSpacing.h16,
              Text(
                state.isPending
                    ? 'تم استلام طلب الشحن بنجاح'
                    : 'تم شحن المحفظة بنجاح!',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.h10,
              Text(
                state.message,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.h20,
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1F2430)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : AppColors.gray200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.primary500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        state.isPending
                            ? 'طلبك قيد المطابقة وسيظهر برصيدك فور اعتماد السند.'
                            : 'الرصيد الجديد: ${state.newBalance.toStringAsFixed(0)} ريال',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h24,
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletRechargeSuccess) {
          _showRechargeResultDialog(context, state, isDark);
        } else if (state is WalletError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
              ),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        extendBody: true,
        appBar: LaffahAppBar(
          title: AppLocalizations.of(context)!.pass_laffah_wallet,
          showMenuButton: false,
          showBackButton: false,
          actions: [
            IconButton(
              tooltip: 'تحديث',
              icon: Icon(
                Icons.refresh_rounded,
                color: isDark ? AppColors.white : AppColors.gray800,
                size: 22,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<WalletBloc>().add(GetWalletBalanceEvent());
              },
            ),
          ],
        ),
        bottomNavigationBar: HomeBottomNavBar(isDark: isDark, currentIndex: 2),
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading && state is! WalletBalanceLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary500),
              );
            }

            double balance = 0;
            List<TransactionEntity> transactions = [];

            if (state is WalletBalanceLoaded) {
              balance = state.wallet.balance;
              transactions = state.wallet.transactions;
            }

            // Filter transactions
            final filteredTransactions = transactions.where((tx) {
              if (_selectedFilter == 'DEPOSIT') return tx.isCredit;
              if (_selectedFilter == 'TRIP') return !tx.isCredit;
              return true;
            }).toList();

            return RefreshIndicator(
              color: AppColors.primary500,
              onRefresh: () async {
                context.read<WalletBloc>().add(GetWalletBalanceEvent());
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  AppSpacing.s16,
                  AppSpacing.s20,
                  110,
                ),
                children: [
                  // Balance Card
                  WalletBalanceCard(
                    balance: balance,
                    onTopUpPressed: () =>
                        _showTopUpBottomSheet(context, isDark),
                  ),

                  AppSpacing.h16,

                  // Trust & Security Notice Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2430)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'محفظة رقمية آمنة • يتم خصم أجرة المشاوير تلقائياً من رصيدك المتاح.',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              color: isDark ? AppColors.gray300 : AppColors.gray700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.h24,

                  // Transaction History Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'سجل المعاملات المالية',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      Text(
                        '${transactions.length} معاملة',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          color: isDark ? AppColors.gray400 : AppColors.gray500,
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.h12,

                  // Filter Segmented Chips (All / Deposits / Trips)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'الكل',
                          count: transactions.length,
                          filterKey: 'ALL',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'عمليات الشحن (+)',
                          count: transactions.where((t) => t.isCredit).length,
                          filterKey: 'DEPOSIT',
                          isDark: isDark,
                          highlightColor: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'المشاوير (-)',
                          count: transactions.where((t) => !t.isCredit).length,
                          filterKey: 'TRIP',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.h16,

                  // Transactions List or Empty State
                  if (filteredTransactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark.withValues(alpha: 0.5)
                            : AppColors.gray50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : AppColors.gray200,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 44,
                            color: isDark
                                ? AppColors.gray600
                                : AppColors.gray400,
                          ),
                          AppSpacing.h10,
                          Text(
                            _selectedFilter == 'ALL'
                                ? 'لا توجد معاملات مالية مسجلة بعد'
                                : (_selectedFilter == 'DEPOSIT'
                                    ? 'لا توجد عمليات شحن سابقة'
                                    : 'لا توجد مشاوير مدفوعة من المحفظة'),
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: isDark
                                  ? AppColors.gray300
                                  : AppColors.gray700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'أي عمليات شحن أو دفع مشاوير ستظهر هنا بتفاصيلها الكاملة',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.gray500
                                  : AppColors.gray500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    for (final tx in filteredTransactions)
                      TransactionListTile(isDark: isDark, transaction: tx),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required String filterKey,
    required bool isDark,
    Color? highlightColor,
  }) {
    final bool isSelected = _selectedFilter == filterKey;
    final Color activeColor = highlightColor ?? AppColors.primary500;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = filterKey);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? const Color(0xFF1E2430) : AppColors.gray100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? Colors.white12 : AppColors.gray300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.gray300 : AppColors.gray700),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : (isDark ? Colors.white10 : Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.gray400 : AppColors.gray600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Multi-Step Recharge Sheet with Yemeni E-Wallets
class _RechargeModalContent extends StatefulWidget {
  final bool isDark;

  const _RechargeModalContent({required this.isDark});

  @override
  State<_RechargeModalContent> createState() => _RechargeModalContentState();
}

class _RechargeModalContentState extends State<_RechargeModalContent> {
  final _amountController = TextEditingController(text: '1000');
  final _refController = TextEditingController();
  final _senderAccountController = TextEditingController();

  int _selectedMethodIndex = 0;
  bool _isSubmitting = false;

  final List<int> _presetAmounts = [500, 1000, 2000, 5000, 10000];

  final List<Map<String, dynamic>> _wallets = [
    {
      'id': 'kuraimi',
      'name': 'الكريمي (حاسب / إم فلوس)',
      'shortName': 'الكريمي',
      'account': '3001234567',
      'accountName': 'مؤسسة لَفَّة للخدمات اللوجستية',
      'scheme': 'kuraimi://',
      'icon': Icons.account_balance_rounded,
      'badge': 'الأكثر استخداماً',
    },
    {
      'id': 'onecash',
      'name': 'ون كاش (OneCash)',
      'shortName': 'ون كاش',
      'account': '770291452',
      'accountName': 'منصة لَفَّة للنقل الذكي',
      'scheme': 'onecash://',
      'icon': Icons.phone_android_rounded,
      'badge': 'مباشر',
    },
    {
      'id': 'jawali',
      'name': 'جوالي (WeCash)',
      'shortName': 'جوالي',
      'account': '770291452',
      'accountName': 'منصة لَفَّة - صنعاء',
      'scheme': 'wecash://',
      'icon': Icons.account_balance_wallet_rounded,
      'badge': 'فوري',
    },
    {
      'id': 'jeeb',
      'name': 'محفظة جيب (اليمن والبحرين)',
      'shortName': 'محفظة جيب',
      'account': '770291452',
      'accountName': 'شركة لَفَّة المحدودة',
      'scheme': 'jeeb://',
      'icon': Icons.wallet_giftcard_rounded,
      'badge': 'فوري',
    },
    {
      'id': 'tadhamon',
      'name': 'محفظتي (بنك التضامن)',
      'shortName': 'محفظتي',
      'account': '770291452',
      'accountName': 'لَفَّة لخدمات التوصيل',
      'scheme': 'tadhamon://',
      'icon': Icons.account_balance_rounded,
      'badge': 'فوري',
    },
    {
      'id': 'cac',
      'name': 'كاك بنك (السريع)',
      'shortName': 'كاك بنك',
      'account': '770291452',
      'accountName': 'لَفَّة للنقل والتوصيل',
      'scheme': 'cacbank://',
      'icon': Icons.account_balance_rounded,
      'badge': 'فوري',
    },
  ];

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(GetCompanyAccountsEvent());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _senderAccountController.dispose();
    super.dispose();
  }

  void _submitRecharge() {
    final amountText = _amountController.text.trim();
    final refText = _refController.text.trim();

    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      _showLocalError('يرجى إدخال مبلغ شحن صحيح');
      return;
    }

    final double amount = double.parse(amountText);
    if (amount < 500) {
      _showLocalError('الحد الأدنى للشحن هو 500 ريال');
      return;
    }

    if (refText.isEmpty) {
      _showLocalError('يرجى إدخال رقم العملية / رقم السند الصادر من المحفظة');
      return;
    }

    setState(() => _isSubmitting = true);

    final selected = _wallets[_selectedMethodIndex];

    context.read<WalletBloc>().add(
          RechargeWalletEvent(
            amount: amount,
            paymentMethod: selected['id'],
            referenceId: refText,
            senderAccount: _senderAccountController.text.trim().isNotEmpty
                ? _senderAccountController.text.trim()
                : null,
          ),
        );

    Navigator.pop(context);
  }

  void _showLocalError(String msg) {
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

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is CompanyAccountsLoaded && state.accounts.isNotEmpty) {
          setState(() {
            for (final acc in state.accounts) {
              final idx = _wallets.indexWhere((w) => w['id'] == acc['id']);
              if (idx != -1) {
                _wallets[idx]['account'] =
                    acc['account_number'] ?? _wallets[idx]['account'];
                _wallets[idx]['accountName'] =
                    acc['account_name'] ?? _wallets[idx]['accountName'];
              }
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.s20,
          right: AppSpacing.s20,
          top: AppSpacing.s16,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s24,
        ),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: AppSpacing.radiusBottomSheet,
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
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppSpacing.h16,

              // Sheet Title & Security Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'شحن رصيد المحفظة',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: widget.isDark ? AppColors.white : AppColors.gray900,
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
                          'إيداع مباشر وآمن',
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
                'حول المبلغ لحساب لَفَّة عبر محفظتك الإلكترونية وسجل رقم السند لتأكيد الإيداع',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11.5,
                  color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),

              AppSpacing.h16,

              // STEP 1: Amount Selection
              Text(
                '1. حدد مبلغ الشحن (ريال يمني):',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: widget.isDark ? AppColors.gray200 : AppColors.gray800,
                ),
              ),
              AppSpacing.h8,

              // Preset Quick Chips
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
                            ? const Color(0xFF1E2430)
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
                  prefixIcon:
                      const Icon(Icons.payments_outlined, size: 20, color: AppColors.primary500),
                  suffixText: 'ريال يمني',
                  suffixStyle: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),

              AppSpacing.h16,

              // STEP 2: Wallet Selection
              Text(
                '2. اختر محفظتك الإلكترونية:',
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
                          ? const Color(0xFF1E2430)
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
                          onTap: () =>
                              _openWalletApp(selectedWallet['scheme']),
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
                              side: const BorderSide(
                                  color: AppColors.primary500),
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
                        color: widget.isDark
                            ? AppColors.gray400
                            : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.h16,

              // STEP 4: Transfer Details Form
              Text(
                '3. بيانات السند للتأكيد والمطابقة:',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: widget.isDark ? AppColors.gray200 : AppColors.gray800,
                ),
              ),
              AppSpacing.h8,

              // Reference / Voucher ID Field
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),

              AppSpacing.h10,

              // Sender Account / Phone Field
              TextField(
                controller: _senderAccountController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم حسابك أو هاتفك المحول منه (اختياري)',
                  hintText: 'مثال: 770291452',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
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
      ),
    );
  }
}
