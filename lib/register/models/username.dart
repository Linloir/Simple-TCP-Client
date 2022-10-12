/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 15:37:34
 * @LastEditTime : 2022-10-12 15:45:11
 * @Description  : 
 */

import 'package:formz/formz.dart';

enum UsernameValidationError { empty }

class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure(): super.pure('');
  const Username.dirty([super.value = '']): super.dirty();

  @override
  UsernameValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : UsernameValidationError.empty;
  }
}
