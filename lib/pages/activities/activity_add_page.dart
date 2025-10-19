import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/services/kegiatan_service.dart';
import 'package:mobile_prakerin/widgets/custom_button.dart';
import 'package:mobile_prakerin/widgets/custom_file_source_dialog.dart';

class ActivityAddPage extends StatefulWidget {
  final String id_presensi;
  const ActivityAddPage({super.key, required this.id_presensi});

  @override
  State<ActivityAddPage> createState() => _ActivityAddPageState();
}

class _ActivityAddPageState extends State<ActivityAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
    CustomFileSourceDialog.show(
      context: context,
      allowedSources: const [
        FileSourceType.camera,
        FileSourceType.gallery,
      ],
      onPicked: (file, fileName) {
        setState(() {
          _imageFile = file;
        });
      },
    );
  }

  Widget _buildImagePreview() {
    if (_imageFile == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.cloud_upload_outlined,
                size: 50, color: AppColors.primaryDark),
            SizedBox(height: 8),
            Text(
              'Upload Foto Kegiatan',
              style: TextStyle(
                  color: AppColors.primaryDark, fontWeight: FontWeight.w500),
            ),
            Text('(JPG/PNG)',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(_imageFile!, fit: BoxFit.cover),
    );
  }

  Widget _buildFormField(String label, Widget field, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            if (required)
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        field,
        const SizedBox(height: 24),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryDark),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final service = KegiatanService();
      final response = await service.addActivity(
        judul: _titleController.text,
        deskripsi: _descriptionController.text,
        durasi: _durationController.text,
        idKehadiran: widget.id_presensi,
        imagePath: _imageFile!.path,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (response['success'] == true) {
        Fluttertoast.showToast(
            msg: response['message']?.toString() ??
                'Berhasil mengirim formulir');
        Navigator.pushReplacementNamed(context, '/presensi');
      } else {
        Fluttertoast.showToast(
            msg: response['message']?.toString() ?? 'Terjadi kesalahan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = MediaQuery.of(context).size.height * 0.02;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Text(
                      'Tambah Kegiatann',
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormField(
                            required: true,
                            'Judul Kegiatan',
                            TextFormField(
                              controller: _titleController,
                              decoration: _inputDecoration(
                                  hintText: 'Masukkan judul kegiatan'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Judul tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                          _buildFormField(
                            required: true,
                            'Deskripsi Kegiatan',
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 6,
                                  decoration: _inputDecoration(
                                      hintText: 'Masukkan deskripsi kegiatan'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Deskripsi tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          _buildFormField(
                            required: true,
                            'Durasi (menit)',
                            TextFormField(
                              controller: _durationController,
                              decoration: _inputDecoration(
                                  hintText: 'Masukkan durasi dalam menit'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Durasi tidak boleh kosong';
                                }
                                final minutes = int.tryParse(value);
                                if (minutes == null || minutes <= 0) {
                                  return 'Masukkan durasi dalam menit (angka > 0)';
                                }
                                return null;
                              },
                            ),
                          ),
                          _buildFormField(
                            required: true,
                            'Foto Kegiatan',
                            InkWell(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _buildImagePreview(),
                              ),
                            ),
                          ),
                          //kasih keterangan bahwa tanda * adalah field yang wajib diisi
                          Text(
                            '* Wajib diisi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: spacing * 2),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : CustomButton(
                                  text: 'Simpan',
                                  backgroundColor: AppColors.primaryDark,
                                  color: AppColors.white,
                                  onPressed: _submitForm,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
