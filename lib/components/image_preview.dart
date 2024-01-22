import 'package:app_admin/utils/cached_image.dart';
import 'package:flutter/material.dart';

openImagePreview(context, String imageUrl) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: <Widget>[
              CustomCacheImage(imageUrl: imageUrl, radius: 5),
              Positioned(
                top: 20,
                right: 20,
                child: InkWell(
                  child: const CircleAvatar(
                    backgroundColor: Colors.deepPurpleAccent,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        );
      });
}
