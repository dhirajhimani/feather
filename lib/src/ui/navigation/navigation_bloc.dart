import 'package:feather/src/models/internal/navigation_route.dart';
import 'package:feather/src/ui/navigation/navigation.dart';
import 'package:feather/src/ui/navigation/navigation_event.dart';
import 'package:feather/src/ui/navigation/navigation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final Navigation navigation;
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationBloc(this.navigation, this.navigatorKey,)
      : super(const NavigationState(NavigationRoute.mainScreen));

  @override
  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {
    if (event is MainScreenNavigationEvent) {
      _navigateToPath("/");
      yield const NavigationState(NavigationRoute.mainScreen);
    }
    if (event is ForecastScreenNavigationEvent) {
      _navigateToPath("/forecast");
      yield const NavigationState(NavigationRoute.forecastScreen);
    }
    if (event is AboutScreenNavigationEvent) {
      _navigateToPath("/about");
      yield const NavigationState(NavigationRoute.aboutScreen);
    }
    if (event is SettingsScreenNavigationEvent) {
      _navigateToPath("/settings");
      yield const NavigationState(NavigationRoute.settingsScreen);
    }
  }

  void _navigateToPath(String path) {
    navigation.router.navigateTo(navigatorKey.currentState!.context, path);
  }

}