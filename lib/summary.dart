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
  int port = 5000;

  bool minLengthValid = true;
  bool maxLengthValid = true;
  bool isLoading = false;

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
    final String url = "http://127.0.0.1:$port/summary";

    Map<String, dynamic> body = {
      'min': minLength,
      'max': maxLength,
      'text': text,
    };

    try {
      setState(() {
        isLoading = true;
      });
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      setState(() {
        isLoading = false;
      });

      if (res.statusCode == 200) {
        Map<String, dynamic> mp = jsonDecode(res.body);
        response = mp['summary']!;
      } else {
        response = 'Failed to send data. Error : ${res.statusCode}';
      }
    } catch (e) {
      response = 'Error $e';
    } finally {
      _otpTextController.text = response;
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
        return;
      }
    }

    sendPostReq();
    _otpTextController.clear();
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
                        Expanded(
                          child: TextFormField(
                            controller: _minLengthController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Min Length (Integer)",
                              errorText: minLengthValid
                                  ? null
                                  : "Please enter a integer",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a minimum length";
                              }
                              if (int.tryParse(value) == null) {
                                return "please enter valid number";
                              } else {
                                int num = int.parse(value);
                                if (num < 5) {
                                  return "it should be > 5";
                                }
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
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _maxLengthController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: "Max Length (Integer)",
                                errorText: maxLengthValid
                                    ? null
                                    : "Please enter a integer"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a maximum length";
                              }
                              if (int.tryParse(value) == null) {
                                return "please enter valid number";
                              } else {
                                int num = int.parse(value);
                                if (num > 250) {
                                  return "it should be < 250";
                                }
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
                      height: 20,
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
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().isEmpty) {
                            return "Enter Text to summarize";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitForm,
                              child: Text("Summarize"),
                            ),
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
                      border: OutlineInputBorder(),
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
