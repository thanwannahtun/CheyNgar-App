import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputForm extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final bool enabled;
  final bool isMultiLine;
  final bool showEllipsisOnOverflow;
  final int? minLines;
  final int? maxLines;
  final double? width;
  final bool readOnly;
  final TextInputType? textInputType;
  final Function(String? value)? onTap;

  const InputForm({
    super.key,
    required this.label,
    required this.controller,
    this.width,
    this.minLines,
    this.maxLines,
    this.isRequired = true,
    this.enabled = true,
    this.textInputType = TextInputType.text,
    this.showEllipsisOnOverflow = false,
    this.isMultiLine = false,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        readOnly: readOnly,
        style: TextStyle(
          overflow: showEllipsisOnOverflow
              ? TextOverflow.ellipsis
              : TextOverflow.clip,
        ),
        validator: (value) {
          if ((controller.text.isEmpty) && isRequired) {
            return '$label ဖြည့်သွင်းပါ';
          }
          return null;
        },
        controller: controller,
        maxLines: isMultiLine ? maxLines : 1,
        minLines: minLines,
        maxLength: maxLines,
        enabled: enabled,
        keyboardType: textInputType,
        inputFormatters:
            textInputType ==
                const TextInputType.numberWithOptions(decimal: true)
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
            : [],
        decoration: InputDecoration(labelText: label),
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        onChanged: (value) {
          // field.didChange(value);
          onTap?.call(value);
        },
        onTap: () {
          onTap?.call(controller.text);
        },
      ),
    );
  }
}
