// lib/screens/add_exercise_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gogofit_frontend/services/api_service.dart';
import 'package:intl/intl.dart';

class AddExerciseScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddExerciseScreen({super.key, required this.selectedDate});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _activityNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _activityNameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _saveExerciseLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final exerciseData = {
        'activity_name': _activityNameController.text.trim(),
        'duration_minutes': int.parse(_durationController.text),
        'calories_burned': int.parse(_caloriesController.text),
        'exercised_at': DateFormat(
          "yyyy-MM-dd HH:mm:ss",
        ).format(widget.selectedDate),
      };

      final response = await _apiService.addExerciseLog(exerciseData);

      if (!mounted) return;

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Latihan berhasil dicatat.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kirim 'true' untuk refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal mencatat latihan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // PERBAIKAN: Menggunakan AppBar solid sesuai gaya halaman utama
      appBar: AppBar(
        backgroundColor: const Color(0xFF015c91), // primaryBlueNormal
        elevation: 0,
        title: const Text(
          'Tambah Latihan',
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
          _isSaving
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0), // Padding lebih seragam
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Ratakan ke kiri
                    children: [
                      const SizedBox(height: 20),
                      // Form Input
                      TextFormField(
                        controller: _activityNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Aktivitas',
                          hintText: 'Contoh: Lari Pagi',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama aktivitas tidak boleh kosong.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Durasi (menit)',
                          hintText: 'Contoh: 30',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Durasi tidak boleh kosong.';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Masukkan angka yang valid (lebih dari 0).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _caloriesController,
                        decoration: const InputDecoration(
                          labelText: 'Kalori Terbakar (kkal)',
                          hintText: 'Contoh: 150',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kalori tidak boleh kosong.';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Masukkan angka yang valid (lebih dari 0).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 55, // Tinggi tombol standar
                        child: ElevatedButton(
                          onPressed: _saveExerciseLog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF01456D,
                            ), // Dark Blue
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Sudut konsisten
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          child: const Text('Simpan Latihan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
