import 'package:flutter/material.dart';
import 'package:health_bridge/constant/color.dart';

class CustomTextField extends StatelessWidget {
  final String? hint1;
  final String? Function(String?) valid;
  final TextEditingController mycontroller;
  final int max;
  final String? lebal;
  bool? obscure = false;
  FocusNode? focusNode;
  Icon? icon;
  void Function()? onPressed;
  CustomTextField(
      {super.key,
      this.hint1,
      required this.mycontroller,
      required this.valid,
      required this.max,
      this.focusNode,
      this.lebal,
      this.obscure,
      this.icon,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: blue5,
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(top: 10, left: 4, right: 4),
      child: TextFormField(
        focusNode: focusNode,
        maxLines: max,
        validator: valid,
        controller: mycontroller,
        obscureText: obscure == null ? false : obscure!,
        decoration: lebal == null
            ? InputDecoration(
                hintText: hint1,
                suffixIcon: icon != null
                    ? IconButton(onPressed: onPressed, icon: icon!)
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(),
                ))
            : InputDecoration(
                label: Text(lebal!),
                suffixIcon: icon != null
                    ? IconButton(onPressed: onPressed, icon: icon!)
                    : null,
                hintText: hint1,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(),
                )),
      ),
    );
  }
}
