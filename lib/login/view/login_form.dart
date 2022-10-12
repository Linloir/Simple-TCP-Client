/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 16:29:25
 * @LastEditTime : 2022-10-12 17:31:23
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tcp_client/login/bloc/login_cubit.dart';
import 'package:tcp_client/login/bloc/login_state.dart';
import 'package:tcp_client/login/models/password.dart';
import 'package:tcp_client/login/models/username.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        UsernameInput(),
        SizedBox(height: 8,),
        PasswordInput(),
        SizedBox(height: 28,),
        SubmitButton()
      ],
    );
  }
}

class UsernameInput extends StatelessWidget {
  const UsernameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return TextField(
          onChanged: (username) {
            context.read<LoginCubit>().onUsernameChange(Username.dirty(username));
          },
          decoration: InputDecoration(
            labelText: 'Username',
            errorText: state.username.invalid ? 'Invalid username' : null
          ),
        );
      },
    );
  }
}

class PasswordInput extends StatelessWidget {
  const PasswordInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) {
            context.read<LoginCubit>().onPasswordChange(Password.dirty(password));
          },
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: state.password.invalid ? 'Invalid password' : null
          ),
        );
      },
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return SizedBox(
          height: 40.0,
          width: 90.0,
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)))),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                switch(states) {
                  case {MaterialState.disabled}:
                    return Colors.grey;
                  case {MaterialState.pressed}:
                    return Colors.blue[800];
                  default:
                    return Colors.blue[700];
                }
              }),
              overlayColor: MaterialStateProperty.all(Colors.blue[900]!.withOpacity(0.2))
            ),
            onPressed: state.status == FormzStatus.submissionInProgress ? null : () {
              context.read<LoginCubit>().onSubmission();
            },
            child: state.status == FormzStatus.submissionInProgress ?
              const SizedBox(
                height: 14.0,
                width: 14.0,
                child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                ),
              ) :
              const Text(
                'LOGIN',
                style: TextStyle(
                  color: Colors.white
                ),
              )
          )
        );
      },
    );
  }
}
