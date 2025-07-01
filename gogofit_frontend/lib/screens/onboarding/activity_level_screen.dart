// lib/screens/onboarding/activity_level_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/models/user_profile_data.dart';
import 'package:gogofit_frontend/screens/onboarding/purpose_screen.dart';

class ActivityLevelScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const ActivityLevelScreen({super.key, required this.registrationData});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  final Color primaryAppColor = const Color(0xFF015C91);
  final Color darkerTextColor = const Color(0xFF002033);
  final Color lightCardBackground = const Color(0xFFE6EFF4);
  final Color selectedCardBackground = const Color(0xFFB0CCDD);
  final Color selectedBorderColor = const Color(0xFF01456D);
  final Color greyTextColor = Colors.grey.shade600;

  late ActivityLevel _selectedActivityLevel;

  @override
  void initState() {
    super.initState();

    ActivityLevel initialLevel;
    if (widget.registrationData.containsKey('activityLevel') &&
        widget.registrationData['activityLevel'] != null) {
      initialLevel = getActivityLevelEnumFromBackendString(
        widget.registrationData['activityLevel'],
      );
    } else {
      // Default ke sedentary jika tidak ada data sama sekali
      initialLevel = currentUserProfile.value.activityLevel;
    }

    _selectedActivityLevel = initialLevel;

    // PERBAIKAN: Langsung update state global agar sinkron dengan UI.
    currentUserProfile.value = currentUserProfile.value.copyWith(
      activityLevel: _selectedActivityLevel,
    );
    debugPrint(
      'ActivityLevelScreen initState: currentUserProfile updated with level: $_selectedActivityLevel',
    );
  }

  void _navigateToNextScreen() {
    // Logika ini sudah benar.
    currentUserProfile.value = currentUserProfile.value.copyWith(
      activityLevel: _selectedActivityLevel,
    );

    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['activityLevel'] = getActivityLevelBackendString(
      _selectedActivityLevel,
    );

    debugPrint(
      'Selected Activity Level: ${getActivityLevelString(_selectedActivityLevel)}, melanjutkan ke Purpose Screen.',
    );
    debugPrint('  - RegistrationData: $updatedRegistrationData');
    debugPrint(
      '  - CurrentProfile State: ${currentUserProfile.value.toJson()}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                PurposeScreen(registrationData: updatedRegistrationData),
      ),
    );
  }

  // Menjadikan logika skip sebagai method terpisah untuk kejelasan
  void _skipOnboarding() {
    // Logika ini sudah benar.
    currentUserProfile.value = currentUserProfile.value.copyWith(
      activityLevel: ActivityLevel.sedentary, // Default jika diskip
    );
    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['activityLevel'] = getActivityLevelBackendString(
      ActivityLevel.sedentary,
    );

    debugPrint(
      'Skip Onboarding dari Activity Level Screen menuju Purpose Screen.',
    );
    debugPrint('  - RegistrationData: $updatedRegistrationData');
    debugPrint(
      '  - CurrentProfile State: ${currentUserProfile.value.toJson()}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                PurposeScreen(registrationData: updatedRegistrationData),
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
                Navigator.pop(context);
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
                onPressed: _skipOnboarding, // Memanggil method skip
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                        color: darkerTextColor,
                        fontFamily: 'Poppins',
                      ),
                      children: <TextSpan>[
                        const TextSpan(text: 'Bagaimana '),
                        TextSpan(
                          text: 'tingkat aktivitas fisik',
                          style: TextStyle(color: primaryAppColor),
                        ),
                        const TextSpan(text: ' Anda sehari-hari?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pilihan ini akan membantu kami menghitung kebutuhan kalori harian Anda secara akurat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: greyTextColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...ActivityLevel.values.map((level) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedActivityLevel = level;
                        });
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              _selectedActivityLevel == level
                                  ? BorderSide(
                                    color: selectedBorderColor,
                                    width: 2.0,
                                  )
                                  : BorderSide.none,
                        ),
                        color:
                            _selectedActivityLevel == level
                                ? selectedCardBackground
                                : lightCardBackground,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  getActivityLevelString(level),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: darkerTextColor,
                                  ),
                                ),
                              ),
                              Radio<ActivityLevel>(
                                value: level,
                                groupValue: _selectedActivityLevel,
                                onChanged: (ActivityLevel? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedActivityLevel = newValue;
                                    });
                                  }
                                },
                                activeColor: primaryAppColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _navigateToNextScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedBorderColor,
                  foregroundColor: Colors.white,
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
                child: const Text('Lanjut'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
