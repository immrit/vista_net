import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

class TicketTimelineWidget extends StatelessWidget {
  final String
  currentStatus; // 'open', 'in_progress', 'waiting_for_payment', 'resolved', 'closed'

  const TicketTimelineWidget({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    // Define steps
    // Mapping status to step index
    // 0: Submitted (open)
    // 1: Processing (in_progress)
    // 2: Done (resolved/closed)

    // Note: Waiting for payment is a specific state, usually part of processing or a separate hold.
    // For now let's use a 3-step or 4-step process.
    // Let's assume:
    // 1. Sent (Registered) - Always active if ticket exists
    // 2. Processing (Assigned/In Progress)
    // 3. Result (Resolved/Closed)

    int currentStep = 0;
    switch (currentStatus.toLowerCase()) {
      case 'open':
        currentStep =
            1; // Passed step 1 (Sent), waiting at 2? Or just finished 1.
        break;
      case 'in_progress':
        currentStep = 2; // Processing
        break;
      case 'waiting_for_payment': // If exists
        currentStep = 2;
        break;
      case 'resolved':
      case 'closed':
        currentStep = 3;
        break;
      default:
        currentStep = 1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          _buildStep(context, 1, 'ثبت شده', currentStep >= 1, currentStep == 1),
          _buildConnector(currentStep >= 2),
          _buildStep(
            context,
            2,
            'در حال بررسی',
            currentStep >= 2,
            currentStep == 2,
          ),
          _buildConnector(currentStep >= 3),
          _buildStep(
            context,
            3,
            'پایان یافته',
            currentStep >= 3,
            currentStep == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    int step,
    String label,
    bool isActive,
    bool isCurrent,
  ) {
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.snappPrimary : Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppTheme.snappPrimary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '$step',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.snappDark : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppTheme.snappPrimary : Colors.grey[200],
        margin: const EdgeInsets.only(bottom: 20), // Align with circles
      ),
    );
  }
}
