import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'amity_uikit_toast_events.dart';
part 'amity_uikit_toast_state.dart';

class AmityToastBloc extends Bloc<AmityToastEvent, AmityToastState> {
  AmityToastBloc()
      : super(const AmityToastState(
          message: "",
          style: AmityToastStyle.hidden,
        )) {
    on<AmityToastShort>(
      (event, emit) {
        final nextState = AmityToastState(
          message: event.message,
          style: AmityToastStyle.short,
          icon: event.icon,
          key: UniqueKey(),
          bottomPadding: event.bottomPadding ?? 0.0,
        );
        AmityLog.debug(
            'ToastBloc: received AmityToastShort (icon: ${event.icon}, length: ${event.message.length}, padding: ${event.bottomPadding ?? 0.0}) -> emit short key=${nextState.key}');
        emit(nextState);
      },
    );

    on<AmityToastDismiss>(
      (event, emit) {
        AmityLog.debug('ToastBloc: received AmityToastDismiss -> emit hidden');
        emit(
          const AmityToastState(
            message: "",
            style: AmityToastStyle.hidden,
            key: null,
            bottomPadding: 0.0,
          ),
        );
      },
    );

    on<AmityToastDismissIfLoading>(
      (event, emit) {
        if (state.style == AmityToastStyle.loading) {
          AmityLog.debug('ToastBloc: received AmityToastDismissIfLoading while loading -> emit hidden');
          emit(
            const AmityToastState(
              message: "",
              style: AmityToastStyle.hidden,
              key: null,
              bottomPadding: 0.0,
            ),
          );
        } else {
          AmityLog.debug(
              'ToastBloc: received AmityToastDismissIfLoading while style=${state.style} -> no-op');
        }
      },
    );

    on<AmityToastLoading>((event, emit) {
      final nextState = AmityToastState(
        message: event.message,
        style: AmityToastStyle.loading,
        icon: event.icon,
        key: UniqueKey(),
        bottomPadding: event.bottomPadding ?? 0.0,
      );
      AmityLog.debug(
          'ToastBloc: received AmityToastLoading (icon: ${event.icon}, length: ${event.message.length}, padding: ${event.bottomPadding ?? 0.0}) -> emit loading key=${nextState.key}');
      emit(nextState);
    });
  }
}
