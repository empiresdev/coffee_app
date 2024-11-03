import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_app/app/app.dart';
import 'package:coffee_app/app/view/app_view.dart';
import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCoffeeCubit extends MockCubit<CoffeeState> implements CoffeeCubit {}

void main() {
  group('App', () {
    late MockCoffeeCubit mockCoffeeCubit;

    setUp(() {
      mockCoffeeCubit = MockCoffeeCubit();
      when(() => mockCoffeeCubit.state)
          .thenReturn(const CoffeeState(status: CoffeeStatus.initial));
    });

    testWidgets('renders AppView', (tester) async {
      when(() => mockCoffeeCubit.init()).thenAnswer((_) async {});
      await tester.pumpWidget(
        App(
          coffeeCubit: mockCoffeeCubit,
        ),
      );
      expect(find.byType(AppView), findsOneWidget);
    });

    testWidgets('ensure CoffeeCubit calls fetchRandomImage when the app starts',
        (tester) async {
      when(() => mockCoffeeCubit.init()).thenAnswer((_) async {});
      await tester.pumpWidget(
        App(
          coffeeCubit: mockCoffeeCubit,
        ),
      );
      verify(() => mockCoffeeCubit.init()).called(1);
    });
  });
}
