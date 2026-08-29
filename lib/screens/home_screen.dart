import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_med/services/auth_service.dart';
import 'package:quick_med/blocs/home_bloc/home_bloc.dart';
import 'package:quick_med/blocs/profile_cubit/profile_cubit.dart';
import 'package:quick_med/custom_components/floating_navbar.dart';
import 'package:quick_med/screens/cart/cart_view.dart';
import 'package:quick_med/blocs/catalogue_cubit/catalogue_cubit.dart';
import 'package:quick_med/screens/landing_screen.dart';
import 'package:quick_med/screens/profile/profile_screen.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _homeBloc),
        BlocProvider(
          create: (context) {
            final cubit = ProfileCubit();
            final userId = AuthService.currentUserId;
            if (userId != null) {
              cubit.loadProfile(userId);
            }
            return cubit;
          },
        ),
        BlocProvider(create: (context) => CatalogueCubit()..load()),
      ],
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
            body: SafeArea(
              child: TabBarView(
                controller: tabController,
                children: const [
                  LandingScreen(),
                  ProfileScreen(),
                  CartView(),
                ],
              ),
            ),
            bottomNavigationBar: FloatingNavbar(
              currentIndex: state.tabIndex,
              onTap: (value) {
                _homeBloc.add(
                  TabIndexChangeEvent(index: value),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
