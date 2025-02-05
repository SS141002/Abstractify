import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:abstractify/screens/navdrawer.dart';
import 'package:abstractify/models/floatingactbutton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class TypedOcr extends StatefulWidget {
  const TypedOcr({super.key});

  @override
  State<TypedOcr> createState() => _TypedOcrState();
}

class _TypedOcrState extends State<TypedOcr> {
  final _otpTextController = TextEditingController();

  File? _imageFile;
  int port = 5000;
  bool isLoading = false;
  String? _selectedLanguage;
  var response = "";

  final List<String> _selectedlanguageCodes = [];
  final Map<String, String> _languages = {
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'Hindi': 'hi',
    'Italian': 'it',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Russian': 'ru'
  };

  String? filename(String path) {
    final regex = RegExp(r'[^\\/]+$');
    final match = regex.firstMatch(path);
    return match != null ? match.group(0) : '';
  }

  void _addLanguage(String language) {
    String code = _languages[language]!;

    if (!_selectedlanguageCodes.contains(code)) {
      setState(() {
        _selectedlanguageCodes.add(code);
      });
    }
  }

  void _removeLanguage(String code) {
    setState(() {
      _selectedlanguageCodes.remove(code);
    });
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> sendImage() async {
    final String url = "http://127.0.0.1:$port/ocr/typed";

    if (_imageFile != null) {
      if (_selectedlanguageCodes.isNotEmpty) {
        var uri = Uri.parse(url);
        var request = http.MultipartRequest('POST', uri);

        request.files.add(
          await http.MultipartFile.fromPath('image', _imageFile!.path),
        );

        request.fields['languages'] = jsonEncode(_selectedlanguageCodes);
        try {
          setState(() {
            isLoading = true;
          });
          _otpTextController.clear();
          final res = await request.send().timeout(
            Duration(
              seconds: 10,
            ),
            onTimeout: () {
              throw TimeoutException("The request timed out..");
            },
          );
          setState(() {
            isLoading = false;
          });
          final resbody = await res.stream.bytesToString();

          if (res.statusCode == 200) {
            Map<String, dynamic> body = jsonDecode(resbody);
            response = body['text'];
          } else {
            response = "failed to upload : ${res.statusCode}";
          }
        } on TimeoutException catch (_) {
          isLoading = false;
          response = "The request timed out.";
        } catch (e) {
          response = 'Error $e';
        } finally {
          _otpTextController.text = response;
        }

        setState(() {
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Atleast 1 Language must be selected"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No Image Selected"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _otpTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Typed OCR",
        ),
        actions: [
          BackButton(),
        ],
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: pickImage,
                        child: Text("Select Image"),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: Text(
                          _imageFile != null
                              ? filename(_imageFile!.path)!
                              : "No image selected",
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DropdownButton<String>(
                    hint: Text("Select Language to Translate"),
                    value: _selectedLanguage,
                    items: _languages.keys.map((String language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue;
                      });

                      if (newValue != null) {
                        _addLanguage(newValue);
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedlanguageCodes.length,
                      itemBuilder: (context, index) {
                        String? language = _languages.keys.firstWhere((key) =>
                            _languages[key] == _selectedlanguageCodes[index]);
                        return ListTile(
                          title: Text(language),
                          trailing: IconButton(
                            onPressed: () {
                              _removeLanguage(_selectedlanguageCodes[index]);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        );
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
                          : FloatingActButton(
                              text: "Process",
                              func: sendImage,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
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
