# OTP Verification Widget

## 📋 Overview

`OtpVerificationWidget` is a reusable, generic OTP (One-Time Password) verification screen that can be used across the app for different purposes like:

- Email verification
- Password reset
- Phone number verification
- Two-factor authentication

## ✨ Features

- ✅ **Visual OTP boxes** - Beautiful, animated input boxes
- ✅ **Auto-focus handling** - Smooth user experience
- ✅ **Timer with resend** - Automatic countdown with resend capability using `ValueNotifier` (no setState issues!)
- ✅ **Customizable** - Flexible parameters for different use cases
- ✅ **Loading states** - Built-in loading indicator support
- ✅ **Error handling** - Integrated error message display
- ✅ **RTL support** - Works with Arabic and English
- ✅ **Responsive** - Uses ScreenUtil for consistent sizing

## 🎯 Usage Examples

### 1. Password Reset OTP

```dart
OtpVerificationWidget(
  title: 'auth_verify_code_title'.tr(),
  description: 'auth_verify_code_desc'.tr(),
  maskedIdentifier: TextHelper.maskEmail(email),
  otpLength: 4,
  isLoading: state.isLoading,
  buttonText: 'auth_verify_button'.tr(),
  onVerify: (otp) {
    cubit.updateOtp(otp);
    cubit.verifyOtp();
  },
  onResend: () async {
    return await cubit.sendOtp();
  },
)
```

### 2. Email Verification

```dart
OtpVerificationWidget(
  title: 'Verify Your Email',
  description: 'We sent a code to your email',
  maskedIdentifier: TextHelper.maskEmail(userEmail),
  otpLength: 4,
  isLoading: isVerifying,
  buttonText: 'Verify Email',
  onVerify: (otp) async {
    await verifyEmail(otp);
  },
  onResend: () async {
    return await resendVerificationCode();
  },
)
```

### 3. Phone Verification

```dart
OtpVerificationWidget(
  title: 'Verify Phone Number',
  description: 'Enter the code sent to your phone',
  maskedIdentifier: TextHelper.maskPhone(phoneNumber),
  otpLength: 6, // Phone OTPs are often 6 digits
  isLoading: isVerifying,
  buttonText: 'Verify',
  onVerify: (otp) {
    verifyPhoneNumber(otp);
  },
  onResend: () async {
    return await resendSMS();
  },
)
```

## 📝 Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `title` | String | ✅ | - | Main title text |
| `description` | String | ✅ | - | Description/instructions |
| `maskedIdentifier` | String? | ❌ | null | Masked email/phone to show user |
| `onVerify` | Function(String) | ✅ | - | Callback when OTP is submitted |
| `onResend` | Future<bool> Function()? | ❌ | null | Callback for resending OTP |
| `isLoading` | bool | ❌ | false | Show loading state |
| `otpLength` | int | ❌ | 4 | Number of OTP digits |
| `buttonText` | String | ❌ | 'Verify' | Button label |
| `backgroundColor` | Color? | ❌ | #121212 | Background color |
| `onBack` | VoidCallback? | ❌ | Navigator.pop | Custom back action |

## 🔧 Helper Functions

### TextHelper.maskEmail()

```dart
TextHelper.maskEmail('john@example.com')
// Output: jo***@example.com
```

### TextHelper.maskPhone()

```dart
TextHelper.maskPhone('+1234567890')
// Output: ******7890
```

## 🎨 Customization

The widget uses:

- `AppColors.brand800` for primary colors
- `AppColors.neutral800` for box background
- `AppColors.neutral700` for inactive borders
- `GoogleFonts.inter()` for typography
- `flutter_screenutil` for responsive sizing

## 🐛 Bug Fixes

### Timer Reset Issue ✅ FIXED

**Problem:** Timer was resetting every time user typed a digit.

**Solution:** Used `ValueNotifier<int>` instead of `setState()` for timer updates. This separates timer state from UI state, preventing unnecessary rebuilds.

```dart
// ❌ Before: Timer resets on every keystroke
int _secondsLeft = 60;
setState(() => _secondsLeft--);

// ✅ After: Timer independent from UI
final ValueNotifier<int> _secondsLeft = ValueNotifier<int>(60);
_secondsLeft.value--;
```

## 📦 Dependencies

- `flutter_bloc` - State management
- `easy_localization` - Translations
- `flutter_screenutil` - Responsive sizing
- `google_fonts` - Typography

## 🔗 Related Files

- `lib/shared/widgets/otp_verification_widget.dart` - Main widget
- `lib/core/helpers/text_helper.dart` - Masking utilities
- `lib/features/forget_password/ui/verify_otp_password_screen.dart` - Usage example

## 📄 License

Part of Fahman App - Internal use only
