import 'dart:convert';
import 'dart:io';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class GenerateLiveCaption extends StatefulWidget {
  const GenerateLiveCaption({Key key}) : super(key: key);

  @override
  State<GenerateLiveCaption> createState() => _GenerateLiveCaptionState();
}

class _GenerateLiveCaptionState extends State<GenerateLiveCaption> {
  bool _loading = true;
  File _image;
  final picker = ImagePicker();
  String resultText = "Fetching Response...";
  
  Future<Map<String, dynamic>> fetchResponse(File image) async {
    print("Hello");
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    //print("MimeType: $mimeTypeData");
    final imageUploadRequest = http.MultipartRequest(
        "POST", Uri.parse("https://api.ocr.space/parse/image"));
    final file = await http.MultipartFile.fromPath("files", image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.fields["apikey"] = "449e03ea5788957";
    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> responseData = json.decode(response.body);
      //print("Data: $responseData");
      parseResponse(responseData);
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void parseResponse(var response) {
    //print("Full: $response");
    //print(response["ParsedResults"]);
    String caption = '';
    for (var parseText in response["ParsedResults"]) {
      caption = caption + parseText["ParsedText"];
    }

    setState(() {
      resultText = caption;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
