import 'package:feather/src/data/model/internal/application_error.dart';
import 'package:feather/src/data/repository/local/application_localization.dart';
import 'package:feather/src/resources/config/application_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WidgetHelper {


  static EdgeInsets buildEdgeInsets(
      {double left = 0, double top = 0, double right = 0, double bottom = 0}) {
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  static LinearGradient buildGradient(Color startColor, Color endColor) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.2, 0.99],
      colors: [
        // Colors are easy thanks to Flutter's Colors class.
        startColor,
        endColor,
      ],
    );
  }

  static Widget buildProgressIndicator() {
    return const Center(
        key: Key("progress_indicator"),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ));
  }

  static Widget buildErrorWidget(
      {required BuildContext context,
      ApplicationError? applicationError,
      VoidCallback? voidCallback,
      required bool withRetryButton}) {
    String? errorText = "";
    final ApplicationLocalization? localization = ApplicationLocalization.of(context);
    if (applicationError == ApplicationError.locationNotSelectedError) {
      errorText = localization!.getText("error_location_not_selected");
    } else if (applicationError == ApplicationError.connectionError) {
      errorText = localization!.getText("error_server_connection");
    } else if (applicationError == ApplicationError.apiError) {
      errorText = localization!.getText("error_api");
    } else {
      errorText = localization!.getText("error_unknown");
    }
    final List<Widget> widgets = [];
    widgets.add(Text(
      errorText,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    ));
    if (withRetryButton) {
      widgets.add(TextButton(
        onPressed: voidCallback,
        child: Text(ApplicationLocalization.of(context)!.getText("retry"),
            style: Theme.of(context).textTheme.subtitle2),
      ));
    }

    return Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
            key: const Key("error_widget"),
            child: SizedBox(
                width: 250,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widgets))));
  }

static LinearGradient buildGradientBasedOnDayCycle(int sunrise, int sunset) {
    final DateTime now = DateTime.now();
    final int nowMs = now.millisecondsSinceEpoch;
    final int sunriseMs = sunrise * 1000;
    final int sunsetMs = sunset * 1000;

    if (nowMs < sunriseMs) {
      final int lastMidnight = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      return getNightGradient((sunriseMs - nowMs) / (sunriseMs - lastMidnight));
    } else if (nowMs > sunsetMs) {
      final int nextMidnight = DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;
      return getNightGradient((nowMs - sunsetMs) / (nextMidnight - sunsetMs));
    } else {
      return getDayGradient((nowMs - sunriseMs) / (sunsetMs - sunriseMs));
    }
  }

  static LinearGradient getNightGradient(double percentage) {
    if (percentage <= 0.1) {
        return buildGradient(ApplicationColors.dawnDuskStartColor, ApplicationColors.dawnDuskEndColor);
      } else if (percentage <= 0.2) {
        return buildGradient(ApplicationColors.twilightStartColor, ApplicationColors.twilightEndColor);
      } else if (percentage <= 0.6) {
        return buildGradient(ApplicationColors.nightStartColor, ApplicationColors.nightEndColor);
      } else {
        return buildGradient(ApplicationColors.midnightStartColor, ApplicationColors.midnightEndColor);
      }
  }

  static LinearGradient getDayGradient(double percentage) {
    if (percentage <= 0.1 || percentage >= 0.9) {
      return buildGradient(ApplicationColors.dawnDuskStartColor, ApplicationColors.dawnDuskEndColor);
    } else if (percentage <= 0.2 || percentage >= 0.8) {
      return buildGradient(ApplicationColors.morningEveStartColor, ApplicationColors.morningEveEndColor);
    } else if (percentage <= 0.4 || percentage >= 0.6) {
      return buildGradient(ApplicationColors.dayStartColor, ApplicationColors.dayEndColor);
    } else {
      return buildGradient(ApplicationColors.middayStartColor, ApplicationColors.middayEndColor);
    }
  }

  static LinearGradient getGradient({int? sunriseTime = 0, int? sunsetTime = 0}) {
    if (sunriseTime == 0 && sunsetTime == 0) {
      return buildGradient(ApplicationColors.midnightStartColor, ApplicationColors.midnightEndColor);
    } else {
      return buildGradientBasedOnDayCycle(sunriseTime!, sunsetTime!);
    }
  }
}
