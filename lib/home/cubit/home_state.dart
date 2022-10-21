/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:02:24
 * @LastEditTime : 2022-10-21 23:28:33
 * @Description  : 
 */

import 'package:equatable/equatable.dart';

enum HomePageStatus { initializing, done }

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
  final HomePageStatus status;

  const HomeState({required this.page, required this.status});

  HomeState copyWith({HomePagePosition? page, HomePageStatus? status}) {
    return HomeState(page: page ?? this.page, status: status ?? this.status);
  }

  @override
  List<Object> get props => [page, status];
}
