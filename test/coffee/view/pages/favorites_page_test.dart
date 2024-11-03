import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:coffee_app/coffee/models/models.dart';
import 'package:coffee_app/coffee/view/pages/favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class MockCoffeeCubit extends MockCubit<CoffeeState> implements CoffeeCubit {}

void main() {
  late MockCoffeeCubit coffeeCubit;
  late FavoritesPage sut;
  late List<LocalCoffeeImage> favorites;
  const coffeeImage = LocalCoffeeImage('any');

  setUp(() {
    coffeeCubit = MockCoffeeCubit();
    sut = const FavoritesPage();
    favorites = List.generate(5, (i) => LocalCoffeeImage('any $i.png'));

    when(() => coffeeCubit.state).thenReturn(
      CoffeeState(
        status: CoffeeStatus.success,
        image: coffeeImage,
        favorites: favorites,
      ),
    );
  });

  testWidgets('renders images from favorites list in grid', (tester) async {
    await tester.pumpApp(
      BlocProvider<CoffeeCubit>(
        create: (context) => coffeeCubit,
        child: sut,
      ),
    );

    expect(find.byType(Image), findsNWidgets(favorites.length));
  });

  testWidgets('renders a message when favorites is empty', (tester) async {
    when(() => coffeeCubit.state).thenReturn(
      const CoffeeState(
        status: CoffeeStatus.success,
        image: coffeeImage,
        favorites: [],
      ),
    );

    await tester.pumpApp(
      locale: const Locale('en'),
      BlocProvider<CoffeeCubit>(
        create: (context) => coffeeCubit,
        child: sut,
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.text('There are no favorite images yet.'), findsOneWidget);
  });

  testWidgets('returns selected image when tapped',
      (WidgetTester tester) async {
    LocalCoffeeImage? localImage;
    await tester.pumpApp(
      BlocProvider<CoffeeCubit>(
        create: (context) => coffeeCubit,
        child: Builder(
          builder: (context) => Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final cubit = context.read<CoffeeCubit>();
                localImage = await Navigator.of(context).push(
                  MaterialPageRoute<LocalCoffeeImage>(
                    builder: (context) => BlocProvider.value(
                      value: cubit,
                      child: const FavoritesPage(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    final floatActionButton = find.byType(FloatingActionButton).first;
    await tester.tap(floatActionButton);
    await tester.pumpAndSettle();

    final firstImage = find.byType(Image).first;
    expect(firstImage, isNotNull);

    await tester.tap(firstImage);
    await tester.pumpAndSettle();

    expect(localImage, isNotNull);
  });

  testWidgets('returns a null image when back from FavoritesPage',
      (WidgetTester tester) async {
    LocalCoffeeImage? localImage;
    await tester.pumpApp(
      BlocProvider<CoffeeCubit>(
        create: (context) => coffeeCubit,
        child: Builder(
          builder: (context) => Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final cubit = context.read<CoffeeCubit>();
                localImage = await Navigator.of(context).push(
                  MaterialPageRoute<LocalCoffeeImage>(
                    builder: (context) => BlocProvider.value(
                      value: cubit,
                      child: const FavoritesPage(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    final floatActionButton = find.byType(FloatingActionButton).first;
    await tester.tap(floatActionButton);
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(localImage, isNull);
  });
  
}
