import 'package:bloc/bloc.dart';
import 'package:coffee_app/coffee/models/models.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';
import 'package:equatable/equatable.dart';

part 'coffee_state.dart';

class CoffeeCubit extends Cubit<CoffeeState> {
  CoffeeCubit({required this.remoteRepository})
      : super(
          const CoffeeState(status: CoffeeStatus.initial),
        );

  final RemoteCoffeeRepository remoteRepository;

  Future<void> fetchRemoteImage() async {
    emit(const CoffeeState(status: CoffeeStatus.loading));
    try{
      final coffeeImage = await remoteRepository.fetchRandomImage();
      emit(CoffeeState(status: CoffeeStatus.success, image: coffeeImage));
    } on Exception {
      emit(const CoffeeState(status: CoffeeStatus.failure));
    }
  }
}
