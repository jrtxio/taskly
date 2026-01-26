import 'package:flutter/material.dart';
import 'package:taskly/l10n/app_localizations.dart';

class EmojiPicker extends StatelessWidget {
  final String? selectedEmoji;
  final Function(String) onEmojiSelected;
  final VoidCallback? onClear;

  const EmojiPicker({
    super.key,
    this.selectedEmoji,
    required this.onEmojiSelected,
    this.onClear,
  });

  static const List<List<String>> emojiCategories = [
    [
      '📋',
      '📝',
      '✅',
      '🎯',
      '💡',
      '📌',
      '🔖',
      '📎',
    ],
    [
      '🏠',
      '🏢',
      '💼',
      '📱',
      '💻',
      '🎨',
      '📚',
      '🎓',
    ],
    [
      '❤️',
      '⭐',
      '🌟',
      '🔥',
      '💪',
      '🎉',
      '🎊',
      '🏆',
    ],
    [
      '🛒',
      '🛍️',
      '🍔',
      '☕',
      '🍕',
      '🥤',
      '🎮',
      '🎬',
    ],
    [
      '✈️',
      '🚗',
      '🚴',
      '🏃',
      '⚽',
      '🏀',
      '🎸',
      '🎵',
    ],
    [
      '💰',
      '💳',
      '📊',
      '📈',
      '💼',
      '📧',
      '📅',
      '⏰',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dialogSelectIcon,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedEmoji != null)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear, size: 16),
                    label: Text(l10n.dialogClear),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: emojiCategories.length,
                itemBuilder: (context, categoryIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: emojiCategories[categoryIndex].map((emoji) {
                        final isSelected = emoji == selectedEmoji;
                        return GestureDetector(
                          onTap: () {
                            onEmojiSelected(emoji);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: Colors.blue, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.dialogCancel),
            ),
          ],
        ),
      ),
    );
  }

  static Future<String?> show(BuildContext context, {String? selectedEmoji}) {
    return showDialog<String>(
      context: context,
      builder: (context) => EmojiPicker(
        selectedEmoji: selectedEmoji,
        onEmojiSelected: (emoji) => Navigator.of(context).pop(emoji),
        onClear: () => Navigator.of(context).pop(null),
      ),
    );
  }
}
