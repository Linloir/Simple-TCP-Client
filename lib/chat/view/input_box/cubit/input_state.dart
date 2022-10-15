/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 21:56:53
 * @LastEditTime : 2022-10-14 21:59:51
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:tcp_client/chat/view/input_box/model/input.dart';

class MessageInputState extends Equatable {
  final MessageInput input;

  final FormzStatus status;

  const MessageInputState({
    this.status = FormzStatus.pure,
    this.input = const MessageInput.pure()
  });

  MessageInputState copyWith({
    FormzStatus? status,
    MessageInput? input
  }) {
    return MessageInputState(
      input: input ?? this.input,
      status:  status ?? this.status
    );
  }

  @override
  List<Object> get props => [status, input];
}