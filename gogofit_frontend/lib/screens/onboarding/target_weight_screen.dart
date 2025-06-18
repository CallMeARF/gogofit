// lib/screens/onboarding/target_weight_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/onboarding/purpose_screen.dart'; // Import halaman tujuan
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'dart:math' as math; // Import ini untuk math.cos dan math.sin

class TargetWeightScreen extends StatefulWidget {
  // BARU: Menerima data registrasi dari layar sebelumnya
  final Map<String, dynamic> registrationData;

  const TargetWeightScreen({super.key, required this.registrationData});

  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen> {
  // Mengubah _selectedWeight menjadi double untuk konsistensi dengan BE
  double _selectedWeight = 60.0; // Nilai default sesuai mockup

  @override
  void initState() {
    super.initState();
    // Inisialisasi target weight jika sudah ada di data (misal dari edit profil atau skip)
    if (widget.registrationData.containsKey('targetWeightKg') &&
        widget.registrationData['targetWeightKg'] != null) {
      _selectedWeight =
          (widget.registrationData['targetWeightKg'] as num).toDouble();
    }
  }

  void _navigateToNextScreen() {
    // Akumulasikan data yang sudah ada dan tambahkan data baru dari layar ini
    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['targetWeightKg'] =
        _selectedWeight; // Simpan target berat badan yang dipilih

    debugPrint(
      'Target berat badan terpilih: $_selectedWeight kg, melanjutkan ke Purpose Screen dengan data: $updatedRegistrationData',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Target berat badan dipilih: ${_selectedWeight.toStringAsFixed(1)} kg',
        ),
      ),
    );

    // Navigasi ke halaman PurposeScreen dengan meneruskan data yang sudah terakumulasi
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PurposeScreen(
              registrationData: updatedRegistrationData, // Teruskan data
            ),
      ),
    );
  }

  // Fungsi untuk 'Skip'
  void _skipOnboarding() {
    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['targetWeightKg'] =
        null; // Jika diskip, set target weight ke null

    debugPrint(
      'Skip Onboarding dari Target Weight Screen menuju Purpose Screen dengan data: $updatedRegistrationData',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Melewati pengisian target berat badan, melanjutkan ke tujuan',
        ),
      ),
    );
    // Navigasi ke halaman PurposeScreen saat tombol 'Skip' ditekan
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PurposeScreen(
              registrationData:
                  updatedRegistrationData, // Teruskan data yang sudah terakumulasi
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Warna abu-abu background icon back
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ), // Warna ikon back hitam
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0, top: 5.0, bottom: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color:
                    Colors
                        .grey
                        .shade200, // Warna abu-abu background tombol Skip
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: _skipOnboarding, // Panggil fungsi skip
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.black, // Warna teks Skip hitam
                    fontSize: 16,
                    fontFamily: 'Poppins', // Font Poppins
                    fontWeight: FontWeight.w500, // SemiBold atau Medium
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002033), // Darker Blue
                  fontFamily: 'Poppins', // Font Poppins
                ),
                children: <TextSpan>[
                  const TextSpan(text: 'Target '),
                  TextSpan(
                    text: 'berat badan',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ), // Normal Blue
                  ),
                  const TextSpan(text: ' anda'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Kami akan menggunakan data ini untuk memberi Anda jenis diet yang lebih baik untuk Anda', // Teks Indonesia
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600, // Warna abu-abu yang lebih sesuai
                fontFamily: 'Poppins', // Font Poppins
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF015C91,
                    ), // Normal Blue dari palet Anda
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'kg', // Label 'kg'
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins', // Font Poppins
                    ),
                  ),
                ),
              ],
            ),
            Align(
              // Indikator panah di atas picker
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(
                  0,
                  10,
                ), // Geser sedikit ke bawah agar lebih pas
                child: const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFFF2A900), // Warna oranye seperti mockup
                  size: 40,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ), // Memberikan sedikit jarak dari unit kg/lb

            SizedBox(
              height:
                  180, // Tinggi yang sama dengan HeightScreen untuk konsistensi
              child: ScrollSnapList(
                itemBuilder: (context, index) {
                  // Menggunakan double untuk weightValue
                  final double weightValue =
                      (40 + index).toDouble(); // Range dari 40 kg
                  final bool isSelected = weightValue == _selectedWeight;

                  return Container(
                    width: 120, // Lebar setiap item
                    height:
                        isSelected
                            ? 150
                            : 130, // Tinggi yang sama dengan HeightScreen
                    margin: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(
                                0xFFB0CCDD,
                              ) // Light :active Blue saat terpilih
                              : const Color(
                                0xFFE6EFF4,
                              ), // Light Blue saat tidak terpilih (default background)
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Border radius 8px
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(
                                  0xFF015C91,
                                ) // Normal Blue untuk border terpilih
                                : Colors.transparent,
                        width: isSelected ? 2 : 0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        fontSize: isSelected ? 48 : 36,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected
                                ? const Color(
                                  0xFF002033,
                                ) // Darker Blue untuk angka terpilih
                                : Colors
                                    .grey
                                    .shade600, // Warna abu-abu untuk angka tidak terpilih
                        fontFamily: 'Poppins', // Font Poppins
                      ),
                      child: Text(
                        weightValue.toStringAsFixed(0),
                      ), // Tampilkan sebagai int untuk berat
                    ),
                  );
                },
                itemCount: 120, // Range dari 40 kg hingga 159 kg (40+119)
                itemSize: 130, // Lebar item + margin (120 + 5 + 5)
                onItemFocus: (index) {
                  setState(() {
                    _selectedWeight =
                        (40 + index).toDouble(); // Simpan selalu dalam KG
                  });
                },
                initialIndex:
                    (_selectedWeight - 40)
                        .round()
                        .toDouble(), // Atur item awal yang terfokus
                curve: Curves.easeOut,
                duration: 300,
                dynamicItemSize: true,
              ),
            ),
            // CustomPaint untuk skala busur di bawah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 150, // Tinggi yang cukup untuk skala
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width - 40, 150),
                  painter: _CurvedScalePainter(
                    _selectedWeight.round(), // Hanya kirim selectedWeight (int)
                  ),
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToNextScreen, // Panggil fungsi navigasi
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01456D), // Dark Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Sudut tombol 8px
                  ),
                  elevation: 5,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins', // Font Poppins
                  ),
                ),
                child: const Text('Next'), // Child argument last
              ),
            ),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}

