import 'package:flutter/material.dart';
import '../../core/network/network_info.dart';
import '../../core/di/injection_container.dart';
import '../../core/theme/app_colors.dart';

class OfflineWarningWrapper extends StatelessWidget {
  final Widget child;

  const OfflineWarningWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        StreamBuilder<bool>(
          stream: sl<NetworkInfo>().isConnectedStream,
          initialData: true,
          builder: (context, snapshot) {
            final isConnected = snapshot.data ?? true;
            if (isConnected) return const SizedBox.shrink();

            return Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
