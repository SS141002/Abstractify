import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:abstractify/screens/imagepreview.dart';
import 'package:flutter/material.dart';
import 'package:abstractify/screens/navdrawer.dart';
import 'package:abstractify/models/floatingactbutton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

enum MethodDt { dilated, lineDetection }

class HandOcr extends StatefulWidget {
  const HandOcr({super.key});

  @override
  State<HandOcr> createState() => _HandOcrState();
}

class _HandOcrState extends State<HandOcr> {
  final _formKey = GlobalKey<FormState>();

  final _kWidthController = TextEditingController();
  final _kHeightController = TextEditingController();
  final _overlapUpperController = TextEditingController();
  final _overlapLowerController = TextEditingController();
  final _minHeightController = TextEditingController();
  final _minWhiteController = TextEditingController(text: "125");
  final _maxWhiteController = TextEditingController(text: "225");
  final _otpTextController = TextEditingController();

  bool kernelHeightValid = true;
  bool kernelWidthValid = true;
  bool overlapUpperValid = true;
  bool overlapLowerValid = true;
  bool minThresValid = true;
  bool minWhiteValid = true;
  bool maxWhiteValid = true;
  bool isLoading = false;

  File? _imageFile;
  String response = "";
  String image1 = "";
  String image2 = "";

  int port = 5000;
  int? imgWidth, imgHeight;
  MethodDt method = MethodDt.dilated;

