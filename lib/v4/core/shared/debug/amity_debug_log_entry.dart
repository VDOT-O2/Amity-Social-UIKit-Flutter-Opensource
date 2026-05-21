import 'package:equatable/equatable.dart';

enum AmityDebugLogLevel { debug, info, warn, error }

class AmityDebugLogEntry extends Equatable {
  const AmityDebugLogEntry({
    required this.timestamp,
    this.scope = '',
    required this.action,
    required this.message,
    required this.level,
    this.snapshot,
  });

  final DateTime timestamp;
  final String scope;
  final String action;
  final String message;
  final AmityDebugLogLevel level;
  final String? snapshot;

  @override
  List<Object?> get props => [timestamp, scope, action, message, level, snapshot];
}
