/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 21:57:44
 * @LastEditTime : 2022-10-14 21:57:44
 * @Description  : 
 */

import 'package:formz/formz.dart';

enum MessageInputValidationError { empty }

class MessageInput extends FormzInput<String, MessageInputValidationError> {
  const MessageInput.pure() : super.pure('');
  const MessageInput.dirty([super.value = '']) : super.dirty();

  @override
  MessageInputValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : MessageInputValidationError.empty;
  }
}

