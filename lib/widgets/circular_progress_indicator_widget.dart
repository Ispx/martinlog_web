import 'package:flutter/material.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  const CircularProgressIndicatorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: context.appTheme.secondColor,
      ),
    );
  }
}
