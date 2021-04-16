import 'package:feather/src/blocs/application_bloc.dart';
import 'package:feather/src/models/remote/overall_weather_data.dart';
import 'package:feather/src/models/remote/weather_response.dart';
import 'package:feather/src/resources/application_localization.dart';
import 'package:feather/src/resources/weather_helper.dart';
import 'package:feather/src/ui/screen/base/animated_state.dart';
import 'package:feather/src/ui/widget/weather_forecast_thumbnail_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CurrentWeatherWidget extends StatefulWidget {
  final WeatherResponse? weatherResponse;

  const CurrentWeatherWidget({Key? key, this.weatherResponse})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CurrentWeatherWidgetState();
  }
}

class CurrentWeatherWidgetState extends AnimatedState<CurrentWeatherWidget> {
  @override
  void dispose() {
    super.dispose();
    applicationBloc.currentWeatherWidgetAnimationState = false;
  }

  @override
  Widget build(BuildContext context) {
    return buildWeatherContainer(widget.weatherResponse!);
  }

  Widget buildWeatherContainer(WeatherResponse response) {
    var currentTemperature = response.mainWeatherData!.temp;
    if (!applicationBloc.isMetricUnits()) {
      currentTemperature =
          WeatherHelper.convertCelsiusToFahrenheit(currentTemperature);
    }

    return FadeTransition(
      opacity: setupAnimation(
          duration: 3000,
          noAnimation: !applicationBloc.currentWeatherWidgetAnimationState),
      child: Container(
        key: Key("weather_current_widget_container"),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 32),
              Image.asset(
                _getWeatherImage(response),
                width: 100,
                height: 100,
              ),
              Text(
                  WeatherHelper.formatTemperature(
                    temperature: currentTemperature,
                    metricUnits: applicationBloc.isMetricUnits(),
                  ),
                  key: Key("weather_current_widget_temperature"),
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.headline5),
              const SizedBox(height: 32),
              Text(_getMaxMinTemperatureRow(response),
                  key: Key("weather_current_widget_min_max_temperature"),
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.subtitle2),
              const SizedBox(height: 4),
              _getPressureAndHumidityRow(response),
              const SizedBox(height: 24),
              WeatherForecastThumbnailListWidget(
                  system: response.system,
                  key: Key("weather_current_widget_thumbnail_list")),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getMaxMinTemperatureRow(WeatherResponse weatherResponse) {
    var maxTemperature = weatherResponse.mainWeatherData!.tempMax;
    var minTemperature = weatherResponse.mainWeatherData!.tempMin;
    if (!applicationBloc.isMetricUnits()) {
      maxTemperature = WeatherHelper.convertCelsiusToFahrenheit(maxTemperature);
      minTemperature = WeatherHelper.convertCelsiusToFahrenheit(minTemperature);
    }

    return "↑${WeatherHelper.formatTemperature(temperature: maxTemperature, metricUnits: applicationBloc.isMetricUnits())}" +
        " ↓${WeatherHelper.formatTemperature(temperature: minTemperature, metricUnits: applicationBloc.isMetricUnits())}";
  }

  Widget _getPressureAndHumidityRow(WeatherResponse weatherResponse) {
    var applicationLocalization = ApplicationLocalization.of(context)!;
    return RichText(
      textDirection: TextDirection.ltr,
      key: Key("weather_current_widget_pressure_humidity"),
      text: TextSpan(
        children: [
          TextSpan(
              text: "${applicationLocalization.getText("pressure")}: ",
              style: Theme.of(context).textTheme.bodyText1),
          TextSpan(
              text: WeatherHelper.formatPressure(
                  weatherResponse.mainWeatherData!.pressure),
              style: Theme.of(context).textTheme.subtitle2),
          TextSpan(
            text: "  ",
          ),
          TextSpan(
              text: "${applicationLocalization.getText("humidity")}: ",
              style: Theme.of(context).textTheme.bodyText1),
          TextSpan(
              text: WeatherHelper.formatHumidity(
                  weatherResponse.mainWeatherData!.humidity),
              style: Theme.of(context).textTheme.subtitle2)
        ],
      ),
    );
  }

  String _getWeatherImage(WeatherResponse weatherResponse) {
    OverallWeatherData overallWeatherData =
        weatherResponse.overallWeatherData![0];
    int code = overallWeatherData.id!;
    return WeatherHelper.getWeatherIcon(code);
  }

  @override
  void onAnimatedValue(double value) {}
}
