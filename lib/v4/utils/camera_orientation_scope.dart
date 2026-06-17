import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraOrientationScope extends StatefulWidget {
  final Widget child;
  const CameraOrientationScope({
    super.key,
    required this.child,
  });
  @override
  State<CameraOrientationScope> createState() =>
      _StoryCameraOrientationScopeState();
}
class _StoryCameraOrientationScopeState
    extends State<CameraOrientationScope> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}