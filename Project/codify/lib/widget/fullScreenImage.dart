import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Hero(
            tag: 'profileImage',
            child: Image.network(imageUrl,fit: BoxFit.cover,height: MediaQuery.sizeOf(context).height-200,width: MediaQuery.sizeOf(context).width-20,),

          ),
        ),
      ),
    );
  }
}