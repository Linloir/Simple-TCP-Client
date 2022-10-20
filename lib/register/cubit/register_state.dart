/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 15:38:13
 * @LastEditTime : 2022-10-20 20:52:19
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:tcp_client/register/models/password.dart';
import 'package:tcp_client/register/models/username.dart';

class RegisterState extends Equatable {
  final Username username;
  final Password password;
  final String avatar;

  final FormzStatus status;
  final String info;

  const RegisterState({
    this.status = FormzStatus.pure,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.avatar = "",
    this.info = ""
  });

  RegisterState copyWith({
    FormzStatus? status,
    Username? username,
    Password? password,
    String? avatar,
    String? info,
  }) {
    return RegisterState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      info: info ?? this.info
    );
  }

  @override
  List<Object?> get props => [status, username, password, avatar, info];
}
