import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';

final _logger = Logger('main');

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      if (kReleaseMode) {
        await _initializeRemoteLogging();
      }

      FlutterError.onError = (errorDetails) {
        _logger.severe(
            'Flutter framework caught an unhandled error (or exception) and called FlutterError.onError: ${errorDetails.summary}',
            errorDetails.exception,
            errorDetails.stack);
      };

      <String>[].removeAt(1100);

      runApp(const MyApp());
    },
    (error, stackTrace) {
      _logger.severe('Unhandled error (or exception) caught in root zone.', error, stackTrace);
    },
  );
}

Future<void> _initializeRemoteLogging() async {
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = 'my-dsn'
        ..addIntegration(LoggingIntegration())
        ..release = 'my-release'
        ..dist = '5'
        ..beforeSend = (event, hint) {
          final loggerName = event.logger;
          if (loggerName != null) {
            event = event.copyWith(
              fingerprint: [
                SentryEvent.defaultFingerprint,
                loggerName,
              ],
            );
          }
          return event;
        };
    },
  );

  Sentry.configureScope((scope) => scope.setTag('system.baseUrl', Uri.base.origin));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MaterialApp(
        title: 'minimal-example',
        home: Scaffold(body: Center(child: Text('Test'))),
      ),
    );
  }
}
