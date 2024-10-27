import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Grammar extends StatefulWidget {
  const Grammar({super.key});

  @override
  State<Grammar> createState() => _GrammarState();
}

class _GrammarState extends State<Grammar> {
  final _formkey = GlobalKey<FormState>();

  final _textController = TextEditingController();
  final _otpTextController = TextEditingController();

  String? text;
  int port = 5000;
  bool isLoading = false;
  var response = "";

  Future<void> sendPostReq() async {
    final String url = "http://127.0.0.1:$port/grammar";

    Map<String, dynamic> body = {'text': text};

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
        response = mp['text'];
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
      text = _textController.text;
    }

    if (text == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Text cannot be null",
          ),
        ),
      );
      return;
    }

    sendPostReq();
    _otpTextController.clear();
  }

  @override
  void dispose() {
    _otpTextController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grammar Checker"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _textController,
                        expands: true,
                        minLines: null,
                        maxLines: null,
                        decoration: const InputDecoration(
                            hintText: "Enter your text here",
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitForm,
                              child: Text("Check"),
                            ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
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
            ),
          ],
        ),
      ),
    );
  }
}
