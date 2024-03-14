import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/signup_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/utils/constants.dart';

class UniversityField extends StatefulWidget {
  @override
  _UniversityFieldState createState() => _UniversityFieldState();
}

class _UniversityFieldState extends State<UniversityField> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ChangeNotifierProvider<SignupViewModel?>.value(
        value: serviceLocator<SignupViewModel>(),
        child: Consumer<SignupViewModel>(
            builder: (context, model, child) => Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  width: size.width * 0.3,
                  decoration: BoxDecoration(
                    color: kPrimaryLightColor,
                    borderRadius: BorderRadius.circular(29),
                  ),
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.school,
                              color: kButtonColor,
                            ),
                            filled: true,
                            fillColor: kPrimaryLightColor,
                            border: InputBorder.none),
                        isEmpty: model.currentSelectedValue == '',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: kPrimaryLightColor,
                            value: model.currentSelectedValue,
                            isExpanded: true,
                            isDense: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                model.currentSelectedValue = newValue;
                                model.inputFields['university_title'] =
                                    newValue;
                              });
                            },
                            items: model.universities.map((String? value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  transform: Matrix4.translationValues(
                                      -10.0, 0.0, 0.0),
                                  child: Text(
                                    value!,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.grey[700]),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                )));
  }
}
