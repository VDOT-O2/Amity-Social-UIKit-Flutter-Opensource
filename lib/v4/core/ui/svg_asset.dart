import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgAsset extends StatelessWidget {
  final String assetPath;
  final Color? color;
  final double? width;
  final double? height;
  final String package;

  const SvgAsset(
    this.assetPath, {
    super.key,
    this.color,
    this.width,
    this.height,
    this.package = 'amity_uikit_beta_service',
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      package: package,
      width: width,
      height: height,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}