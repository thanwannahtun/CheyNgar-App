import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/dropdown_data/dropdown_data_cubit.dart';

class EnumDropdown<T extends Enum> extends StatelessWidget {
  final String label;
  final List<T> items;
  // Optional: Pass an existing cubit the widget to look it up
  final DropdownDataCubit<T>? cubit;

  const EnumDropdown({
    super.key,
    required this.label,
    required this.items,
    this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    // Look up the cubit if not passed explicitly
    final effectiveCubit = cubit ?? context.read<DropdownDataCubit<T>>();

    return BlocBuilder<DropdownDataCubit<T>, DropdownDataState<T>>(
      bloc: effectiveCubit,
      builder: (context, state) {
        return DropdownButtonFormField<T>(
          decoration: InputDecoration(labelText: label),
          value: state.data,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item.name.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              )
              .toList(),
          onChanged: effectiveCubit.onDropdownChanged,
        );
      },
    );
  }
}
