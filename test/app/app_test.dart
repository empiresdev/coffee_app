import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_app/app/app.dart';
import 'package:coffee_app/app/view/app_view.dart';
import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:coffee_app/coffee/models/coffee_image.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCoffeeCubit extends MockCubit<CoffeeState> implements CoffeeCubit {}

class MockLocalCoffeeRepository extends Mock implements LocalCoffeeRepository {}

class MockRemoteCoffeeRepository extends Mock
    implements RemoteCoffeeRepository {}

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
    testWidgets('ensure repositories are injected to CoffeeCubit',
        (tester) async {
      final mockRemoteCoffeeRepository = MockRemoteCoffeeRepository();
      final mockLocalCoffeeRepository = MockLocalCoffeeRepository();
      final sut = App(
        remoteRepository: mockRemoteCoffeeRepository,
        localRepository: mockLocalCoffeeRepository,
      );

      when(mockRemoteCoffeeRepository.fetchRandomImage)
          .thenAnswer((_) async => const RemoteCoffeeImage('any'));
      when(mockLocalCoffeeRepository.fetchAllFavorites)
          .thenAnswer((_) async => [const LocalCoffeeImage('any')]);

      await tester.pumpWidget(sut);

      expect(sut.cubit.localRepository, mockLocalCoffeeRepository);
      expect(sut.cubit.remoteRepository, mockRemoteCoffeeRepository);
      verify(mockRemoteCoffeeRepository.fetchRandomImage).called(1);
      verify(mockLocalCoffeeRepository.fetchAllFavorites).called(1);
    });
  });
}
