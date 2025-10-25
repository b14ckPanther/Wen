import 'package:flutter/material.dart';

import 'package:mobile/l10n/app_localizations.dart';

class UpgradePlanSheet extends StatelessWidget {
  const UpgradePlanSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final plans = [
      (
        title: l10n.paymentsStandardPlan,
        price: l10n.paymentsStandardPrice,
        benefits: [
          l10n.paymentsStandardBenefit1,
          l10n.paymentsStandardBenefit2,
          l10n.paymentsStandardBenefit3,
        ],
      ),
      (
        title: l10n.paymentsPremiumPlan,
        price: l10n.paymentsPremiumPrice,
        benefits: [
          l10n.paymentsPremiumBenefit1,
          l10n.paymentsPremiumBenefit2,
          l10n.paymentsPremiumBenefit3,
        ],
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentsUpgradeTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.paymentsUpgradeDescription,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          for (final plan in plans) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          plan.price,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...plan.benefits.map(
                      (benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(benefit)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.paymentsComingSoon)),
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.paymentsCheckoutStub),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
