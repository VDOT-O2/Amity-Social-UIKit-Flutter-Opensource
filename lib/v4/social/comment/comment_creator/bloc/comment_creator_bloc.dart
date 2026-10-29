import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/error_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';

part 'comment_creator_events.dart';

part 'comment_creator_state.dart';

class CommentCreatorBloc
    extends Bloc<CommentCreatorEvent, CommentCreatorState> {
  final AmityComment? replyTo;

  CommentCreatorBloc({
    required this.replyTo,
  }) : super(CommentCreatorState(text: "", replyTo: replyTo)) {
    on<CommentCreatorTextChage>((event, emit) {
      emit(state.copyWith(text: event.text));
    });

    on<CommentCreatorCreated>((event, emit) async {
      final replyTo = state.replyTo?.commentId;
      emit(const CommentCreatorState(text: "", replyTo: null));

      final mentionMetadataList = event.mentionMetadataList;
      final mentionUserIds = event.mentionUserIds;
      final mentionMetadataJson =
          AmityMentionMetadataCreator(mentionMetadataList).create();

      if (replyTo != null) {
        try {
          if (event.referenceType == AmityCommentReferenceType.POST) {
            AmitySocialClient.newCommentRepository()
                .createComment()
                .post(event.referenceId)
                .parentId(replyTo)
                .create()
                .text(event.text)
                .mentionUsers(mentionUserIds)
                .metadata(mentionMetadataJson)
                .send();
          } else if (event.referenceType == AmityCommentReferenceType.STORY) {
            await AmitySocialClient.newCommentRepository()
                .createComment()
                .story(event.referenceId)
                .parentId(replyTo)
                .create()
                .text(event.text)
                .mentionUsers(mentionUserIds)
                .metadata(mentionMetadataJson)
                .send();
          }
        } catch (error) {
          if (error != null && error is AmityException) {
            if (error.code ==
                error.getErrorCode(AmityErrorCode.BAN_WORD_FOUND)) {
              event.toastBloc.add(AmityToastShort(
                  message: event.context.l10n.comment_create_error_ban_word));
            }
            if (error.code ==
                error.getErrorCode(AmityErrorCode.TARGET_NOT_FOUND)) {
              if (error.message.contains("Story")) {
                event.toastBloc.add(AmityToastShort(
                    message:
                        event.context.l10n.comment_create_error_story_deleted));
              }
            }
          }
        }
      } else {
        try {
          if (event.referenceType == AmityCommentReferenceType.POST) {
            await AmitySocialClient.newCommentRepository()
                .createComment()
                .post(event.referenceId)
                .create()
                .text(event.text)
                .mentionUsers(mentionUserIds)
                .metadata(mentionMetadataJson)
                .send();
          } else if (event.referenceType == AmityCommentReferenceType.STORY) {
            await AmitySocialClient.newCommentRepository()
                .createComment()
                .story(event.referenceId)
                .create()
                .text(event.text)
                .mentionUsers(mentionUserIds)
                .metadata(mentionMetadataJson)
                .send();
          }
        } catch (error) {
          if (error != null && error is AmityException) {
            if (error.code ==
                error.getErrorCode(AmityErrorCode.BAN_WORD_FOUND)) {
              event.toastBloc.add(AmityToastShort(
                  message: event.context.l10n.comment_create_error_ban_word));
            }
            if (error.code ==
                error.getErrorCode(AmityErrorCode.TARGET_NOT_FOUND)) {
              if (error.message.contains("Story")) {
                event.toastBloc.add(AmityToastShort(
                    message:
                        event.context.l10n.comment_create_error_story_deleted));
              }
            }
          }
        }
      }
    });
  }
}
