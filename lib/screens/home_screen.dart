import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_med/blocs/home_bloc/home_bloc.dart';
import 'package:quick_med/custom_components/floating_navbar.dart';
import 'package:quick_med/screens/cart_screen.dart';
import 'package:quick_med/screens/landing_screen.dart';
import 'package:quick_med/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late HomeBloc _homeBloc;

  @override
  void initState() {
    _homeBloc = HomeBloc();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      _homeBloc.add(TabIndexChangeEvent(index: tabController.index));
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _homeBloc,
      child: BlocConsumer<HomeBloc, HomeState>(
        bloc: _homeBloc,
        listener: (context, state) {
          if (tabController.index != state.tabIndex) {
            tabController.animateTo(state.tabIndex);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: TabBarView(
              controller: tabController,
              // physics: const NeverScrollableScrollPhysics(),
              children: const [
                LandingScreen(),
                ProfileScreen(),
                CartScreen(),
              ],
            ),
            bottomNavigationBar: FloatingNavbar(
              currentIndex: state.tabIndex,
              onTap: (value) {
                _homeBloc.add(TabIndexChangeEvent(index: value));
              },
            ),
          );
        },
      ),
    );
  }
}
