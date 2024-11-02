import 'package:coffee_app/coffee/models/models.dart';

abstract class RemoteCoffeeRepository {
  Future<RemoteCoffeeImage> fetchRandomImage();
}
