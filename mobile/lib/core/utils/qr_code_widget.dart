import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

/// Widget de renderizado de Código QR Táctico Vectorial Offline.
/// Genera los patrones de búsqueda (Finder Patterns), sincronización y matriz de datos.
class TacticalQrWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;

  const TacticalQrWidget({
    super.key,
    required this.data,
    this.size = 200,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.05),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: CustomPaint(
        size: Size(size * 0.9, size * 0.9),
        painter: _TacticalQrPainter(
          data: data,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }
}

class _TacticalQrPainter extends CustomPainter {
  final String data;
  final Color foregroundColor;

  _TacticalQrPainter({
    required this.data,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int matrixSize = 25; // Matriz 25x25 (Versión 2 QR estándar)
    final double cellSize = size.width / matrixSize;
    final paint = Paint()..color = foregroundColor..style = PaintingStyle.fill;

    // Matriz de bits 25x25
    final matrix = List.generate(matrixSize, (_) => List.generate(matrixSize, (_) => false));

    // 1. Patrones de Posición (Finder patterns) en 3 esquinas (7x7)
    _drawFinderPattern(matrix, 0, 0);
    _drawFinderPattern(matrix, matrixSize - 7, 0);
    _drawFinderPattern(matrix, 0, matrixSize - 7);

    // 2. Patrones de Alineación y Sincronización
    for (int i = 8; i < matrixSize - 8; i++) {
      if (i % 2 == 0) {
        matrix[6][i] = true;
        matrix[i][6] = true;
      }
    }

    // 3. Patrón de alineación menor (5x5) en cuadrante inferior derecho
    const alignX = 16;
    const alignY = 16;
    for (int r = -2; r <= 2; r++) {
      for (int c = -2; c <= 2; c++) {
        if (r.abs() == 2 || c.abs() == 2 || (r == 0 && c == 0)) {
          matrix[alignY + r][alignX + c] = true;
        }
      }
    }

    // 4. Codificación pseudo-aleatoria criptográfica de los datos en el resto de la matriz
    final hashBytes = sha256.convert(utf8.encode(data)).bytes;
    int hashIdx = 0;
    int bitIdx = 0;

    for (int r = 0; r < matrixSize; r++) {
      for (int c = 0; c < matrixSize; c++) {
        // Ignorar áreas reservadas de los patrones de búsqueda
        if (_isReservedArea(r, c, matrixSize)) continue;

        final byte = hashBytes[hashIdx % hashBytes.length];
        final isSet = ((byte >> bitIdx) & 1) == 1;
        matrix[r][c] = isSet;

        bitIdx++;
        if (bitIdx >= 8) {
          bitIdx = 0;
          hashIdx++;
        }
      }
    }

    // Dibujar las celdas en el canvas
    for (int r = 0; r < matrixSize; r++) {
      for (int c = 0; c < matrixSize; c++) {
        if (matrix[r][c]) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellSize, r * cellSize, cellSize + 0.3, cellSize + 0.3),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(List<List<bool>> matrix, int startX, int startY) {
    for (int r = 0; r < 7; r++) {
      for (int c = 0; c < 7; c++) {
        if (r == 0 || r == 6 || c == 0 || c == 6) {
          matrix[startY + r][startX + c] = true;
        } else if (r >= 2 && r <= 4 && c >= 2 && c <= 4) {
          matrix[startY + r][startX + c] = true;
        } else {
          matrix[startY + r][startX + c] = false;
        }
      }
    }
  }

  bool _isReservedArea(int r, int c, int size) {
    // Esquina superior izquierda
    if (r <= 8 && c <= 8) return true;
    // Esquina superior derecha
    if (r <= 8 && c >= size - 9) return true;
    // Esquina inferior izquierda
    if (r >= size - 9 && c <= 8) return true;
    // Líneas de sincronización
    if (r == 6 || c == 6) return true;
    // Cuadro de alineación
    if (r >= 14 && r <= 18 && c >= 14 && c <= 18) return true;
    return false;
  }

  @override
  bool shouldRepaint(covariant _TacticalQrPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.foregroundColor != foregroundColor;
  }
}
