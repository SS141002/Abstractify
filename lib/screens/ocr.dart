import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:abstractify/screens/navdrawer.dart';
import 'package:abstractify/widgets/floatingactbutton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:abstractify/widgets/ocr_dropzone_widget.dart';
import 'package:abstractify/models/ocr_data.dart';
import 'package:abstractify/widgets/ocr_mode_section.dart';
import 'package:abstractify/widgets/language_dropdown.dart';
import 'package:abstractify/models/ocr_result_model.dart';
import 'package:abstractify/widgets/ocr_result_grid.dart';
import 'package:abstractify/utils/socket_service.dart';
import 'package:abstractify/providers/ocr_result_provider.dart';

class Ocr extends ConsumerStatefulWidget {
  const Ocr({super.key});

  @override
  ConsumerState<Ocr> createState() => _OcrState();
}

class _OcrState extends ConsumerState<Ocr> {
  final _formKey = GlobalKey<FormState>();
  final SocketService socketService = SocketService();

  final _kWidthController = TextEditingController();
  final _kHeightController = TextEditingController();
  final _overlapUpperController = TextEditingController();
  final _overlapLowerController = TextEditingController();
  final _minHeightController = TextEditingController();
  final _otpTextController = TextEditingController();

  RangeValues _range = const RangeValues(125, 225);

  bool kernelHeightValid = true;
  bool kernelWidthValid = true;
  bool overlapUpperValid = true;
  bool overlapLowerValid = true;
  bool minThresValid = true;
  bool minWhiteValid = true;
  bool maxWhiteValid = true;
  bool isLoading = false;

  String response = "";
  int progress = 0;
  String status = "";

  List<String> selectedLanguages = [];

  int port = 5000;
  PageType selectedPageType = PageType.plain;
  OcrMode selectedOcrMode = OcrMode.handwritten;
  SegmentationMode selectedSegmentationMode = SegmentationMode.automatic;

  List<OcrResult> ocrResults = [];

