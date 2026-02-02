import 'dart:async';
import 'package:universal_io/io.dart';

/// Interface for audio conversion.
/// Implement this to provide custom audio conversion logic (e.g., using FFmpeg).
abstract class WhisperAudioConverter {
  /// Converts the given [input] file to a 16kHz mono WAV file.
  /// Returns the converted [File], or null if conversion fails.
  Future<File?> convert(File input);
}

/// Legacy class kept for internal routing, now uses the registered converter.
class WhisperAudioConvert {
  const WhisperAudioConvert({
    required this.audioInput,
    required this.audioOutput,
  });

  final File audioInput;
  final File audioOutput;

  /// This method is now handled by the [WhisperController]'s registered converter.
  Future<File?> convert() async {
    // This is now just a placeholder.
    // Actual logic moved to WhisperController and external converter packages.
    return null;
  }
}
