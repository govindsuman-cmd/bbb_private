import 'package:flutter/material.dart';

class ForgetPasswordDropUp extends StatefulWidget {
  final Function(String email, String mobile) onSubmit;

  const ForgetPasswordDropUp({super.key, required this.onSubmit});
//
  @override
  State<ForgetPasswordDropUp> createState() => _ForgetPasswordDropUpState();
}

class _ForgetPasswordDropUpState extends State<ForgetPasswordDropUp> {
  int currentStep = 1;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final List<TextEditingController> otpControllers =
  List.generate(4, (index) => TextEditingController());
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;

  void goToNextStep() {
    setState(() {
      currentStep += 1;
    });
  }

  void goToPreviousStep() {
    setState(() {
      currentStep -= 1;
    });
  }

  String getOTP() {
    return otpControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  currentStep == 1
                      ? "Forgot Password"
                      : currentStep == 2
                      ? "Enter OTP"
                      : "Reset Password",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                if (currentStep == 1) ...[
                  const Text(
                    "Enter your Email for the verification process. We will send a 4-digit code to your Email/Mobile No.",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "or",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile No.',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                ] else if (currentStep == 2) ...[
                  const Text(
                    "Enter the 4-digit OTP sent to your Email/Mobile.",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      return SizedBox(
                        width: 50,
                        child: TextField(
                          controller: otpControllers[index],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 3) {
                              FocusScope.of(context).nextFocus();
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ] else if (currentStep == 3) ...[

                  const SizedBox(height: 20),
                  TextField(
                    controller: newPasswordController,
                    obscureText: !newPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          newPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            newPasswordVisible = !newPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !confirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          confirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            confirmPasswordVisible = !confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (currentStep == 1) {
                      widget.onSubmit(emailController.text, mobileController.text);
                      goToNextStep();
                    } else if (currentStep == 2) {
                      String otp = getOTP();
                      print("OTP Submitted: $otp");
                      goToNextStep();
                    } else if (currentStep == 3) {
                      String newPassword = newPasswordController.text;
                      String confirmPassword = confirmPasswordController.text;

                      if (newPassword == confirmPassword) {
                        print("Password successfully reset.");
                      } else {
                        print("Passwords do not match.");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 19),
                    backgroundColor: const Color(0xFF009A90),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    currentStep == 3 ? 'Update Password' : 'Submit',
                  ),
                ),
                const SizedBox(height: 15),
                if (currentStep > 1)
                  TextButton(
                    onPressed: goToPreviousStep,
                    child: const Text("Cancel"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}