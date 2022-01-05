import 'package:app_project_begin/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const MyHomePage(title: 'login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _usercontroller = TextEditingController();
  final TextEditingController _passcontroller = TextEditingController();
  bool __isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 250,
              height: 250,
              child: Image.asset(
                'assets/logo.png',
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 10.0),
              child: TextFormField(
                controller: _usercontroller,
                style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 15,
                ),
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  labelText: "UserName",

                  // hintText: "Input YourName",
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, bottom: 10),
              child: TextFormField(
                controller: _passcontroller,
                obscureText: __isObscure,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  // hintText: "Input Password",

                  labelText: 'Password',
                  suffixIcon: IconButton(
                      icon: Icon(__isObscure
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          __isObscure = !__isObscure;
                        });
                      }),

                  border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),

                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green)),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.2,
              height: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.brown,
              ),
              child: MaterialButton(
                onPressed: () {
                  if (_usercontroller.text == "pisey" ||
                      _passcontroller.text == '1234') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Homepage(),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Expanded(
                          child: AlertDialog(
                            title: const Text('Welcome'),
                            content: const Text('Invalid Password'),
                            actions: [
                              TextButton(
                                // textColor: Colors.black,

                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                // textColor: Colors.black,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('ACCEPT'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
                child: const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
