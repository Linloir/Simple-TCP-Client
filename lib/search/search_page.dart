/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 17:04:12
 * @LastEditTime : 2022-10-13 17:08:13
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:tcp_client/search/view/search_bar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SearchBar(),
      ),
    );
  }
}
