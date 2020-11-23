import 'package:flutter_bloc/flutter_bloc.dart';

class NameCubit extends Cubit<String> {
  NameCubit(String state) : super(state);

  void change(String name) => emit(name);
}
