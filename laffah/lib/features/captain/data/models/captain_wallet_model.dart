import '../../domain/entities/captain_wallet_entity.dart';
import 'captain_transaction_model.dart';

class CaptainWalletModel extends CaptainWalletEntity {
  const CaptainWalletModel({
    required super.availableBalance,
    required super.todayEarnings,
    required super.weeklyEarnings,
    required super.completedTripsToday,
    required super.dailyTarget,
    required super.previousWeekEarnings,
    required super.recentTransactions,
  });

  factory CaptainWalletModel.fromJson(Map<String, dynamic> json) {
    return CaptainWalletModel(
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ??
          (json['balance'] as num?)?.toDouble() ??
          0.0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ??
          (json['today_earnings'] as num?)?.toDouble() ??
          0.0,
      weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ??
          (json['weekly_earnings'] as num?)?.toDouble() ??
          0.0,
      completedTripsToday: json['completedTripsToday'] as int? ??
          json['completed_trips_today'] as int? ??
          0,
      dailyTarget: (json['dailyTarget'] as num?)?.toDouble() ??
          (json['daily_target'] as num?)?.toDouble() ??
          5000.0,
      previousWeekEarnings:
          (json['previousWeekEarnings'] as num?)?.toDouble() ??
              (json['previous_week_earnings'] as num?)?.toDouble() ??
              0.0,
      recentTransactions: ((json['recentTransactions'] ??
                  json['recent_transactions'] ??
                  json['transactions']) as List<dynamic>?)
              ?.map((e) =>
                  CaptainTransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
