import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DropdownDataState<T extends Enum> extends Equatable {
  final T? data;

  const DropdownDataState({this.data});

  @override
  List<Object?> get props => [data];
}

class DropdownDataCubit<T extends Enum> extends Cubit<DropdownDataState<T>> {
  DropdownDataCubit([T? initialValue])
    : super(DropdownDataState(data: initialValue));

  void onDropdownChanged(T? newValue) {
    emit(DropdownDataState(data: newValue));
  }

  void clearSelectedValue() {
    emit(const DropdownDataState(data: null));
  }
}
