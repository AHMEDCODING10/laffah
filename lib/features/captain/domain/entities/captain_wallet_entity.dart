import 'package:equatable/equatable.dart';
import 'captain_transaction_entity.dart';

class CaptainWalletEntity extends Equatable {
  final double availableBalance;
  final double todayEarnings;
  final double weeklyEarnings;
  final int completedTripsToday;
  final double dailyTarget;
  final double previousWeekEarnings;
  final List<CaptainTransactionEntity> recentTransactions;

  const CaptainWalletEntity({
    required this.availableBalance,
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.completedTripsToday,
    required this.dailyTarget,
    required this.previousWeekEarnings,
    required this.recentTransactions,
  });

  double get targetProgress => (todayEarnings / dailyTarget).clamp(0.0, 1.0);

  double get weekOverWeekGrowth {
    if (previousWeekEarnings == 0) return 100.0;
    return ((weeklyEarnings - previousWeekEarnings) / previousWeekEarnings) *
        100;
  }

  @override
  List<Object?> get props => [
        availableBalance,
        todayEarnings,
        weeklyEarnings,
        completedTripsToday,
        dailyTarget,
        previousWeekEarnings,
        recentTransactions,
      ];
}
