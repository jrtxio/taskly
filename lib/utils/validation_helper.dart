import 'package:flutter/material.dart';
import 'package:taskly/l10n/app_localizations.dart';

class ValidationError {
  final String Function(AppLocalizations) getMessage;
  final String fallbackMessage;
  final int? offset;
  final int? length;

  ValidationError(
    this.getMessage, {
    required this.fallbackMessage,
    this.offset,
    this.length,
  });

  String get message => fallbackMessage;
}

class ValidationHelper {
  static const int maxTaskLength = 1000;
  static const int maxListNameLength = 100;
  static const int minListNameLength = 1;
  static const int maxSearchLength = 200;

  static ValidationError? validateTaskText(String text) {
    if (text.trim().isEmpty) {
      return ValidationError(
        (l10n) => l10n.errorEnterTaskDesc,
        fallbackMessage: 'Please enter task description',
      );
    }

    if (text.length > maxTaskLength) {
      return ValidationError(
        (l10n) => l10n.errorTaskDescTooLong(maxTaskLength),
        fallbackMessage: 'Task description cannot exceed $maxTaskLength characters',
        length: text.length,
      );
    }

    if (text.trim().length < 1) {
      return ValidationError(
        (l10n) => l10n.errorEnterTaskDesc,
        fallbackMessage: 'Please enter task description',
      );
    }

    return null;
  }

  static ValidationError? validateListName(String name) {
    if (name.trim().isEmpty) {
      return ValidationError(
        (l10n) => l10n.errorEnterListName,
        fallbackMessage: 'Please enter list name',
      );
    }

    if (name.length > maxListNameLength) {
      return ValidationError(
        (l10n) => l10n.errorListNameTooLong(maxListNameLength),
        fallbackMessage: 'List name cannot exceed $maxListNameLength characters',
        length: name.length,
      );
    }

    if (name.trim().length < minListNameLength) {
      return ValidationError(
        (l10n) => l10n.errorEnterListName,
        fallbackMessage: 'Please enter list name',
      );
    }

    return null;
  }

  static ValidationError? validateSearchKeyword(String keyword) {
    if (keyword.length > maxSearchLength) {
      return ValidationError(
        (l10n) => l10n.errorSearchKeywordTooLong(maxSearchLength),
        fallbackMessage: 'Search keyword cannot exceed $maxSearchLength characters',
        length: keyword.length,
      );
    }

    return null;
  }

  static ValidationError? validateDueDate(String? dueDate) {
    if (dueDate == null || dueDate!.isEmpty) {
      return null;
    }

    try {
      final date = DateTime.parse(dueDate!);
      if (date.isBefore(DateTime(1900))) {
        return ValidationError(
          (l10n) => l10n.errorDateTooEarly,
          fallbackMessage: 'Date cannot be earlier than 1900',
        );
      }

      if (date.isAfter(DateTime(2100))) {
        return ValidationError(
          (l10n) => l10n.errorDateTooLate,
          fallbackMessage: 'Date cannot be later than 2100',
        );
      }
    } catch (e) {
      return ValidationError(
        (l10n) => l10n.errorInvalidDateFormat,
        fallbackMessage: 'Invalid date format',
      );
    }

    return null;
  }

  static List<ValidationError> validateAll({
    String? taskText,
    String? listName,
    String? searchKeyword,
    String? dueDate,
  }) {
    final errors = <ValidationError>[];

    if (taskText != null) {
      final error = validateTaskText(taskText);
      if (error != null) errors.add(error);
    }

    if (listName != null) {
      final error = validateListName(listName);
      if (error != null) errors.add(error);
    }

    if (searchKeyword != null) {
      final error = validateSearchKeyword(searchKeyword);
      if (error != null) errors.add(error);
    }

    if (dueDate != null) {
      final error = validateDueDate(dueDate);
      if (error != null) errors.add(error);
    }

    return errors;
  }

  static void showValidationErrors(BuildContext context, List<ValidationError> errors) {
    if (errors.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogValidationFailed),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors
                .map((error) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(error.getMessage(l10n))),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogConfirm),
          ),
        ],
      ),
    );
  }

  static String? getValidationMessage(ValidationError? error, AppLocalizations l10n) {
    return error?.getMessage(l10n);
  }
}
