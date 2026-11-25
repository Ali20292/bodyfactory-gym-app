import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart' as picker;

/// Where a new profile picture comes from.
///
/// Its own enum rather than `image_picker`'s `ImageSource`, so controllers and
/// tests never import the plugin — a plugin type in a test means a method
/// channel that is not there.
enum PhotoOrigin { camera, gallery }

@immutable
class PickedImage {
  const PickedImage({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// Picking a photo, as a seam.
abstract class ProfileImageSource {
  /// Null when the user backed out of the picker.
  Future<PickedImage?> pick(PhotoOrigin origin);
}

class PlatformProfileImageSource implements ProfileImageSource {
  PlatformProfileImageSource({picker.ImagePicker? imagePicker})
    : _picker = imagePicker ?? picker.ImagePicker();

  final picker.ImagePicker _picker;

  @override
  Future<PickedImage?> pick(PhotoOrigin origin) async {
    final picker.XFile? file = await _picker.pickImage(
      source: origin == PhotoOrigin.camera
          ? picker.ImageSource.camera
          : picker.ImageSource.gallery,
      // A first pass in the platform picker, which is cheaper than decoding a
      // 12-megapixel original in Dart. `prepareProfileImage` still runs after
      // it — this is a hint, not a guarantee.
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
    if (file == null) return null;

    return PickedImage(bytes: await file.readAsBytes(), fileName: file.name);
  }
}

final Provider<ProfileImageSource> profileImageSourceProvider =
    Provider<ProfileImageSource>((Ref ref) => PlatformProfileImageSource());

/// The longest edge of the stored picture. An avatar is never shown larger
/// than ~110pt, so 512 is generous even on a 3x screen.
const int _targetSize = 512;

/// The ceiling from CLAUDE.md. The backend re-checks it; this is what keeps
/// the app from ever sending more.
const int maxProfileImageBytes = 500 * 1024;

/// Crops [raw] to a centred square, scales it to [_targetSize], and encodes
/// JPEG under [maxProfileImageBytes].
///
/// A top-level function so it can be handed to `compute`: decoding and
/// re-encoding a photo is tens of milliseconds at best and hundreds at worst,
/// which is a visible stutter if it runs on the UI isolate.
///
/// Returns null if the bytes are not a decodable image.
Uint8List? prepareProfileImage(Uint8List raw) {
  // `decodeImage` does not merely return null on rubbish input: probing the
  // formats can throw a RangeError off the end of a truncated file. A photo
  // that failed to copy off the camera is a plausible thing to be handed, and
  // it must come back as "not an image", not as a crash.
  img.Image? decoded;
  try {
    decoded = img.decodeImage(raw);
  } on Object {
    return null;
  }
  if (decoded == null) return null;

  // Centre crop, so a portrait photo keeps the face rather than the ceiling.
  final int edge = decoded.width < decoded.height
      ? decoded.width
      : decoded.height;
  final img.Image square = img.copyCrop(
    decoded,
    x: (decoded.width - edge) ~/ 2,
    y: (decoded.height - edge) ~/ 2,
    width: edge,
    height: edge,
  );

  final img.Image resized = edge > _targetSize
      ? img.copyResize(square, width: _targetSize, height: _targetSize)
      : square;

  // Step the quality down until it fits. Two or three passes in practice, and
  // it terminates either way — the last quality is returned regardless.
  Uint8List encoded = img.encodeJpg(resized, quality: 88);
  for (final int quality in <int>[72, 58, 45, 35]) {
    if (encoded.lengthInBytes <= maxProfileImageBytes) break;
    encoded = img.encodeJpg(resized, quality: quality);
  }

  return encoded;
}
