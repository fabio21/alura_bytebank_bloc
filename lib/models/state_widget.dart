import 'package:bytebank/models/transaction.dart';
import 'package:flutter/widgets.dart';

const String none = "InitWidgetState";
const String waiting = "LoadingWidgetState";
const String active = "InitContactsListState";
const String done = "LoadedWidgetState";
const String error =  "FatalErrorWidgetState";
const String finish = "FinishWidgetState";
const String send = "SendWidgetState";

@immutable
abstract class WidgetStateCreate {
  const WidgetStateCreate();
}

@immutable
class InitWidgetState extends WidgetStateCreate {
  const InitWidgetState();

  @override
  String toString() => "InitWidgetState";
}

@immutable
class LoadingWidgetState extends WidgetStateCreate {
  const LoadingWidgetState();

  @override
  String toString() => "LoadingWidgetState()";
}

@immutable
class LoadedWidgetState extends WidgetStateCreate {
  final Object contacts;

  const LoadedWidgetState(this.contacts);

  @override
  String toString() => "LoadedWidgetState";
}

@immutable
class SendWidgetState extends WidgetStateCreate {
  const SendWidgetState();
  @override
  String toString() => "SendWidgetState";
}

@immutable
class FinishWidgetState extends WidgetStateCreate {
  final Transaction transaction;
  const FinishWidgetState({this.transaction});

  @override
  String toString() => "FinishWidgetState";
}

@immutable
class FatalErrorWidgetState extends WidgetStateCreate {
  final String message;
  const FatalErrorWidgetState(this.message);
  @override
  String toString() => "FatalErrorWidgetState";
}
