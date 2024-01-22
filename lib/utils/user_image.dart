import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../configs/config.dart';

DecorationImage getUserImage(
    BuildContext context, String? imageUrl, String? assetString) {
  return DecorationImage(
      fit: imageUrl != null ? BoxFit.cover : BoxFit.scaleDown,
      image: imageUrl != null
          ? CachedNetworkImageProvider(imageUrl)
          : AssetImage(assetString ?? Config.defaultAvatarString)
              as ImageProvider<Object>);
}
