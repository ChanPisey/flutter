import 'dart:convert';

class CatPhoto {
  String id;
  String url;
  int width;
  int height;

  CatPhoto({
    this.id,
    this.url,
    this.width,
    this.height,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'url': url,
        'width': width,
        'height': height,
      };

  factory CatPhoto.fromJson(dynamic json) {
    return CatPhoto(
      id: json['id'] as String,
      url: json['url'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  @override
  String toString() {
    return 'CatPhoto(id: $id, url: $url, width: $width, height: $height)';
  }
}
