import 'package:animated_login/animated_login.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_demo/src/routes.dart';

import 'dialog_builders.dart';
import 'login_functions.dart';


/// Example login screen
class LoginScreen extends StatefulWidget {
  /// Simulates the multilanguage, you will implement your own logic.
  /// According to the current language, you can display a text message
  /// with the help of [LoginTexts] class.
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Example selected language, default is English.
  LanguageOption language = _languageOptions[1];

  /// Current auth mode, default is [AuthMode.login].
  AuthMode currentMode = AuthMode.login;

  CancelableOperation? _operation;

  @override
  Widget build(BuildContext context) {
    return AnimatedLogin(
      onLogin: (LoginData data) async =>
          _authOperation(LoginFunctions(context).onLogin(data)),
      onSignup: (SignUpData data) async =>
          _authOperation(LoginFunctions(context).onSignup(data)),
      onForgotPassword: _onForgotPassword,
      logo: Image.asset("assets/images/logo.gif"),
      // backgroundImage: 'images/background_image.jpg',
      signUpMode: SignUpModes.both,
      // socialLogins: _socialLogins(context),
      loginDesktopTheme: _desktopTheme,
      loginMobileTheme: _mobileTheme,
      loginTexts: _loginTexts,
      emailValidator: ValidatorModel(
          validatorCallback: (String? email) => 'What an email! $email'),
      changeLanguageCallback: (LanguageOption? _language) {
        if (_language != null) {
          DialogBuilder(context).showResultDialog(
              'Successfully changed the language to: ${_language.value}.');
          if (mounted) setState(() => language = _language);
        }
      },
      changeLangDefaultOnPressed: () async => _operation?.cancel(),
      languageOptions: _languageOptions,
      selectedLanguage: language,
      initialMode: currentMode,
      onAuthModeChange: (AuthMode newMode) async {
        currentMode = newMode;
        await _operation?.cancel();
      },
    );
  }

  Future<String?> _authOperation(Future<String?> func) async {
    await _operation?.cancel();
    _operation = CancelableOperation.fromFuture(func);
    final String? res = await _operation?.valueOrCancellation();
    if (_operation?.isCompleted == true) {
      DialogBuilder(context).showResultDialog(res ?? 'Successful.');

      Future.delayed(Duration(seconds: 2), () {
        Routes().directToHomePage();
      });
    }
    return res;
  }

  Future<String?> _onForgotPassword(String email) async {
    await _operation?.cancel();
    return await LoginFunctions(context).onForgotPassword(email);
  }

  static List<LanguageOption> get _languageOptions => const <LanguageOption>[
        LanguageOption(
          value: 'Turkish',
          code: 'TR',
          iconPath: 'assets/images/tr.png',
        ),
        LanguageOption(
          value: 'English',
          code: 'EN',
          iconPath: 'assets/images/en.png',
        ),
      ];

  /// You can adjust the colors, text styles, button styles, borders
  /// according to your design preferences for *DESKTOP* view.
  /// You can also set some additional display options such as [showLabelTexts].
  LoginViewTheme get _desktopTheme => _mobileTheme.copyWith(
        // To set the color of button text, use foreground color.
        dialogTheme: const AnimatedDialogTheme(
          languageDialogTheme: LanguageDialogTheme(
              optionMargin: EdgeInsets.symmetric(horizontal: 80)),
        ),
        actionButtonStyle: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
        loadingSocialButtonColor: Colors.blue,
        loadingButtonColor: Colors.white,
        privacyPolicyStyle: const TextStyle(color: Colors.black87),
        privacyPolicyLinkStyle: const TextStyle(
            color: Colors.blue, decoration: TextDecoration.underline),
      );

  /// You can adjust the colors, text styles, button styles, borders
  /// according to your design preferences for *MOBILE* view.
  /// You can also set some additional display options such as [showLabelTexts].
  LoginViewTheme get _mobileTheme => LoginViewTheme(
        // showLabelTexts: false,
        backgroundColor: Colors.blue, // const Color(0xFF6666FF),
        formFieldBackgroundColor: Colors.white,
        formWidthRatio: 60,
        actionButtonStyle: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.blue),
        ),
        animatedComponentOrder: const <AnimatedComponent>[
          AnimatedComponent(
            component: LoginComponents.logo,
            animationType: AnimationType.right,
          ),
          AnimatedComponent(component: LoginComponents.title),
          // AnimatedComponent(component: LoginComponents.description),
          // AnimatedComponent(component: LoginComponents.formTitle),
          // AnimatedComponent(component: LoginComponents.socialLogins),
          AnimatedComponent(component: LoginComponents.useEmail),
          AnimatedComponent(component: LoginComponents.form),
          // AnimatedComponent(component: LoginComponents.notHaveAnAccount),
          // AnimatedComponent(component: LoginComponents.forgotPassword),
          // AnimatedComponent(component: LoginComponents.policyCheckbox),
          AnimatedComponent(component: LoginComponents.changeActionButton),
          AnimatedComponent(component: LoginComponents.actionButton),
        ],
        // privacyPolicyStyle: const TextStyle(color: Colors.white70),
        // privacyPolicyLinkStyle: const TextStyle(
        //     color: Colors.white, decoration: TextDecoration.underline),
      );

  LoginTexts get _loginTexts => LoginTexts(
        nameHint: _username,
        login: _login,
        signUp: _signup,
        welcomeBack: _welcome,
        welcomeBackDescription: _desc,
        // signupEmailHint: 'Signup Email',
        // loginEmailHint: 'Login Email',
        // signupPasswordHint: 'Signup Password',
        // loginPasswordHint: 'Login Password',
      );

  /// You can adjust the texts in the screen according to the current language
  /// With the help of [LoginTexts], you can create a multilanguage scren.
  String get _username => language.code == 'TR' ? 'Kullanıcı Adı' : 'Username';

  String get _login => language.code == 'TR' ? 'Giriş Yap' : 'Login';

  String get _signup => language.code == 'TR' ? 'Kayıt Ol' : 'Sign Up';

  String get _welcome => language.code == 'TR' ? 'Kullanıcı Adı' : 'Welcome';

  String get _desc => language.code == 'TR' ? 'Kullanıcı Adı' : 'Desc';


}

/// Example forgot password screen
class ForgotPasswordScreen extends StatelessWidget {
  /// Example forgot password screen that user is navigated to
  /// after clicked on "Forgot Password?" text.
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('FORGOT PASSWORD'),
      ),
    );
  }
}
