import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_app_bar.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../domain/entities/wallet_entity.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/transaction_list_tile.dart';
import '../widgets/wallet_balance_card.dart';

/// WalletPage — يعرض رصيد الراكب الحقيقي مع نظام الشحن الفوري للمحافظ اليمنية
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fire event on global singleton without creating a new BlocProvider that kills it on dispose
    context.read<WalletBloc>().add(GetWalletBalanceEvent());
    return const _WalletView();
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  void _showTopUpBottomSheet(BuildContext parentContext, bool isDark) {
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletRechargeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  AppSpacing.w12,
                  Expanded(
                    child: Text(
                      '${state.message} الرصيد الجديد: ${state.newBalance.toStringAsFixed(0)} ريال',
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
        ),
        bottomNavigationBar: HomeBottomNavBar(isDark: isDark, currentIndex: 2),
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading && state is! WalletBalanceLoaded) {
              return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary500));
            }

            double balance = 0;
            List<TransactionEntity> transactions = [];

            if (state is WalletBalanceLoaded) {
              balance = state.wallet.balance;
              transactions = state.wallet.transactions;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                100,
              ),
              children: [
                WalletBalanceCard(
                  balance: balance,
                  onTopUpPressed: () =>
                      _showTopUpBottomSheet(context, isDark),
                ),
                AppSpacing.h24,
                Text(
                  'آخر المعاملات المالية',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h12,
                if (transactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s24),
                      child: Text(
                        'لا توجد معاملات سابقة حتى الآن',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color:
                              isDark ? AppColors.gray500 : AppColors.gray600,
                        ),
                      ),
                    ),
                  )
                else
                  for (final tx in transactions)
                    TransactionListTile(isDark: isDark, transaction: tx),
              ],
            );
          },
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

  final List<Map<String, dynamic>> _wallets = [
    {
      'id': 'onecash',
      'name': 'ون كاش (OneCash)',
      'account': '777000111',
      'accountName': 'منصة لَفَّة للنقل الذكي',
      'scheme': 'onecash://',
      'icon': Icons.phone_android_rounded,
      'badge': 'فوري',
    },
    {
      'id': 'kuraimi',
      'name': 'الكريمي (حاسب / M-Floos)',
      'account': '3001234567',
      'accountName': 'مؤسسة لَفَّة للخدمات اللوجستية',
      'scheme': 'kuraimi://',
      'icon': Icons.account_balance_rounded,
      'badge': 'شائع جداً',
    },
    {
      'id': 'jawali',
      'name': 'جوالي (WeCash)',
      'account': '770123456',
      'accountName': 'منصة لَفَّة - صنعاء',
      'scheme': 'wecash://',
      'icon': Icons.account_balance_wallet_rounded,
      'badge': 'فوري',
    },
    {
      'id': 'jeeb',
      'name': 'محفظة جيب (اليمن والبحرين)',
      'account': '500987654',
      'accountName': 'شركة لَفَّة المحدودة',
      'scheme': 'jeeb://',
      'icon': Icons.wallet_giftcard_rounded,
      'badge': 'فوري',
    },
    {
      'id': 'tadhamon',
      'name': 'محفظتي (بنك التضامن)',
      'account': '880112233',
      'accountName': 'لَفَّة لخدمات التوصيل',
      'scheme': 'tadhamon://',
      'icon': Icons.account_balance_rounded,
      'badge': 'فوري',
    },
    {
      'id': 'cac',
      'name': 'كاك بنك (السريع)',
      'account': '100456789',
      'accountName': 'لَفَّة للنقل والتوصيل',
      'scheme': 'cacbank://',
      'icon': Icons.account_balance_rounded,
      'badge': 'فوري',
    },
  ];

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
      _showLocalError('يرجى إدخال رقم العملية / رقم الإشعار الصادر من المحفظة');
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
                'يرجى فتح تطبيق المحفظة على هاتفك وإجراء التحويل',
                style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
              ),
              backgroundColor: AppColors.primary500,
            ),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final selectedWallet = _wallets[_selectedMethodIndex];

    return Container(
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSpacing.h16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'شحن المحفظة فورياً',
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
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded,
                          color: AppColors.success, size: 14),
                      Text(
                        ' شحن لحظي',
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
            AppSpacing.h16,
            Text(
              '1. اختر محفظتك الإلكترونية:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: widget.isDark ? AppColors.gray300 : AppColors.gray700,
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
                    label: Text(w['name'].toString().split(' ').first),
                    selected: isSelected,
                    selectedColor: AppColors.primary500,
                    labelStyle: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.gray700,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedMethodIndex = index);
                    },
                  );
                },
              ),
            ),
            AppSpacing.h16,
            // Company Account Details Box
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
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
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded,
                            size: 18, color: AppColors.primary500),
                        tooltip: 'نسخ رقم الحساب',
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: selectedWallet['account']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ رقم الحساب بنجاح',
                                  style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic')),
                              duration: Duration(seconds: 1),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
            Text(
              '2. بيانات التحويل للتأكيد الفوري:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: widget.isDark ? AppColors.gray300 : AppColors.gray700,
              ),
            ),
            AppSpacing.h8,
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'مبلغ الشحن (ريال)',
                      hintText: '1000',
                      prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _refController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'رقم العملية / الإشعار *',
                      hintText: 'مثال: 9841023',
                      prefixIcon: const Icon(Icons.receipt_long_outlined,
                          size: 20, color: AppColors.primary500),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h12,
            TextField(
              controller: _senderAccountController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم حسابك المحول منه (اختياري)',
                hintText: 'رقم هاتفك أو حسابك بالمحفظة',
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            AppSpacing.h20,
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
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_rounded),
                          AppSpacing.w8,
                          Text(
                            'تأكيد وشحن الرصيد فوراً',
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
