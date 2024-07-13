import 'package:firebase_core/firebase_core.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/cart.dart';
import 'package:flutter_e_commerce_app/pages/explore.dart';
import 'package:flutter_e_commerce_app/pages/profile.dart';
import 'package:flutter_e_commerce_app/pages/search.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'firebase_options.dart';
import 'helpers/di.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await initAppModule();

  runApp( MaterialApp(
    home: const HomePage(),
    debugShowCheckedModeBanner: false,
    builder: EasyLoading.init(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _selectedPage = 0;

  List<Widget> pages = [
    ExplorePage(),
    SearchPage(),
    CartPage(),
    ProfilePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController(initialPage: 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (index) => setState(() { _selectedPage = index; }),
        controller: _pageController,
        children: [
          ...pages
        ],
      ),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedPage,
        showElevation: false,
        onItemSelected: (index) => _onItemTapped(index),
        items: [
          FlashyTabBarItem(
            icon: Icon(Icons.home_outlined, size: 23),
            title: Text('হোম'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.search, size: 23),
            title: Text('খুঁজুন'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.shopping_bag_outlined, size: 23),
            title: Text('কার্ট'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.account_circle_outlined, size: 23,),
            title: Text('প্রোফাইল'),
          ),
        ],
      ),
    );
  }
}
