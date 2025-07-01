// lib/screens/onboarding/current_weight_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/models/user_profile_data.dart';
import 'package:gogofit_frontend/screens/onboarding/target_weight_screen.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'dart:math' as math;

class CurrentWeightScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const CurrentWeightScreen({super.key, required this.registrationData});

  @override
  State<CurrentWeightScreen> createState() => _CurrentWeightScreenState();
}

class _CurrentWeightScreenState extends State<CurrentWeightScreen> {
  double _selectedCurrentWeight = 65.0; // Nilai default

  @override
  void initState() {
    super.initState();

    double initialWeight;
    if (widget.registrationData.containsKey('currentWeightKg') &&
        widget.registrationData['currentWeightKg'] != null) {
      initialWeight =
          (widget.registrationData['currentWeightKg'] as num).toDouble();
    } else if (currentUserProfile.value.currentWeightKg > 0.0) {
      initialWeight = currentUserProfile.value.currentWeightKg;
    } else {
      initialWeight = 65.0; // Default fallback
    }

    _selectedCurrentWeight = initialWeight;

    // PERBAIKAN: Sinkronkan nilai awal ke state global untuk konsistensi.
    currentUserProfile.value = currentUserProfile.value.copyWith(
      currentWeightKg: _selectedCurrentWeight,
    );
    debugPrint(
      'CurrentWeightScreen initState: currentUserProfile updated with weight: $_selectedCurrentWeight',
    );
  }

  void _navigateToNextScreen() {
    // Logika ini sudah benar, state global diperbarui.
    currentUserProfile.value = currentUserProfile.value.copyWith(
      currentWeightKg: _selectedCurrentWeight,
    );

    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['currentWeightKg'] = _selectedCurrentWeight;

    // Menambahkan debug print yang lebih detail
    debugPrint(
      'Berat badan saat ini terpilih: ${_selectedCurrentWeight.toStringAsFixed(1)} kg, melanjutkan ke Target Weight Screen.',
    );
    debugPrint('  - RegistrationData: $updatedRegistrationData');
    debugPrint(
      '  - CurrentProfile State: ${currentUserProfile.value.toJson()}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Berat badan saat ini dipilih: ${_selectedCurrentWeight.toStringAsFixed(1)} kg',
        ),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                TargetWeightScreen(registrationData: updatedRegistrationData),
      ),
    );
  }

  void _skipOnboarding() {
    // Logika ini sudah benar, state global diperbarui.
    currentUserProfile.value = currentUserProfile.value.copyWith(
      currentWeightKg: 0.0,
    );

    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['currentWeightKg'] = 0.0;

    debugPrint(
      'Skip Onboarding dari Current Weight Screen menuju Target Weight Screen.',
    );
    debugPrint('  - RegistrationData: $updatedRegistrationData');
    debugPrint(
      '  - CurrentProfile State: ${currentUserProfile.value.toJson()}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Melewati pengisian berat badan saat ini, melanjutkan ke target berat badan',
        ),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                TargetWeightScreen(registrationData: updatedRegistrationData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kode build tetap sama persis karena sudah menggunakan `_CurvedWeightScalePainter` yang benar.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: _skipOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002033),
                  fontFamily: 'Poppins',
                ),
                children: <TextSpan>[
                  const TextSpan(text: 'Berapa '),
                  TextSpan(
                    text: 'berat badan saat ini',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const TextSpan(text: ' Anda?'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Kami akan menggunakan data ini untuk memberi Anda jenis diet yang lebih baik untuk Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
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
                    color: const Color(0xFF015C91),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'kg',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, 10),
                child: const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFFF2A900),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: ScrollSnapList(
                itemBuilder: (context, index) {
                  final double weightValue = (40 + index).toDouble();
                  final bool isSelected = weightValue == _selectedCurrentWeight;

                  return Container(
                    width: 120,
                    height: isSelected ? 150 : 130,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFB0CCDD)
                              : const Color(0xFFE6EFF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF015C91)
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
                                ? const Color(0xFF002033)
                                : Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                      child: Text(weightValue.toStringAsFixed(0)),
                    ),
                  );
                },
                itemCount: 121,
                itemSize: 130,
                onItemFocus: (index) {
                  setState(() {
                    _selectedCurrentWeight = (40 + index).toDouble();
                  });
                },
                initialIndex:
                    ((_selectedCurrentWeight - 40).round().clamp(
                      0,
                      120,
                    )).toDouble(),
                curve: Curves.easeOut,
                duration: 300,
                dynamicItemSize: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 150,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width - 40, 150),
                  painter: _CurvedWeightScalePainter(
                    _selectedCurrentWeight.round(),
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToNextScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01456D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _CurvedWeightScalePainter extends CustomPainter {
  final int selectedWeight;

  _CurvedWeightScalePainter(this.selectedWeight);

  static const double tickLengthShort = 10;
  static const double tickLengthLong = 15;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint =
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final needlePaint =
        Paint()
          ..color = const Color(0xFFF2A900)
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;

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

    centralDisplayLabel = centralDisplayLabel.clamp(50, 150);

    final int minDisplayLabel = centralDisplayLabel - 10;
    final int maxDisplayLabel = centralDisplayLabel + 10;

    const int visualTickRangeExtension = 5;
    final int minTickValue = minDisplayLabel - visualTickRangeExtension;
    final int maxTickValue = maxDisplayLabel + visualTickRangeExtension;
    final int totalVisualTickUnits = maxTickValue - minTickValue;

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

    final double anglePerUnit = visualScaleSweepAngle / totalVisualTickUnits;

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

    for (int i = minTickValue; i <= maxTickValue; i++) {
      bool shouldDrawMajorLabel =
          (i == minDisplayLabel ||
              i == maxDisplayLabel ||
              (i == centralDisplayLabel &&
                  selectedWeight != centralDisplayLabel));
      bool isMidTick = (i % 5 == 0 && !shouldDrawMajorLabel);

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

      Offset tickEnd = Offset(
        pointOnArcX - normalX * currentTickLength,
        pointOnArcY - normalY * currentTickLength,
      );
      canvas.drawLine(tickStart, tickEnd, linePaint);

      if (shouldDrawMajorLabel) {
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: '$i',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontFamily: 'Poppins',
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

    TextPainter textSelectedPaint = TextPainter(
      text: TextSpan(
        text: '$selectedWeight',
        style: const TextStyle(
          color: Color(0xFFF2A900),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
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
    if (oldDelegate is _CurvedWeightScalePainter) {
      return oldDelegate.selectedWeight != selectedWeight;
    }
    return true;
  }
}
