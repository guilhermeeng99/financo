import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// First-run experience for the chat. The robot avatar establishes the
/// brand, and the four suggestion pills double as both an onboarding nudge
/// (showing what the AI can do) and a one-tap shortcut to pre-fill the input.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({required this.onSuggestionTap, super.key});

  /// Fired when a suggestion pill is tapped — the page sets the message
  /// input controller's text. Suggestion is intentionally NOT auto-sent so
  /// the user can review and edit before committing.
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final suggestions = [
      t.chat.suggestion1,
      t.chat.suggestion2,
      t.chat.suggestion3,
      t.chat.suggestion4,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const ChatAvatar(size: 80),
              const SizedBox(height: 24),
              Text(
                t.chat.welcomeTitle,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: colors.onBackground,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t.chat.welcomeBody,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onBackgroundLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.chat.tryAsking.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onBackgroundLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              ...suggestions.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SuggestionPill(
                    label: s,
                    onTap: () => onSuggestionTap(s),
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

class _SuggestionPill extends StatelessWidget {
  const _SuggestionPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.24),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: colors.onBackgroundLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
