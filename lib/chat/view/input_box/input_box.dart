/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 17:54:30
 * @LastEditTime : 2022-10-15 00:27:39
 * @Description  : 
 */

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/chat/cubit/chat_cubit.dart';
import 'package:tcp_client/chat/view/input_box/cubit/input_cubit.dart';
import 'package:tcp_client/chat/view/input_box/cubit/input_state.dart';
import 'package:tcp_client/chat/view/input_box/model/input.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';

class InputBox extends StatelessWidget {
  InputBox({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessageInputCubit>(
      create:(context) => MessageInputCubit(
        chatCubit: context.read<ChatCubit>()
      ),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Expanded(
              child: BlocListener<MessageInputCubit, MessageInputState>(
                listenWhen: (previous, current) => previous.status != FormzStatus.pure && current.status == FormzStatus.pure,
                listener: (context, state) {
                  _controller.clear();
                },
                child: Builder(
                    builder: (context) => TextField(
                    controller: _controller,
                    onChanged: (value) {
                      context.read<MessageInputCubit>().onInputChange(MessageInput.dirty(value));
                    },
                  ),
                )
              ),
            ),
            IconButton(
              onPressed: () {
                var chatCubit = context.read<ChatCubit>();
                chatCubit.localServiceRepository.pickFile(FileType.any).then((file) async {
                  if(file != null) {
                    var newMessage = Message(
                      userid: (await SharedPreferences.getInstance()).getInt('userid')!,
                      targetid: chatCubit.userID,
                      content: basename(file.file.path),
                      contenttype: MessageType.file,
                      payload: file,
                      token: (await SharedPreferences.getInstance()).getInt('token')!
                    );
                    chatCubit.addMessage(newMessage);
                  }
                });
              }, 
              icon: const Icon(Icons.attach_file_rounded)
            ),
            BlocBuilder<MessageInputCubit, MessageInputState>(
              builder:(context, state) {
                return IconButton(
                  onPressed: state.status == FormzStatus.valid ? () {
                    context.read<MessageInputCubit>().onSubmission();
                  } : null,
                  icon: const Icon(Icons.send_rounded),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
