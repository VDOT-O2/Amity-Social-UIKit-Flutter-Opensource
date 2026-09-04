import 'dart:io';
import 'dart:typed_data';

import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

// Selecting photos and videos always goes through the platform picker — the
// Android Photo Picker on Android, PHPicker on iOS. Neither needs a runtime
// permission: the user picks the files and the app receives only those.
//
// This is a hard requirement of Google Play's Photo and Video Permissions
// policy: READ_MEDIA_IMAGES / READ_MEDIA_VIDEO are reserved for apps whose core
// function is browsing the whole gallery, which this app's avatar / post /
// chat-attachment flows are not. Do not add a permission request to any picking
// path, and do not reintroduce a custom gallery browser (wechat_assets_picker,
// PhotoManager asset listing) — both require the permissions we must not hold.
class MediaPermissionHandler {
  static bool _androidPhotoPickerConfigured = false;
  static bool _photoManagerPermissionCheckDisabled = false;

  // Route image_picker through the Android Photo Picker (ACTION_PICK_IMAGES,
  // with the Google Play services backport below Android 13) instead of the
  // legacy gallery intent, which needs READ_MEDIA_*. ImagePickerPlatform.instance
  // is a singleton, so this only has to happen once.
  static void enableAndroidPhotoPicker() {
    if (_androidPhotoPickerConfigured) return;
    final platform = ImagePickerPlatform.instance;
    if (platform is ImagePickerAndroid) {
      platform.useAndroidPhotoPicker = true;
      _androidPhotoPickerConfigured = true;
    }
  }

  // Permission gate for *writing* to the shared gallery. Reading never needs
  // one. Android 10 (API 29) and up insert through MediaStore without any
  // permission; only API 28 still needs WRITE_EXTERNAL_STORAGE, which the
  // manifest declares with maxSdkVersion="28".
  Future<bool> handleMediaPermissions() async {
    if (!Platform.isAndroid) return true;
    if (await _androidSdkInt() >= 29) return true;

    final status = await Permission.storage.status;
    if (status.isDenied) {
      final result = await Permission.storage.request();
      if (!result.isGranted) {
        await _showPermissionDialog();
      }
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDialog();
      return false;
    }
    return status.isGranted;
  }

  Future<void> _showPermissionDialog() async {
    final BuildContext? context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    final appName = await _getAppName();

    PermissionAlertV4Dialog().show(
      context: context,
      title: 'Allow access to your photos and videos',
      detailText:
          'This allows $appName to save photos and videos to this device.',
      bottomButtonText: 'OK',
      topButtonText: 'Open settings',
      onTopButtonAction: () {
        openAppSettings();
      },
    );
  }

  Future<String> _getAppName() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.appName;
    } catch (e) {
      return 'this app';
    }
  }

  Future<int> _androidSdkInt() async {
    if (!Platform.isAndroid) return 0;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

  // Pick a single image through the platform photo picker.
  Future<XFile?> pickImage() async {
    enableAndroidPhotoPicker();
    try {
      return await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (e) {
      AmityLog.debug('Error picking image: $e');
      return null;
    }
  }

  // Pick a single video through the platform photo picker.
  Future<XFile?> pickVideo() async {
    enableAndroidPhotoPicker();
    try {
      return await ImagePicker().pickVideo(source: ImageSource.gallery);
    } catch (e) {
      AmityLog.debug('Error picking video: $e');
      return null;
    }
  }

  // Pick several images and/or videos in one pass through the platform photo
  // picker.
  Future<List<XFile>> pickImageAndVideo({int limit = 10}) async {
    enableAndroidPhotoPicker();
    try {
      // image_picker rejects a limit below 2; a single-item selection is just
      // an unbounded pick the caller trims.
      return await ImagePicker().pickMultipleMedia(
        limit: limit >= 2 ? limit : null,
      );
    } catch (e) {
      AmityLog.debug('Error picking media: $e');
      return [];
    }
  }

  // photo_manager's editor otherwise asks for the gallery read permissions this
  // app deliberately does not declare. Saving does not need them.
  void _ignorePhotoManagerPermissionCheck() {
    if (_photoManagerPermissionCheckDisabled) return;
    PhotoManager.setIgnorePermissionCheck(true);
    _photoManagerPermissionCheckDisabled = true;
  }

  // Save media to gallery
  Future<bool> saveVideoToGallery(String filePath, String? fileName) async {
    if (await handleMediaPermissions()) {
      try {
        _ignorePhotoManagerPermissionCheck();
        await PhotoManager.editor.saveVideo(
          File(filePath),
          title: fileName ?? 'video_${DateTime.now().millisecondsSinceEpoch}',
        );
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> saveImageToGallery(Uint8List imageData, String? fileName) async {
    if (await handleMediaPermissions()) {
      try {
        _ignorePhotoManagerPermissionCheck();
        await PhotoManager.editor.saveImage(
          imageData,
          filename:
              fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> downloadAndSaveVideo(String url) async {
    Dio dio = Dio();
    final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    try {
      // Get the application documents directory
      Directory appDocDir = await getApplicationCacheDirectory();

      // Create a file path with the filename
      String filePath = '${appDocDir.path}/$fileName';

      // Start downloading the video
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (int received, int total) {},
      );

      // Save the video to gallery
      await saveVideoToGallery(filePath, fileName);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> downloadAndSaveImage(String url) async {
    Dio dio = Dio();
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final Uint8List imageBytes = Uint8List.fromList(response.data);

      // Save the video to gallery
      await saveImageToGallery(imageBytes, fileName);
      return true;
    } catch (e) {
      return false;
    }
  }
}
