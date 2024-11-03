import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_app/app/view/app_view.dart';
import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:coffee_app/coffee/view/pages/pages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class MockCoffeeCubit extends MockCubit<CoffeeState> implements CoffeeCubit {}

void main() {
  late CoffeeCubit coffeeCubit;

  setUp(() {
    coffeeCubit = MockCoffeeCubit();

    when(() => coffeeCubit.state)
        .thenReturn(const CoffeeState(status: CoffeeStatus.initial));
  });
  testWidgets('renders CoffeePage', (tester) async {
    await tester.pumpApp(
      BlocProvider.value(
        value: coffeeCubit,
        child: const AppView(),
      ),
    );
    expect(find.byType(CoffeePage), findsOneWidget);
  });
}
