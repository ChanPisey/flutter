import 'package:app_siderbar/favourite.dart';
import 'package:app_siderbar/friends.dart';
import 'package:app_siderbar/policies.dart';
import 'package:app_siderbar/request.dart';
import 'package:app_siderbar/setting.dart';
import 'package:app_siderbar/share.dart';
import 'package:flutter/material.dart';
import 'login.dart';

// ignore: camel_case_types
class navbar extends StatelessWidget {
  const navbar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('pisey.com'),
            accountEmail: const Text('chanpisey3232@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAHXPluq6GtTRPDIHRv5kJPy86uFjp5sO7hg&usqp=CAU',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: const BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                    image: NetworkImage(
                      'https://img.freepik.com/free-vector/blue-copy-space-digital-background_23-2148821698.jpg?size=626&ext=jpg',
                    ),
                    fit: BoxFit.cover)),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: const Text('Favourite'),
            // ignore: avoid_returning_null_for_void
            onTap: () => null,
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Friends'),
            // ignore: avoid_returning_null_for_void
            onTap: () => onItemPressed(context, index: 1),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            // ignore: avoid_returning_null_for_void
            onTap: () => null,
          ),
          ListTile(
            leading: const Icon(Icons.notifications_on),
            title: const Text('Request'),
            // ignore: avoid_returning_null_for_void
            onTap: () => null,
            trailing: ClipOval(
              child: Container(
                color: Colors.red,
                width: 20,
                height: 20,
                child: const Center(
                  child: Text(
                    '5',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Setting'),
            // ignore: avoid_returning_null_for_void
            onTap: () => onItemPressed(context, index: 0),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Policies'),
            // ignore: avoid_returning_null_for_void
            onTap: () => null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Exit'),
            // ignore: avoid_returning_null_for_void
            onTap: () => onItemPressed(context, index: 3),
          ),
        ],
      ),
    );
  }

  void onItemPressed(BuildContext context, {required int index}) {
    Navigator.pop(context);
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const favourite()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const friends()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const share()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const request()));
        break;
      case 5:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const setting()));
        break;
      case 6:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const policies()));
        break;
      case 7:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const login()));
    }
  }
}
