import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);
// import 'package:logger/logger.dart';

// class AppLogger {
//   static final Logger _logger = Logger(
//     printer: PrettyPrinter(
//       methodCount: 2, // Limit the stack trace depth
//       errorMethodCount: 5, // For error logs
//       lineLength: 120, // Wrap lines after 120 characters
//       colors: true, // Enable colors in the logs
//       //printEmojis: true, // Emojis for log levels like 🎯
//     ),
//   );

//   // Log methods
//   static void d(String message) => _logger.d(message);
//   static void i(String message) => _logger.i(message);
//   static void w(String message) => _logger.w(message);
//   static void e(String message) => _logger.e(message);
  
// }

// final appLogger = AppLogger();
