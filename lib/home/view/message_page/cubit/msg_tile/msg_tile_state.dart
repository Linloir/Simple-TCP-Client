/*
 * @Author       : Linloir
 * @Date         : 2022-10-23 16:30:52
 * @LastEditTime : 2022-10-23 16:40:47
 * @Description  : 
 */

import 'package:equatable/equatable.dart';

class MessageTileState extends Equatable {
  final int unreadCount;

  const MessageTileState({required this.unreadCount});

  MessageTileState operator +(int other) {
    return MessageTileState(unreadCount: unreadCount + other);
  }

  @override
  List<Object> get props => [unreadCount];
}
