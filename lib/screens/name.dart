import 'dart:async';

import 'package:bytebank/components/container.dart';
import 'package:bytebank/models/name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class NameContainer extends BlocContainer {
  @override
  Widget build(BuildContext context) {
    return NameView();
  }
}

class NameView extends BlocContainer {

 final TextEditingController _nameController = TextEditingController();

 @override
  Widget build(BuildContext context) {
   _nameController.text = context.watch<NameCubit>().state;
    return Scaffold(
        appBar: AppBar(
          title: Text("name"),
        ),
        body: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Desired name"),
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: SizedBox(
                width: double.maxFinite,
                child: RaisedButton(
                  child: Text("Change"),
                  onPressed: () {
                    onPressed(context);
                    return Navigator.pop(context);
                  }
                ),
              ),
            )
          ],
        ));
  }

 FutureOr onPressed(BuildContext context) async {
   final name = _nameController.text;
   context.read<NameCubit>().change(name);
   FocusScope.of(context).requestFocus(FocusNode());
   return Future<void>.delayed(Duration(milliseconds: 1000));

 }
}