  Future<void> sendPostReq(WidgetRef ref) async {
    final String url = "http://127.0.0.1:$port/ocr";
    final notifier = ref.read(ocrResultsProvider.notifier);
    final results = ref.read(ocrResultsProvider);

    var request = http.MultipartRequest('POST', Uri.parse(url));

    // 1. Add images with UUID as filename identifier
    for (final result in results.values) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          result.path,
          filename: result.uuid, // Use UUID instead of original filename
        ),
      );
    }

    // 2. Prepare language codes
    final List<String> easyOcrCodes = selectedLanguages
        .map((label) => SupportedLanguageExtension.fromLabel(label)?.code)
        .where((code) => code != null)
        .cast<String>()
        .toList();

    // 3. Add form fields
    request.fields.addAll({
      'pageType': selectedPageType.toString().split('.').last,
      'ocrMode': selectedOcrMode.toString().split('.').last,
      'segmentMode': selectedSegmentationMode.toString().split('.').last,
      'languages': jsonEncode(easyOcrCodes),
      'kHeight': _kHeightController.text,
      'kWidth': _kWidthController.text,
      'overlapUp': _overlapUpperController.text,
      'overlapDn': _overlapLowerController.text,
      'minHeight': _minHeightController.text,
      'minWhite': _range.start.round().toString(),
      'maxWhite': _range.end.round().toString(),
    });

    try {
      setState(() => isLoading = true);

      // Send request with timeout
      final res = await request.send().timeout(
            const Duration(seconds: 240),
            onTimeout: () =>
                throw TimeoutException("Request timed out after 2 minutes"),
          );

      final resBody = await res.stream.bytesToString();

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(resBody);

        // Update results using UUID keys from response
        body.forEach((uuid, text) {
          if (results.containsKey(uuid)) {
            notifier.updateText(uuid, text.toString());
          }
        });

        // Build response text with original filenames
        final currentResults = ref.read(ocrResultsProvider);
        final updatedResults = currentResults.values.toList();
        setState(() {
          response = updatedResults
              .map((e) => "[${e.filename}]\n${e.text}")
              .join("\n\n");
        });
      } else {
        // Handle server errors
        try {
          final errorJson = jsonDecode(resBody);
          setState(() {
            response =
                "Error: ${errorJson['message'] ?? 'Unknown server error'}";
          });
        } catch (_) {
          setState(() {
            response = "Request failed with status: ${res.statusCode}";
          });
        }
      }
    } on TimeoutException catch (_) {
      setState(() => response = "Request timed out");
    } catch (e) {
      setState(() => response = "Error: ${e.toString()}");
    } finally {
      _otpTextController.text = response;
      setState(() => isLoading = false);
    }
  }

  void _submitForm(WidgetRef ref) {
    final results = ref.read(ocrResultsProvider);

    if (results.isNotEmpty) {
      if (_formKey.currentState!.validate()) {
        _otpTextController.clear();
        sendPostReq(ref);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No images selected")),
      );
    }
  }

  @override
  void dispose() {
    _kWidthController.dispose();
    _kHeightController.dispose();
    _overlapUpperController.dispose();
    _overlapLowerController.dispose();
    _minHeightController.dispose();
    _otpTextController.dispose();
    socketService.disconnect();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    socketService.connect(onProgress: (data) {
      setState(() {
        progress = data['progress'] ?? 0;
        status = data['status'] ?? "";
      });
    });
  }

  Widget buildProgressBar() {
    if (!isLoading) {
      return const SizedBox(height: 4); // invisible when not loading
    }

    return LinearProgressIndicator(
      value: progress / 100,
      minHeight: 4,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "OCR",
        ),
        actions: [
          BackButton(
            onPressed: () {
              socketService.disconnect();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildProgressBar(),
              const SizedBox(
                height: 6,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropZoneWidget(),
                          const SizedBox(
                            height: 15,
                          ),
                          OcrToggleSection(
                            selectedOcrMode: selectedOcrMode,
                            onOcrModeChanged: (val) =>
                                setState(() => selectedOcrMode = val),
                            selectedSegmentationMode: selectedSegmentationMode,
                            onSegmentationChanged: (val) =>
                                setState(() => selectedSegmentationMode = val),
                            selectedPageType: selectedPageType,
                            onPageTypeChanged: (val) =>
                                setState(() => selectedPageType = val),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          if (selectedSegmentationMode ==
                                  SegmentationMode.manual ||
                              selectedOcrMode == OcrMode.typed)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  if (selectedOcrMode == OcrMode.typed)
                                    MultiLanguageSelector(
                                      selectedLanguages: selectedLanguages,
                                      onSelectionChanged: (newList) {
                                        setState(() {
                                          selectedLanguages = newList;
                                        });
                                      },
                                    ),
                                  if (selectedOcrMode == OcrMode.handwritten &&
                                      selectedSegmentationMode ==
                                          SegmentationMode.manual &&
                                      selectedPageType == PageType.plain)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _kHeightController,
                                            enabled: selectedPageType ==
                                                PageType.plain,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: "Kernel Height (px)",
                                              helperText: "usually small",
                                              errorText: (kernelHeightValid ||
                                                      selectedPageType !=
                                                          PageType.plain)
                                                  ? null
                                                  : "Please enter valid integer",
                                            ),
                                            onChanged: (String value) {
                                              final val = int.tryParse(value);
                                              setState(() => kernelHeightValid =
                                                  val != null);
                                            },
                                            validator: (value) {
                                              if (selectedPageType ==
                                                  PageType.ruled) {
                                                return null;
                                              }
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please Enter kernel height";
                                              }
                                              if (int.tryParse(value) == null) {
                                                return "Please Enter Valid Number";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 30),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _kWidthController,
                                            enabled: selectedPageType ==
                                                PageType.plain,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: "Kernel Width",
                                              helperText:
                                                  "proportional to text size",
                                              errorText: (kernelWidthValid ||
                                                      selectedPageType !=
                                                          PageType.plain)
                                                  ? null
                                                  : "Please enter valid integer",
                                            ),
                                            onChanged: (String value) {
                                              final val = int.tryParse(value);
                                              setState(() => kernelWidthValid =
                                                  val != null);
                                            },
                                            validator: (value) {
                                              if (selectedPageType ==
                                                  PageType.ruled) {
                                                return null;
                                              }
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please Enter kernel width";
                                              }
                                              if (int.tryParse(value) == null) {
                                                return "Please Enter Valid Number";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (selectedOcrMode == OcrMode.handwritten &&
                                      selectedSegmentationMode ==
                                          SegmentationMode.manual &&
                                      selectedPageType == PageType.ruled)
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          'Brightness Range:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Expanded(
                                          child: RangeSlider(
                                            values: _range,
                                            min: 0,
                                            max: 255,
                                            divisions: 255,
                                            labels: RangeLabels(
                                              _range.start.round().toString(),
                                              _range.end.round().toString(),
                                            ),
                                            onChanged: (RangeValues values) {
                                              setState(() {
                                                _range = values;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  if (selectedOcrMode == OcrMode.handwritten &&
                                      selectedSegmentationMode ==
                                          SegmentationMode.manual)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _overlapUpperController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: "Overlap Top (px)",
                                              helperText:
                                                  "How much images can overlap from top",
                                              errorText: overlapUpperValid
                                                  ? null
                                                  : "Please enter valid integer",
                                            ),
                                            onChanged: (String value) {
                                              final val = int.tryParse(value);
                                              setState(() => overlapUpperValid =
                                                  val != null);
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please enter overlap";
                                              }
                                              if (int.tryParse(value) == null) {
                                                return "Please enter valid number";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 30),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _overlapLowerController,
                                            enabled: selectedPageType ==
                                                PageType.ruled,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: "Overlap Bottom (px)",
                                              helperText:
                                                  "How much images can overlap from bottom",
                                              errorText: (overlapLowerValid ||
                                                      selectedPageType !=
                                                          PageType.ruled)
                                                  ? null
                                                  : "Please enter valid integer",
                                            ),
                                            onChanged: (String value) {
                                              final val = int.tryParse(value);
                                              setState(() => overlapLowerValid =
                                                  val != null);
                                            },
                                            validator: (value) {
                                              if (selectedPageType ==
                                                  PageType.plain) return null;
                                              if (value == null ||
                                                  value.isEmpty)
                                                return "Please enter overlap";
                                              if (int.tryParse(value) == null)
                                                return "Please enter valid number";
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  if (selectedOcrMode == OcrMode.handwritten &&
                                      selectedSegmentationMode ==
                                          SegmentationMode.manual)
                                    TextFormField(
                                      controller: _minHeightController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText:
                                            "Minimum Height Threshold (px)",
                                        helperText:
                                            "It sets how much minimum height an image should have to be considered as text",
                                        errorText: minThresValid
                                            ? null
                                            : "Please enter valid integer",
                                      ),
                                      onChanged: (String value) {
                                        final val = int.tryParse(value);
                                        setState(
                                            () => minThresValid = val != null);
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter height threshold";
                                        }
                                        if (int.tryParse(value) == null) {
                                          return "Please enter valid number";
                                        }
                                        return null;
                                      },
                                    ),
                                ],
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
                                      onPressed: () {
                                        _submitForm(ref);
                                      }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: OcrResultGrid(),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            /*
                            TextField(
                              controller: _otpTextController,
                              readOnly: true,
                              maxLines: 5,
                              decoration: InputDecoration(
                                labelText: "Response",
                                border: const OutlineInputBorder(),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
