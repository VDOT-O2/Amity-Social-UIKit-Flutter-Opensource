import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';
import 'package:amity_uikit_beta_service/view/user/medie_component.dart';
import 'package:flutter/material.dart';

import '../../components/alert_dialog.dart';

class UserFeedVM extends ChangeNotifier {
  MediaType _selectedMediaType = MediaType.photos;
  void doSelectMedieType(MediaType mediaType) {
    _selectedMediaType = mediaType;
   AmityLog.debug(_selectedMediaType.toString());
    notifyListeners();
  }

  MediaType getMediaType() => _selectedMediaType;

  AmityUser? amityUser;
  late AmityUserFollowInfo amityMyFollowInfo = AmityUserFollowInfo();
  late PagingController<AmityPost> _controller;
  var amityPosts = <AmityPost>[];
  late PagingController<AmityPost> _imagePostController;
  final amityImagePosts = <AmityPost>[];
  late PagingController<AmityPost> _videoPostController;
  final amityVideoPosts = <AmityPost>[];
  final scrollcontroller = ScrollController();
  bool loading = false;
  TabController? userFeedTabController;
  void changeTab() {
    notifyListeners();
  }

  Future<void> initUserFeed(
      {AmityUser? amityUser, required String userId}) async {
    _getUser(userId: userId, otherUser: amityUser);
    await listenForUserFeed(userId);
    listenForImageFeed(userId);
    listenForVideoFeed(userId);
  }

  Future<void> _getUser({required String userId, AmityUser? otherUser}) async {
   AmityLog.debug("getUser=> $userId");
    if (userId == AmityCoreClient.getUserId()) {
     AmityLog.debug("isCurrentUser:$userId");
      amityUser = AmityCoreClient.getCurrentUser();
     AmityLog.debug("get user from currentamityUser :$amityUser");
    } else {
     AmityLog.debug("isNotCurrentUser:$userId");
      if (otherUser != null) {
       AmityLog.debug("set instant user object");
        amityUser = otherUser;
      } else {
       AmityLog.debug("get new user object");
        await AmityCoreClient.newUserRepository()
            .getUser(userId)
            .then((AmityUser user) {
         AmityLog.debug("get user success");
          amityUser = user;
        }).onError<AmityException>((error, stackTrace) {
         AmityLog.debug("fail getting user Data");
        });
      }
    }
    amityMyFollowInfo.id = null;
   AmityLog.debug("get following info");
    amityUser!.relationship().getFollowInfo(amityUser!.userId!).then((value) {
      amityMyFollowInfo = value;

      amityMyFollowInfo = value;
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error", message: error.toString());
    });
  }

