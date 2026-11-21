// Local diagnostic template: remove or gate the counter outside profiling builds.
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileSelector<B extends StateStreamable<S>, S, T> extends StatefulWidget {
  const ProfileSelector({
    required this.selector,
    required this.builder,
    super.key,
  });

  final T Function(S state) selector;
  final Widget Function(BuildContext context, T value, int rebuilds) builder;

  @override
  State<ProfileSelector<B, S, T>> createState() => _ProfileSelectorState<B, S, T>();
}

class _ProfileSelectorState<B extends StateStreamable<S>, S, T>
    extends State<ProfileSelector<B, S, T>> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) => BlocSelector<B, S, T>(
        selector: widget.selector,
        builder: (context, value) {
          _rebuilds++;
          return widget.builder(context, value, _rebuilds);
        },
      );
}
