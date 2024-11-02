import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:coffee_app/coffee/models/models.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCoffeeRepository extends Mock implements RemoteCoffeeRepository {}

void main() {
  group('CoffeeCubit', () {
    late CoffeeCubit sut;
    late RemoteCoffeeRepository remoteRepository;
    late RemoteCoffeeImage remoteCoffeeImage;

    setUp(() {
      remoteCoffeeImage = const RemoteCoffeeImage(
          'https://coffee.alexflipnote.dev/l-CRpPjbniY_coffee.jpg');
      remoteRepository = MockCoffeeRepository();
      when(() => remoteRepository.fetchRandomImage()).thenAnswer(
        (_) async => remoteCoffeeImage,
      );
      sut = CoffeeCubit(remoteRepository: remoteRepository);
    });
    test('initial state is correct', () {
      final sut = CoffeeCubit(remoteRepository: remoteRepository);
      expect(sut.state, const CoffeeState(status: CoffeeStatus.initial));
    });

    group('fetchRemoteImage', () {
      blocTest<CoffeeCubit, CoffeeState>(
        'emits [loading, success] when first fetchRemoteImage returns success',
        build: () => sut,
        act: (cubit) => cubit.fetchRemoteImage(),
        seed: () => const CoffeeState(status: CoffeeStatus.initial),
        expect: () => <CoffeeState>[
          const CoffeeState(status: CoffeeStatus.loading),
          CoffeeState(status: CoffeeStatus.success, image: remoteCoffeeImage),
        ],
      );

      blocTest<CoffeeCubit, CoffeeState>(
        'emits [loading, failure] when first fetchRemoteImage throws',
        setUp: () {
          when(() => remoteRepository.fetchRandomImage())
              .thenThrow(Exception('error'));
        },
        build: () => sut,
        seed: () => const CoffeeState(status: CoffeeStatus.initial),
        act: (cubit) => cubit.fetchRemoteImage(),
        expect: () => <CoffeeState>[
          const CoffeeState(status: CoffeeStatus.loading),
          const CoffeeState(status: CoffeeStatus.failure),
        ],
      );
    });
  });
}
