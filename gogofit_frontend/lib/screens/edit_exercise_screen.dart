// lib/screens/edit_exercise_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gogofit_frontend/models/exercise_log.dart';
import 'package:gogofit_frontend/services/api_service.dart';

class EditExerciseScreen extends StatefulWidget {
  final ExerciseLog exerciseLog;

  const EditExerciseScreen({super.key, required this.exerciseLog});

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late TextEditingController _activityNameController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data latihan yang ada
    _activityNameController = TextEditingController(
      text: widget.exerciseLog.activityName,
    );
    _durationController = TextEditingController(
      text: widget.exerciseLog.durationMinutes.toString(),
    );
    _caloriesController = TextEditingController(
      text: widget.exerciseLog.caloriesBurned.toString(),
    );
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedData = {
        'activity_name': _activityNameController.text.trim(),
        'duration_minutes': int.parse(_durationController.text),
        'calories_burned': int.parse(_caloriesController.text),
        // exercised_at tidak diubah di sini, tapi bisa ditambahkan jika perlu
      };

      final response = await _apiService.updateExerciseLog(
        widget.exerciseLog.id,
        updatedData,
      );

      if (!mounted) return;

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Perubahan berhasil disimpan.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kirim 'true' untuk refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal menyimpan perubahan.'),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF015c91),
        elevation: 0,
        title: const Text(
          'Edit Latihan',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isSaving
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _activityNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Aktivitas',
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
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF01456D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          child: const Text('Simpan Perubahan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
