import 'package:flutter/material.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          ListTileBottomWidget(
            title: "Operações",
          ),
          ListTileBottomWidget(
            title: "Transportadoras",
          ),
          ListTileBottomWidget(
            title: "Administrativo",
          ),
        ],
      ),
    );
  }
}

class ListTileBottomWidget extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final TextStyle? textStyle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  const ListTileBottomWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      onTap: () => onTap != null ? onTap!() : null,
      child: Column(
        children: [
          ListTile(
            leading: leading,
            trailing: trailing,
            title: Text(
              title,
              style: textStyle ??
                  AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: subtitle,
          ),
          const Divider()
        ],
      ),
    );
  }
}
