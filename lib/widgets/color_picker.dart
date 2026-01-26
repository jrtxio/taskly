import 'package:flutter/material.dart';
import 'package:taskly/l10n/app_localizations.dart';

class ColorPicker extends StatelessWidget {
  final Color? selectedColor;
  final Function(Color) onColorSelected;
  final VoidCallback? onClear;

  const ColorPicker({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
    this.onClear,
  });

  static const List<Color> presetColors = [
    Color(0xFF007AFF), // Blue
    Color(0xFFFF3B30), // Red
    Color(0xFFFF9500), // Orange
    Color(0xFFFFCC00), // Yellow
    Color(0xFF4CD964), // Green
    Color(0xFF5AC8FA), // Light Blue
    Color(0xFF5856D6), // Purple
    Color(0xFFFF2D55), // Pink
    Color(0xFF8E8E93), // Gray
    Color(0xFFC7C7CC), // Light Gray
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dialogSelectColor,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedColor != null)
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
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: presetColors.map((color) {
                final isSelected = selectedColor == color;
                print('DEBUG: ColorPicker - color: $color, selectedColor: $selectedColor, isSelected: $isSelected');
                return GestureDetector(
                  onTap: () {
                    print('DEBUG: ColorPicker - onTap - calling onColorSelected with: $color');
                    onColorSelected(color);
                    print('DEBUG: ColorPicker - onTap - onColorSelected called (will pop dialog)');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: Colors.black.withOpacity(0.3),
                              width: 3,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.dialogCancel),
            ),
          ],
        ),
      ),
    );
  }

  static Future<Color?> show(BuildContext context, {Color? selectedColor}) {
    return showDialog<Color>(
      context: context,
      builder: (context) => ColorPicker(
        selectedColor: selectedColor,
        onColorSelected: (color) => Navigator.of(context).pop(color),
        onClear: () => Navigator.of(context).pop(null),
      ),
    );
  }
}
