/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 11:05:08
 * @LastEditTime : 2022-10-12 11:03:13
 * @Description  : 
 */

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(builder: (context) => const HomePage());

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
