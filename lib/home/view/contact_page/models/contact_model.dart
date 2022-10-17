/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 15:34:08
 * @LastEditTime : 2022-10-17 17:20:47
 * @Description  : 
 */

import 'package:azlistview/azlistview.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class ContactModel extends ISuspensionBean {
  final UserInfo userInfo;

  ContactModel({required this.userInfo});

  @override
  String getSuspensionTag() {
    var pinyin = PinyinHelper.getPinyinE(userInfo.userName);
    var tag = pinyin.substring(0, 1).toUpperCase();
    if(!RegExp('[A-Z]').hasMatch(tag)) {
      tag = '#';
    }
    return tag;
  }
}
