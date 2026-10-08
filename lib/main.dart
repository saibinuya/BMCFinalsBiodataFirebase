import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BioDataApp());
}

class BioDataApp extends StatelessWidget {
  const BioDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Professional Bio-Data',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF173F5F),
        ),
      ),
      home: const BioDataPage(),
    );
  }
}

class BioDataPage extends StatefulWidget {
  const BioDataPage({super.key});

  @override
  State<BioDataPage> createState() => _BioDataPageState();
}

class _BioDataPageState extends State<BioDataPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final birthDateController = TextEditingController();
  final ageController = TextEditingController();
  final civilStatusController = TextEditingController();
  final nationalityController = TextEditingController();
  final religionController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  final elementaryController = TextEditingController();
  final seniorHighController = TextEditingController();
  final collegeController = TextEditingController();
  final courseController = TextEditingController();

  final skillsController = TextEditingController();

  final positionController = TextEditingController();
  final companyController = TextEditingController();
  final workYearsController = TextEditingController();

  final certificationController = TextEditingController();
  final signatureController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  Uint8List? imageBytes;
  String? imageName;

  bool isSaving = false;

  static const Color navy = Color(0xFF173F5F);
  static const Color darkNavy = Color(0xFF102C43);
  static const Color accent = Color(0xFF2E86AB);
  static const Color background = Color(0xFFF5F7FA);

  @override
  void dispose() {
    fullNameController.dispose();
    birthDateController.dispose();
    ageController.dispose();
    civilStatusController.dispose();
    nationalityController.dispose();
    religionController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();

    elementaryController.dispose();
    seniorHighController.dispose();
    collegeController.dispose();
    courseController.dispose();

    skillsController.dispose();

    positionController.dispose();
    companyController.dispose();
    workYearsController.dispose();

    certificationController.dispose();
    signatureController.dispose();

    super.dispose();
  }

  Future<void> pickProfilePicture() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        imageBytes = bytes;
        imageName = image.name;
      });
    } catch (e) {
      showMessage('Unable to select picture.');
    }
  }

  Future<String?> uploadProfilePicture() async {
    if (imageBytes == null) return null;

    final safeName = imageName ?? 'profile.jpg';

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$safeName';

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child(fileName);

    String contentType = 'image/jpeg';

    final lowerName = safeName.toLowerCase();

    if (lowerName.endsWith('.png')) {
      contentType = 'image/png';
    } else if (lowerName.endsWith('.webp')) {
      contentType = 'image/webp';
    }

    await storageRef.putData(
      imageBytes!,
      SettableMetadata(
        contentType: contentType,
      ),
    );

    return await storageRef.getDownloadURL();
  }

  Future<void> saveData() async {
    if (!_formKey.currentState!.validate()) {
      showMessage('Please fill in the required fields.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String? imageUrl;

      if (imageBytes != null) {
        imageUrl = await uploadProfilePicture();
      }

      await FirebaseFirestore.instance.collection('biodata').add({
        'fullName': fullNameController.text.trim(),
        'birthDate': birthDateController.text.trim(),
        'age': ageController.text.trim(),
        'civilStatus': civilStatusController.text.trim(),
        'nationality': nationalityController.text.trim(),
        'religion': religionController.text.trim(),
        'email': emailController.text.trim(),
        'contactNumber': contactController.text.trim(),
        'address': addressController.text.trim(),

        'education': {
          'elementary': elementaryController.text.trim(),
          'seniorHighSchool': seniorHighController.text.trim(),
          'college': collegeController.text.trim(),
          'course': courseController.text.trim(),
        },

        'skills': skillsController.text.trim(),

        'workExperience': {
          'position': positionController.text.trim(),
          'company': companyController.text.trim(),
          'years': workYearsController.text.trim(),
        },

        'certification': certificationController.text.trim(),
        'signature': signatureController.text.trim(),

        'profileImageUrl': imageUrl,

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage(
        'Bio-data saved successfully!',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Failed to save data. Check your Firebase settings.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void clearForm() {
    fullNameController.clear();
    birthDateController.clear();
    ageController.clear();
    civilStatusController.clear();
    nationalityController.clear();
    religionController.clear();
    emailController.clear();
    contactController.clear();
    addressController.clear();

    elementaryController.clear();
    seniorHighController.clear();
    collegeController.clear();
    courseController.clear();

    skillsController.clear();

    positionController.clear();
    companyController.clear();
    workYearsController.clear();

    certificationController.clear();
    signatureController.clear();

    setState(() {
      imageBytes = null;
      imageName = null;
    });

    showMessage('Form cleared.');
  }

  void showMessage(
    String message, {
    bool success = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: success ? const Color(0xFF238636) : darkNavy,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            darkNavy,
            navy,
            accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BIO-DATA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Professional Personal Information Form',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget profileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool mobile = constraints.maxWidth < 600;

          final picture = Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          navy,
                          accent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: navy.withOpacity(.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: imageBytes != null
                          ? Image.memory(
                              imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: const Color(0xFFEAF0F5),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 65,
                                color: navy,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 3,
                    right: 3,
                    child: InkWell(
                      onTap: pickProfilePicture,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: navy,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: pickProfilePicture,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Upload Photo'),
              ),
            ],
          );

          final information = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Profile',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Create your professional bio-data',
                style: TextStyle(
                  color: darkNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your information below. Fields marked with * are required.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          );

          if (mobile) {
            return Column(
              children: [
                picture,
                const SizedBox(height: 12),
                information,
              ],
            );
          }

          return Row(
            children: [
              picture,
              const SizedBox(width: 30),
              Expanded(child: information),
            ],
          );
        },
      ),
    );
  }

  Widget sectionCard(
    String title,
    String subtitle,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5EAF0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2F7),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: navy,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkNavy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }

  Widget textField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 14,
          color: darkNavy,
        ),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  size: 20,
                  color: Colors.grey.shade500,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE3E8ED),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: accent,
              width: 1.7,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 1.5,
            ),
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget responsiveTwoColumns(
    BuildContext context,
    List<Widget> children,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(
            children: children,
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 16),
            Expanded(child: children[1]),
          ],
        );
      },
    );
  }

  Widget buildButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5EAF0),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 500) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                saveButton(),
                const SizedBox(height: 10),
                clearButton(),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 160,
                child: clearButton(),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: saveButton(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget saveButton() {
    return ElevatedButton.icon(
      onPressed: isSaving ? null : saveData,
      icon: isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.save_rounded),
      label: Text(
        isSaving ? 'Saving...' : 'Save Bio-Data',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget clearButton() {
    return OutlinedButton.icon(
      onPressed: isSaving ? null : clearForm,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Clear Form'),
      style: OutlinedButton.styleFrom(
        foregroundColor: darkNavy,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        side: const BorderSide(
          color: Color(0xFFD4DCE4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                22,
                16,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1050,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        profileHeader(),

                        sectionCard(
                          'Personal Information',
                          'Basic information and contact details',
                          Icons.person_outline_rounded,
                          [
                            responsiveTwoColumns(
                              context,
                              [
                                textField(
                                  'Full Name',
                                  fullNameController,
                                  required: true,
                                  icon: Icons.person_outline,
                                ),
                                textField(
                                  'Date of Birth',
                                  birthDateController,
                                  hint: 'MM/DD/YYYY',
                                  icon: Icons.calendar_today_outlined,
                                ),
                              ],
                            ),
                            responsiveTwoColumns(
                              context,
                              [
                                textField(
                                  'Age',
                                  ageController,
                                  keyboardType: TextInputType.number,
                                  icon: Icons.cake_outlined,
                                ),
                                textField(
                                  'Civil Status',
                                  civilStatusController,
                                  icon: Icons.family_restroom_outlined,
                                ),
                              ],
                            ),
                            responsiveTwoColumns(
                              context,
                              [
                                textField(
                                  'Nationality',
                                  nationalityController,
                                  icon: Icons.public_outlined,
                                ),
                                textField(
                                  'Religion',
                                  religionController,
                                  icon: Icons.auto_awesome_outlined,
                                ),
                              ],
                            ),
                            responsiveTwoColumns(
                              context,
                              [
                                textField(
                                  'Email Address',
                                  emailController,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  icon: Icons.email_outlined,
                                ),
                                textField(
                                  'Contact Number',
                                  contactController,
                                  keyboardType: TextInputType.phone,
                                  icon: Icons.phone_outlined,
                                ),
                              ],
                            ),
                            textField(
                              'Complete Address',
                              addressController,
                              maxLines: 2,
                              icon: Icons.location_on_outlined,
                            ),
                          ],
                        ),

                        sectionCard(
                          'Educational Background',
                          'Schools, degree, and academic information',
                          Icons.school_outlined,
                          [
                            responsiveTwoColumns(
                              context,
                              [
                                textField(
                                  'Elementary School',
                                  elementaryController,
                                  icon: Icons.school_outlined,
                                ),
                                textField(
                                  'Senior High School',
                                  seniorHighController,
                                  icon: Icons.school_outlined,
                                ),
                              ],
                            ),
                            responsiveTwoColumns(
                              context,
                              [
                                textField(
                                  'College / University',
                                  collegeController,
                                  icon: Icons.account_balance_outlined,
                                ),
                                textField(
                                  'Course / Program',
                                  courseController,
                                  icon: Icons.menu_book_outlined,
                                ),
                              ],
                            ),
                          ],
                        ),

                        sectionCard(
                          'Skills & Abilities',
                          'List your skills and areas of expertise',
                          Icons.workspace_premium_outlined,
                          [
                            textField(
                              'Skills',
                              skillsController,
                              maxLines: 4,
                              hint:
                                  'Example: Programming, Communication, Teamwork',
                              icon: Icons.star_outline_rounded,
                            ),
                          ],
                        ),

                        sectionCard(
                          'Work Experience',
                          'Professional experience and employment history',
                          Icons.work_outline_rounded,
                          [
                            responsiveTwoColumns(
                              context,
                              [
                                textField(
                                  'Position / Job Title',
                                  positionController,
                                  icon: Icons.badge_outlined,
                                ),
                                textField(
                                  'Company / Organization',
                                  companyController,
                                  icon: Icons.business_outlined,
                                ),
                              ],
                            ),
                            textField(
                              'Years of Experience',
                              workYearsController,
                              icon: Icons.timeline_outlined,
                            ),
                          ],
                        ),

                        sectionCard(
                          'Certification & Signature',
                          'Additional credentials and verification',
                          Icons.verified_outlined,
                          [
                            textField(
                              'Certification',
                              certificationController,
                              maxLines: 2,
                              icon: Icons.workspace_premium_outlined,
                            ),
                            textField(
                              'Signature / Full Name',
                              signatureController,
                              icon: Icons.draw_outlined,
                            ),
                          ],
                        ),

                        buildButtons(),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 15,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Your information is securely stored in Firebase.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}