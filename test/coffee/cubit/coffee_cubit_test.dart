import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:coffee_app/coffee/models/models.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCoffeeRepository extends Mock implements CoffeeRepository {}

void main() {
  group('CoffeeCubit', () {
    late CoffeeCubit sut;
    late MockCoffeeRepository mockCoffeeRepository;
    const remoteCoffeeImage = RemoteCoffeeImage(
      'https://coffee.alexflipnote.dev/l-CRpPjbniY_coffee.jpg',
    );

    setUp(() {
      mockCoffeeRepository = MockCoffeeRepository();
      when(() => mockCoffeeRepository.fetchRandomImage()).thenAnswer(
        (_) async => remoteCoffeeImage,
      );
      sut = CoffeeCubit(
        repository: mockCoffeeRepository,
      );
    });
    test('initial state is correct', () {
      expect(sut.state, const CoffeeState(status: CoffeeStatus.initial));
    });

    group('fetchRemoteImage', () {
      group('starting from initial state', () {
        blocTest<CoffeeCubit, CoffeeState>(
          'emits [loading, success] when '
          'first fetchRemoteImage returns success',
          build: () => sut,
          act: (cubit) => cubit.fetchRemoteImage(),
          seed: () => const CoffeeState(status: CoffeeStatus.initial),
          expect: () => <CoffeeState>[
            const CoffeeState(status: CoffeeStatus.loading),
            const CoffeeState(
              status: CoffeeStatus.success,
              image: remoteCoffeeImage,
            ),
          ],
        );

        blocTest<CoffeeCubit, CoffeeState>(
          'emits [loading, failure] when first fetchRemoteImage throws',
          setUp: () {
            when(() => mockCoffeeRepository.fetchRandomImage())
                .thenThrow(Exception('error'));
          },
          build: () => sut,
          seed: () => const CoffeeState(status: CoffeeStatus.initial),
          act: (cubit) => cubit.fetchRemoteImage(),
          expect: () => <CoffeeState>[
            const CoffeeState(status: CoffeeStatus.loading),
            const CoffeeState(
              status: CoffeeStatus.failure,
              messageId: 'fetchRandomImageFailureMessage',
            ),
          ],
        );
      });

      group('starting with a loaded image', () {
        late RemoteCoffeeImage startImage;
        blocTest<CoffeeCubit, CoffeeState>(
          'emits [loading, success] when an image is loaded and '
          'fetchRemoteImage returns success',
          setUp: () {
            startImage = const RemoteCoffeeImage(
              'https://coffee.alexflipnote.dev/Bk9YHzyGMwo_coffee.jpg',
            );
          },
          build: () => sut,
          act: (cubit) => cubit.fetchRemoteImage(),
          seed: () => CoffeeState(
            status: CoffeeStatus.success,
            image: startImage,
          ),
          expect: () => <CoffeeState>[
            CoffeeState(status: CoffeeStatus.loading, image: startImage),
            const CoffeeState(
              status: CoffeeStatus.success,
              image: remoteCoffeeImage,
            ),
          ],
        );

        blocTest<CoffeeCubit, CoffeeState>(
          'emits [loading, failure] with last image when '
          'fetchRemoteImage throws',
          setUp: () {
            startImage = const RemoteCoffeeImage(
              'https://coffee.alexflipnote.dev/Bk9YHzyGMwo_coffee.jpg',
            );
            when(() => mockCoffeeRepository.fetchRandomImage())
                .thenThrow(Exception('error'));
          },
          build: () => sut,
          seed: () => CoffeeState(
            status: CoffeeStatus.success,
            image: startImage,
          ),
          act: (cubit) => cubit.fetchRemoteImage(),
          expect: () => <CoffeeState>[
            CoffeeState(status: CoffeeStatus.loading, image: startImage),
            CoffeeState(
              status: CoffeeStatus.failure,
              image: startImage,
              messageId: 'fetchRandomImageFailureMessage',
            ),
          ],
        );
      });
    });

    group('saveFavoriteImage', () {
      const startRemoteImage = RemoteCoffeeImage(
        'https://coffee.alexflipnote.dev/0WJ4IjWOOEg_coffee.png',
      );
      const startLocalImage = LocalCoffeeImage('0WJ4IjWOOEg_coffee.png');

      blocTest<CoffeeCubit, CoffeeState>(
        'emits no state if there is no rendered image when '
        'saveFavoriteImage is called',
        build: () => sut,
        seed: () => const CoffeeState(status: CoffeeStatus.initial),
        act: (cubit) => cubit.saveFavoriteImage(),
        expect: () => <CoffeeState>[],
      );

      blocTest<CoffeeCubit, CoffeeState>(
        'emits updated favorite list when '
        'saveFavoriteImage returns success',
        setUp: () {
          when(
            () => mockCoffeeRepository.addImage(startRemoteImage),
          ).thenAnswer(
            (_) async => [startLocalImage],
          );
        },
        build: () => sut,
        seed: () => const CoffeeState(
          status: CoffeeStatus.success,
          image: startRemoteImage,
        ),
        act: (cubit) => cubit.saveFavoriteImage(),
        expect: () => <CoffeeState>[
          const CoffeeState(
            status: CoffeeStatus.loading,
            image: startRemoteImage,
          ),
          const CoffeeState(
            status: CoffeeStatus.success,
            image: startLocalImage,
            favorites: [startLocalImage],
          ),
        ],
      );

      blocTest<CoffeeCubit, CoffeeState>(
        'emits [failure] when '
        'saveFavoriteImage throws',
        setUp: () {
          when(
            () => mockCoffeeRepository.addImage(startRemoteImage),
          ).thenThrow(Exception('an error'));
        },
        build: () => sut,
        seed: () => const CoffeeState(
          status: CoffeeStatus.success,
          image: startRemoteImage,
        ),
        act: (cubit) => cubit.saveFavoriteImage(),
        expect: () => <CoffeeState>[
          const CoffeeState(
            status: CoffeeStatus.loading,
            image: startRemoteImage,
          ),
          const CoffeeState(
            status: CoffeeStatus.failure,
            image: startRemoteImage,
            messageId: 'saveImageFailureMessage',
          ),
        ],
      );
    });

    group('loadAllFavoriteImages', () {
      late CoffeeState initialState;
      const favorites = <LocalCoffeeImage>[
        LocalCoffeeImage('test.jpg'),
        LocalCoffeeImage('test.png'),
      ];

      blocTest<CoffeeCubit, CoffeeState>(
        'emits favorite list from localRepository when '
        'state is initial',
        setUp: () {
          initialState = const CoffeeState(status: CoffeeStatus.initial);
          when(() => mockCoffeeRepository.fetchAllFavorites())
              .thenAnswer((_) async => favorites);
        },
        build: () => sut,
        seed: () => initialState,
        act: (cubit) => cubit.loadAllFavoriteImages(),
        expect: () => <CoffeeState>[
          const CoffeeState(status: CoffeeStatus.initial, favorites: favorites),
        ],
      );

      blocTest<CoffeeCubit, CoffeeState>(
        'emits favorite list from localRepository when '
        'state is success',
        setUp: () {
          initialState = const CoffeeState(
            status: CoffeeStatus.success,
            image: remoteCoffeeImage,
            favorites: [],
          );
          when(() => mockCoffeeRepository.fetchAllFavorites())
              .thenAnswer((_) async => favorites);
        },
        build: () => sut,
        seed: () => initialState,
        act: (cubit) => cubit.loadAllFavoriteImages(),
        expect: () => <CoffeeState>[
          CoffeeState(
            status: initialState.status,
            image: initialState.image,
            favorites: favorites,
          ),
        ],
      );

      blocTest<CoffeeCubit, CoffeeState>(
        'emits empty favorite list when '
        'localRepository throws',
        setUp: () {
          when(() => mockCoffeeRepository.fetchAllFavorites())
              .thenThrow(Exception('error'));
        },
        build: () => sut,
        seed: () => const CoffeeState(
          status: CoffeeStatus.success,
          image: remoteCoffeeImage,
        ),
        act: (cubit) => cubit.loadAllFavoriteImages(),
        expect: () => <CoffeeState>[
          const CoffeeState(
            status: CoffeeStatus.success,
            image: remoteCoffeeImage,
            favorites: [],
          ),
        ],
      );
    });

    group('loadFavoriteImage', () {
      late CoffeeState initialState;
      const localCoffeeImage = LocalCoffeeImage('test.jpg');

      blocTest<CoffeeCubit, CoffeeState>(
        'emits the local image when current state is initial',
        setUp: () {
          initialState = const CoffeeState(
            status: CoffeeStatus.initial,
            favorites: [localCoffeeImage],
          );
        },
        build: () => sut,
        seed: () => initialState,
        act: (cubit) => cubit.loadFavoriteImage(localCoffeeImage),
        expect: () => <CoffeeState>[
          const CoffeeState(
            status: CoffeeStatus.success,
            image: localCoffeeImage,
            favorites: [localCoffeeImage],
          ),
        ],
      );

      blocTest<CoffeeCubit, CoffeeState>(
        'emits the local image when current state has a remote image ',
        setUp: () {
          initialState = const CoffeeState(
            status: CoffeeStatus.success,
            image: remoteCoffeeImage,
            favorites: [localCoffeeImage],
          );
        },
        build: () => sut,
        seed: () => initialState,
        act: (cubit) => cubit.loadFavoriteImage(localCoffeeImage),
        expect: () => <CoffeeState>[
          const CoffeeState(
            status: CoffeeStatus.success,
            image: localCoffeeImage,
            favorites: [localCoffeeImage],
          ),
        ],
      );

      blocTest<CoffeeCubit, CoffeeState>(
        'emits the local image when current state is another local image ',
        setUp: () {
          initialState = const CoffeeState(
            status: CoffeeStatus.success,
            image: LocalCoffeeImage('previous image.png'),
            favorites: [
              localCoffeeImage,
              LocalCoffeeImage('previous image.png'),
            ],
          );
        },
        build: () => sut,
        seed: () => initialState,
        act: (cubit) => cubit.loadFavoriteImage(localCoffeeImage),
        expect: () => <CoffeeState>[
          const CoffeeState(
            status: CoffeeStatus.success,
            image: localCoffeeImage,
            favorites: [
              localCoffeeImage,
              LocalCoffeeImage('previous image.png'),
            ],
          ),
        ],
      );
    });

    group('init', () {
      test('calls fetchRemoteImage and loadAllFavorites when init is called',
          () async {
        when(() => mockCoffeeRepository.fetchRandomImage()).thenAnswer(
          (_) async => const RemoteCoffeeImage(''),
        );
        when(() => mockCoffeeRepository.fetchAllFavorites()).thenAnswer(
          (_) async => <LocalCoffeeImage>[],
        );

        await sut.init();

        verify(() => mockCoffeeRepository.fetchRandomImage()).called(1);
        verify(() => mockCoffeeRepository.fetchAllFavorites()).called(1);
      });
    });
  });
}
