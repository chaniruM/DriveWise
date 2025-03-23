import 'package:flutter/material.dart';
import 'package:drivewise/services/api_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _dataLoaded = false;

  String? _profileImageUrl;
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  // Store original data for discard functionality
  String? _originalName;
  String? _originalPhone;
  String? _originalLocation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user profile data from API
      final response = await ApiService.getRequest('user/profile', context);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _locationController.text = userData['location'] ?? '';
          _profileImageUrl = userData['profileImage'];
          _dataLoaded = true;

          // Save original values
          _saveOriginalValues();
        });
      } else {
        // If profile doesn't exist yet, at least load the email
        await _loadUserEmail();
      }
    } catch (e) {
      // Fallback to just loading email if API call fails
      await _loadUserEmail();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save original values to restore when discarding changes
  void _saveOriginalValues() {
    _originalName = _nameController.text;
    _originalPhone = _phoneController.text;
    _originalLocation = _locationController.text;
  }

  // Restore original values when discarding changes
  void _restoreOriginalValues() {
    _nameController.text = _originalName ?? '';
    _phoneController.text = _originalPhone ?? '';
    _locationController.text = _originalLocation ?? '';
    _profileImageFile = null; // Reset any selected image
  }

  Future<void> _loadUserEmail() async {
    String? email = await ApiService.getUserEmail();
    if (email != null) {
      setState(() {
        _emailController.text = email;
        _dataLoaded = true;
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      // Reset image file when canceling edit
      if (!_isEditing) {
        _profileImageFile = null;
      }
    });
  }

  // Discard changes and exit edit mode
  void _discardChanges() {
    setState(() {
      _restoreOriginalValues();
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Changes discarded')),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (image != null) {
      setState(() {
        _profileImageFile = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (photo != null) {
      setState(() {
        _profileImageFile = File(photo.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () {
              Navigator.of(context).pop();
              _takePhoto();
            },
          ),
        ],
      ),
    );
  }

  void _submitDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // First upload image if selected
        String? imageUrl;
        if (_profileImageFile != null) {
          final uploadResponse = await ApiService.uploadProfileImage(
            _profileImageFile!,
            context,
          );

          if (uploadResponse['success']) {
            imageUrl = uploadResponse['imageUrl'];
          } else {
            throw Exception(
                'Failed to upload image: ${uploadResponse['message']}');
          }
        }

        // Then update profile with all data including possible new image URL
        Map<String, dynamic> userDetails = {
          "name": _nameController.text,
          "email": _emailController.text,
          "phone": _phoneController.text,
          if (_locationController.text.isNotEmpty)
            "location": _locationController.text,
          if (imageUrl != null) "profileImage": imageUrl,
        };

        final response = await ApiService.postRequest(
            'user/profile/update', userDetails, context);

        if (response.statusCode == 200) {
          // Refresh profile data to get the updated image URL
          await _loadUserData();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
          _toggleEdit();
        } else {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Text('Failed to update profile: ${responseData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
          _profileImageFile = null;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {bool required = true}) {
    return InputDecoration(
      labelText: required ? label : '$label (Optional)',
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Center the profile image
        GestureDetector(
          onTap: _isEditing ? _showImagePickerOptions : null,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 75, // Increased size
                backgroundColor: Colors.grey[300],
                child: _profileImageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(75),
                  child: Image.file(
                    _profileImageFile!,
                    width: 150, // Increased size
                    height: 150, // Increased size
                    fit: BoxFit.cover,
                  ),
                )
                    : _profileImageUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(75),
                  child: CachedNetworkImage(
                    imageUrl:
                    ApiService.getImageUrl(_profileImageUrl!),
                    placeholder: (context, url) =>
                        CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.person, size: 50),
                    width: 150,
                    // Increased size
                    height: 150,
                    // Increased size
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(Icons.person, size: 50, color: Colors.grey[600]),
              ),
              if (_isEditing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // const SizedBox(height: 16),
        // Name and email below the profile picture
        Center(
          child: Text(
            _nameController.text.isNotEmpty
                ? _nameController.text
                : "Your Name",
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            _emailController.text.isNotEmpty
                ? _emailController.text
                : "your.email@example.com",
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      // Show both Save and Discard buttons when editing
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _discardChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
              ),
              child: const Text(
                'Discard Changes',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: ElevatedButton(
              onPressed: _submitDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ),
        ],
      );
    } else {
      // Show only Edit button when not editing
      return ElevatedButton(
        onPressed: _toggleEdit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataLoaded && _isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          backgroundColor: Color(0xFF030B23),
          elevation: 5,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Color(0xFF030B23),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 10.0),
                // Horizontal divider line with black color
                Container(
                  height: 1.0,
                  width: double.infinity,
                  color: Colors.black45,
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                // const SizedBox(height: 20.0),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Name', Icons.person),
                  validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 26.0),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('Email', Icons.email),
                  readOnly: true, // Email should not be editable here
                ),
                const SizedBox(height: 26.0),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration('Phone Number', Icons.phone),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your phone number';
                    }
                    // Basic validation for 10-digit US numbers
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                  enabled: _isEditing,
                ),
                const SizedBox(height: 26.0),
                TextFormField(
                  controller: _locationController,
                  decoration: _inputDecoration('Location', Icons.location_on,
                      required: false),
                  // No validator since location is optional
                  enabled: _isEditing,
                ),

                // Add action buttons at the bottom
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20.0),
                  child: _buildActionButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();

    super.dispose();
  }
}