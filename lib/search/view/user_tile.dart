/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 21:41:41
 * @LastEditTime : 2022-10-23 10:30:24
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/common/avatar/avatar.dart';
import 'package:tcp_client/common/username/username.dart';
import 'package:tcp_client/profile/user_profile_page.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';
import 'package:tcp_client/search/cubit/search_cubit.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    required this.userInfo,
    super.key
  });

  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(ProfilePage.route(
          userID: userInfo.userID, 
          localServiceRepository: context.read<SearchCubit>().localServiceRepository,
          tcpRepository: context.read<SearchCubit>().tcpRepository,
          userRepository: context.read<UserRepository>()
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8,
        ),
        child: Row(
          children: [
            UserAvatar(userid: userInfo.userID),
            const SizedBox(width: 12,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0
                ),
                child: UserNameText(
                  userid: userInfo.userID,
                )
              )
            ),
          ],
        ),
      ),
    );
  }
}
