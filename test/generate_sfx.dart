import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// Script tạo file âm thanh Cyberpunk SFX định dạng WAV chuẩn 44.1kHz 16-bit Mono
void main() {
  final audioDir = Directory('assets/audio');
  if (!audioDir.existsSync()) {
    audioDir.createSync(recursive: true);
  }

  // 1. tap.wav: Cyber blip (880Hz -> 1320Hz decay)
  File('assets/audio/tap.wav').writeAsBytesSync(
    _generateWav(
      durationMs: 90,
      sampleRate: 44100,
      generator: (t, total) {
        final progress = t / total;
        final freq = 880.0 + 440.0 * (1.0 - progress);
        final envelope = exp(-progress * 12.0); // Fast decay
        return sin(2 * pi * freq * t) * envelope * 0.8;
      },
    ),
  );

  // 2. combo.wav: Sparkling chord arpeggio
  File('assets/audio/combo.wav').writeAsBytesSync(
    _generateWav(
      durationMs: 250,
      sampleRate: 44100,
      generator: (t, total) {
        final progress = t / total;
        final envelope = exp(-progress * 6.0);
        // Chime notes: C5 (523Hz), E5 (659Hz), G5 (783Hz), C6 (1046Hz)
        final note1 = sin(2 * pi * 523.25 * t);
        final note2 = sin(2 * pi * 659.25 * t);
        final note3 = sin(2 * pi * 783.99 * t);
        final note4 = sin(2 * pi * 1046.50 * t);
        return ((note1 + note2 + note3 + note4) / 4.0) * envelope * 0.9;
      },
    ),
  );

  // 3. win.wav: Victory Fanfare (C-E-G-C ascending power synth)
  File('assets/audio/win.wav').writeAsBytesSync(
    _generateWav(
      durationMs: 800,
      sampleRate: 44100,
      generator: (t, total) {
        final progress = t / total;
        final envelope = min(1.0, (1.0 - progress) * 1.5) * min(1.0, progress * 20.0);
        
        // Sequence of frequencies
        double currentFreq = 523.25; // C5
        if (progress > 0.2) currentFreq = 659.25; // E5
        if (progress > 0.4) currentFreq = 783.99; // G5
        if (progress > 0.6) currentFreq = 1046.50; // C6

        final wave = sin(2 * pi * currentFreq * t) + 0.3 * sin(4 * pi * currentFreq * t);
        return wave * envelope * 0.7;
      },
    ),
  );

  // 4. button.wav: Clean mechanical UI click
  File('assets/audio/button.wav').writeAsBytesSync(
    _generateWav(
      durationMs: 60,
      sampleRate: 44100,
      generator: (t, total) {
        final progress = t / total;
        final freq = 450.0 * (1.0 - progress * 0.5);
        final envelope = exp(-progress * 18.0);
        return sin(2 * pi * freq * t) * envelope * 0.6;
      },
    ),
  );

  // 5. undo.wav: Reverse pitch drop blip
  File('assets/audio/undo.wav').writeAsBytesSync(
    _generateWav(
      durationMs: 120,
      sampleRate: 44100,
      generator: (t, total) {
        final progress = t / total;
        final freq = 880.0 * (1.0 - progress);
        final envelope = exp(-progress * 8.0);
        return sin(2 * pi * freq * t) * envelope * 0.7;
      },
    ),
  );

  // 6. hint.wav: Harmonic Bell chime
  File('assets/audio/hint.wav').writeAsBytesSync(
    _generateWav(
      durationMs: 300,
      sampleRate: 44100,
      generator: (t, total) {
        final progress = t / total;
        final envelope = exp(-progress * 5.0);
        final f1 = sin(2 * pi * 1318.51 * t); // E6
        final f2 = sin(2 * pi * 1760.00 * t); // A6
        return ((f1 + f2) / 2.0) * envelope * 0.8;
      },
    ),
  );

  // Finished generating SFX wav files
}

Uint8List _generateWav({
  required int durationMs,
  required int sampleRate,
  required double Function(double t, double totalTime) generator,
}) {
  final totalSamples = (sampleRate * (durationMs / 1000.0)).round();
  final totalTime = durationMs / 1000.0;
  final byteData = ByteData(44 + totalSamples * 2);

  // RIFF header
  byteData.setUint8(0, 0x52); // 'R'
  byteData.setUint8(1, 0x49); // 'I'
  byteData.setUint8(2, 0x46); // 'F'
  byteData.setUint8(3, 0x46); // 'F'
  byteData.setUint32(4, 36 + totalSamples * 2, Endian.little);
  byteData.setUint8(8, 0x57);  // 'W'
  byteData.setUint8(9, 0x41);  // 'A'
  byteData.setUint8(10, 0x56); // 'V'
  byteData.setUint8(11, 0x45); // 'E'

  // 'fmt ' chunk
  byteData.setUint8(12, 0x66); // 'f'
  byteData.setUint8(13, 0x6D); // 'm'
  byteData.setUint8(14, 0x74); // 't'
  byteData.setUint8(15, 0x20); // ' '
  byteData.setUint32(16, 16, Endian.little); // Chunk size
  byteData.setUint16(20, 1, Endian.little);  // Format: PCM
  byteData.setUint16(22, 1, Endian.little);  // Channels: Mono
  byteData.setUint32(24, sampleRate, Endian.little); // Sample rate
  byteData.setUint32(28, sampleRate * 2, Endian.little); // Byte rate
  byteData.setUint16(32, 2, Endian.little);  // Block align
  byteData.setUint16(34, 16, Endian.little); // Bits per sample

  // 'data' chunk
  byteData.setUint8(36, 0x64); // 'd'
  byteData.setUint8(37, 0x61); // 'a'
  byteData.setUint8(38, 0x74); // 't'
  byteData.setUint8(39, 0x61); // 'a'
  byteData.setUint32(40, totalSamples * 2, Endian.little);

  // Write samples
  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate.toDouble();
    final sampleVal = generator(t, totalTime).clamp(-1.0, 1.0);
    final int16Val = (sampleVal * 32767.0).round();
    byteData.setInt16(44 + i * 2, int16Val, Endian.little);
  }

  return byteData.buffer.asUint8List();
}
