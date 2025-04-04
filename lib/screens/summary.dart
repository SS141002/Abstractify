import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:abstractify/widgets/floatingactbutton.dart';
import 'package:abstractify/screens/navdrawer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  final _formkey = GlobalKey<FormState>();

  final _minLengthController = TextEditingController(text: "20");
  final _maxLengthController = TextEditingController(text: "80");
  final _textController = TextEditingController();
  final _otpTextController = TextEditingController();

  String? response;
  int? minLength;
  int? maxLength;
  int port = 5000;
  bool minLengthValid = true;
  bool maxLengthValid = true;
  bool isLoading = false;

  // Variables for file picker and summarization mode
  PlatformFile? pickedFile;
  String? selectedFileName;
  String selectedMode = 'Extractive'; // Default summarization mode

  @override
  void dispose() {
    _minLengthController.dispose();
    _maxLengthController.dispose();
    _textController.dispose();
    _otpTextController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
      withData: true, // to get bytes directly
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFile = result.files.single;
        selectedFileName = pickedFile!.name;
      });
    }
  }

  Future<void> sendPostReq() async {
    final String url = "http://127.0.0.1:$port/summary";
    http.Response res;
    try {
      setState(() {
        isLoading = true;
      });
      // If a file is selected, send a multipart request
      if (pickedFile != null) {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.fields['min'] = minLength.toString();
        request.fields['max'] = maxLength.toString();
        request.fields['mode'] = selectedMode;
        // Add the file using its bytes and secure filename
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          pickedFile!.bytes!,
          filename: pickedFile!.name,
        ));
        var streamedResponse = await request.send().timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException("The request timed out.");
          },
        );
        res = await http.Response.fromStream(streamedResponse);
      } else {
        // Otherwise, send JSON payload with text from the input field
        Map<String, dynamic> body = {
          'min': minLength,
          'max': maxLength,
          'mode': selectedMode,
          'text': _textController.text,
        };
        res = await http
            .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException("The request timed out.");
          },
        );
      }
      if (res.statusCode == 200) {
        Map<String, dynamic> mp = jsonDecode(res.body);
        response = mp['summary']!;
      } else {
        response = 'Failed to send data. Error: ${res.statusCode}';
      }
    } on TimeoutException catch (_) {
      response = "The request timed out.";
    } catch (e) {
      response = 'Error: $e';
    } finally {
      _otpTextController.text = response ?? "";
      setState(() {
        isLoading = false;
      });
    }
  }

  void _submitForm() {
    if (_formkey.currentState!.validate()) {
      minLength = int.tryParse(_minLengthController.text);
      maxLength = int.tryParse(_maxLengthController.text);

      if (minLength! > maxLength!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Min length cannot be greater than max length")),
        );
        return;
      }
      _otpTextController.clear();
      sendPostReq();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Summarizer"),
        actions: [BackButton()],
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Form(
          key: _formkey,
          child: Row(
            children: [
              // Left side: Input area
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _pickFile,
                          child: Text('Choose File'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedFileName ?? 'No file selected',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
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
                                  : "Please enter an integer",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter a minimum length";
                              }
                              if (int.tryParse(value) == null) {
                                return "Enter a valid number";
                              }
                              int num = int.parse(value);
                              if (num < 5) {
                                return "It should be > 5";
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() {
                                minLengthValid = int.tryParse(val) != null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: TextFormField(
                            controller: _maxLengthController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Max Length (Integer)",
                              errorText: maxLengthValid
                                  ? null
                                  : "Please enter an integer",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter a maximum length";
                              }
                              if (int.tryParse(value) == null) {
                                return "Enter a valid number";
                              }
                              int num = int.parse(value);
                              if (num > 250) {
                                return "It should be < 250";
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() {
                                maxLengthValid = int.tryParse(val) != null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Summarization Mode:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedMode,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMode = newValue!;
                            });
                          },
                          items: <String>[
                            'Extractive',
                            'Abstractive',
                            'Bullet Points'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Text input for summary if no file is chosen
                    Expanded(
                      child: TextFormField(
                        controller: _textController,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        decoration: const InputDecoration(
                          hintText:
                              "Enter your text here (or choose a file above)",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (pickedFile == null &&
                              (value == null || value.trim().isEmpty)) {
                            return "Enter text to summarize or choose a file";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          // Smooth transition effect
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeInOut,
                          child: isLoading
                              ? SizedBox(
                                  height: 75,
                                  key: ValueKey(
                                      1), // Unique key to trigger animation
                                  child: Lottie.asset(
                                    "assets/animations/waiting.json",
                                    frameRate: FrameRate(60),
                                  ),
                                )
                              : FloatingActButton(
                                  key: ValueKey(
                                      2), // Unique key for smooth switch
                                  text: "Summarize",
                                  func: isLoading
                                      ? () {}
                                      : _submitForm, // Disable button if loading
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right side: Display summary result
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
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
      ),
    );
  }
}
