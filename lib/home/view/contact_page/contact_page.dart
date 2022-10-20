/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 23:36:07
 * @LastEditTime : 2022-10-20 17:04:52
 * @Description  : 
 */

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/home/view/contact_page/cubit/contact_cubit.dart';
import 'package:tcp_client/home/view/contact_page/cubit/contact_state.dart';
import 'package:tcp_client/home/view/contact_page/models/contact_model.dart';
import 'package:tcp_client/home/view/contact_page/view/contact_tile.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactCubit, ContactState>(
      builder: (context, state) {
        var indexedData = state.indexedData;
        return AzListView(
          data: indexedData,
          itemCount: indexedData.length,
          itemBuilder: (context, index) {
            return ContactTile(
              contactInfo: (indexedData[index] as ContactModel),
            );
          },
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          susItemBuilder: (context, index) {
            return Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 16.0),
              color: Colors.grey[200],
              alignment: Alignment.centerLeft,
              child: Text(
                indexedData[index].getSuspensionTag() == '⨂' ? 'Pending for reply' : indexedData[index].getSuspensionTag() == '⊙' ? 'Requesting' : indexedData[index].getSuspensionTag(),
                softWrap: false,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[700],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
