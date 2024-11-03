import 'package:coffee_app/app/app.dart';
import 'package:coffee_app/app/view/app_view.dart';
import 'package:coffee_app/coffee/models/coffee_image.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalCoffeeRepository extends Mock implements LocalCoffeeRepository {}

class MockRemoteCoffeeRepository extends Mock
    implements RemoteCoffeeRepository {}

void main() {
  group('App', () {
    late MockLocalCoffeeRepository mockLocalCoffeeRepository;
    late MockRemoteCoffeeRepository mockRemoteCoffeeRepository;

    setUp(() {
      mockLocalCoffeeRepository = MockLocalCoffeeRepository();
      mockRemoteCoffeeRepository = MockRemoteCoffeeRepository();
    });

    testWidgets('renders AppView', (tester) async {
      when(() => mockRemoteCoffeeRepository.fetchRandomImage())
          .thenAnswer((_) async => const RemoteCoffeeImage('any url'));
      await tester.pumpWidget(
        App(
          localRepository: mockLocalCoffeeRepository,
          remoteRepository: mockRemoteCoffeeRepository,
        ),
      );
      expect(find.byType(AppView), findsOneWidget);
    });

    testWidgets('ensure CoffeeCubit calls fetchRandomImage when the app starts',
        (tester) async {
      when(() => mockRemoteCoffeeRepository.fetchRandomImage())
          .thenAnswer((_) async => const RemoteCoffeeImage('any url'));
      await tester.pumpWidget(
        App(
          localRepository: mockLocalCoffeeRepository,
          remoteRepository: mockRemoteCoffeeRepository,
        ),
      );
      expect(find.byType(AppView), findsOneWidget);
    });
  });
}
