import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerFormField extends StatefulWidget {
  /// **if [firstDate] is not provided, it defaults to [today]'s date**
  const DatePickerFormField({
    super.key,
    this.value,
    required this.label,
    this.onChanged,
    this.width,
    this.firstDate,
    this.validateionEnabled = true,
  });

  final DateTime? value;
  final DateTime? firstDate;
  final String label;
  final double? width;

  final bool validateionEnabled;
  final ValueChanged<DateTime?>? onChanged;

  @override
  State<DatePickerFormField> createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  DateTime? selectedDate;

  // final GlobalKey<FormFieldState<DateTime>> _fieldKey =
  //     GlobalKey<FormFieldState<DateTime>>();

  @override
  void initState() {
    selectedDate = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DatePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value && widget.value != selectedDate) {
      selectedDate = widget.value;

      // Sync FormField internal state
      // _fieldKey.currentState?.didChange(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    void selectDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: widget.value ?? DateTime.now(),
        firstDate: widget.firstDate ?? DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 100),
      );
      if (picked != null && picked != widget.value) {
        widget.onChanged?.call(picked);
        setState(() {
          selectedDate = picked;
        });
      }
    }

    return SizedBox(
      width: widget.width,
      child: GestureDetector(
        onTap: selectDate,
        child: FormField<DateTime>(
          validator: widget.validateionEnabled
              ? (date) {
                  if (selectedDate == null) {
                    return 'Please select a date';
                  }
                  return null;
                }
              : null,
          builder: (FormFieldState<DateTime> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(widget.label),
                // const SizedBox(height: 8),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: widget.label,
                    // hintText: widget.label,
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Theme.of(context).colorScheme.surface,
                    // filled: true,
                  ),
                  child: Text(
                    widget.value != null
                        ? DateFormat.yMMMd().format(widget.value!)
                        : 'Select date',
                    style: TextStyle(
                      color: widget.value != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (field.errorText != null)
                  Text(
                    field.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// class DatePickerFormField extends FormField<DateTime> {
//   /// **if [firstDate] is not provided, it defaults to [today]'s date**
//   DatePickerFormField({
//     super.key,
//     DateTime? value,
//     required String label,
//     DateTime? firstDate,
//     double? width,
//     ValueChanged<DateTime?>? onChanged,
//   }) : super(
//          initialValue: value,
//          validator: (date) {
//            if (date == null) {
//              return 'Please select a date';
//            }
//            return null;
//          },
//          builder: (FormFieldState<DateTime> field) {
//            //  final state = field as _DatePickerFormFieldState;

//            Future<void> selectDate() async {
//              final picked = await showDatePicker(
//                context: field.context,
//                initialDate: field.value ?? DateTime.now(),
//                firstDate: firstDate ?? DateTime.now(),
//                lastDate: DateTime(DateTime.now().year + 10),
//              );

//              if (picked != null && picked != field.value) {
//                field.didChange(picked);
//                onChanged?.call(picked);
//              }
//            }

//            return SizedBox(
//              width: width,
//              child: GestureDetector(
//                onTap: selectDate,
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: [
//                    Text(label),
//                    const SizedBox(height: 8),
//                    InputDecorator(
//                      decoration: InputDecoration(
//                        hintText: label,
//                        hintStyle: const TextStyle(color: Colors.grey),
//                        fillColor: Theme.of(field.context).colorScheme.surface,
//                      ),
//                      child: Text(
//                        field.value != null
//                            ? DateFormat.yMMMd().format(field.value!)
//                            : 'Select date',
//                        style: TextStyle(
//                          color:
//                              field.value != null
//                                  ? Theme.of(field.context).colorScheme.onSurface
//                                  : Colors.grey.shade600,
//                        ),
//                      ),
//                    ),
//                    if (field.errorText != null)
//                      Padding(
//                        padding: const EdgeInsets.only(top: 4),
//                        child: Text(
//                          field.errorText!,
//                          style: TextStyle(
//                            color: Theme.of(field.context).colorScheme.error,
//                            fontSize: 12,
//                          ),
//                        ),
//                      ),
//                  ],
//                ),
//              ),
//            );
//          },
//        );

//   @override
//   FormFieldState<DateTime> createState() => _DatePickerFormFieldState();
// }

// class _DatePickerFormFieldState extends FormFieldState<DateTime> {
//   @override
//   void didUpdateWidget(covariant DatePickerFormField oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     final newValue = (widget as DatePickerFormField).initialValue;

//     if (newValue != value) {
//       didChange(newValue);
//     }
//   }
// }
