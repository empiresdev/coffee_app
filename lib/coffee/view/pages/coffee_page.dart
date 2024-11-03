import 'dart:io';

import 'package:coffee_app/coffee/cubit/coffee_cubit.dart';
import 'package:coffee_app/coffee/models/coffee_image.dart';
import 'package:coffee_app/coffee/view/pages/favorites_page.dart';
import 'package:coffee_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoffeePage extends StatelessWidget {
  const CoffeePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appBarTitle),
        actions: [
          IconButton(
            key: const Key('SeeFavoritesButton'),
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () async {
              final cubit = context.read<CoffeeCubit>();
              final result = await Navigator.of(context).push(
                MaterialPageRoute<LocalCoffeeImage>(
                  builder: (context) => BlocProvider.value(
                    value: cubit,
                    child: const FavoritesPage(),
                  ),
                ),
              );
              if (result != null) {
                await cubit.loadFavoriteImage(result);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: BlocConsumer<CoffeeCubit, CoffeeState>(
                listener: (BuildContext context, CoffeeState state) {
                  if (state.status == CoffeeStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        dismissDirection: DismissDirection.none,
                        showCloseIcon: true,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        content: Text(
                          state.message ?? l10n.errorMessage,
                        ),
                      ),
                    );
                  }
                },
                buildWhen: (previous, current) =>
                    previous.image != current.image,
                builder: (context, state) {
                  final image = state.image;
                  switch (image?.runtimeType) {
                    case RemoteCoffeeImage:
                      return Image.network(
                        image!.imageUrl,
                        key: Key('Remote_${image.imageUrl}'),
                        fit: BoxFit.contain,
                      );
                    case LocalCoffeeImage:
                      final file = File(image!.imageUrl);
                      return Image.file(
                        file,
                        key: Key('Local_${image.imageUrl}'),
                        fit: BoxFit.contain,
                      );
                  }
                  return Container(key: const Key('NoImageCoffeeState'));
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<CoffeeCubit, CoffeeState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        FloatingActionButton(
                          key: const Key('FavoriteButton'),
                          heroTag: 'FavoriteButton',
                          onPressed: state.isLoading || state.isFavorite
                              ? null
                              : context.read<CoffeeCubit>().saveFavoriteImage,
                          child: state.isLoading
                              ? const CircularProgressIndicator.adaptive()
                              : Icon(
                                  state.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FloatingActionButton.extended(
                            key: const Key('NextButton'),
                            heroTag: 'NextButton',
                            onPressed: state.isLoading
                                ? null
                                : context.read<CoffeeCubit>().fetchRemoteImage,
                            icon: state.isLoading
                                ? null
                                : const Icon(Icons.skip_next),
                            label: state.isLoading
                                ? const CircularProgressIndicator.adaptive()
                                : Text(l10n.nextButtonTitle),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
