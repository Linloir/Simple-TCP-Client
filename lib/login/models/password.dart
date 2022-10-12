/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 15:37:29
 * @LastEditTime : 2022-10-12 15:46:38
 * @Description  : 
 */

import 'package:formz/formz.dart';

enum PasswordValidationError { empty }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : PasswordValidationError.empty;
  }
}
