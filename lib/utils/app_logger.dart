import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
  level: Level.debug,
  filter: ProductionFilter(),
);

class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}
