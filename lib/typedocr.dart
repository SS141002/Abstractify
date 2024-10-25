import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class TypedOcr extends StatefulWidget {
  const TypedOcr({super.key});

  @override
  State<TypedOcr> createState() => _TypedOcrState();
}

class _TypedOcrState extends State<TypedOcr> {
  final _otpTextController = TextEditingController();
  File? _imageFile;
  int port = 5000;
  String? _selectedLanguage;
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
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    } else {}
  }

  Future<void> sendImage() async {
    final String url = "http://127.0.0.1:$port/ocrtyped";

    if (_imageFile != null) {
      if (_selectedlanguageCodes.isNotEmpty) {
        var uri = Uri.parse(url);
        var request = http.MultipartRequest('POST', uri);

        request.files.add(
          await http.MultipartFile.fromPath('image', _imageFile!.path),
        );

        request.fields['languages'] = jsonEncode(_selectedlanguageCodes);

        final res = await request.send();
        final resbody = await res.stream.bytesToString();

        if (res.statusCode == 200) {
          Map<String, dynamic> response = jsonDecode(resbody);
          _otpTextController.text = response['text'];
        } else {
          _otpTextController.text = "failed to upload : ${res.statusCode}";
        }
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
        title: Text("Typed OCR"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
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
                  Row(
                    children: [
                      Spacer(),
                      ElevatedButton(
                        onPressed: sendImage,
                        child: Text("Process"),
                      ),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
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
