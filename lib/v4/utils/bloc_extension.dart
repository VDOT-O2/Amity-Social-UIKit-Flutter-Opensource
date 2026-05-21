import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/debug/amity_debug_log_controller.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log_level.dart';

extension BlocExtension<Event,State> on Bloc<Event,State> {
  void addEvent(Event event) {
    if(!isClosed) {
      add(event);
    }
  }

  void addDebugLog({
    required AmityDebugLogController controller,
    required String action,
    required String message,
    String scope = '',
    AmityLogLevel level = AmityLogLevel.debug,
    String? snapshot,
  }) {
    controller.addEntry(
      scope: scope,
      action: action,
      message: message,
      level: level,
      snapshot: snapshot,
    );
  }
}