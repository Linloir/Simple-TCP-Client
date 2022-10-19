/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 17:54:30
 * @LastEditTime : 2022-10-19 23:33:25
 * @Description  : 
 */

import 'dart:convert';

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
import 'package:tcp_client/repositories/local_service_repository/models/local_file.dart';

class InputBox extends StatelessWidget {
  InputBox({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessageInputCubit>(
      create:(context) => MessageInputCubit(
        chatCubit: context.read<ChatCubit>()
      ),
      child: Container(
        // height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: BlocListener<MessageInputCubit, MessageInputState>(
                listenWhen: (previous, current) => previous.status != FormzStatus.pure && current.status == FormzStatus.pure,
                listener: (context, state) {
                  _controller.clear();
                },
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: Builder(
                    builder: (context) => TextField(
                      controller: _controller,
                      onChanged: (value) {
                        context.read<MessageInputCubit>().onInputChange(MessageInput.dirty(value));
                      },
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1.0
                          )
                        ),
                        hintText: 'Input message here'
                      ),
                    ),
                  ),
                )
              ),
            ),
            const SizedBox(width: 8.0,),
            IconButton(
              onPressed: () {
                var chatCubit = context.read<ChatCubit>();
                chatCubit.localServiceRepository.pickFile(FileType.any).then((file) async {
                  if(file != null) {
                    var newMessage = Message(
                      userid: (await SharedPreferences.getInstance()).getInt('userid')!,
                      targetid: chatCubit.userID,
                      content: basename(file.path),
                      contenttype: MessageType.file,
                      payload: LocalFile(file: file, filemd5: ""),
                    );
                    chatCubit.addMessage(newMessage);
                  }
                });
              }, 
              icon: Icon(Icons.attach_file_rounded, color: Colors.grey[700],)
            ),
            const SizedBox(width: 8.0,),
            IconButton(
              onPressed: () {
                var chatCubit = context.read<ChatCubit>();
                chatCubit.localServiceRepository.pickFile(FileType.image).then((img) async {
                  if(img != null) {
                    var newMessage = Message(
                      userid: (await SharedPreferences.getInstance()).getInt('userid')!,
                      targetid: chatCubit.userID,
                      content: base64.encode(await img.readAsBytes()),
                      contenttype: MessageType.image,
                    );
                    chatCubit.addMessage(newMessage);
                  }
                });
              }, 
              icon: Icon(Icons.photo_rounded, color: Colors.grey[700],)
            ),
            const SizedBox(width: 8.0,),
            BlocBuilder<MessageInputCubit, MessageInputState>(
              builder:(context, state) {
                return IconButton(
                  onPressed: state.status == FormzStatus.valid ? () {
                    context.read<MessageInputCubit>().onSubmission();
                  } : null,
                  icon: const Icon(Icons.send_rounded),
                  color: state.status == FormzStatus.valid ? Colors.blue : Colors.grey[400],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
