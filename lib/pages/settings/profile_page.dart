import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/widgets/custom_button.dart';
import 'package:mobile_prakerin/widgets/custom_file_source_dialog.dart';

import '../../models/home_model.dart';
import '../../services/auth_service.dart';
import '../../services/home_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  File? _imageFile;
  String? _imagePath;
  bool _isLoading = false;
  HomeModel? _homeModel;
  bool _isLoadingLoad = true;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    final service = HomeService();
    final data = await service.getData();

    if (mounted) {
      setState(() {
        _homeModel = data;
        _nameController.text = _homeModel?.name ?? '';
        _emailController.text = _homeModel?.email ?? '';
        _phoneController.text = _homeModel?.noHp ?? '';
        _addressController.text = _homeModel?.alamat ?? '';
        _imagePath = _homeModel?.foto;
        _isLoadingLoad = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final service = AuthService();
      final response = await service.editProfil(
        name: _nameController.text,
        email: _emailController.text,
        telepon: _phoneController.text,
        alamat: _addressController.text,
        imagePath: _imageFile?.path,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (response['success'] == true) {
        Fluttertoast.showToast(
            msg: response['message']?.toString() ?? 'Profil berhasil diubah');
        Navigator.pushReplacementNamed(context, '/settings');
      } else {
        Fluttertoast.showToast(
            msg: response['message']?.toString() ?? 'Terjadi kesalahan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Text(
                      'Ubah Profil',
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
                  child: _isLoadingLoad
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.accent2,
                                      width: 3,
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: screenWidth * 0.15,
                                        backgroundImage: _imageFile != null
                                            ? FileImage(_imageFile!)
                                            : _imagePath != null
                                                ? NetworkImage(_imagePath!)
                                                : const NetworkImage(
                                                    'https://picsum.photos/200',
                                                  ) as ImageProvider,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.accent2,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            _showImageSourceDialog();
                                          },
                                          icon: const Icon(Icons.camera_alt,
                                              color: AppColors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                _buildFormField(
                                  'Nama Lengkap',
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: _inputDecoration(
                                        hintText: 'Masukkan nama lengkap'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                _buildFormField(
                                  'Email',
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: _inputDecoration(
                                        hintText: 'Masukkan email'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                _buildFormField(
                                  'Nomor HP',
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: _inputDecoration(
                                        hintText: 'Masukkan nomor HP'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nomor HP tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                _buildFormField(
                                  'Alamat',
                                  TextFormField(
                                    controller: _addressController,
                                    maxLines: 3,
                                    decoration: _inputDecoration(
                                        hintText: 'Masukkan alamat lengkap'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Alamat tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                _isLoading
                                    ? const CircularProgressIndicator()
                                    : CustomButton(
                                        text: 'Simpan',
                                        backgroundColor: AppColors.primaryDark,
                                        color: AppColors.white,
                                        onPressed: _submitForm),
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

  Widget _buildFormField(String label, Widget field) {
    return Column(
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
