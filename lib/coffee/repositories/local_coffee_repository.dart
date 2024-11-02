import 'package:coffee_app/coffee/models/models.dart';

abstract class LocalCoffeeRepository {
  Future<List<LocalCoffeeImage>> addImage(RemoteCoffeeImage remoteImage);
}
