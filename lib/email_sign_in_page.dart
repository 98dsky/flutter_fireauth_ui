import 'dart:async';

import 'package:fireauth_ui/localizations.dart';
import 'package:flutter/material.dart';
import 'package:fireauth_ui/password_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class FireAuthEmailSignInPage extends StatefulWidget {
  final String _email;

  FireAuthEmailSignInPage(String email) : _email = email;

  @override
  State<StatefulWidget> createState() {
    return new FireAuthEmailSignInPageState(_email);
  }
}

class FireAuthEmailSignInPageState extends State<FireAuthEmailSignInPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  bool _loading = false;

  FireAuthEmailSignInPageState(String email) : _email = email;

  String _validateEmail(String value) {
    if (value.isEmpty)
      return FireAuthUILocalizations.of(context).emptyEmailWarning;
    final RegExp nameExp =
        new RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
    if (!nameExp.hasMatch(value))
      return FireAuthUILocalizations.of(context).invalidEmailWarning;
    return null;
  }

  Future _onSignIn() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _loading = true;
      });
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        int popCount = 4;
        Navigator.popUntil(context, (Route<dynamic> route) {
          popCount--;
          return popCount == 0;
        });
      }catch (e) {
        _showError(e);
      }
      setState(() {
        _loading = false;
      });

    }
  }

  Future<Null> _forgotPassword() async {
    setState(() {
      _loading = true;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    } catch (e) {
      _showError(e);
    }
    setState(() {
      _loading = false;
    });
  }

  void _showError(error) {
    String errorMsg = "";
    if (error is PlatformException) {
      PlatformException platformException = error;
      errorMsg = platformException.details;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
            title: new Text(FireAuthUILocalizations.of(context).error),
            content: new Text(errorMsg),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text(FireAuthUILocalizations.of(context).okay))
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle linkStyle =
        themeData.textTheme.body2.copyWith(color: themeData.accentColor);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(FireAuthUILocalizations.of(context).signIn),
      ),
      body: new Stack(
        children: <Widget>[
          _loading ? new LinearProgressIndicator() : new Container(),
          new Form(
              key: _formKey,
              child: new SingleChildScrollView(
                  child: new Padding(
                padding: const EdgeInsets.all(24.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    new TextFormField(
                      initialValue: _email,
                      decoration: new InputDecoration(
                        hintText: FireAuthUILocalizations.of(context).emailHint,
                        labelText: FireAuthUILocalizations.of(context).email,
                        filled: true,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (String value) {
                        _email = value;
                      },
                      validator: _validateEmail,
                      enabled: !_loading,
                    ),
                    new SizedBox(
                      height: 24.0,
                    ),
                    new FireAuthUIPasswordField(
                      //fieldKey: _passwordFieldKey,
                      helperText: 'No more than 8 characters.',
                      labelText: FireAuthUILocalizations.of(context).password,
                      onSaved: (String value) {
                        _password = value;
                      },
                      enabled: !_loading,
                    ),
                    new Align(
                      alignment: Alignment.centerLeft,
                      child: new FlatButton(
                        onPressed: _loading ? null : _forgotPassword,
                        child: new Text(
                          FireAuthUILocalizations.of(context).forgotPassword,
                          style: linkStyle,
                        ),
                      ),
                    ),
                    new SizedBox(
                      height: 12.0,
                    ),
                    new RaisedButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: _loading ? null : _onSignIn,
                      child: new Text(
                        FireAuthUILocalizations.of(context).signIn,
                        style: Theme
                            .of(context)
                            .textTheme
                            .button
                            .copyWith(color: Colors.white),
                      ),
                    )
                  ],
                ),
              )))
        ],
      ),
    );
  }
}
