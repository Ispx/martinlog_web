import 'package:flutter/material.dart';
import 'package:martinlog_web/core/consts/routes.dart';
import 'package:martinlog_web/functions/futures.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/widgets/circular_progress_indicator_widget.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: FutureBuilder(
            future: Future.any([]),
            builder: (context, snap) {
              if (snap.hasError) {
                return Text(snap.error.toString());
              }
              if (!snap.hasData) {
                return CircularProgressIndicatorWidget();
              }
              if (snap.connectionState == ConnectionState.done) {
                GoTo.goTo(Routes.operation);
              }
              return SizedBox.shrink();
            }),
      ),
    );
  }
}
