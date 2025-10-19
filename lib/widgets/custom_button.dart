import 'package:flutter/material.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  final Color? backgroundColor;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 16,
    this.backgroundColor = AppColors.white,
    this.color = AppColors.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.05;

    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: color,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
