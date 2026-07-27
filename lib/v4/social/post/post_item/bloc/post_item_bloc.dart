import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'post_item_events.dart';
part 'post_item_state.dart';

class PostItemBloc extends Bloc<PostItemEvent, PostItemState> {
  AmityPost post;
  BuildContext context;

  PostItemBloc(this.context, this.post) : super(PostItemState(post: post)) {
    on<PostItemLoading>((event, emit) async {
      var post =
          await AmitySocialClient.newPostRepository().getPost(event.postId);
      emit(state.copyWith(post: post));
    });

    on<PostItemReacted>((event, emit) async {
      emit(state.copyWith(isReacting: false));
    });

    on<AddReactionToPost>((event, emit) async {
      final post = state.post;
      final previousReactionCount = post.reactionCount;
      final previousMyReactions = post.myReactions?.toList();

      _applyOptimisticReaction(post, event.reactionType, isAdding: true);
      emit(state.copyWith(post: post, isReacting: true));

      try {
        await _syncReaction(
          post: post,
          reactionType: event.reactionType,
          isAdding: true,
          previousMyReactions: previousMyReactions,
        );
      } catch (_) {
        _restoreOptimisticReaction(
          post: post,
          previousReactionCount: previousReactionCount,
          previousMyReactions: previousMyReactions,
        );
      }

      emit(state.copyWith(post: post, isReacting: false));
    });

    on<RemoveReactionToPost>((event, emit) async {
      final post = state.post;
      final previousReactionCount = post.reactionCount;
      final previousMyReactions = post.myReactions?.toList();

      _applyOptimisticReaction(post, event.reactionType, isAdding: false);
      emit(state.copyWith(post: post, isReacting: true));

      try {
        await _syncReaction(
          post: post,
          reactionType: event.reactionType,
          isAdding: false,
          previousMyReactions: previousMyReactions,
        );
      } catch (_) {
        _restoreOptimisticReaction(
          post: post,
          previousReactionCount: previousReactionCount,
          previousMyReactions: previousMyReactions,
        );
      }

      emit(state.copyWith(post: post, isReacting: false));
    });

    on<PostItemFlag>((event, emit) async {
      final flag = await event.post.report().flag();
      if (flag) {
        event.toastBloc.add(AmityToastShort(
            message: context.l10n.post_reported, icon: AmityToastIcon.success));
        var updatedPost = await AmitySocialClient.newPostRepository()
            .getPost(event.post.postId!);
        emit(state.copyWith(post: updatedPost));
      }
    });

    on<PostItemUnFlag>((event, emit) async {
      final flag = await event.post.report().unflag();
      if (flag) {
        event.toastBloc.add(AmityToastShort(
            message: context.l10n.post_unreported,
            icon: AmityToastIcon.success));
        var updatedPost = await AmitySocialClient.newPostRepository()
            .getPost(event.post.postId!);
        emit(state.copyWith(post: updatedPost));
      }
    });

    on<PostItemDelete>((event, emit) async {
      event.action?.onPostDeleted(event.post);
      var updatedPost = event.post;
      updatedPost.isDeleted = true;
      emit(state.copyWith(post: updatedPost));
    });

    on<PostItemLoaded>((event, emit) async {
      AmityPost post = event.post;
      emit(state.copyWith(post: post));
    });
  }

  void _applyOptimisticReaction(
    AmityPost post,
    String reactionType, {
    required bool isAdding,
  }) {
    final reactions = List<String>.from(post.myReactions ?? const []);
    var reactionCount = post.reactionCount ?? 0;

    if (isAdding) {
      if (reactions.isNotEmpty) {
        reactionCount = reactionCount > 0 ? reactionCount - 1 : 0;
      }
      reactions
        ..clear()
        ..add(reactionType);
      reactionCount++;
    } else {
      if (reactions.isNotEmpty) {
        reactionCount = reactionCount > 0 ? reactionCount - 1 : 0;
      }
      reactions.clear();
    }

    post.myReactions = reactions;
    post.reactionCount = reactionCount;
  }

  Future<void> _syncReaction({
    required AmityPost post,
    required String reactionType,
    required bool isAdding,
    required List<String>? previousMyReactions,
  }) async {
    if (isAdding) {
      if (previousMyReactions?.isNotEmpty ?? false) {
        await post.react().removeReaction(previousMyReactions!.first);
      }
      await post.react().addReaction(reactionType);
      return;
    }

    if (previousMyReactions?.isNotEmpty ?? false) {
      await post.react().removeReaction(previousMyReactions!.first);
    }
  }

  void _restoreOptimisticReaction({
    required AmityPost post,
    required int? previousReactionCount,
    required List<String>? previousMyReactions,
  }) {
    post.reactionCount = previousReactionCount;
    post.myReactions = previousMyReactions?.toList();
  }
}
