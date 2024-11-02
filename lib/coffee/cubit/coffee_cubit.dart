import 'package:bloc/bloc.dart';
import 'package:coffee_app/coffee/models/models.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:equatable/equatable.dart';

part 'coffee_state.dart';

class CoffeeCubit extends Cubit<CoffeeState> {
  CoffeeCubit({
    required this.remoteRepository,
    required this.localRepository,
  }) : super(
          const CoffeeState(status: CoffeeStatus.initial),
        );

  final RemoteCoffeeRepository remoteRepository;
  final LocalCoffeeRepository localRepository;

  Future<void> fetchRemoteImage() async {
    emit(CoffeeState(status: CoffeeStatus.loading, image: state.image));
    try {
      final coffeeImage = await remoteRepository.fetchRandomImage();
      emit(CoffeeState(status: CoffeeStatus.success, image: coffeeImage));
    } on Exception {
      emit(CoffeeState(status: CoffeeStatus.failure, image: state.image));
    }
  }

  Future<void> saveFavoriteImage() async {
    if (state.image == null) {
      return;
    }
    final currentImage = state.image! as RemoteCoffeeImage;
    emit(CoffeeState(status: CoffeeStatus.loading, image: currentImage));
    try {
      final favorites = await localRepository.addImage(currentImage);
      emit(
        CoffeeState(
          status: CoffeeStatus.success,
          image: currentImage,
          favorites: favorites,
        ),
      );
    } on Exception {
      emit(CoffeeState(status: CoffeeStatus.failure, image: currentImage));
    }
  }
}
