import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:flutter/material.dart';

class AmityStoryUploadProgressRow extends StatelessWidget {
  const AmityStoryUploadProgressRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Text(
            "Uploading...",
            style: TextStyle(color: Colors.white , fontSize: 15 , fontFamily: AmityTextStyle.fontFamily , fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
