import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/widgets/custom_button.dart';
import 'package:mobile_prakerin/widgets/custom_file_source_dialog.dart';

import '../../services/presensi_service.dart';

class PresensiFormulirPage extends StatefulWidget {
  const PresensiFormulirPage({super.key});

  @override
  State<PresensiFormulirPage> createState() => _PresensiFormulirPageState();
}

class _PresensiFormulirPageState extends State<PresensiFormulirPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  String _selectedType = 'Sakit';
  DateTime _selectedDate = DateTime.now();
  File? _file;
  String? _fileName;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final service = PresensiService();
      final response = await service.addFormulir(
        tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate),
        catatan: _reasonController.text,
        status: _selectedType,
        imagePath: _file!.path,
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
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showFileSourceDialog() {
    CustomFileSourceDialog.show(
      context: context,
      allowedSources: const [
        FileSourceType.camera,
        FileSourceType.gallery,
        FileSourceType.file,
      ],
      onPicked: (file, fileName) {
        setState(() {
          _file = file;
          _fileName = fileName;
        });
      },
    );
  }

  Widget _buildFilePreview() {
    if (_file == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 50,
              color: AppColors.primaryDark,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload Bukti / Dokumen Pendukung',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              '(Gambar/PDF/DOC)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final extension = _fileName?.split('.').last.toLowerCase() ?? '';

    if (extension == 'pdf') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              _fileName ?? 'PDF Document',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    } else if (extension == 'doc' || extension == 'docx') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 50, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              _fileName ?? 'Word Document',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _file!,
          fit: BoxFit.fill,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = screenHeight * 0.02;

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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Text(
                      'Form Izin/Sakit',
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
                            'Jenis Ketidakhadiran',
                            DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: _inputDecoration(),
                              items: ['Sakit', 'Izin'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedType = newValue!;
                                });
                              },
                            ),
                          ),
                          _buildFormField(
                            required: true,
                            'Tanggal',
                            InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd MMMM yyyy', 'id_ID')
                                          .format(_selectedDate),
                                    ),
                                    const Icon(Icons.calendar_today,
                                        color: AppColors.primaryDark),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildFormField(
                            required: true,
                            'Bukti / Dokumen Pendukung',
                            InkWell(
                              onTap: _showFileSourceDialog,
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _buildFilePreview(),
                              ),
                            ),
                          ),
                          _buildFormField(
                            'Alasan',
                            TextFormField(
                              controller: _reasonController,
                              maxLines: 5,
                              decoration: _inputDecoration(
                                hintText: 'Jelaskan alasan ketidakhadiran Anda',
                              ),
                            ),
                          ),
                          Text(
                            '* Wajib diisi',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: spacing * 2),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryDark,
                                  ),
                                )
                              : CustomButton(
                                  text: 'Kirim',
                                  backgroundColor: AppColors.primaryDark,
                                  color: AppColors.white,
                                  onPressed: _submit,
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

  Widget _buildFormField(String label, Widget field, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 6),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
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
}
