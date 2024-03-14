import 'package:flutter/material.dart';
import 'package:invigilatorpc/ui/widgets/text_field_container.dart';
import 'package:invigilatorpc/utils/constants.dart';

class RoundedInputField extends StatelessWidget {
  final String? hintText;
  final IconData icon;
  final TextEditingController? editingController;

  const RoundedInputField({
    Key? key,
    this.hintText,
    this.icon = Icons.person,
    this.editingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        cursorColor: kPrimaryColor,
        controller: editingController,
        enableInteractiveSelection: true,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kButtonColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
