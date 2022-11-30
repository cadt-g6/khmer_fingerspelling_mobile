import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:khmer_fingerspelling_flutter/providers/prediction_provider.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class ImageClassifierResult {
  final String label;
  final double accuracy;

  ImageClassifierResult(
    this.label,
    this.accuracy,
  );
}

class ImageClassifier {
  String get baseUrl => PredictionProvider.instance.baseUrl;

  Future<List<ImageClassifierResult>?> predict(File file) async {
    List<ImageClassifierResult> results = [];
    Map<String, dynamic> json = await _send(file);

    for (dynamic predict in json['predicts']) {
      results.add(ImageClassifierResult(predict[0], predict[1]));
    }

    results.sort((a, b) => b.accuracy > a.accuracy ? 1 : -1);
    return results;
  }

  Future<Map<String, dynamic>> _send(File file) async {
    http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.tryParse("$baseUrl/classify_image")!,
    );

    http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      'body',
      await file.readAsBytes(),
      filename: basename(file.path),
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(multipartFile);
    request.fields['file_name'] = basename(file.path);

    http.StreamedResponse response = await request.send();

    String bodyStr = await response.stream.transform(utf8.decoder).last;
    Map<String, dynamic> json = jsonDecode(bodyStr);

    return json;
  }
}
