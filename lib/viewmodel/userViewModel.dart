import 'package:esprit_alumni_frontend/view/screens/login.dart';
import 'package:esprit_alumni_frontend/view/screens/signup2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../view/screens/home.dart';
import '../../view/components/themes/colors.dart';
import '../view/screens/rsetpassword2.dart';

class UserViewModel extends ChangeNotifier {
  static String baseUrl = "10.0.2.2:8081";

  UserViewModel();

  static Future<void> login(
      String? email, String? password, BuildContext context) async {
    Map<String, dynamic> userData = {"email": email, "password": password};

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8"
    };

    http
        .post(Uri.http(baseUrl, "/login"),
            body: json.encode(userData), headers: headers)
        .then((http.Response response) async {
      if (response.statusCode == 200) {
        // Map<String, dynamic> userData = json.decode(response.body);

        // Shared preferences
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString("userId", userData["_id"]);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (response.statusCode == 400) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                  title: Text("Sign in failed",
                      style: TextStyle(color: AppColors.primary)),
                  content: Text("Wrong password"));
            });
      } else if (response.statusCode == 402) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                  title: Text("Sign in failed",
                      style: TextStyle(color: AppColors.primary)),
                  content: Text(
                      "Your Email has not been verified. Please check your mail"));
            });
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                  title: Text("Sign in failed",
                      style: TextStyle(color: AppColors.primary)),
                  content: Text(
                      "The email address is not associated with any account. please check and try again!"));
            });
      }
    });
  }

  static Future<void> signup(
      String? email,
      String? password,
      String? username,
      String? gender,
      String? option,
      String? dateofbirth,
      String? level,
      String? speciality,
      BuildContext context) async {
    Map<String, dynamic> userData = {
      "email": email,
      "password": password,
      "username": username,
      "gender": gender,
      "option": option,
      "dateofbirth": dateofbirth,
      "level": level,
      "speciality": speciality
    };

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8"
    };

    http
        .post(Uri.http(baseUrl, "/signup"),
            body: json.encode(userData), headers: headers)
        .then((http.Response response) async {
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                  title: Text("Sign up successful",
                      style: TextStyle(color: AppColors.primary)),
                  content:
                      Text("Please check your mail to verify your account"));
            });
      } else if (response.statusCode == 400) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                  title: Text("Sign up failed",
                      style: TextStyle(color: AppColors.primary)),
                  content:
                      Text("Account already exists please use another email"));
            });
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                  title: Text("Network error",
                      style: TextStyle(color: AppColors.primary)),
                  content: Text(
                      "please check your internet connection and try again!"));
            });
      }
    });
  }

  static Future<void> forgotPassword(
      String? email, BuildContext context) async {
    Map<String, dynamic> userData = {"email": email};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", email.toString());

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8"
    };

    http
        .post(Uri.http(baseUrl, "/reset"),
            body: json.encode(userData), headers: headers)
        .then((http.Response response) async {
      if (response.statusCode == 200) {
        // take the ateibutes sents in response body
        final jsonResponse = jsonDecode(response.body);
        String token = jsonResponse["token"];

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new reset2Page(token)),
        );
      } else if (response.statusCode == 400) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: const Text("NOT FOUND",
                      style: TextStyle(color: AppColors.primary)),
                  content: Container(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "media/notfound.png",
                        height: 300,
                        width: 300,
                      ),
                      const Text(
                          "The email address is not associated with any account. please check and try again!"),
                    ],
                  )));
            });
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: const Text("Network error",
                      style: TextStyle(color: AppColors.primary)),
                  content: Container(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'media/No connection-bro.png',
                        height: 300,
                        width: 300,
                      ),
                      const Text(
                          "please check your internet connection and try again!"),
                    ],
                  )));
            });
      }
    });
  }

  static Future<void> resetpassword(
      String? email, String? password, BuildContext context) async {
    Map<String, dynamic> userData = {
      "email": email,
      "newpassword": password,
    };

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8"
    };

    http
        .post(Uri.http(baseUrl, "/resetpassword"),
            body: json.encode(userData), headers: headers)
        .then((http.Response response) async {
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: const Text("Password reset successful",
                      style: TextStyle(color: AppColors.primary)),
                  content: Container(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'media/Ok-bro.png',
                        height: 300,
                        width: 300,
                      ),
                      const Text(
                          "Your password has been successfully reset . you can now login with your new password"),
                    ],
                  )));
            });
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                  title: Text("Network error",
                      style: TextStyle(color: AppColors.primary)),
                  content: Text(
                      "please check your internet connection and try again!"));
            });
      }
    });
  }

  static Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the Google sign-in
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      Map<String, String> headers = {
        "Content-Type": "application/json; charset=UTF-8"
      };

      // Check if the user is already registered in the app
      final response = await http
          .get(Uri.http(baseUrl, '/checkuser/${googleUser.email}'),
              headers: headers)
          .then((http.Response response) {
        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (response.statusCode == 201) {
          // show a dialog to ask the user to register
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text("Login failed",
                        style: TextStyle(color: AppColors.primary)),
                    content: Container(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'media/Forgot password-bro.png',
                          height: 300,
                          width: 300,
                        ),
                        const Text(
                            "Please verify your email address before logging in"),
                      ],
                    )));
              });
        } else if (response.statusCode == 400) {
          // show a dialog to ask the user to register
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text("Sign up",
                        style: TextStyle(color: AppColors.primary)),
                    content: Container(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'media/Forgot password-bro.png',
                          height: 300,
                          width: 300,
                        ),
                        const Text(
                            "You are not registered in the app please sign up first"),
                      ],
                    )));
              });
        } else {
          // Handle other error codes as needed
          throw Exception('Failed to check user registration');
        }
      });
    } catch (e) {
      //show a dialog with the error message
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text("Some thing went wrong",
                    style: TextStyle(color: AppColors.primary)),
                content: Container(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'media/No connection-bro.png',
                      height: 300,
                      width: 300,
                    ),
                    const Text("something went wrong pleas try again!"),
                  ],
                )));
          });
    }
  }

  static Future<UserCredential?> signupWithGoogle(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the Google sign-in
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      Map<String, String> headers = {
        "Content-Type": "application/json; charset=UTF-8"
      };

      // Check if the user is already registered in the app
      final response = await http
          .get(Uri.http(baseUrl, '/checkuser/${googleUser.email}'),
              headers: headers)
          .then((http.Response response) {
        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (response.statusCode == 201) {
          // show a dialog to ask the user to register
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text("You're already registered",
                        style: TextStyle(color: AppColors.primary)),
                    content: Container(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'media/Forgot password-bro.png',
                          height: 300,
                          width: 300,
                        ),
                        const Text(
                            "you are already registered in the app please verify your account and login"),
                      ],
                    )));
              });
        } else if (response.statusCode == 400) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Signup2Page(
                      googleUser.email, googleUser.displayName, "")));
        } else {
          // Handle other error codes as needed
          throw Exception('Failed to check user registration');
        }
      });
    } catch (e) {
      print(e);
      //show a dialog with the error message
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text("Some thing went wrong",
                    style: TextStyle(color: AppColors.primary)),
                content: Container(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'media/No connection-bro.png',
                      height: 300,
                      width: 300,
                    ),
                    const Text("something went wrong pleas try again!"),
                  ],
                )));
          });
    }
  }
}
