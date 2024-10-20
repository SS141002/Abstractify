import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  final _formkey = GlobalKey<FormState>();

  final _minLengthController = TextEditingController(text: "10");
  final _maxLengthController = TextEditingController(text: "50");
  final _textController = TextEditingController();
  final _otpTextController = TextEditingController();

  int? minLength;
  int? maxLength;
  String? text;

  bool minLengthValid = true;
  bool maxLengthValid = true;

  var response = "";

  @override
  void dispose() {
    super.dispose();
    _minLengthController.dispose();
    _maxLengthController.dispose();
    _textController.dispose();
    _otpTextController.dispose();
  }

  Future<void> sendPostReq() async {
    final String url = "http://127.0.0.1:5000/summary";

    Map<String, dynamic> body = {
      'min': minLength,
      'max': maxLength,
      'text': text,
    };

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        setState(() {
          Map<String, dynamic> mp = jsonDecode(res.body);
          response = mp['summary']!;
          _otpTextController.text = response;
        });
      } else {
        setState(() {
          response = 'Failed to send data. Error : ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        response = 'Error $e';
      });
    }
  }

  void _submitForm() {
    if (_formkey.currentState!.validate()) {
      minLength = int.tryParse(_minLengthController.text);
      maxLength = int.tryParse(_maxLengthController.text);
      text = _textController.text;

      if (minLength == null || maxLength == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "please enter valid integer values for min length and mex length "),
          ),
        );
        return;
      }

      if (minLength! > maxLength!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("min length cannot be greater than max length"),
          ),
        );
      }
    }

    sendPostReq();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Summarizer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 250,
                          child: TextFormField(
                            controller: _minLengthController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              label: const Text(
                                "Min Length (Integer)",
                              ),
                              errorText: minLengthValid
                                  ? null
                                  : "Please enter a integer",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a minimum length";
                              }
                              if (int.tryParse(value)! < 5) {
                                return "Minimum Length Cannot be less than 5";
                              }
                              return null;
                            },
                            onChanged: (String val) {
                              final v = int.tryParse(val);

                              if (v == null) {
                                setState(() => minLengthValid = false);
                              } else {
                                setState(() => minLengthValid = true);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: TextFormField(
                            controller: _maxLengthController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                label: Text(
                                  "Max Length (Integer)",
                                ),
                                errorText: maxLengthValid
                                    ? null
                                    : "Please enter a integer"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a maximum length";
                              }
                              if (int.tryParse(value)! > 250) {
                                return "Minimum Length Cannot be more than 250";
                              }
                              return null;
                            },
                            onChanged: (String val) {
                              final v = int.tryParse(val);

                              if (v == null) {
                                setState(() => maxLengthValid = false);
                              } else {
                                setState(() => maxLengthValid = true);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _textController,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        decoration: const InputDecoration(
                          hintText: "Enter your text here",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text("Submit"),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                  child: TextField(
                    controller: _otpTextController,
                    readOnly: true,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
