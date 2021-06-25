import 'package:equatable/equatable.dart';

class Burrito extends Equatable {
  final String filling;
  final Set<String> sauce;
  final Set<String> extras;

  const Burrito({
    required this.filling,
    required this.sauce,
    required this.extras,
  });

  @override
  List<Object> get props => [filling, sauce, extras];

  @override
  bool get stringify => true;
}

class BurritoSauce {
  final String slug;
  final String name;

  BurritoSauce(
    this.slug,
    this.name,
  );
}

class BurritoOrder extends Equatable {
  final Burrito burrito;
  final int count;

  const BurritoOrder({
    required this.burrito,
    required this.count,
  });

  @override
  List<Object> get props => [burrito, count];

  @override
  bool get stringify => true;
}
