/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:02:24
 * @LastEditTime : 2022-10-13 16:55:05
 * @Description  : 
 */

import 'package:equatable/equatable.dart';

enum HomePagePosition { 
  message(0), 
  contact(1), 
  profile(2);

  const HomePagePosition(int value): _value = value;
  final int _value;
  final List<String> _literals = const ['Messages', 'Contacts', 'Me'];
  int get value => _value;
  String get literal => _literals[value];

  //Construct the enum type by value
  factory HomePagePosition.fromValue(int value) {
    return HomePagePosition.values.firstWhere((element) => element._value == value, orElse: () => HomePagePosition.message);
  }
}

class HomeState extends Equatable {
  final HomePagePosition page;

  const HomeState({required this.page});

  HomeState copyWith({HomePagePosition? page}) {
    return HomeState(page: page ?? this.page);
  }

  @override
  List<Object> get props => [page];
}
