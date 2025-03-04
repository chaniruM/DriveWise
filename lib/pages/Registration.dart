import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _buildHeader(),
                _buildMainContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 7, 17, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '10:30 AM',
            style: AppTextStyles.timeText,
          ),
          Image.network(
            'https://cdn.builder.io/api/v1/image/assets/TEMP/054038b178187161efc5d9b3e907111ac78d7078018a7bc080425169933fc6fd?placeholderIfAbsent=true&apiKey=deaaa906077b48a6afbb7d861ce495e3',
            width: 100,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 89),
        child: Column(
          children: [
            Image.network(
              'https://cdn.builder.io/api/v1/image/assets/TEMP/6748e5c01972d7cc04cd9b8de8f850db80cfbb8c576689368d29ce118c4528fd?placeholderIfAbsent=true&apiKey=deaaa906077b48a6afbb7d861ce495e3',
              width: 240,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 72),
            Text(
              'Registration',
              style: AppTextStyles.titleText,
            ),
            const SizedBox(height: 28),
            _buildTextField(
              'Username (Mobile number)',
              backgroundColor: AppColors.inputBackground,
            ),
            const SizedBox(height: 32),
            _buildTextField('Email'),
            const SizedBox(height: 20),
            _buildTextField('Password'),
            const SizedBox(height: 32),
            _buildVerificationOptions(),
            const SizedBox(height: 24),
            _buildRegisterButton(),
            const SizedBox(height: 38),
            _buildLoginLink(),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 52),
                child: Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/7ae8d3b7b30478456ab3d1e452a72328d09af38b550050f334bf45d6299f5599?placeholderIfAbsent=true&apiKey=deaaa906077b48a6afbb7d861ce495e3',
                  width: 26,
                  height: 26,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {Color backgroundColor = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        hint,
        style: AppTextStyles.inputText,
      ),
    );
  }

  Widget _buildVerificationOptions() {
    return SizedBox(
      width: 145,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Email', style: AppTextStyles.optionText),
          Text('SMS', style: AppTextStyles.optionText),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Register',
          style: AppTextStyles.buttonText,
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: AppTextStyles.regularText,
        ),
        const SizedBox(width: 5),
        Text(
          'Login here',
          style: AppTextStyles.linkText,
        ),
      ],
    );
  }
}