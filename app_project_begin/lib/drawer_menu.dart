import 'package:app_project_begin/drawer_item.dart';
import 'package:app_project_begin/main.dart';
import 'package:app_project_begin/page_account.dart';
import 'package:app_project_begin/page_chat.dart';
import 'package:app_project_begin/page_favourite.dart';
import 'package:app_project_begin/page_people.dart';
import 'package:app_project_begin/page_setting.dart';
import 'package:flutter/material.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 80, 24, 0),
          child: Column(
            children: [
              headerWidget(),
              const SizedBox(
                height: 30,
              ),
              const Divider(
                thickness: 1,
                height: 10,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 30,
              ),
              DrawerItem(
                  name: "People",
                  icon: Icons.people,
                  onPressed: () => onItemPressed(context, index: 0)),
              const SizedBox(
                height: 30,
              ),
              DrawerItem(
                  name: "My Account",
                  icon: Icons.account_box_rounded,
                  onPressed: () => onItemPressed(context, index: 1)),
              const SizedBox(
                height: 30,
              ),
              DrawerItem(
                  name: "Charts",
                  icon: Icons.chat_rounded,
                  onPressed: () => onItemPressed(context, index: 2)),
              const SizedBox(
                height: 30,
              ),
              DrawerItem(
                  name: "Favourites",
                  icon: Icons.favorite,
                  onPressed: () => onItemPressed(context, index: 3)),
              const SizedBox(
                height: 30,
              ),
              const Divider(
                thickness: 1,
                height: 10,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 30,
              ),
              DrawerItem(
                name: "Setting",
                icon: Icons.settings,
                onPressed: () => onItemPressed(context, index: 4),
              ),
              const SizedBox(
                height: 30,
              ),
              DrawerItem(
                  name: "Log out",
                  icon: Icons.logout_rounded,
                  onPressed: () => onItemPressed(context, index: 5)),
            ],
          ),
        ),
      ),
    );
  }

  void onItemPressed(BuildContext context, {required int index}) {
    Navigator.pop(context);
    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const People()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Account()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Favourrite()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Chat()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Setting()));
        break;
      case 5:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyApp()));
    }
  }

  Widget headerWidget() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/logo.png'),
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Chan Pisey",
                style: TextStyle(fontSize: 14, color: Colors.white)),
            SizedBox(
              height: 10,
            ),
            Text("pisey12@gmail.com",
                style: TextStyle(fontSize: 14, color: Colors.white)),
          ],
        ),
      ],
    );
  }
}
