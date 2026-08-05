import 'dart:math' as math;
import 'dart:typed_data';

/// Lightweight RFC-6238 TOTP generator (HMAC-SHA1, 6-digit, 30-second window).
///
/// Usage:
/// ```dart
/// final code = TotpService.generateCode('JBSWY3DPEHPK3PXP');
/// final remaining = TotpService.remainingSeconds();
/// ```
///
/// Accepts base32-encoded secrets (RFC-4648, upper-case, padding optional)
/// or `otpauth://` URIs parsed via [parseOtpauthUri].
class TotpService {
  TotpService._();

  static const _period = 30;
  static const _digits = 6;

  // ── Public API ──────────────────────────────────────────────────────────

  /// The number of seconds until the current TOTP code expires.
  static int remainingSeconds() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return _period - (now % _period);
  }

  /// Generate the current 6-digit TOTP code for [secretBase32].
  ///
  /// Returns `null` if the secret is invalid (not valid base32).
  static String? generateCode(String secretBase32) {
    try {
      final key = _base32Decode(secretBase32.toUpperCase().replaceAll(' ', ''));
      final counter = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ _period;
      return _hotp(key, counter);
    } catch (_) {
      return null;
    }
  }

  /// Parse an `otpauth://totp/...` URI and return the secret, label, and
  /// issuer.  Returns `null` if the URI is not a valid TOTP URI.
  static ({String secret, String label, String? issuer})? parseOtpauthUri(
    String uri,
  ) {
    try {
      final u = Uri.parse(uri);
      if (u.scheme != 'otpauth' || u.host != 'totp') return null;

      final secret = u.queryParameters['secret'];
      if (secret == null || secret.isEmpty) return null;

      final label = Uri.decodeComponent(
        u.pathSegments.isNotEmpty ? u.pathSegments.last : '',
      );
      final issuer = u.queryParameters['issuer'];

      return (secret: secret, label: label, issuer: issuer);
    } catch (_) {
      return null;
    }
  }

  // ── HOTP core ───────────────────────────────────────────────────────────

  /// HMAC-based one-time password (RFC 4226, section 5.3).
  static String? _hotp(Uint8List key, int counter) {
    final counterBytes = ByteData(8)..setUint64(0, counter, Endian.big);
    try {
      final result = _hmacSha1Sync(
        key,
        Uint8List.fromList(counterBytes.buffer.asUint8List()),
      );
      if (result == null) return null;
      return _dynamicTruncation(result);
    } catch (_) {
      return null;
    }
  }

  /// Dynamic truncation (RFC 4226, section 5.4).
  static String _dynamicTruncation(Uint8List hmac) {
    final offset = hmac.last & 0x0f;
    final binary =
        ((hmac[offset] & 0x7f) << 24) |
        ((hmac[offset + 1] & 0xff) << 16) |
        ((hmac[offset + 2] & 0xff) << 8) |
        (hmac[offset + 3] & 0xff);
    final otp = binary % math.pow(10, _digits).toInt();
    return otp.toString().padLeft(_digits, '0');
  }

  // ── Crypto helpers ──────────────────────────────────────────────────────

  /// Synchronous HMAC-SHA1 (needed because TOTP must be instant).
  /// Uses the `cryptography` package with a synchronous workaround.
  static Uint8List? _hmacSha1Sync(Uint8List key, Uint8List message) {
    // cryptography package is async. Use dart:crypto instead.
    // We'll use the simple synchronous Dart HMAC implementation.
    try {
      return _syncHmacSha1(key, message);
    } catch (_) {
      return null;
    }
  }

  /// Pure-Dart HMAC-SHA1 synchronous fallback.
  static Uint8List _syncHmacSha1(Uint8List key, Uint8List message) {
    // Block size for SHA1 is 64 bytes
    const blockSize = 64;

    var k = key;
    if (k.length > blockSize) {
      k = _sha1(k);
    }
    if (k.length < blockSize) {
      k = Uint8List.fromList([...k, ...List.filled(blockSize - k.length, 0)]);
    }

    final oKeyPad = Uint8List.fromList(
      List.generate(blockSize, (i) => k[i] ^ 0x5c),
    );
    final iKeyPad = Uint8List.fromList(
      List.generate(blockSize, (i) => k[i] ^ 0x36),
    );

    return _sha1(
      Uint8List.fromList([
        ...oKeyPad,
        ..._sha1(Uint8List.fromList([...iKeyPad, ...message])),
      ]),
    );
  }

  /// Minimal SHA-1 implementation (RFC 3174).
  static Uint8List _sha1(Uint8List data) {
    // Pad the message
    final ml = data.length * 8;
    var padded = Uint8List.fromList([...data, 0x80]);
    while ((padded.length * 8) % 512 != 448) {
      padded = Uint8List.fromList([...padded, 0]);
    }
    final lengthBytes = ByteData(8)..setUint64(0, ml, Endian.big);
    padded = Uint8List.fromList([
      ...padded,
      ...lengthBytes.buffer.asUint8List().reversed.skip(4),
    ]);

    // Initial hash values
    var h0 = 0x67452301;
    var h1 = 0xEFCDAB89;
    var h2 = 0x98BADCFE;
    var h3 = 0x10325476;
    var h4 = 0xC3D2E1F0;

    // Process each 512-bit chunk
    for (var i = 0; i < padded.length; i += 64) {
      final w = List<int>.filled(80, 0);
      for (var t = 0; t < 16; t++) {
        w[t] =
            (padded[i + t * 4] << 24) |
            (padded[i + t * 4 + 1] << 16) |
            (padded[i + t * 4 + 2] << 8) |
            padded[i + t * 4 + 3];
      }
      for (var t = 16; t < 80; t++) {
        w[t] = _rotl32(w[t - 3] ^ w[t - 8] ^ w[t - 14] ^ w[t - 16], 1);
      }

      var a = h0, b = h1, c = h2, d = h3, e = h4;
      for (var t = 0; t < 80; t++) {
        final fk = _sha1Fk(t, b, c, d);
        final temp = _add32(
          _add32(_rotl32(a, 5), fk),
          _add32(_add32(e, w[t]), _sha1K(t)),
        );
        e = d;
        d = c;
        c = _rotl32(b, 30);
        b = a;
        a = temp;
      }
      h0 = _add32(h0, a);
      h1 = _add32(h1, b);
      h2 = _add32(h2, c);
      h3 = _add32(h3, d);
      h4 = _add32(h4, e);
    }

    final result = ByteData(20);
    result.setUint32(0, h0, Endian.big);
    result.setUint32(4, h1, Endian.big);
    result.setUint32(8, h2, Endian.big);
    result.setUint32(12, h3, Endian.big);
    result.setUint32(16, h4, Endian.big);
    return result.buffer.asUint8List();
  }

  static int _sha1Fk(int t, int b, int c, int d) {
    if (t <= 19) return (b & c) | ((~b) & d);
    if (t <= 39) return b ^ c ^ d;
    if (t <= 59) return (b & c) | (b & d) | (c & d);
    return b ^ c ^ d;
  }

  static int _sha1K(int t) {
    if (t <= 19) return 0x5A827999;
    if (t <= 39) return 0x6ED9EBA1;
    if (t <= 59) return 0x8F1BBCDC;
    return 0xCA62C1D6;
  }

  static int _rotl32(int n, int s) =>
      ((n << s) | (n >>> (32 - s))) & 0xFFFFFFFF;
  static int _add32(int a, int b) => (a + b) & 0xFFFFFFFF;

  // ── Base32 ──────────────────────────────────────────────────────────────

  static const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  static Uint8List _base32Decode(String base32) {
    // Strip padding
    base32 = base32.replaceAll(RegExp(r'=+$'), '');

    final result = <int>[];
    var bits = 0;
    var value = 0;

    for (var i = 0; i < base32.length; i++) {
      final idx = _base32Alphabet.indexOf(base32[i]);
      if (idx == -1) throw FormatException('Invalid base32: ${base32[i]}');
      value = (value << 5) | idx;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        result.add((value >> bits) & 0xff);
      }
    }

    return Uint8List.fromList(result);
  }
}
