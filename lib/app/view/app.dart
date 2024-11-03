import 'package:coffee_app/app/view/app_view.dart';
import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatefulWidget {
  App({
    this.localRepository,
    this.remoteRepository,
    CoffeeCubit? coffeeCubit,
    super.key,
  })  : assert(
          (coffeeCubit != null) ||
              (localRepository != null && remoteRepository != null),
          'Repositories are required if CoffeeCubit is null.',
        ),
        _coffeeCubit = coffeeCubit ??
            CoffeeCubit(
              localRepository: localRepository!,
              remoteRepository: remoteRepository!,
            );

  final LocalCoffeeRepository? localRepository;
  final RemoteCoffeeRepository? remoteRepository;
  final CoffeeCubit? _coffeeCubit;

  CoffeeCubit get cubit => _coffeeCubit!;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.cubit.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => widget.cubit,
      child: const AppView(),
    );
  }
}
