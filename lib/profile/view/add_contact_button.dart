/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 09:34:53
 * @LastEditTime : 2022-10-14 12:00:52
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/chat/chat_page.dart';
import 'package:tcp_client/profile/cubit/user_profile_cubit.dart';
import 'package:tcp_client/profile/cubit/user_profile_state.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class AddContactButton extends StatelessWidget {
  const AddContactButton({
    required this.userID,
    super.key
  });

  final int userID;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        if(state.status == ContactStatus.isContact) {
          return TextButton(
            onPressed: () {
              Navigator.of(context).push(ChatPage.route(
                userRepository: context.read<UserRepository>(),
                localServiceRepository: context.read<LocalServiceRepository>(),
                tcpRepository: context.read<TCPRepository>(),
                userID: userID
              ));
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
              minimumSize: MaterialStateProperty.all(const Size(300, 0)),
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              overlayColor: MaterialStateProperty.all(Colors.blue[800]!.withOpacity(0.2)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12
              ),
              child: Text(
                'Chat',
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
          );
        }
        if(state.status == ContactStatus.pendingReply) {
          return TextButton(
            onPressed: null,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
              minimumSize: MaterialStateProperty.all(const Size(300, 0)),
              backgroundColor: MaterialStateProperty.all(Colors.grey[400]),
              overlayColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.2)),
              foregroundColor: MaterialStateProperty.all(Colors.grey[800]),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12
              ),
              child: Text(
                'Pending for Reply',
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
          );
        }
        else if(state.status == ContactStatus.notContact) {
          return TextButton(
            onPressed: () {
              context.read<UserProfileCubit>().addContact();
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
              minimumSize: MaterialStateProperty.all(const Size(300, 0)),
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              overlayColor: MaterialStateProperty.all(Colors.blue[800]!.withOpacity(0.2)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12
              ),
              child: Text(
                'Add Contact',
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
          );
        }
        else if(state.status == ContactStatus.consulting) {
          return TextButton(
            onPressed: null,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
              minimumSize: MaterialStateProperty.all(const Size(300, 0)),
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              overlayColor: MaterialStateProperty.all(Colors.blue[800]!.withOpacity(0.2)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12
              ),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            )
          );
        }
        else {
          return Container();
        }
      },
    );
  }
}
