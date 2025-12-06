import 'package:logger/logger.dart';

class AppLogger {
  // Use SimplePrinter to avoid ANSI color codes in device logs
  static final Logger _logger = Logger(printer: SimplePrinter());

  static void i(String message) => _logger.i(message);
  static void d(String message) => _logger.d(message);
  static void w(String message) => _logger.w(message);
  static void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error, stackTrace);
}
