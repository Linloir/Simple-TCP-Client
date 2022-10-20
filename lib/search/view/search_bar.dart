/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 17:06:52
 * @LastEditTime : 2022-10-20 17:30:37
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/search/cubit/search_cubit.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: TextField(
        onChanged: (value) {
          context.read<SearchCubit>().onKeyChanged(value);
        },
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0
        ),
        showCursor: true,
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          border: InputBorder.none
          // errorBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.red, width: 2.0)
          // ),
          // disabledBorder: InputBorder.none,
          // enabledBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.blue, width: 2.0)
          // ),
          // focusedBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.white, width: 2.0)
          // )
        ),
      ),
    );
  }
}
