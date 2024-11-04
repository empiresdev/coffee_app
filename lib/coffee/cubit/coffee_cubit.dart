import 'package:bloc/bloc.dart';
import 'package:coffee_app/coffee/models/models.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:equatable/equatable.dart';

part 'coffee_state.dart';

class CoffeeCubit extends Cubit<CoffeeState> {
  CoffeeCubit({required this.repository})
      : super(
          const CoffeeState(status: CoffeeStatus.initial),
        );

  final CoffeeRepository repository;

  Future<void> init() async {
    await Future.wait([fetchRemoteImage(), loadAllFavoriteImages()]);
  }

  Future<void> fetchRemoteImage() async {
    emit(state.copyWith(status: CoffeeStatus.loading, image: state.image));
    try {
      final coffeeImage = await repository.fetchRandomImage();
      emit(state.copyWith(status: CoffeeStatus.success, image: coffeeImage));
    } on Exception {
      emit(
        state.copyWith(
          status: CoffeeStatus.failure,
          image: state.image,
          messageId: 'fetchRandomImageFailureMessage',
        ),
      );
    }
  }

  Future<void> saveFavoriteImage() async {
    if (state.image == null) {
      return;
    }
    final currentImage = state.image!;
    emit(state.copyWith(status: CoffeeStatus.loading, image: currentImage));
    try {
      final favorites = await repository.addImage(currentImage);
      emit(
        state.copyWith(
          status: CoffeeStatus.success,
          image: favorites.last,
          favorites: favorites,
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          status: CoffeeStatus.failure,
          image: currentImage,
          messageId: 'saveImageFailureMessage',
        ),
      );
    }
  }

  Future<void> loadAllFavoriteImages() async {
    try {
      final favorites = await repository.fetchAllFavorites();
      emit(state.copyWith(favorites: favorites));
    } on Exception {
      emit(state.copyWith(favorites: []));
    }
  }

  Future<void> loadFavoriteImage(LocalCoffeeImage localCoffeeImage) async {
    emit(
      state.copyWith(
        status: CoffeeStatus.success,
        image: localCoffeeImage,
      ),
    );
  }
}
