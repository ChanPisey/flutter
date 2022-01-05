// import 'package:flutter/material.dart';

// import 'My_Home.dart';

// class Student{
//   late String name;
//   String get st_name {
//     return name;
//   }
//   void set st_name(String name){
//     this.name =name;
//
//   }
//   void result(){
//     print(name);
//   }
// }
// void main() {
//   runApp(const MyApp());
//   // var list = [1, 2, 3, 4, 5];
//   // var mapping = {'id': 1, 'name': 'Pisey'};
//   // dynamic name = 'Pisey';
//   // print(list);
//   // print(mapping);
//   // print(name);
//   // var i =1;
//   // for (i; i <= 10; i++) {
//   //   if (i % 5 == 0) {
//   //     print(i);
//   //   }
//   // }
//   // add(10,5);
//   // Student st = new Student();
//   // st.name= "Hello testings";
//   // st.result();
// }

// // void add(int a,int b){
// //   int c;
// //   c = a +b;
// //   print(c);
// // }
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter app',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//       ),
//       home: MyHome(),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//   final String title;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Product List")),
//       body: ListView(
//         shrinkWrap: true,
//         padding: const EdgeInsets.fromLTRB((2.0), 10.0, 2.0, 10.0),
//         children: <Widget>[
//           ProductBox(
//               name: "iPhone",
//               description: "IPhone is my favourite",
//               price: 1000,
//               image: "download.png"),
//           ProductBox(
//               name: "iPhone",
//               description: "IPhone is my favourite",
//               price: 1000,
//               image: "download.png"),
//           ProductBox(
//               name: "iPhone",
//               description: "IPhone is my favourite",
//               price: 1000,
//               image: "download.png"),
//           ProductBox(
//               name: "iPhone",
//               description: "IPhone is my favourite",
//               price: 1000,
//               image: "download.png"),
//           ProductBox(
//               name: "iPhone",
//               description: "IPhone is my favourite",
//               price: 1000,
//               image: "download.png"),
//           ProductBox(
//               name: "iPhone",
//               description: "IPhone is my favourite",
//               price: 1000,
//               image: "download.png"),
//           ProductBox(
//               name: "iPhone",
//               description: "IPhone is my favourite",
//               price: 1000,
//               image: "download.png"),
//           ProductBox(
//               name: "iPhone",
//               description: "IPhone is my favourite",
//               price: 1000,
//               image: "download.png"),
//         ],
//       ),
//     );
//   }
// }
//
// class ProductBox extends StatelessWidget {
//   const ProductBox(
//       {Key? key,
//       required this.name,
//       required this.description,
//       required this.price,
//       required this.image})
//       : super(key: key);
//   final String name;
//   final String description;
//   final int price;
//   final String image;
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(2),
//       height: 120,
//       child: Card(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[
//             Image.asset("assets/image/" + image),
//             Expanded(
//                 child: Container(
//               padding: EdgeInsets.all(5),
//               color: Colors.green,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   Text(
//                     this.name,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text(this.description),
//                   Text("Price:" + this.price.toString())
//                 ],
//               ),
//             ))
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'model.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
// to set the root of app.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'API Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Message"),
          backgroundColor: Colors.cyan,
          content: new Text("Hello Testing"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Flutter-API"),
      ),
      // body: _buildBody(context),
      body: Center(
          child: GestureDetector(
              onTap: () {
                _showDialog(context);
              },
              child: Text(
                'TESTING',
              ))),
    );

    //   floatingActionButton: FloatingActionButton.extended(
    //     onPressed: () {},

    //     label: Icon(Icons.cancel),
    //     backgroundColor: Colors.green,
    //   ),
    // );
  }

  FutureBuilder<List<User>> _buildBody(BuildContext context) {
    final HttpService httpService = HttpService();

    return FutureBuilder<List<User>>(
      future: httpService.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final List<User> posts = snapshot.requireData;
          return _buildPosts(context, posts);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  ListView _buildPosts(BuildContext context, List<User> posts) {
    return ListView.builder(
      itemCount: posts.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return Card(
          elevation: 5,
          child: ListTile(
            title: Text(
              posts[index].title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // subtitle: Text(posts[index].completed.toString()),
          ),
        );
      },
    );
  }
}

class HttpService {
  Future<List<User>> getPosts() async {
    final String postsURL = "https://jsonplaceholder.typicode.com/posts";
    Response res = await get(Uri.parse(postsURL));

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);

      List<User> posts = body
          .map(
            (dynamic item) => User.fromJson(item),
          )
          .toList();
      await Future.delayed(Duration(seconds: 2));
      return posts;
    } else {
      throw "Unable to retrieve posts.";
    }
  }
}
