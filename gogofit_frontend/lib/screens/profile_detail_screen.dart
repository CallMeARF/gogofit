// lib/screens/profile_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gogofit_frontend/models/user_profile_data.dart';
import 'package:intl/intl.dart';
import 'package:gogofit_frontend/services/api_service.dart';
import 'package:gogofit_frontend/screens/change_password_screen.dart';
import 'package:gogofit_frontend/screens/auth/forgot_password_screen.dart';
import 'package:gogofit_frontend/exceptions/unauthorized_exception.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final Color primaryBlueNormal = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color lightBlueCardBackground = const Color(0xFFD9E7EF);
  final Color accentBlueColor = const Color(0xFF015c91);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _currentWeightController =
      TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _purposeOptions = [
    'Menurunkan Berat Badan',
    'Menaikkan Berat Badan',
    'Menjaga Kesehatan',
    'Lainnya',
  ];
  late String _selectedGender = _genderOptions.first;
  late String _selectedPurpose = _purposeOptions.first;
  late DateTime _selectedBirthDate = DateTime(2000, 1, 1);
  bool _isEditing = false;
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  // Fungsi helper untuk inisial tetap di sini karena spesifik untuk layar ini.
  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    List<String> names = name.trim().split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names.first.isNotEmpty ? names.first[0] : '';
    }
    if (names.length > 1) {
      initials += names.last.isNotEmpty ? names.last[0] : '';
    }
    return initials.toUpperCase();
  }

  // PERBAIKAN 1: Hapus fungsi _getAvatarColor dari sini.
  // Logika warna sekarang ada di dalam UserProfile model.

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    currentUserProfile.addListener(_updateUI);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    currentUserProfile.removeListener(_updateUI);
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final UserProfile? fetchedProfile = await _apiService.getUserProfile();
      if (fetchedProfile != null) {
        currentUserProfile.value = fetchedProfile;
        _loadProfileData(fetchedProfile);
      } else {
        debugPrint(
          'Fetched profile is null. ApiService might have handled redirect.',
        );
      }
    } on UnauthorizedException {
      debugPrint(
        'ProfileDetailScreen: Caught UnauthorizedException. Redirect handled by ApiService.',
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
      setState(() {
        _isLoading = false;
      });
      _showAlertDialog('Error', 'Terjadi kesalahan saat memuat profil: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateUI() {
    _loadProfileData(currentUserProfile.value);
    if (mounted) {
      setState(() {});
    }
  }

  void _loadProfileData(UserProfile profile) {
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _selectedBirthDate = profile.birthDate;
    _birthDateController.text = DateFormat(
      'dd MMMM yyyy',
      'id',
    ).format(profile.birthDate);
    _heightController.text = profile.heightCm.toStringAsFixed(1);
    _currentWeightController.text = profile.currentWeightKg.toStringAsFixed(1);
    _targetWeightController.text = profile.targetWeightKg.toStringAsFixed(1);

    _selectedGender =
        _genderOptions.contains(profile.gender)
            ? profile.gender
            : _genderOptions.first;
    _selectedPurpose =
        _purposeOptions.contains(getDietPurposeString(profile.purpose))
            ? getDietPurposeString(profile.purpose)
            : _purposeOptions.first;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _loadProfileData(currentUserProfile.value);
      }
    });
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlueNormal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkerBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryBlueNormal,
                textStyle: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat(
          'dd MMMM yyyy',
          'id',
        ).format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _currentWeightController.text.isEmpty ||
        _targetWeightController.text.isEmpty) {
      _showAlertDialog('Error', 'Semua field harus diisi.');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+?\.[^@]+').hasMatch(_emailController.text)) {
      _showAlertDialog('Error', 'Format email tidak valid.');
      return;
    }

    final double height = double.tryParse(_heightController.text) ?? 0.0;
    if (height <= 0) {
      _showAlertDialog('Error', 'Tinggi badan harus lebih dari 0.');
      return;
    }

    final double currentWeight =
        double.tryParse(_currentWeightController.text) ?? 0.0;
    if (currentWeight <= 0) {
      _showAlertDialog('Error', 'Berat badan saat ini harus lebih dari 0.');
      return;
    }

    final double targetWeight =
        double.tryParse(_targetWeightController.text) ?? 0.0;
    if (targetWeight <= 0) {
      _showAlertDialog('Error', 'Target berat badan harus lebih dari 0.');
      return;
    }

    final updatedProfile = currentUserProfile.value.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      gender: _selectedGender,
      birthDate: _selectedBirthDate,
      heightCm: height,
      currentWeightKg: currentWeight,
      targetWeightKg: targetWeight,
      purpose: getDietPurposeEnumFromFlutterString(_selectedPurpose),
    );

    try {
      final response = await _apiService.updateProfile(updatedProfile);

      if (response['success']) {
        currentUserProfile.value = updatedProfile;
        _showAlertDialog('Sukses', 'Profil berhasil diperbarui!', () {
          setState(() {
            _isEditing = false;
          });
        });
      } else {
        _showAlertDialog(
          'Error',
          response['message'] ?? 'Gagal memperbarui profil.',
        );
      }
    } on UnauthorizedException {
      debugPrint(
        'ProfileDetailScreen: updateProfile caught UnauthorizedException. Redirect handled by ApiService.',
      );
    } catch (e) {
      debugPrint('Error saving profile: $e');
      _showAlertDialog('Error', 'Terjadi kesalahan saat menyimpan profil: $e');
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
              child: Text(
                'OK',
                style: TextStyle(fontFamily: 'Poppins', color: accentBlueColor),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlueNormal,
        elevation: 0,
        title: const Text(
          'Pengaturan Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
              : ValueListenableBuilder<UserProfile>(
                valueListenable: currentUserProfile,
                builder: (context, profile, child) {
                  if (profile.name.isEmpty) {
                    return const Center(
                      child: Text(
                        'Profil tidak tersedia. Silakan login kembali.',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                // PERBAIKAN 2: Panggil getter dari model.
                                backgroundColor: profile.avatarColor,
                                child: Text(
                                  _getInitials(profile.name),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                profile.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: darkerBlue,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                profile.email,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                        // ... (sisa UI tetap sama)
                        _buildProfileInputField(
                          label: 'Nama Lengkap',
                          controller: _nameController,
                          readOnly: !_isEditing,
                        ),
                        _buildProfileInputField(
                          label: 'Email',
                          controller: _emailController,
                          readOnly: !_isEditing,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildDropdownField(
                          label: 'Jenis Kelamin',
                          value: _selectedGender,
                          options: _genderOptions,
                          readOnly: !_isEditing,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGender = newValue!;
                            });
                          },
                        ),
                        _buildProfileInputField(
                          label: 'Tanggal Lahir',
                          controller: _birthDateController,
                          readOnly: true,
                          onTap:
                              _isEditing
                                  ? () => _selectBirthDate(context)
                                  : null,
                        ),
                        _buildProfileInputField(
                          label: 'Tinggi Badan (cm)',
                          controller: _heightController,
                          readOnly: !_isEditing,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$'),
                            ),
                          ],
                          hintText: 'Ex: 170.5',
                        ),
                        _buildProfileInputField(
                          label: 'Berat Badan Saat Ini (kg)',
                          controller: _currentWeightController,
                          readOnly: !_isEditing,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$'),
                            ),
                          ],
                          hintText: 'Ex: 65.0',
                        ),
                        _buildProfileInputField(
                          label: 'Target Berat Badan (kg)',
                          controller: _targetWeightController,
                          readOnly: !_isEditing,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$'),
                            ),
                          ],
                          hintText: 'Ex: 60.0',
                        ),
                        _buildDropdownField(
                          label: 'Sasaran Kesehatan',
                          value: _selectedPurpose,
                          options: _purposeOptions,
                          readOnly: !_isEditing,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedPurpose = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        if (_isEditing)
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentBlueColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: OutlinedButton(
                                  onPressed: _toggleEditMode,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: accentBlueColor,
                                    side: BorderSide(
                                      color: accentBlueColor,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Batalkan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _toggleEditMode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentBlueColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                'Edit Profil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ChangePasswordScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightBlueCardBackground,
                              foregroundColor: darkerBlue,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            child: const Text('Ubah Kata Sandi'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightBlueCardBackground,
                              foregroundColor: darkerBlue,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            child: const Text('Lupa Kata Sandi?'),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildProfileInputField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: darkerBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: accentBlueColor, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              isDense: true,
            ),
            style: TextStyle(
              color: darkerBlue,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: darkerBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: readOnly ? Colors.grey.shade400 : accentBlueColor,
                  width: readOnly ? 1.5 : 2.0,
                ),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: darkerBlue),
                style: TextStyle(
                  color: darkerBlue,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                onChanged: readOnly ? null : onChanged,
                items:
                    options.map<DropdownMenuItem<String>>((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
