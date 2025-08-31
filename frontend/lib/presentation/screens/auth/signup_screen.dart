import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _showVerificationNotice = false;
  
  // Password strength
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;
  double _strengthWidth = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthColor = Colors.grey;
        _strengthWidth = 0.0;
      });
      return;
    }

    int strength = 0;
    List<String> feedback = [];

    if (password.length >= 8) strength++;
    else feedback.add('8+ chars');

    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    else feedback.add('uppercase');

    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    else feedback.add('lowercase');

    if (RegExp(r'\d').hasMatch(password)) strength++;
    else feedback.add('number');

    if (password.contains('!') || password.contains('@') || password.contains('#') || 
        password.contains('\$') || password.contains('%') || password.contains('^') || 
        password.contains('&') || password.contains('*') || password.contains('(') || 
        password.contains(')') || password.contains('_') || password.contains('+') || 
        password.contains('-') || password.contains('=') || password.contains('[') || 
        password.contains(']') || password.contains('{') || password.contains('}') || 
        password.contains(';') || password.contains(':') || password.contains('"') || 
        password.contains('\\') || password.contains('|') || password.contains(',') || 
        password.contains('.') || password.contains('<') || password.contains('>') || 
        password.contains('/') || password.contains('?')) strength++;

    setState(() {
      if (strength <= 1) {
        _passwordStrength = 'Weak password';
        _strengthColor = const Color(0xFFdc3545);
        _strengthWidth = 0.25;
      } else if (strength <= 2) {
        _passwordStrength = 'Fair password';
        _strengthColor = const Color(0xFFffc107);
        _strengthWidth = 0.5;
      } else if (strength <= 3) {
        _passwordStrength = 'Good password';
        _strengthColor = const Color(0xFF17a2b8);
        _strengthWidth = 0.75;
      } else {
        _passwordStrength = 'Strong password';
        _strengthColor = const Color(0xFF28a745);
        _strengthWidth = 1.0;
      }

      if (feedback.isNotEmpty && strength < 4) {
        _passwordStrength += ' (needs: ${feedback.take(2).join(', ')})';
      }
    });
  }

  void _checkPasswordMatch() {
    if (_confirmPasswordController.text.isNotEmpty) {
      setState(() {});
    }
  }

  bool _isFormValid() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    final emailValid = email.isNotEmpty && RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    final passwordValid = password.isNotEmpty && password.length >= 8 && 
                         RegExp(r'[A-Z]').hasMatch(password) && 
                         RegExp(r'[a-z]').hasMatch(password) && 
                         RegExp(r'\d').hasMatch(password);
    final passwordsMatch = password == confirmPassword && confirmPassword.isNotEmpty;

    return emailValid && passwordValid && passwordsMatch;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        final success = await authProvider.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );

        if (success && mounted) {
          setState(() {
            _showVerificationNotice = true;
          });
          
          // 성공 메시지 표시
          _showSuccessDialog();
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('계정이 성공적으로 생성되었습니다!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎉 회원가입 완료!'),
            const SizedBox(height: 16),
            Text('📧 인증 이메일이 전송되었습니다:\n${_emailController.text.trim()}'),
            const SizedBox(height: 16),
            const Text('📋 다음 단계:'),
            const SizedBox(height: 8),
            const Text('1. 이메일 확인 (스팸 폴더도 확인)'),
            const Text('2. 인증 링크 클릭'),
            const Text('3. 프로필 설정 완료'),
            const Text('4. K-Medical 탐색 시작'),
            const SizedBox(height: 8),
            const Text('⏰ 인증 링크는 24시간 후 만료됩니다'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _socialSignup(String provider) {
    String providerName = provider == 'google' ? 'Google' : 'X (Twitter)';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$providerName 회원가입'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$providerName 인증으로 회원가입합니다...'),
            const SizedBox(height: 16),
            const Text('✅ 장점:'),
            const Text('• 빠르고 안전한 접근'),
            const Text('• 비밀번호 불필요'),
            const Text('• 프로필과 동기화'),
            const Text('• 향상된 보안 기능'),
            const Text('• 즉시 계정 설정'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$providerName 인증을 시작합니다...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('계속'),
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📋 이용약관'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('K-Medical 플랫폼 약관:'),
              SizedBox(height: 16),
              Text('🏥 의료 서비스:'),
              Text('• 정보 제공 플랫폼'),
              Text('• 의료 상담 제공 안함'),
              Text('• 병원 파트너십 검증'),
              Text('• 사용자 책임 명시'),
              SizedBox(height: 8),
              Text('💳 결제 및 청구:'),
              Text('• 투명한 가격 정책'),
              Text('• 안전한 결제 처리'),
              Text('• 환불 조건 명시'),
              SizedBox(height: 8),
              Text('🌍 국제 사용자:'),
              Text('• 다국어 지원'),
              Text('• 글로벌 접근성'),
              Text('• 국경 간 규정 준수'),
              SizedBox(height: 8),
              Text('⚖️ 한국 법률에 의해 관리됨'),
              Text('📄 최종 업데이트: 2025년 1월'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔒 개인정보 처리방침'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('개인정보 보호가 중요합니다:'),
              SizedBox(height: 16),
              Text('🛡️ 데이터 보호:'),
              Text('• GDPR & CCPA 준수'),
              Text('• 의료 데이터 암호화 (256-bit)'),
              Text('• 무단 데이터 공유 금지'),
              Text('• 한국의 안전한 클라우드 저장'),
              SizedBox(height: 8),
              Text('👥 수집하는 정보:'),
              Text('• 계정 등록 세부사항'),
              Text('• 의료 문의 기록'),
              Text('• 플랫폼 사용 분석'),
              Text('• 커뮤니케이션 선호도'),
              SizedBox(height: 8),
              Text('🔐 귀하의 권리:'),
              Text('• 언제든지 데이터 접근'),
              Text('• 데이터 삭제 요청'),
              Text('• 정보 쉽게 업데이트'),
              Text('• 마케팅 선호도 제어'),
              SizedBox(height: 8),
              Text('🏥 의료 기록은 국제 의료 개인정보 보호 기준에 따라 처리됩니다'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          // Logo
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ).createShader(bounds),
                            child: const Text(
                              'K-Medical',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Premium Korean Healthcare Platform',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // Tabs
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFf8f9fa),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _navigateToLogin,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      child: const Text(
                                        'Sign In',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF666666),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF667eea).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      child: Text(
                                        'Sign Up',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Verification Notice
                            if (_showVerificationNotice)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFe3f2fd),
                                  border: Border.all(color: const Color(0xFF90caf9)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.email, color: Color(0xFF1565c0)),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '📧 이메일 인증 전송됨!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Color(0xFF1565c0),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      '인증 이메일을 받은 편지함으로 보냈습니다. 이메일을 확인하고 인증 링크를 클릭하여 가입을 완료하세요.',
                                      style: TextStyle(
                                        color: Color(0xFF1565c0),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Email
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email address',
                                    filled: true,
                                    fillColor: const Color(0xFFfafbfc),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFe9ecef), width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFe9ecef), width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '이메일을 입력해주세요';
                                    }
                                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                                      return '올바른 이메일 형식을 입력해주세요';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Create Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  onChanged: _checkPasswordStrength,
                                  decoration: InputDecoration(
                                    hintText: 'Create a strong password',
                                    filled: true,
                                    fillColor: const Color(0xFFfafbfc),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFe9ecef), width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFe9ecef), width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                        color: const Color(0xFF666666),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '비밀번호를 입력해주세요';
                                    }
                                    if (value.length < 8) {
                                      return '비밀번호는 8자 이상이어야 합니다';
                                    }
                                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                      return '대문자를 포함해야 합니다';
                                    }
                                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                                      return '소문자를 포함해야 합니다';
                                    }
                                    if (!RegExp(r'\d').hasMatch(value)) {
                                      return '숫자를 포함해야 합니다';
                                    }
                                    return null;
                                  },
                                ),
                                
                                // Password Strength
                                if (_passwordStrength.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFe9ecef),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: _strengthWidth,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _strengthColor,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _passwordStrength,
                                        style: TextStyle(
                                          color: _strengthColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Confirm Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  onChanged: (value) => _checkPasswordMatch(),
                                  decoration: InputDecoration(
                                    hintText: 'Confirm your password',
                                    filled: true,
                                    fillColor: const Color(0xFFfafbfc),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFe9ecef), width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFe9ecef), width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                        color: const Color(0xFF666666),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '비밀번호를 다시 입력해주세요';
                                    }
                                    if (value != _passwordController.text) {
                                      return '비밀번호가 일치하지 않습니다';
                                    }
                                    return null;
                                  },
                                ),
                                
                                // Password Match Indicator
                                if (_confirmPasswordController.text.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        _confirmPasswordController.text == _passwordController.text
                                            ? Icons.check_circle
                                            : Icons.error,
                                        color: _confirmPasswordController.text == _passwordController.text
                                            ? Colors.green
                                            : Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _confirmPasswordController.text == _passwordController.text
                                            ? '비밀번호가 일치합니다 ✓'
                                            : '비밀번호가 일치하지 않습니다',
                                        style: TextStyle(
                                          color: _confirmPasswordController.text == _passwordController.text
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            
                            const SizedBox(height: 25),
                            
                            // Create Account Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isFormValid() && !_isLoading ? _signUp : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ).copyWith(
                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _isFormValid() && !_isLoading
                                          ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
                                          : [Colors.grey, Colors.grey.shade600],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isLoading)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      else
                                        const Icon(Icons.person_add, color: Colors.white),
                                      const SizedBox(width: 10),
                                      Text(
                                        _isLoading ? 'Creating Account...' : 'Create Account',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 25),
                            
                            // Divider
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: const Color(0xFFe9ecef))),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    'or sign up with',
                                    style: TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(child: Container(height: 1, color: const Color(0xFFe9ecef))),
                              ],
                            ),
                            
                            const SizedBox(height: 25),
                            
                            // Social Signup
                            Column(
                              children: [
                                // Google
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFdb4437), width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _socialSignup('google'),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'G',
                                              style: TextStyle(
                                                color: Color(0xFFdb4437),
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Sign up with Google',
                                              style: TextStyle(
                                                color: Color(0xFF333333),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 15),
                                
                                // Twitter
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _socialSignup('twitter'),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              '𝕏',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Sign up with X (Twitter)',
                                              style: TextStyle(
                                                color: Color(0xFF333333),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 25),
                            
                            // Terms
                            Text.rich(
                              TextSpan(
                                text: '계정을 만들면 ',
                                style: const TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: '이용약관',
                                    style: const TextStyle(
                                      color: Color(0xFF667eea),
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()..onTap = _showTerms,
                                  ),
                                  const TextSpan(text: ' 및 '),
                                  TextSpan(
                                    text: '개인정보 처리방침',
                                    style: const TextStyle(
                                      color: Color(0xFF667eea),
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()..onTap = _showPrivacy,
                                  ),
                                  const TextSpan(text: '에 동의하게 됩니다'),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 