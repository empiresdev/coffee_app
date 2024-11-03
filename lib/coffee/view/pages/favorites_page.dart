import 'dart:io';

import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:coffee_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesAppBarTitle),
      ),
      body: BlocBuilder<CoffeeCubit, CoffeeState>(
        builder: (context, state) {
          final favorites = state.favorites ?? [];
          if (favorites.isEmpty) {
            return Center(
              child: Text(l10n.favoritesEmptyErrorMessage),
            );
          }
          return SafeArea(
            child: GridView.count(
              padding: const EdgeInsets.all(8),
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: favorites
                  .map(
                    (image) => GestureDetector(
                      onTap: () => Navigator.of(context).pop(image),
                      child: Card(
                        child: Image.file(
                          File(image.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
