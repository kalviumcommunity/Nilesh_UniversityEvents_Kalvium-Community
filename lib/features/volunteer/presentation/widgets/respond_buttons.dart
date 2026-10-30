import 'package:flutter/material.dart';

/// Confirm / Decline buttons. A button is disabled when its callback is
/// null or while [isSubmitting]. The response logic itself is wired in
/// Step 4; until then the screen passes no callbacks.
class RespondButtons extends StatelessWidget {
  const RespondButtons({
    super.key,
    this.onConfirm,
    this.onDecline,
    this.isSubmitting = false,
  });

  final VoidCallback? onConfirm;
  final VoidCallback? onDecline;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onDecline,
            style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
            child: const Text('Decline'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: isSubmitting ? null : onConfirm,
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm'),
          ),
        ),
      ],
    );
  }
}
