import 'package:equatable/equatable.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

}

class CategoryInitial extends CategoryState {
  @override
  List<Object> get props => [];
}

class CategorySelected extends CategoryState {
  final String category;

  const CategorySelected(this.category);

  @override
  List<Object> get props => [category];
}