import 'dart:convert';
import 'dart:io';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/data/app_exception/app_exceptions.dart';
import 'package:figma_new_project/data/network/BaseApiService.dart';
import 'package:http/http.dart' as http;

class NetworkApiService extends BaseApiService {

  var headers = {
    'Cookie': 'restaurant_session=$cookie',
    'Content-type': 'application/json',
    'Accept': 'application/json'
  };

  @override
  Future getGetApiResponse(String url) async {

    dynamic responseJson;

    try {

      var request = http.Request('GET', Uri.parse(url));
      http.StreamedResponse response = await request.send();
      responseJson = returnResponseGet(response);

    }
    on SocketException {
      throw FetchDataException('No Internet Exception ');
    }
    return responseJson;

  }


  @override
  Future getPostApiResponse(String url, dynamic data) async {
    dynamic responseJson;
    try {

      var request = http.Request('POST', Uri.parse(url));
      request.body = json.encode(data);
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      responseJson = returnResponseGet(response);

    } on SocketException {
      throw FetchDataException('No Internet Exception ');
    }

    return responseJson;
  }

  dynamic returnResponseGet(http.StreamedResponse response) async {

    switch(response.statusCode) {
      case 200:
        final responseData = await response.stream.bytesToString();
        return responseData;
      case 302 :
        throw BadRequestException(response.reasonPhrase);
      case 420 :
        throw BadRequestException(response.reasonPhrase);
      case 400 :
        throw BadRequestException(response.reasonPhrase);
      case 401 :
        throw BadRequestException(response.reasonPhrase);
      case 404 :
        throw BadRequestException(response.reasonPhrase);
      case 500 :
        throw BadRequestException(response.reasonPhrase);
      default:
        throw FetchDataException('Error occured while communicating with server ${response.statusCode.toString()}');
    }

  }

}