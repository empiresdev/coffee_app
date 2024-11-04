import 'package:coffee_app/app/app.dart';
import 'package:coffee_app/bootstrap.dart';
import 'package:coffee_app/coffee/repositories/repositories.dart';

void main() {
  bootstrap(
    () => App(
      coffeeRepository: HttpFileCoffeeRepository(),
    ),
  );
}
