/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 10:53:24
 * @LastEditTime : 2022-10-14 11:12:22
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/home/view/profile_page/cubit/log_out_cubit.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.read<LogOutCubit>().onLogout();
      },
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
        minimumSize: MaterialStateProperty.all(const Size(300, 0)),
        backgroundColor: MaterialStateProperty.all(Colors.red[700]),
        overlayColor: MaterialStateProperty.all(Colors.red[900]!.withOpacity(0.2)),
        foregroundColor: MaterialStateProperty.all(Colors.white),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12
        ),
        child: Text(
          'Log Out',
          style: TextStyle(
            fontSize: 20
          ),
        ),
      ),
    );
  }
}
