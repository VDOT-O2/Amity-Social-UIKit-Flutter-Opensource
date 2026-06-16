import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityTopSearchBarComponent extends NewBaseComponent {
  final void Function(String)? onTextChanged;
  final TextEditingController textcontroller;
  final String hintText;
  final bool showCancelButton;
  final FocusNode? focusNode;

  AmityTopSearchBarComponent({
    Key? key,
    String? pageId,
    required this.textcontroller,
    this.hintText = '',
    this.onTextChanged,
    this.showCancelButton = true,
    this.focusNode,
  }) : super(key: key, pageId: pageId, componentId: 'top_search_bar');

  @override
  Widget buildComponent(BuildContext context) {
    const borderRadius = 24.0;

    return ListenableBuilder(
      listenable: Listenable.merge([textcontroller, if (focusNode != null) focusNode!]),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textcontroller,
                  focusNode: focusNode,
                  style: TextStyle(
                    color: theme.baseColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: (focusNode?.hasFocus ?? false) ? theme.textFieldBackgroundFocused : theme.textFieldBackground,
                    prefixIcon: Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.only(top: 12, bottom: 12, right: 8, left: 12),
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_navigation_search.svg',
                        package: 'amity_uikit_beta_service',
                        colorFilter: ColorFilter.mode(
                          theme.textSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: theme.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.24,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    focusColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide(
                        color: theme.border,
                        width: 1,
                      ),
                    ),
                    suffixIconColor: theme.baseColorShade3,
                    suffixIcon: textcontroller.text.isNotEmpty
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: theme.baseColorShade3,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              IconButton(
                                icon: SvgPicture.asset(
                                  'assets/Icons/amity_ic_close_button.svg',
                                  package: 'amity_uikit_beta_service',
                                  colorFilter: ColorFilter.mode(
                                    theme.baseColorShade4,
                                    BlendMode.srcIn,
                                  ),
                                  width: 17,
                                  height: 17,
                                ),
                                onPressed: () {
                                  textcontroller.clear();
                                  onTextChanged?.call('');
                                },
                              )
                            ],
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    onTextChanged?.call(value);
                  },
                ),
              ),
              if (showCancelButton)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      context.l10n.general_cancel,
                      style: AmityTextStyle.body(theme.primaryColor),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}
