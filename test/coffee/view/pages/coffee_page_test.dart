import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:coffee_app/coffee/models/coffee_image.dart';
import 'package:coffee_app/coffee/view/pages/favorites_page.dart';
import 'package:coffee_app/coffee/view/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../helpers/pump_app.dart';

class MockCoffeeCubit extends MockCubit<CoffeeState> implements CoffeeCubit {}

void main() {
  late CoffeeCubit coffeeCubit;
  late CoffeePage sut;

  setUp(() {
    coffeeCubit = MockCoffeeCubit();
    sut = const CoffeePage();
    when(() => coffeeCubit.state).thenReturn(
      const CoffeeState(status: CoffeeStatus.initial),
    );
  });

  group('CoffeeState.status', () {
    testWidgets('renders enabled bottom buttons when state is initial',
        (tester) async {
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(status: CoffeeStatus.initial),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget.runtimeType == FloatingActionButton &&
              (widget as FloatingActionButton).onPressed != null,
        ),
        findsExactly(2),
      );
    });

    testWidgets(
        'renders disabled bottom buttons with circular indicator when '
        'status is loading', (tester) async {
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(status: CoffeeStatus.loading),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget.runtimeType == FloatingActionButton &&
              (widget as FloatingActionButton).onPressed == null,
        ),
        findsExactly(2),
      );
      expect(find.byType(CircularProgressIndicator), findsExactly(2));
    });

    testWidgets('renders enabled bottom buttons when status is success',
        (tester) async {
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(status: CoffeeStatus.success),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget.runtimeType == FloatingActionButton &&
              (widget as FloatingActionButton).onPressed != null,
        ),
        findsExactly(2),
      );
    });

    testWidgets('renders enabled bottom buttons when status is failure',
        (tester) async {
      whenListen(
        coffeeCubit,
        Stream.fromIterable([
          const CoffeeState(status: CoffeeStatus.initial),
          const CoffeeState(status: CoffeeStatus.failure),
        ]),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget.runtimeType == FloatingActionButton &&
              (widget as FloatingActionButton).onPressed != null,
        ),
        findsExactly(2),
      );
    });

    group('FailureMessages', () {
      testWidgets(
          'renders a snackbar when status is failure with '
          'fetchRandomImageFailureMessage', (tester) async {
        whenListen(
          coffeeCubit,
          Stream.fromIterable([
            const CoffeeState(status: CoffeeStatus.initial),
            const CoffeeState(
              status: CoffeeStatus.failure,
              messageId: 'fetchRandomImageFailureMessage',
            ),
          ]),
        );

        await tester.pumpApp(
          locale: const Locale('en'),
          BlocProvider.value(
            value: coffeeCubit,
            child: sut,
          ),
        );

        expect(find.byType(SnackBar), findsNothing);
        await tester.pump();
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text(
            'Unable to load a random image. '
            'A server error occurred, please try again later.',
          ),
          findsOneWidget,
        );
      });

      testWidgets(
          'renders a snackbar when status is failure with '
          'loadFavoriteImageFailureMessage', (tester) async {
        whenListen(
          coffeeCubit,
          Stream.fromIterable([
            const CoffeeState(status: CoffeeStatus.initial),
            const CoffeeState(
              status: CoffeeStatus.failure,
              messageId: 'loadFavoriteImageFailureMessage',
            ),
          ]),
        );

        await tester.pumpApp(
          locale: const Locale('en'),
          BlocProvider.value(
            value: coffeeCubit,
            child: sut,
          ),
        );

        expect(find.byType(SnackBar), findsNothing);
        await tester.pump();
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text(
            'Failed to open your favorite image. Please try again later.',
          ),
          findsOneWidget,
        );
      });

      testWidgets(
          'renders enabled bottom buttons and a snackbar with '
          'saveImageFailureMessage', (tester) async {
        whenListen(
          coffeeCubit,
          Stream.fromIterable([
            const CoffeeState(status: CoffeeStatus.initial),
            const CoffeeState(
              status: CoffeeStatus.failure,
              messageId: 'saveImageFailureMessage',
            ),
          ]),
        );

        await tester.pumpApp(
          locale: const Locale('en'),
          BlocProvider.value(
            value: coffeeCubit,
            child: sut,
          ),
        );

        expect(find.byType(SnackBar), findsNothing);
        await tester.pump();
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text(
            'Failed to save the image. Please try again later.',
          ),
          findsOneWidget,
        );
      });

      testWidgets(
          'renders a snackbar when status is failure with '
          'unknown error message', (tester) async {
        whenListen(
          coffeeCubit,
          Stream.fromIterable([
            const CoffeeState(status: CoffeeStatus.initial),
            const CoffeeState(status: CoffeeStatus.failure),
          ]),
        );

        await tester.pumpApp(
          locale: const Locale('en'),
          BlocProvider.value(
            value: coffeeCubit,
            child: sut,
          ),
        );

        expect(find.byType(SnackBar), findsNothing);
        await tester.pump();
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text(
            'An error occurred',
          ),
          findsOneWidget,
        );
      });
    });
  });

  group('CoffeeState.image', () {
    testWidgets('renders Empty when image is null', (tester) async {
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(status: CoffeeStatus.initial),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );

      expect(find.byKey(const Key('NoImageCoffeeState')), findsOneWidget);
    });

    testWidgets(
        'renders RemoteCoffeeImage when image is a valid RemoteCoffeeImage',
        (tester) async {
      const imageUrl = 'any url';
      const remoteCoffeeImage = RemoteCoffeeImage(imageUrl);
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(
          status: CoffeeStatus.success,
          image: remoteCoffeeImage,
        ),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpApp(
          BlocProvider.value(
            value: coffeeCubit,
            child: sut,
          ),
        );
      });

      expect(find.byKey(const Key('Remote_$imageUrl')), findsOneWidget);
    });

    testWidgets(
        'renders LocalCoffeeImage when image is a valid LocalImageCoffee',
        (tester) async {
      const imageUrl = 'any url';
      const localCoffeeImage = LocalCoffeeImage(imageUrl);
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(
          status: CoffeeStatus.success,
          image: localCoffeeImage,
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );

      expect(find.byKey(const Key('Local_$imageUrl')), findsOneWidget);
    });
  });

  group('CoffeeState.isFavorite', () {
    testWidgets(
        'renders correct favorite button state if image is not favorite',
        (tester) async {
      const coffeeImage = LocalCoffeeImage('any url');
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(
          status: CoffeeStatus.success,
          image: coffeeImage,
          favorites: [],
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('renders correct favorite button state if image is favorite',
        (tester) async {
      const coffeeImage = LocalCoffeeImage('any url');
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(
          status: CoffeeStatus.success,
          image: coffeeImage,
          favorites: [coffeeImage],
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('updates favorite button state when favorite status changes',
        (tester) async {
      const coffeeImage = LocalCoffeeImage('any url');
      whenListen(
        coffeeCubit,
        Stream.fromIterable([
          const CoffeeState(status: CoffeeStatus.success, image: coffeeImage),
          const CoffeeState(
            status: CoffeeStatus.success,
            image: coffeeImage,
            favorites: [coffeeImage],
          ),
        ]),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      await tester.pump();
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('Tap events', () {
    testWidgets('triggers fetchRandomImage when next button is tapped',
        (tester) async {
      const localCoffeeImage = LocalCoffeeImage('any');
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(
          status: CoffeeStatus.success,
          image: localCoffeeImage,
        ),
      );
      when(() => coffeeCubit.fetchRemoteImage()).thenAnswer((_) async {});

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );
      await tester.tap(find.byKey(const Key('NextButton')));
      await tester.pumpAndSettle();
      verify(() => coffeeCubit.fetchRemoteImage()).called(1);
    });

    testWidgets('triggers saveFavoriteImage when favorite button is tapped',
        (tester) async {
      const localCoffeeImage = LocalCoffeeImage('any');
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(
          status: CoffeeStatus.success,
          image: localCoffeeImage,
        ),
      );
      when(() => coffeeCubit.saveFavoriteImage()).thenAnswer((_) async {});

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );
      await tester.tap(find.byKey(const Key('FavoriteButton')));
      await tester.pumpAndSettle();
      verify(() => coffeeCubit.saveFavoriteImage()).called(1);
    });

    testWidgets('navigates to FavoritesPage when grid button is tapped',
        (tester) async {
      const localCoffeeImage = LocalCoffeeImage('any');
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(
          status: CoffeeStatus.success,
          image: localCoffeeImage,
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );
      await tester.tap(find.byKey(const Key('SeeFavoritesButton')));
      await tester.pumpAndSettle();
      expect(find.byType(FavoritesPage), findsOneWidget);
    });

    testWidgets(
        'ensures loadFavoriteImage is called when '
        'FavoritesPage returns a valid local image', (tester) async {
      const favorites = [LocalCoffeeImage('any')];
      when(() => coffeeCubit.state).thenReturn(
        const CoffeeState(
          status: CoffeeStatus.success,
          favorites: favorites,
        ),
      );
      when(() => coffeeCubit.loadFavoriteImage(favorites[0]))
          .thenAnswer((_) async {});

      await tester.pumpApp(
        BlocProvider.value(
          value: coffeeCubit,
          child: sut,
        ),
      );

      await tester.tap(find.byKey(const Key('SeeFavoritesButton')));
      await tester.pumpAndSettle();
      expect(find.byType(FavoritesPage), findsOneWidget);

      final anyImage = find.byType(Image).first;
      await tester.tap(anyImage);
      await tester.pumpAndSettle();
      verify(() => coffeeCubit.loadFavoriteImage(favorites[0])).called(1);
    });
  });
}
