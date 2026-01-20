import 'package:flutter/material.dart';

class ValidationError {
  final String message;
  final int? offset;
  final int? length;

  ValidationError(this.message, {this.offset, this.length});
}

class ValidationHelper {
  static const int maxTaskLength = 1000;
  static const int maxListNameLength = 100;
  static const int minListNameLength = 1;
  static const int maxSearchLength = 200;

  static ValidationError? validateTaskText(String text) {
    if (text.trim().isEmpty) {
      return ValidationError('请输入任务描述');
    }

    if (text.length > maxTaskLength) {
      return ValidationError(
        '任务描述不能超过 $maxTaskLength 个字符',
        length: text.length,
      );
    }

    if (text.trim().length < 1) {
      return ValidationError('任务描述不能为空');
    }

    return null;
  }

  static ValidationError? validateListName(String name) {
    if (name.trim().isEmpty) {
      return ValidationError('请输入列表名称');
    }

    if (name.length > maxListNameLength) {
      return ValidationError(
        '列表名称不能超过 $maxListNameLength 个字符',
        length: name.length,
      );
    }

    if (name.trim().length < minListNameLength) {
      return ValidationError('列表名称不能为空');
    }

    return null;
  }

  static ValidationError? validateSearchKeyword(String keyword) {
    if (keyword.length > maxSearchLength) {
      return ValidationError(
        '搜索关键词不能超过 $maxSearchLength 个字符',
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
        return ValidationError('日期不能早于 1900 年');
      }

      if (date.isAfter(DateTime(2100))) {
        return ValidationError('日期不能晚于 2100 年');
      }
    } catch (e) {
      return ValidationError('无效的日期格式');
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入验证失败'),
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
                          Expanded(child: Text(error.message)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  static String? getValidationMessage(ValidationError? error) {
    return error?.message;
  }
}
