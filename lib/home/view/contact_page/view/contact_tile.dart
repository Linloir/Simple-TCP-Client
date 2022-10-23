/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:02:00
 * @LastEditTime : 2022-10-20 16:26:33
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/chat/chat_page.dart';
import 'package:tcp_client/common/avatar/avatar.dart';
import 'package:tcp_client/common/username/username.dart';
import 'package:tcp_client/home/cubit/home_cubit.dart';
import 'package:tcp_client/home/cubit/home_state.dart';
import 'package:tcp_client/home/view/contact_page/cubit/contact_cubit.dart';
import 'package:tcp_client/home/view/contact_page/models/contact_model.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_cubit.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({
    required this.contactInfo,
    super.key
  });

  final ContactModel contactInfo;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Stack(
        fit: StackFit.expand,
        children: [
          InkWell(
            onTap: contactInfo.status == ContactStatus.added ? () {
              Navigator.of(context).push(ChatPage.route(
                userRepository: context.read<UserRepository>(),
                localServiceRepository: context.read<LocalServiceRepository>(),
                tcpRepository: context.read<TCPRepository>(),
                userID: contactInfo.userInfo.userID
              ));
              context.read<MessageListCubit>().addEmptyMessageOf(targetUser: contactInfo.userInfo.userID);
              context.read<HomeCubit>().switchPage(HomePagePosition.message);
            } : (){},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Row(
              children: [
                IgnorePointer(
                  child: UserAvatar(userid: contactInfo.userInfo.userID),
                ),
                const SizedBox(width: 12,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0
                    ),
                    child: IgnorePointer(
                      child: UserNameText(userid: contactInfo.userInfo.userID,)
                    ),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: contactInfo.status == ContactStatus.added ? null :
                          contactInfo.status == ContactStatus.pending ? 
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: LoadingIndicator(
                                indicatorType: Indicator.ballPulse, 
                                colors: [Colors.blue.withOpacity(0.5)],
                              ),
                            ) :
                          TextButton(
                            onPressed: () async {
                              context.read<ContactCubit>().tcpRepository.pushRequest(AddContactRequest(
                                userid: contactInfo.userInfo.userID, 
                                token: (await SharedPreferences.getInstance()).getInt('token')
                              ));
                            },
                            child: const Text('Confirm'),
                          ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
