import 'package:amity_uikit_beta_service/v4/utils/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveChannelRouteScope extends StatefulWidget {
  const ActiveChannelRouteScope({super.key, required this.channelId, required this.child});

  final String? channelId;
  final Widget child;

  @override
  State<ActiveChannelRouteScope> createState() => _ActiveChannelRouteScopeState();
}

class _ActiveChannelRouteScopeState extends State<ActiveChannelRouteScope> with RouteAware {
  NavigationProvider? _navigationProvider;
  PageRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _navigationProvider ??= context.read<NavigationProvider>();

    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _route) {
      _route = route;
      navigationRouteObserver.subscribe(this, route);
      _setActiveChannel();
    }
  }

  @override
  void didPush() {
    _setActiveChannel();
  }

  @override
  void didPopNext() {
    _setActiveChannel();
  }

  @override
  void didPushNext() {
    _clearActiveChannel();
  }

  void _setActiveChannel() {
    final channelId = widget.channelId;
    if (channelId == null || channelId.isEmpty) {
      return;
    }

    _navigationProvider?.setActiveChannelId(channelId);
  }

  void _clearActiveChannel() {
    final channelId = widget.channelId;
    if (channelId == null || channelId.isEmpty) {
      return;
    }

    _navigationProvider?.clearActiveChannelId(channelId: channelId);
  }

  @override
  void dispose() {
    if (_route != null) {
      navigationRouteObserver.unsubscribe(this);
    }
    _clearActiveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
