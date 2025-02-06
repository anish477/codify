import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageService {
  final String cloudName = 'dk6xnlqr2';

  Future<String?> uploadImage(BuildContext context, XFile imageFile) async {
    try {
      final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'beubfeucucb';


      final bytes = await imageFile.readAsBytes();


      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      );

      request.files.add(multipartFile);

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        final imageUrl = jsonMap['secure_url'];
        print('Image URL: $imageUrl');
        return imageUrl;
      } else {
        print('Image upload failed: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
      return null;
    }
  }
}