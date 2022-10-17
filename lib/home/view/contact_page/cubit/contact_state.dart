/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:01:39
 * @LastEditTime : 2022-10-17 17:28:33
 * @Description  : 
 */

import 'package:azlistview/azlistview.dart';
import 'package:equatable/equatable.dart';
import 'package:tcp_client/home/view/contact_page/models/contact_model.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class ContactState extends Equatable {
  final List<UserInfo> contacts;
  final List<UserInfo> pending;
  final List<UserInfo> requesting;

  const ContactState({
    required this.contacts,
    required this.pending,
    required this.requesting
  });

  static ContactState empty() => const ContactState(contacts: [], pending: [], requesting: []);

  List<ISuspensionBean> get indexedData {
    var indexedList = contacts.map((e) => ContactModel(userInfo: e)).toList();
    indexedList.sort((a, b) => a.getSuspensionTag().compareTo(b.getSuspensionTag()));
    // SuspensionUtil.sortListBySuspensionTag(indexedList);
    SuspensionUtil.setShowSuspensionStatus(indexedList);
    return indexedList;
  }

  @override
  List<Object> get props => contacts;
}
