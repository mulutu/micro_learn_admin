import 'package:app_admin/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

TextFormField imageTextField(TextEditingController imageCtrl, XFile? imageFile ,VoidCallback onClear, VoidCallback onPickImage) {
  return TextFormField(
      controller: imageCtrl,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: 'Enter Image Url or Select Image',
        alignLabelWithHint: true,
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                imageCtrl.clear();
                onClear();
              },
            ),
            IconButton(
              tooltip: 'Select Image',
              icon: const Icon(Icons.image_outlined),
              onPressed: () => onPickImage(),
            ),
          ],
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) return 'Value is empty';
        //if(imageFile == null && !AppService.isURLValid(value)) return 'Image is not valid';
        if(imageFile == null){
          if (!AppService.isURLValid(value)) return 'Image is not valid';
        }
        return null;
      });
}


TextFormField audioTextField(TextEditingController imageCtrl, VoidCallback onClear, VoidCallback onPickAudio) {
  return TextFormField(
      controller: imageCtrl,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: 'Enter Audio Url or Select Audio File',
        alignLabelWithHint: true,
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                imageCtrl.clear();
                onClear();
              },
            ),
            IconButton(
              tooltip: 'Select Audio File',
              icon: const Icon(Icons.audio_file),
              onPressed: () => onPickAudio(),
            ),
          ],
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) return 'Value is empty';
        return null;
      });
}
