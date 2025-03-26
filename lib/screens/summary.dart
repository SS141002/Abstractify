import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:abstractify/models/floatingactbutton.dart';
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

  PlatformFile? pickedFile;
  String? selectedFileName;
  String selectedMode = 'Extractive'; // Default summarization mode

  double _submitButtonScale = 1.0;
  double _fileButtonScale = 1.0;

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
      withData: true,
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

      if (pickedFile != null) {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.fields['min'] = minLength.toString();
        request.fields['max'] = maxLength.toString();
        request.fields['mode'] = selectedMode;
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
          SnackBar(content: Text("Min length cannot be greater than max length")),
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
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        MouseRegion(
                          onEnter: (_) => setState(() => _fileButtonScale = 1.1),
                          onExit: (_) => setState(() => _fileButtonScale = 1.0),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            transform: Matrix4.identity()..scale(_fileButtonScale),
                            child: ElevatedButton(
                              onPressed: _pickFile,
                              child: Text('Choose File'),
                            ),
                          ),
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
                      children: [
                        Text(
                          'Summarization Mode:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedMode,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMode = newValue!;
                            });
                          },
                          items: <String>['Extractive', 'Abstractive', 'Bullet Points']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _textController,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        decoration: const InputDecoration(
                          hintText: "Enter your text here (or choose a file above)",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (pickedFile == null && (value == null || value.trim().isEmpty)) {
                            return "Enter text to summarize or choose a file";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                          height: 75,
                          child: Lottie.asset(
                            "assets/animations/waiting.json",
                            frameRate: FrameRate(60),
                          ),
                        )
                            : MouseRegion(
                          onEnter: (_) => setState(() => _submitButtonScale = 1.1),
                          onExit: (_) => setState(() => _submitButtonScale = 1.0),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            transform: Matrix4.identity()..scale(_submitButtonScale),
                            child: FloatingActButton(
                              text: "Summarize",
                              func: _submitForm,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
