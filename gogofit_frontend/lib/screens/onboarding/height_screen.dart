// lib/screens/onboarding/height_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/onboarding/target_weight_screen.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart'; // Import package ini
// import 'dart:math' as math; // DIHAPUS: Import ini tidak lagi digunakan

class HeightScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const HeightScreen({super.key, required this.registrationData});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  double _selectedHeight = 175.0; // Nilai default sesuai mockup

  @override
  void initState() {
    super.initState();
    if (widget.registrationData.containsKey('heightCm') &&
        widget.registrationData['heightCm'] != null) {
      _selectedHeight = (widget.registrationData['heightCm'] as num).toDouble();
    }
  }

  void _navigateToNextScreen() {
    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['heightCm'] = _selectedHeight;

    debugPrint(
      'Tinggi badan terpilih: $_selectedHeight cm, melanjutkan ke Target Weight Screen dengan data: $updatedRegistrationData',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tinggi badan dipilih: ${_selectedHeight.toStringAsFixed(1)} cm',
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
    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['heightCm'] = null;

    debugPrint(
      'Skip Onboarding dari Height Screen menuju Target Weight Screen dengan data: $updatedRegistrationData',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Melewati pengisian tinggi badan, melanjutkan ke target berat badan',
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
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
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
                  color: const Color(0xFF002033),
                  fontFamily: 'Poppins',
                ),
                children: <TextSpan>[
                  const TextSpan(text: 'Berapa '),
                  TextSpan(
                    text: 'tinggi badan',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const TextSpan(text: ' anda?'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Kami akan menggunakan data ini untuk memberi anda jenis diet yang lebih baik untuk anda',
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
                    'cm',
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
            SizedBox(
              height: 180,
              child: ScrollSnapList(
                itemBuilder: (context, index) {
                  final double heightValue = (150 + index).toDouble();
                  final bool isSelected = heightValue == _selectedHeight;

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
                      child: Text(heightValue.toStringAsFixed(0)),
                    ),
                  );
                },
                itemCount: 70,
                itemSize: 130,
                onItemFocus: (index) {
                  setState(() {
                    _selectedHeight = (150 + index).toDouble();
                  });
                },
                initialIndex:
                    ((_selectedHeight - 150).round().clamp(0, 69)).toDouble(),
                curve: Curves.easeOut,
                duration: 300,
                dynamicItemSize: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width - 40, 30),
                painter: _HeightScalePainter(_selectedHeight.round()),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 40),
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
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}

class _HeightScalePainter extends CustomPainter {
  final int selectedHeight;

  _HeightScalePainter(this.selectedHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 1;

    final Paint selectedPaint =
        Paint()
          ..color = const Color(0xFFF2A900)
          ..strokeWidth = 2;

    const double tickHeightShort = 10;
    const double tickHeightMedium = 12;
    const double tickHeightLong = 15;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    final double centerCanvasX = size.width / 2;

    const double visibleUnitsRange = 30;
    final double pixelsPerUnit = size.width / visibleUnitsRange;

    int centralDisplayLabel;
    int nearestTen = (selectedHeight ~/ 10) * 10;
    int remainder = selectedHeight % 10;

    if (remainder == 0) {
      centralDisplayLabel = selectedHeight;
    } else if (remainder <= 5) {
      centralDisplayLabel = nearestTen;
    } else {
      centralDisplayLabel = nearestTen + 10;
    }
    centralDisplayLabel = centralDisplayLabel.clamp(160, 210);

    final int minDisplayLabel = centralDisplayLabel - 10;
    final int maxDisplayLabel = centralDisplayLabel + 10;

    const int visualTickRangeExtension = 5;
    final int minTickValue = minDisplayLabel - visualTickRangeExtension;
    final int maxTickValue = maxDisplayLabel + visualTickRangeExtension;

    for (int i = minTickValue; i <= maxTickValue; i++) {
      double xPos = centerCanvasX + (i - selectedHeight) * pixelsPerUnit;

      if (xPos >= 0 && xPos <= size.width) {
        double currentTickHeight = tickHeightShort / 4;

        bool shouldDrawMajorLabel = false;
        if (i == minDisplayLabel || i == maxDisplayLabel) {
          shouldDrawMajorLabel = true;
          currentTickHeight = tickHeightLong;
        } else if (i == centralDisplayLabel) {
          if (selectedHeight != centralDisplayLabel) {
            shouldDrawMajorLabel = true;
          }
          currentTickHeight = tickHeightLong;
        } else if (i % 5 == 0) {
          currentTickHeight = tickHeightMedium;
        }

        canvas.drawLine(
          Offset(xPos, size.height / 2 - currentTickHeight / 2),
          Offset(xPos, size.height / 2 + currentTickHeight / 2),
          paint,
        );

        if (shouldDrawMajorLabel) {
          TextPainter textPainter = TextPainter(
            text: TextSpan(
              text: '$i',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          textPainter.paint(
            canvas,
            Offset(
              xPos - textPainter.width / 2,
              size.height / 2 + currentTickHeight / 2 + 5,
            ),
          );
        }
      }
    }

    canvas.drawLine(
      Offset(centerCanvasX, size.height / 2 - tickHeightLong / 2),
      Offset(centerCanvasX, size.height / 2 + tickHeightLong / 2),
      selectedPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    _HeightScalePainter old = oldDelegate as _HeightScalePainter;
    return old.selectedHeight != selectedHeight;
  }
}
