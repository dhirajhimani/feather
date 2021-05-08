import 'package:feather/src/blocs/application_bloc.dart';
import 'package:feather/src/models/internal/overflow_menu_element.dart';
import 'package:feather/src/models/internal/unit.dart';
import 'package:feather/src/resources/application_localization.dart';
import 'package:feather/src/resources/config/application_colors.dart';
import 'package:feather/src/ui/settings/settings_screen_bloc.dart';
import 'package:feather/src/ui/settings/settings_screen_event.dart';
import 'package:feather/src/ui/settings/settings_screen_state.dart';
import 'package:feather/src/ui/widget/animated_gradient.dart';
import 'package:feather/src/ui/widget/loading_widget.dart';
import 'package:feather/src/ui/widget/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool unitImperial = !applicationBloc.isMetricUnits();
  int refreshTime = applicationBloc.refreshTime;
  late SettingsScreenBloc _settingsScreenBloc;

  @override
  void initState() {
    _settingsScreenBloc = BlocProvider.of(context);
    _settingsScreenBloc.add(LoadSettingsScreenEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        const AnimatedGradientWidget(
          duration: Duration(seconds: 3),
        ),
        BlocBuilder(
          bloc: _settingsScreenBloc,
          builder: (context, state) {
            if (state is InitialSettingsScreenState ||
                state is LoadingSettingsScreenState) {
              return const LoadingWidget();
            } else if (state is LoadedSettingsScreenState) {
              return Container(
                key: const Key("weather_main_screen_container"),
                child: _getSettingsContainer(state),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        const TransparentAppBar(),
      ],
    ));
  }

  Widget _getSettingsContainer(LoadedSettingsScreenState state) {
    final applicationLocalization = ApplicationLocalization.of(context)!;
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          _buildUnitsChangeWidget(
              applicationLocalization, state.unit == Unit.imperial),
          Text(
            applicationLocalization.getText("units_description"),
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 30),
          _buildRefreshTimePickerWidget(
              applicationLocalization, state.refreshTime),
          const SizedBox(height: 10),
          Text(
            applicationLocalization.getText("refresh_time_description"),
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              "${applicationLocalization.getText("last_refresh_time")}:",
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ]),
          const SizedBox(height: 10),
          Text(
              DateTime.fromMillisecondsSinceEpoch(
                      applicationBloc.lastRefreshTime)
                  .toString(),
              style: Theme.of(context).textTheme.bodyText1),
        ],
      ),
    );
  }

  Widget _buildUnitsChangeWidget(
      ApplicationLocalization applicationLocalization, bool unitImperial) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${applicationLocalization.getText("units")}:",
          style: Theme.of(context).textTheme.subtitle2,
        ),
        Row(
          children: [
            Text(applicationLocalization.getText("metric")),
            Switch(
                value: unitImperial,
                activeColor: Colors.grey,
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white,
                inactiveThumbColor: Colors.grey,
                onChanged: onChangedUnitState),
            Text(applicationLocalization.getText("imperial")),
            const SizedBox(height: 10),
          ],
        )
      ],
    );
  }

  Widget _buildRefreshTimePickerWidget(
      ApplicationLocalization applicationLocalization, int refreshTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${applicationLocalization.getText("refresh_time")}:",
          style: Theme.of(context).textTheme.subtitle2,
        ),
        Center(
          child: Row(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  cardColor: ApplicationColors.nightStartColor,
                ),
                child: PopupMenuButton<PopupMenuElement>(
                  onSelected: (PopupMenuElement element) {
                    _onMenuClicked(element);
                  },
                  itemBuilder: (BuildContext context) {
                    return _getRefreshTimeMenu(context)
                        .map((PopupMenuElement element) {
                      return PopupMenuItem<PopupMenuElement>(
                        value: element,
                        child: Text(
                          element.title!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      _getSelectedMenuElementText(refreshTime),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  List<PopupMenuElement> _getRefreshTimeMenu(BuildContext context) {
    final applicationLocalization = ApplicationLocalization.of(context)!;
    final List<PopupMenuElement> menuList = [];
    menuList.add(PopupMenuElement(
      key: const Key("menu_settings_refresh_time_10_minutes"),
      title: "10 ${applicationLocalization.getText("minutes")}",
    ));
    menuList.add(PopupMenuElement(
      key: const Key("menu_settings_refresh_time_15_minutes"),
      title: "15 ${applicationLocalization.getText("minutes")}",
    ));
    menuList.add(PopupMenuElement(
      key: const Key("menu_settings_refresh_time_30_minutes"),
      title: "30 ${applicationLocalization.getText("minutes")}",
    ));
    menuList.add(PopupMenuElement(
      key: const Key("menu_settings_refresh_time_60_minutes"),
      title: "60 ${applicationLocalization.getText("minutes")}",
    ));

    return menuList;
  }

  void onChangedUnitState(bool state) {
    Unit unit;
    if (state) {
      unit = Unit.imperial;
    } else {
      unit = Unit.metric;
    }
    _settingsScreenBloc.add(ChangeUnitsSettingsScreenEvent(unit));
  }

  String _getSelectedMenuElementText(int refreshTime) {
    final applicationLocalization = ApplicationLocalization.of(context);
    switch (refreshTime) {
      case 600000:
        return "10 ${applicationLocalization!.getText("minutes")}";
      case 900000:
        return "15${applicationLocalization!.getText("minutes")}";
      case 1800000:
        return "30 ${applicationLocalization!.getText("minutes")}";
      case 3600000:
        return "60 ${applicationLocalization!.getText("minutes")}";
      default:
        return "10 ${applicationLocalization!.getText("minutes")}";
    }
  }

  void _onMenuClicked(PopupMenuElement element) {
    int selectedRefreshTime = 600000;
    if (element.key == const Key("menu_settings_refresh_time_10_minutes")) {
      selectedRefreshTime = 600000;
    } else if (element.key ==
        const Key("menu_settings_refresh_time_15_minutes")) {
      selectedRefreshTime = 900000;
    } else if (element.key ==
        const Key("menu_settings_refresh_time_30_minutes")) {
      selectedRefreshTime = 1800000;
    } else {
      selectedRefreshTime = 3600000;
    }

    _settingsScreenBloc
        .add(ChangeRefreshTimeSettingsScreenEvent(selectedRefreshTime));
  }
}