// Custom Painter untuk menggambar skala berbentuk busur dinamis
class _CurvedScalePainter extends CustomPainter {
  final int selectedWeight; // Hanya selectedWeight (dalam KG)

  _CurvedScalePainter(this.selectedWeight);

  static const double tickLengthShort = 10;
  static const double tickLengthLong = 15;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint =
        Paint()
          ..color =
              Colors
                  .grey
                  .shade400 // Warna garis skala abu-abu (dari palet: Colors.grey.shade400)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final Paint needlePaint =
        Paint()
          ..color = const Color(0xFFF2A900) // Warna oranye untuk jarum
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;

    // --- Kalkulasi Rentang Angka Tampilan Dinamis ---
    int centralDisplayLabel;
    int nearestTen = (selectedWeight ~/ 10) * 10;
    int remainder = selectedWeight % 10;

    if (remainder == 0) {
      centralDisplayLabel = selectedWeight;
    } else if (remainder <= 5) {
      centralDisplayLabel = nearestTen;
    } else {
      centralDisplayLabel = nearestTen + 10;
    }

    centralDisplayLabel = centralDisplayLabel.clamp(50, 140);

    final int minDisplayLabel = centralDisplayLabel - 10;
    final int maxDisplayLabel = centralDisplayLabel + 10;

    const int visualTickRangeExtension = 5;
    final int minTickValue = minDisplayLabel - visualTickRangeExtension;
    final int maxTickValue = maxDisplayLabel + visualTickRangeExtension;
    final int totalVisualTickUnits = maxTickValue - minTickValue;

    // --- Definisi dan Perhitungan Busur ---
    final double paddingX = 20;
    final double startArcX = paddingX;
    final double endArcX = size.width - paddingX;
    final double arcLineY = size.height * 0.3;

    final double arcSagitta = size.height * 0.25;

    final double chordLength = endArcX - startArcX;
    final double actualRadius =
        (math.pow(chordLength, 2) / (8 * arcSagitta)) + (arcSagitta / 2);
    final double actualArcCenterX = size.width / 2;
    final double actualArcCenterY = arcLineY + actualRadius - arcSagitta;

