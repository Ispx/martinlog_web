import 'package:flutter/material.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';

class LinearProgressIndicatorWidget extends StatelessWidget {
  const LinearProgressIndicatorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LinearProgressIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: context.appTheme.secondColor,
      ),
    );
  }
}
