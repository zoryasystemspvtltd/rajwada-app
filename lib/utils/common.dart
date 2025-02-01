import 'package:flutter/material.dart';

import 'app_dimen.dart';
// import 'package:fluttertoast/fluttertoast.dart';


class NavigationData {
  static NavigationData instance = NavigationData();

  NavigationData();


  showSnackBar(text, context) {
    var snackBar = SnackBar(
      backgroundColor: Colors.red[900],
      content: Text(
        text,
        style: const TextStyle(color: Colors.white, letterSpacing: 1),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }



  customInputFieldWithoutIcon(hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.transparent,
      border: InputBorder.none,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey,
        fontSize: hDimen(14),
        fontWeight: FontWeight.normal,
      ),
    );
  }

  customInputFields(hintText, icon){
    return InputDecoration(
      filled: true,
      fillColor:const Color(0XFFFAF3E0),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(35.0)),
        borderSide: BorderSide(color: Colors.white, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(35.0)),
        borderSide: BorderSide(color: Colors.white),
      ),
      //labelText: 'Email',
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.white,
      ),
      prefixIcon: Container(
          width: 65,
          height: 56,
          margin: const EdgeInsets.only(left: 0, right: 15),
          child: Stack(
            children: <Widget>[
              const Image(
                width: 60,
                height: 56,
                fit: BoxFit.fill,
                image: AssetImage(
                  "assets/images/leaf.png",
                ),
              ),
              Align(
                alignment: const Alignment(-0.2,0),
                child: Icon(icon, color: Colors.pinkAccent, size: 28,),
              )
            ],
          )
      ),
    );
  }

  Future<void> showMyDialog(context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Development Instruction!',
            style:
            TextStyle(color: Colors.red[900], fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'This window will be active only for development purpose. \n\nTo Login as Parent use email id: parent@gmail.com and password 000000 \n\nTo Login as Babysitter use email id: babysitter@gmail.com and password 000000',
                  style: TextStyle(
                      color: Colors.grey[700], fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Okay...',
                style: TextStyle(color: Colors.red[900]),
              ),
              onPressed: () => {Navigator.of(context).pop()},
            ),
          ],
        );
      },
    );
  }


}

void mPrint(Object object, {String tag = "", bool printOn = true}) {
  if (!printOn) return;
  debugPrint("[$tag] :: $object");
}

Widget vSpacing(double dimen) {
  return SizedBox(
    height: dimen,
    width: 0,
  );
}

Widget hSpacing(double dimen) {
  return SizedBox(
    height: 0,
    width: dimen,
  );
}

// showToast({required String message}) {
//   Fluttertoast.showToast(
//     msg: message,
//     toastLength: Toast.LENGTH_LONG,
//     textColor: Colors.white,
//     fontSize: hDimen(16),
//     backgroundColor: Colors.black,
//   );
// }
