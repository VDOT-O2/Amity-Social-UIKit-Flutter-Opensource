import 'dart:async';

import 'package:amity_uikit_beta_service/v4/core/shared/debug/amity_debug_log_entry.dart';

class AmityDebugLogController {
  AmityDebugLogController({this.maxHistory = 100});

  final int maxHistory;
  final List<AmityDebugLogEntry> _history = [];
  final StreamController<List<AmityDebugLogEntry>> _historyController =
      StreamController<List<AmityDebugLogEntry>>.broadcast();

  List<AmityDebugLogEntry> get history => List<AmityDebugLogEntry>.unmodifiable(_history);

  Stream<List<AmityDebugLogEntry>> get historyStream => _historyController.stream;

  void addEntry({
    String scope = '',
    required String action,
    required String message,
    AmityDebugLogLevel level = AmityDebugLogLevel.debug,
    String? snapshot,
  }) {
    _history.add(
      AmityDebugLogEntry(
        timestamp: DateTime.now(),
        scope: scope.trim(),
        action: action,
        message: message,
        level: level,
        snapshot: snapshot,
      ),
    );

    if (_history.length > maxHistory) {
      _history.removeRange(0, _history.length - maxHistory);
    }

    if (!_historyController.isClosed) {
      _historyController.add(history);
    }
  }

  void clear() {
    _history.clear();
    if (!_historyController.isClosed) {
      _historyController.add(history);
    }
  }

  void dispose() {
    _historyController.close();
  }
}
