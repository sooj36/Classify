import 'package:flutter/material.dart';
import 'package:weathercloset/utils/top_level_setting.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final String? hintText;
  bool? isObsecre = true;
  bool? enabled = true;

  CustomTextField({
    super.key,
    this.controller,
    this.data,
    this.hintText,
    this.isObsecre,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        obscureText: isObsecre ?? true,
        cursorColor: AppTheme.primaryColor,
        style: const TextStyle(fontSize: 14, color: AppTheme.textColor1),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.subBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.decorationColor1, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.decorationColor1, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
          prefixIcon: Icon(
            data,
            color: AppTheme.secondaryColor1,
            size: 18,
          ),
          focusColor: AppTheme.primaryColor,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppTheme.textColor2, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          suffixIcon: isObsecre == true
              ? IconButton(
                  icon: const Icon(
                    Icons.visibility_off,
                    color: AppTheme.textColor2,
                    size: 18,
                  ),
                  onPressed: () {
                    // 비밀번호 보기 기능은 StatefulWidget에서 구현해야 하므로 여기서는 구현하지 않음
                  },
                )
              : null,
        ),
      ),
    );
  }
}
