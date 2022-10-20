/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 15:34:08
 * @LastEditTime : 2022-10-20 16:00:22
 * @Description  : 
 */

import 'package:azlistview/azlistview.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

enum ContactStatus { added, pending, requesting }

class ContactModel extends ISuspensionBean {
  final UserInfo userInfo;
  final ContactStatus status;

  ContactModel({required this.userInfo, required this.status});

  @override
  String getSuspensionTag() {
    if(status == ContactStatus.pending) {
      return '⨂';
    }
    else if(status == ContactStatus.requesting) {
      return '⊙';
    }
    var pinyin = PinyinHelper.getPinyinE(userInfo.userName);
    var tag = pinyin.substring(0, 1).toUpperCase();
    if(!RegExp('[A-Z]').hasMatch(tag)) {
      tag = '#';
    }
    return tag;
  }
}
