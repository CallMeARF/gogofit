// lib/screens/onboarding/purpose_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/dashboard_screen.dart';
import 'package:gogofit_frontend/services/api_service.dart';
import 'package:gogofit_frontend/models/user_profile_data.dart';

class PurposeScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const PurposeScreen({super.key, required this.registrationData});

  @override
  State<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends State<PurposeScreen> {
  final List<String> _purposeOptions = [
    'Menurunkan Berat Badan',
    'Menaikkan Berat Badan',
    'Menjaga Kesehatan',
  ];

  String? _selectedPurpose;
  final ApiService _apiService = ApiService();
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();

    String initialPurpose = getDietPurposeString(
      currentUserProfile.value.purpose,
    );
    if (widget.registrationData.containsKey('purpose') &&
        widget.registrationData['purpose'] != null) {
      initialPurpose = widget.registrationData['purpose'];
    }

    if (_purposeOptions.contains(initialPurpose)) {
      _selectedPurpose = initialPurpose;
    }

    // PERBAIKAN 1: Langsung update state global agar sinkron dengan UI.
    if (_selectedPurpose != null) {
      currentUserProfile.value = currentUserProfile.value.copyWith(
        purpose: getDietPurposeEnumFromFlutterString(_selectedPurpose!),
      );
    }
    debugPrint(
      'PurposeScreen initState: currentUserProfile updated with purpose: ${currentUserProfile.value.purpose}',
    );
  }

  Future<void> _completeRegistration({bool skipPurpose = false}) async {
    if (!skipPurpose && _selectedPurpose == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mohon pilih tujuan Anda.')));
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    // PERBAIKAN 2: Lakukan `copyWith` terakhir untuk `purpose` sebelum mengirim data.
    final DietPurpose finalPurpose =
        skipPurpose || _selectedPurpose == null
            ? DietPurpose.maintainHealth
            : getDietPurposeEnumFromFlutterString(_selectedPurpose!);

    currentUserProfile.value = currentUserProfile.value.copyWith(
      purpose: finalPurpose,
    );

    // Sekarang, semua data di currentUserProfile sudah final dan siap dikirim.
    final UserProfile finalProfile = currentUserProfile.value;

    debugPrint('Final Registration Data to API:');
    debugPrint('  - Profile State: ${finalProfile.toJson()}');
    debugPrint('  - Password included from registrationData.');

    try {
      final response = await _apiService.register(
        name: finalProfile.name,
        email: finalProfile.email,
        password: widget.registrationData['password'] as String,
        passwordConfirmation:
            widget.registrationData['passwordConfirmation'] as String,
        gender: finalProfile.gender == 'Laki-laki' ? 'male' : 'female',
        birthDate: finalProfile.birthDate,
        heightCm: finalProfile.heightCm,
        currentWeightKg: finalProfile.currentWeightKg,
        targetWeightKg: finalProfile.targetWeightKg,
        purpose: getDietPurposeBackendString(finalProfile.purpose),
        activityLevel: getActivityLevelBackendString(
          finalProfile.activityLevel,
        ),
      );

      if (!mounted) return;

      if (response['success']) {
        final UserProfile? fetchedProfile = await _apiService.getUserProfile();
        if (mounted && fetchedProfile != null) {
          currentUserProfile.value = fetchedProfile;
        }

        _showAlertDialog(
          'Sukses',
          response['message'] ?? 'Registrasi berhasil!',
          () {
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false,
            );
          },
        );
      } else {
        setState(() => _isRegistering = false);
        _showAlertDialog(
          'Error',
          response['message'] ?? 'Registrasi gagal. Mohon coba lagi.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRegistering = false;
      });
      debugPrint('Registration Error: $e');
      _showAlertDialog(
        'Error',
        'Terjadi kesalahan saat registrasi: ${e.toString().contains('Exception:') ? e.toString().split('Exception:').last.trim() : 'Unknown error'}',
      );
    }
  }

  void _showAlertDialog(String title, String message, [VoidCallback? onOk]) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF015C91),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onOk?.call();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kode build tetap sama
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
                onPressed: () => _completeRegistration(skipPurpose: true),
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
      body:
          _isRegistering
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
              : Padding(
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
                          const TextSpan(text: 'Apa '),
                          TextSpan(
                            text: 'tujuan',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
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
                    ..._purposeOptions.map((purposeText) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildPurposeOption(
                          context,
                          purposeText,
                          purposeText == 'Menurunkan Berat Badan'
                              ? 'assets/images/purpose_lose_weight.png'
                              : (purposeText == 'Menaikkan Berat Badan'
                                  ? 'assets/images/purpose_gain_weight.png'
                                  : 'assets/images/purpose_stay_healthy.png'),
                          const Color(0xFF01456D),
                          const Color(0xFFE6EFF4),
                        ),
                      );
                    }),
                    const Spacer(),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _selectedPurpose != null
                                ? () => _completeRegistration()
                                : null,
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
                        child: const Text('Selesai'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
    );
  }

  Widget _buildPurposeOption(
    BuildContext context,
    String title,
    String imagePath,
    Color selectedBorderColor,
    Color defaultBackgroundColor,
  ) {
    bool isSelected = _selectedPurpose == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPurpose = title;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB0CCDD) : defaultBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? selectedBorderColor : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A9E9E9E),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002033),
                fontFamily: 'Poppins',
              ),
            ),
            Image.asset(imagePath, height: 100, width: 100),
          ],
        ),
      ),
    );
  }
}
