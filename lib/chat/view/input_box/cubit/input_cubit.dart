/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 21:57:05
 * @LastEditTime : 2022-10-18 15:30:09
 * @Description  : 
 */

import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/chat/cubit/chat_cubit.dart';
import 'package:tcp_client/chat/view/input_box/cubit/input_state.dart';
import 'package:tcp_client/chat/view/input_box/model/input.dart';
import 'package:tcp_client/repositories/common_models/message.dart';

class MessageInputCubit extends Cubit<MessageInputState> {
  MessageInputCubit({
    required this.chatCubit,
  }): super(const MessageInputState());

  final ChatCubit chatCubit;

  void onInputChange(MessageInput input) {
    emit(state.copyWith(
      status: Formz.validate([input]),
      input: input
    ));
  }

  Future<void> onSubmission() async {
    chatCubit.addMessage(Message(
      userid: (await SharedPreferences.getInstance()).getInt('userid')!,
      targetid: chatCubit.userID,
      contenttype: MessageType.plaintext,
      content: state.input.value,
    ));
    emit(state.copyWith(
      status: FormzStatus.pure,
      input: const MessageInput.pure()
    ));
  }
}
