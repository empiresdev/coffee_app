import 'package:coffee_app/app/view/app_view.dart';
import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({
    required this.localRepository,
    required this.remoteRepository,
    super.key,
  });

  final LocalCoffeeRepository localRepository;
  final RemoteCoffeeRepository remoteRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoffeeCubit(
        localRepository: localRepository,
        remoteRepository: remoteRepository,
      )..init(),
      child: const AppView(),
    );
  }
}
