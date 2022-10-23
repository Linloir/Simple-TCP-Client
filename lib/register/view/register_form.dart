/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 16:29:25
 * @LastEditTime : 2022-10-23 10:28:12
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tcp_client/register/cubit/register_cubit.dart';
import 'package:tcp_client/register/cubit/register_state.dart';
import 'package:tcp_client/register/models/password.dart';
import 'package:tcp_client/register/models/username.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

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
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return TextField(
          onChanged: (username) {
            context.read<RegisterCubit>().onUsernameChange(Username.dirty(username));
          },
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          enableIMEPersonalizedLearning: false,
          enableSuggestions: false,
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
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => previous.password != current.password || previous.status != current.status,
      builder: (context, state) {
        return TextField(
          onChanged: (password) {
            context.read<RegisterCubit>().onPasswordChange(Password.dirty(password));
          },
          onEditingComplete: () {
            if(
              state.status == FormzStatus.valid || 
              state.status == FormzStatus.submissionFailure
            ) {
              context.read<RegisterCubit>().onSubmission();
            }
          },
          textInputAction: TextInputAction.done,
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
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return SizedBox(
          height: 40.0,
          width: 100.0,
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
            onPressed: () {
              if(
                state.status == FormzStatus.valid || 
                state.status == FormzStatus.submissionFailure
              ) {
                context.read<RegisterCubit>().onSubmission();
              }
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
                'REGISTER',
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