  Future<void> listenForUserFeed(String userId) async {
    _controller = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getUserFeed(userId)
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_controller.error == null) {
            amityPosts.clear();
            amityPosts.addAll(_controller.loadedItems);

            notifyListeners();
          } else {
            //Error on pagination controller
           AmityLog.debug("Error: listenForUserFeed... with userId = $userId");
           AmityLog.debug("ERROR::${_controller.error.toString()}");
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.fetchNextPage();
    });

    scrollcontroller.addListener(() {
      loadnextpage(scrollcontroller, _controller);
    });
  }

  void listenForImageFeed(String userId) {
    _imagePostController = PagingController(
      pageFuture: (token) => AmitySocialClient.newPostRepository()
          .getPosts()
          .targetUser(userId)
          .types([AmityDataType.IMAGE])
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_imagePostController.error == null) {
            amityImagePosts.clear();
            amityImagePosts.addAll(_imagePostController.loadedItems);

            notifyListeners();
          } else {
            //Error on pagination controller
           AmityLog.debug("Error: listenForUserFeed... with userId = $userId");
           AmityLog.debug("ERROR::${_imagePostController.error.toString()}");
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _imagePostController.fetchNextPage();
    });

    scrollcontroller.addListener(() {
      loadnextpage(scrollcontroller, _imagePostController);
    });
  }

  void listenForVideoFeed(String userId) {
    _videoPostController = PagingController(
      pageFuture: (token) => AmitySocialClient.newPostRepository()
          .getPosts()
          .targetUser(userId)
          .types([AmityDataType.VIDEO])
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_videoPostController.error == null) {
            amityVideoPosts.clear();
            amityVideoPosts.addAll(_videoPostController.loadedItems);

            notifyListeners();
          } else {
            //Error on pagination controller
           AmityLog.debug("Error: listenForUserFeed... with userId = $userId");
           AmityLog.debug("ERROR::${_videoPostController.error.toString()}");
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _videoPostController.fetchNextPage();
    });

    scrollcontroller.addListener(() {
      loadnextpage(scrollcontroller, _videoPostController);
    });
  }

  void loadnextpage(ScrollController scrollController,
      PagingController<AmityPost> pagingController) {
    if ((scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) &&
        pagingController.hasMoreItems) {
      pagingController.fetchNextPage();
    }
  }

  Future<void> editCurrentUserInfo(
      {required String displayName,
      required String description,
      String? avatarFileId}) async {
    if (avatarFileId != null) {
      await AmityCoreClient.getCurrentUser()
          .update()
          .avatarFileId(avatarFileId)
          .description(description)
          .displayName(displayName)
          .update()
          .then((value) =>
              {log("update displayname & description & avatarFileUrl success")})
          .onError((error, stackTrace) async => {
               AmityLog.debug("update displayname & description & avatarFileUrl fail"),
                // await AmityDialog().showAlertErrorDialog(
                //     title: "Error!", message: error.toString())
              });
    } else {
      await AmityCoreClient.getCurrentUser()
          .update()
          .displayName(displayName)
          .description(description)
          .update()
          .then((value) => {log("update displayname & description success")})
          .onError((error, stackTrace) async => {
               AmityLog.debug("update displayname & description fail"),
                // await AmityDialog().showAlertErrorDialog(
                //     title: "Error!", message: error.toString())
              });
    }
  }

  Future<void> followButtonAction(
      AmityUser user, AmityFollowStatus amityFollowStatus) async {
   AmityLog.debug(amityFollowStatus.toString());
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      await sendFollowRequest(user: user);
      initUserFeed(userId: amityUser!.userId!);
      notifyListeners();
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
     AmityLog.debug("withDraw");
      await withdrawFollowRequest(user);
      initUserFeed(userId: amityUser!.userId!);
      notifyListeners();
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      await _getUser(userId: amityUser!.userId!);

     AmityLog.debug("clear post");
      initUserFeed(userId: amityUser!.userId!);
    } else if (amityFollowStatus == AmityFollowStatus.BLOCKED) {
      //do nothing
    } else {
      AmityDialog().showAlertErrorDialog(
          title: "Error!",
          message: "followButtonAction: cant handle amityFollowStatus");
    }
  }

  void deletePost(
      AmityPost post, Function(bool success, String message) callback) async {
    AmitySocialClient.newPostRepository()
        .deletePost(postId: post.postId!)
        .then((value) {
      int postIndex = amityPosts.indexWhere((p) => p.postId == post.postId);
     AmityLog.debug("index:$postIndex");
     AmityLog.debug("amityPosts length before removal: ${amityPosts.length}");
      amityPosts.removeAt(postIndex);
     AmityLog.debug("amityPosts length after removal: ${amityPosts.length}");
      notifyListeners();
     AmityLog.debug("notifyListeners");
      listenForUserFeed(amityUser!.userId!);
      callback(true, "Post deleted successfully.");

      callback(false, "Post not found in the list.");
    }).onError((error, stackTrace) async {
      String errorMessage = error.toString();
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: errorMessage);
      callback(false, errorMessage);
    });
  }

  Future<void> sendFollowRequest({required AmityUser user}) async {
    AmityCoreClient.newUserRepository()
        .relationship()
        .user(user.userId!)
        .follow()
        .then((AmityFollowStatus followStatus) {
      //success
     AmityLog.debug("sendFollowRequest: Success");

      notifyListeners();
    }).onError((error, stackTrace) {
      //handle error
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> withdrawFollowRequest(AmityUser user) async {
    await AmityCoreClient.newUserRepository()
        .relationship()
        .me()
        .unfollow(user.userId!)
        .then((value) {
     AmityLog.debug("withdrawFollowRequest: Success");
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> unfollowUser(AmityUser user) async {
   AmityLog.debug("unfollowUser: userId=${user.userId}");
    await AmityCoreClient.newUserRepository()
        .relationship()
        .unfollow(user.userId!)
        .then((value) {
     AmityLog.debug("unfollowUser: Success");
      amityImagePosts.clear();
      amityPosts.clear();
      amityVideoPosts.clear();
     AmityLog.debug("clear post: $amityImagePosts, $amityPosts, $amityVideoPosts");
      notifyListeners();
      initUserFeed(userId: amityUser!.userId!);
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void blockUser(String userId, Function onCallBack) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .blockUser(userId)
        .then((value) {
     AmityLog.debug(value);
      AmitySuccessDialog.showTimedDialog("Blocked user");
      _getUser(userId: userId);
      notifyListeners();
      // onCallBack();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void unBlockUser(String userId) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .unblockUser(userId)
        .then((value) {
     AmityLog.debug(value);
      AmitySuccessDialog.showTimedDialog("Unblock user");
      _getUser(userId: userId);
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
}
