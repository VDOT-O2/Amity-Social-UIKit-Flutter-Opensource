import 'package:equatable/equatable.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log_level.dart';

class AmityDebugLogEntry extends Equatable {
  const AmityDebugLogEntry({
    required this.timestamp,
    required this.action,
    required this.message,
    required this.level,
    this.scope = '',
    this.snapshot,
  });

  final DateTime timestamp;
  final String scope;
  final String action;
  final String message;
  final AmityLogLevel level;
  final String? snapshot;

  @override
  List<Object?> get props => [timestamp, scope, action, message, level, snapshot];
}
