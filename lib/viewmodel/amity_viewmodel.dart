import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';
import 'package:flutter/material.dart';

import '../components/alert_dialog.dart';

class AmityVM extends ChangeNotifier {
  AmityUser? currentamityUser;

  /// Creates a login builder with the shared session handler
  dynamic _createLoginBuilder(String userID) {
    return AmityCoreClient.login(userID, sessionHandler: (AccessTokenRenewal renewal) {
      renewal.renew();
    });
  }

  /// Handles the login response and error cases
  Future<bool> _handleLoginResponse(Future<AmityUser> loginFuture) async {
    return await loginFuture.then((value) async {
      AmityLog.debug("login - success");
      currentamityUser = value;
      notifyListeners();
      return true;
    }).catchError((error, stackTrace) async {
      currentamityUser = null;
      AmityLog.error("login - error", error, stackTrace: stackTrace);
      //        await AmityDialog()
      //            .showAlertErrorDialog(title: "Error!", message: error.toString());
      return false;
    });
  }

  Future<void> login({required String userID, String? displayName, String? authToken}) async {
    AmityLog.debug("login with $userID");

    // Create the base login builder
    var loginBuilder = _createLoginBuilder(userID);

    // Add authToken if provided
    if (authToken != null) {
      AmityLog.debug("authToken is provided");
      loginBuilder = loginBuilder.authToken(authToken);
    } else {
      AmityLog.debug("authToken == null");
    }

    // Add displayName if provided
    if (displayName != null) {
      AmityLog.debug("displayName is provided");
      loginBuilder = loginBuilder.displayName(displayName);
    } else if (authToken != null) {
      AmityLog.debug("displayName is not provided");
    }

    // Submit and handle the response
    await _handleLoginResponse(loginBuilder.submit());
  }

  Future logout() async {
    await AmityCoreClient.logout();
    currentamityUser = null;
    notifyListeners();
  }

  Future<void> refreshCurrentUserData() async {
    if (currentamityUser != null) {
      await AmityCoreClient.newUserRepository().getUser(currentamityUser!.userId!).then((user) {
        currentamityUser = user;
        notifyListeners();
      }).onError((error, stackTrace) async {
        AmityLog.debug(error.toString());
        await AmityDialog().showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
  }

  late Function(AmityPost) onShareButtonPressed;
  void setShareButtonFunction(Function(AmityPost) onShareButtonPressed) {} // Callback function)
}
