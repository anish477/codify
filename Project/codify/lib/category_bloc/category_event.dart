import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
}

class SelectCategory extends CategoryEvent {
  final String category;

  const SelectCategory(this.category);

  @override
  List<Object> get props => [category];
}