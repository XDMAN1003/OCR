import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  //const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  File _image;
  final picker = ImagePicker();
  String resultText = "Fetching Response...";

  pickImage() async {
    var image = await picker.getImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      _loading = false;
    });

    var str = fetchResponse(_image);
    print(str);
  }

  pickGalleryImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      _loading = false;
    });

    var str = fetchResponse(_image);
    print(str);
  }

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

  void parseResponse(var response){
    //print("Full: $response");
    //print(response["ParsedResults"]);
    String caption = '';
    for(var parseText in response["ParsedResults"]){
      caption = caption + parseText["ParsedText"];
    }
    
    setState(() {
      resultText = caption;
    });
  }

  // void parseResponse(var response) {
  //   String r = "";
  //   var predictions = response["predictions"];
  //   for (var prediction in predictions) {
  //     var caption = prediction["caption"];
  //     var probability = prediction["probability"];
  //     r = r + "$caption\n\n";
  //   }
  //   setState(() {
  //     resultText = r;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.004, 1],
                colors: [Color(0x11232526), Color(0xFF232526)])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 60,
            ),
            const Text(
              "Text Generator",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 35.0),
            ),
            const Text(
              "Image to text Generator",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Container(
              height: MediaQuery.of(context).size.height - 250,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7)
                  ]),
              child: Column(
                children: [
                  Center(
                      child: _loading
                          ? Container(
                              width: 500.0,
                              child: Column(children: [
                                SizedBox(
                                  height: 50.0,
                                ),
                                Container(
                                  width: 100,
                                  child: Image.asset("assets/notepad.png"),
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 17),
                                          decoration: BoxDecoration(
                                              color: Color(0xFF56ab2f),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text(
                                            "Live Camera",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      GestureDetector(
                                        onTap: pickGalleryImage ,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 17),
                                          decoration: BoxDecoration(
                                              color: Color(0xFF56ab2f),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text(
                                            "Camera Roll",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      GestureDetector(
                                        onTap: pickImage,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 17),
                                          decoration: BoxDecoration(
                                              color: Color(0xFF56ab2f),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text(
                                            "Take a Photo",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ]),
                            )
                          : Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5)),
                                    height: 200,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _loading = true;
                                                resultText =
                                                    "Fetching Response...";
                                              });
                                            },
                                            icon: Icon(Icons.arrow_back_ios),
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              205,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(
                                              _image,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),SizedBox(height: 20,),
                                  Container(child: Text("$resultText", textAlign: TextAlign.center,style: TextStyle(fontSize: 14, color: Colors.black),),)
                                ],
                              ),
                            ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
