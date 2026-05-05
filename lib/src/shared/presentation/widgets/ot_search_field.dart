import 'package:flutter/material.dart';

import '../../../app/ui_style.dart';

class OTSearchField extends StatelessWidget {
  const OTSearchField({
    required this.placeholder,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onTap,
    super.key,
  });

  final String placeholder;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: colors.mutedFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colors.tertiaryText,
              size: 20,
            ),
          ),
          textInputAction: TextInputAction.search,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