    final double visualScaleStartAngle = math.atan2(
      arcLineY - actualArcCenterY,
      startArcX - actualArcCenterX,
    );
    final double visualScaleEndAngle = math.atan2(
      arcLineY - actualArcCenterY,
      endArcX - actualArcCenterX,
    );
    final double visualScaleSweepAngle =
        visualScaleEndAngle - visualScaleStartAngle;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(actualArcCenterX, actualArcCenterY),
        radius: actualRadius,
      ),
      visualScaleStartAngle,
      visualScaleSweepAngle,
      false,
      linePaint,
    );

    final double anglePerUnit = visualScaleSweepAngle / totalVisualTickUnits;

    for (int i = minTickValue; i <= maxTickValue; i++) {
      Offset tickEnd = Offset.zero;

      bool shouldDrawMajorLabel = false;
      if (i == minDisplayLabel || i == maxDisplayLabel) {
        shouldDrawMajorLabel = true;
      } else if (i == centralDisplayLabel &&
          selectedWeight != centralDisplayLabel) {
        shouldDrawMajorLabel = true;
      }

      bool isMidTick =
          (i % 5 == 0 && !shouldDrawMajorLabel && i != centralDisplayLabel);

      final double currentAngle =
          visualScaleStartAngle + (i - minTickValue) * anglePerUnit;

      final double pointOnArcX =
          actualArcCenterX + actualRadius * math.cos(currentAngle);
      final double pointOnArcY =
          actualArcCenterY + actualRadius * math.sin(currentAngle);

      final double dx = pointOnArcX - actualArcCenterX;
      final double dy = pointOnArcY - actualArcCenterY;
      final double normalizeFactor = math.sqrt(dx * dx + dy * dy);
      final double normalX = dx / normalizeFactor;
      final double normalY = dy / normalizeFactor;

      Offset tickStart = Offset(pointOnArcX, pointOnArcY);

      double currentTickLength = tickLengthShort / 2;
      if (shouldDrawMajorLabel) {
        currentTickLength = tickLengthLong;
      } else if (isMidTick) {
        currentTickLength = tickLengthShort;
      }

      tickEnd = Offset(
        pointOnArcX - normalX * currentTickLength,
        pointOnArcY - normalY * currentTickLength,
      );
      canvas.drawLine(tickStart, tickEnd, linePaint);

      if (shouldDrawMajorLabel) {
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: '$i',
            style: TextStyle(
              color: Colors.grey.shade600, // Warna teks skala abu-abu
              fontSize: 14,
              fontFamily: 'Poppins', // Font Poppins untuk teks skala
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final double textOffset = currentTickLength + 8;
        textPainter.paint(
          canvas,
          Offset(
            pointOnArcX - normalX * textOffset - textPainter.width / 2,
            pointOnArcY - normalY * textOffset - textPainter.height / 2,
          ),
        );
      }
    }

    // --- Menggambar Jarum Penunjuk ---
    final double needleAngle =
        visualScaleStartAngle + (selectedWeight - minTickValue) * anglePerUnit;

    final double pointOnArcSelectedX =
        actualArcCenterX + actualRadius * math.cos(needleAngle);
    final double pointOnArcSelectedY =
        actualArcCenterY + actualRadius * math.sin(needleAngle);

    final double needleStartX = pointOnArcSelectedX;
    final double needleStartY = pointOnArcSelectedY + 40;

    final double needleEndX = pointOnArcSelectedX;
    final double needleEndY = pointOnArcSelectedY;

    canvas.drawLine(
      Offset(needleStartX, needleStartY),
      Offset(needleEndX, needleEndY),
      needlePaint,
    );

    // --- Menggambar Angka Berat Badan Terpilih (dinamis) di bawah jarum ---
    TextPainter textSelectedPaint = TextPainter(
      text: TextSpan(
        text: '$selectedWeight',
        style: const TextStyle(
          color: Color(0xFFF2A900), // Warna oranye
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins', // Font Poppins
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textSelectedPaint.paint(
      canvas,
      Offset(needleStartX - textSelectedPaint.width / 2, needleStartY + 8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    _CurvedScalePainter old = oldDelegate as _CurvedScalePainter;
    return old.selectedWeight != selectedWeight;
  }
}