  String? filename(String path) {
    final regex = RegExp(r'[^\\/]+$');
    final match = regex.firstMatch(path);
    return match != null ? match.group(0) : '';
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
      var decodedImage = await decodeImageFromList(
        _imageFile!.readAsBytesSync(),
      );

      setState(() {
        imgHeight = decodedImage.height;
        imgWidth = decodedImage.width;
      });
    }
  }

  Future<void> sendPostReq() async {
    final String url = "http://127.0.0.1:$port/ocr/hand";

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.files.add(
      await http.MultipartFile.fromPath('image', _imageFile!.path),
    );

    request.fields['type'] = method.toString();
    request.fields['kHeight'] = _kHeightController.text;
    request.fields['kWidth'] = _kWidthController.text;
    request.fields['overlapUp'] = _overlapUpperController.text;
    request.fields['overlapDn'] = _overlapLowerController.text;
    request.fields['minHeight'] = _minHeightController.text;
    request.fields['minWhite'] = _minWhiteController.text;
    request.fields['maxWhite'] = _maxWhiteController.text;

    try {
      setState(() {
        isLoading = true;
      });
      final res = await request.send().timeout(
        Duration(
          seconds: 120,
        ),
        onTimeout: () {
          throw TimeoutException("The request timed out..");
        },
      );
      setState(() {
        isLoading = false;
      });

      final resBody = await res.stream.bytesToString();

      if (res.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(resBody);
        response = body['text'];
        image1 = body['image1'];
        image2 = body['image2'];
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
  }

  void _submitForm() {
    if (_imageFile != null) {
      if (_formKey.currentState!.validate()) {
        int min = int.parse(_minWhiteController.text);
        int max = int.parse(_maxWhiteController.text);
        if (min < max) {
          _otpTextController.clear();
          sendPostReq();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("minimum brightness cannot exceed maximum brightness"),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No image selected")));
    }
  }

  @override
  void dispose() {
    _kWidthController.dispose();
    _kHeightController.dispose();
    _overlapUpperController.dispose();
    _overlapLowerController.dispose();
    _minHeightController.dispose();
    _minWhiteController.dispose();
    _maxWhiteController.dispose();
    _otpTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Handwritten OCR",
        ),
        actions: [
          BackButton(),
        ],
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                                : "No image Selected",
                            overflow: TextOverflow.clip,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Text("Image Height : "),
                        Text(imgHeight == null ? "N/A" : "$imgHeight"),
                        const SizedBox(width: 30),
                        Text("Image Width : "),
                        Text(imgWidth == null ? "N/A" : "$imgWidth"),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text("Detection Method :"),
                    Row(
                      children: [
                        Radio(
                          value: MethodDt.dilated,
                          groupValue: method,
                          onChanged: (MethodDt? value) {
                            setState(() {
                              method = value!;
                            });
                          },
                        ),
                        Text(
                          "Dilation (for plain pages)",
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Radio(
                          value: MethodDt.lineDetection,
                          groupValue: method,
                          onChanged: (MethodDt? value) {
                            setState(() {
                              method = value!;
                            });
                          },
                        ),
                        Text(
                          "Line Detection (for ruled pages)",
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _kHeightController,
                            enabled: method == MethodDt.dilated,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Kernel Height (px)",
                              helperText: "usually small",
                              errorText: (kernelHeightValid ||
                                      method != MethodDt.dilated)
                                  ? null
                                  : "Please enter valid integer",
                            ),
                            onChanged: (String value) {
                              final val = int.tryParse(value);

                              if (val == null) {
                                setState(() => kernelHeightValid = false);
                              } else {
                                setState(() => kernelHeightValid = true);
                              }
                            },
                            validator: (value) {
                              if (method == MethodDt.lineDetection) {
                                return null;
                              } else {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter kernel height";
                                }
                                if (int.tryParse(value) == null) {
                                  return "Please Enter Valid Number";
                                } else {
                                  int num = int.parse(value);
                                  if (num < 1 || num > (0.1 * imgHeight!)) {
                                    return "Values must be between 1 and ${0.1 * imgHeight!}";
                                  }
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _kWidthController,
                            enabled: method == MethodDt.dilated,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Kernel Width",
                              helperText: "proportional to text size",
                              errorText: (kernelWidthValid ||
                                      method != MethodDt.dilated)
                                  ? null
                                  : "Please enter valid integer",
                            ),
                            onChanged: (String value) {
                              final val = int.tryParse(value);

                              if (val == null) {
                                setState(() => kernelWidthValid = false);
                              } else {
                                setState(() => kernelWidthValid = true);
                              }
                            },
                            validator: (value) {
                              if (method == MethodDt.lineDetection) {
                                return null;
                              } else {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter kernel width";
                                }
                                if (int.tryParse(value) == null) {
                                  return "Please Enter Valid Number";
                                } else {
                                  int num = int.parse(value);
                                  if (num < 1 || num > imgWidth!) {
                                    return "Values must be between 1 and $imgWidth";
                                  }
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _overlapUpperController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Overlap (px)",
                              helperText:
                                  "It sets how much can images overlap from top",
                              errorText: (overlapUpperValid)
                                  ? null
                                  : "Please enter valid integer",
                            ),
                            onChanged: (String value) {
                              final val = int.tryParse(value);

                              if (val == null) {
                                setState(() => overlapUpperValid = false);
                              } else {
                                setState(() => overlapUpperValid = true);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Enter overlap";
                              }
                              if (int.tryParse(value) == null) {
                                return "please enter valid number";
                              } else {
                                int num = int.parse(value);
                                if (num < 0 || num > (0.25 * imgHeight!)) {
                                  return "Values must be between 0 and ${0.25 * imgHeight!}";
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _overlapLowerController,
                            enabled: method == MethodDt.lineDetection,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Overlap (px)",
                              helperText:
                                  "It sets how much can images overlap from bottom",
                              errorText: (overlapLowerValid ||
                                      method != MethodDt.lineDetection)
                                  ? null
                                  : "Please enter valid integer",
                            ),
                            onChanged: (String value) {
                              final val = int.tryParse(value);

                              if (val == null) {
                                setState(() => overlapLowerValid = false);
                              } else {
                                setState(() => overlapLowerValid = true);
                              }
                            },
                            validator: (value) {
                              if (method == MethodDt.dilated) {
                                return null;
                              } else {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter overlap";
                                }
                                if (int.tryParse(value) == null) {
                                  return "please enter valid number";
                                } else {
                                  int num = int.parse(value);
                                  if (num < 0 || num > (0.25 * imgHeight!)) {
                                    return "Values must be between 0 and ${0.25 * imgHeight!}";
                                  }
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _minHeightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Minimum Height Threshold (px)",
                        helperText:
                            "It sets how much minimum height a image should have to be considered as text",
                        errorText: (minThresValid)
                            ? null
                            : "Please enter valid integer",
                      ),
                      onChanged: (String value) {
                        final val = int.tryParse(value);

                        if (val == null) {
                          setState(() => minThresValid = false);
                        } else {
                          setState(() => minThresValid = true);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please height threshold";
                        }
                        if (int.tryParse(value) == null) {
                          return "please enter valid number";
                        } else {
                          int num = int.parse(value);
                          if (num < 1 || num > imgHeight!) {
                            return "Values must be between 1 and $imgHeight";
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minWhiteController,
                            enabled: method == MethodDt.lineDetection,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Minimum Whiteness",
                              errorText: (minWhiteValid ||
                                      method != MethodDt.lineDetection)
                                  ? null
                                  : "Please enter valid integer",
                            ),
                            onChanged: (String value) {
                              final val = int.tryParse(value);

                              if (val == null) {
                                setState(() => minWhiteValid = false);
                              } else {
                                setState(() => minWhiteValid = true);
                              }
                            },
                            validator: (value) {
                              if (method == MethodDt.dilated) {
                                return null;
                              } else {
                                if (value == null || value.isEmpty) {
                                  return "Please enter minimum Whiteness";
                                }
                                if (int.tryParse(value) == null) {
                                  return "please enter valid number";
                                } else {
                                  int num = int.parse(value);
                                  if (num < 1) {
                                    return "Values must be > 0";
                                  }
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _maxWhiteController,
                            enabled: method == MethodDt.lineDetection,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Maximum Whiteness",
                              errorText: (maxWhiteValid ||
                                      method != MethodDt.lineDetection)
                                  ? null
                                  : "Please enter valid integer",
                            ),
                            onChanged: (String value) {
                              final val = int.tryParse(value);

                              if (val == null) {
                                setState(() => maxWhiteValid = false);
                              } else {
                                setState(() => maxWhiteValid = true);
                              }
                            },
                            validator: (value) {
                              if (method == MethodDt.dilated) {
                                return null;
                              } else {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter maximum Whiteness";
                                }
                                if (int.tryParse(value) == null) {
                                  return "please enter valid number";
                                } else {
                                  int num = int.parse(value);
                                  if (num > 255) {
                                    return "Values must be < 255";
                                  }
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    Center(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => ImagePreview(
                                        image1: image1, image2: image2),
                                  ),
                                );
                              },
                        child: Text("Preview Image"),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
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
                                func: _submitForm,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 0, 16),
                  child: TextField(
                    controller: _otpTextController,
                    expands: true,
                    readOnly: true,
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
