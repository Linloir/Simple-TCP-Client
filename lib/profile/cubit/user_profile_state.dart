/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 08:54:25
 * @LastEditTime : 2022-10-14 09:11:04
 * @Description  : 
 */

import 'package:equatable/equatable.dart';

enum ContactStatus { isContact, pendingReply, notContact, consulting, none }

class UserProfileState extends Equatable {
  final ContactStatus status;

  const UserProfileState({required this.status});

  @override
  List<Object> get props => [status];
}
