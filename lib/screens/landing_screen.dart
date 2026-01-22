import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_med/blocs/landing_screen_bloc/landing_screen_bloc.dart';
import 'package:quick_med/custom_components/data_error_widget.dart';
import 'package:quick_med/custom_components/loading_indicator.dart';
import 'package:quick_med/custom_components/themed_card.dart';
import 'package:quick_med/custom_components/suffix_action_text_field.dart';
import 'package:quick_med/services/enum.dart';
import 'package:quick_med/services/strings.dart';
import 'package:quick_med/services/text_styles.dart';
import 'package:quick_med/services/theme_colours.dart';
import 'package:quick_med/utils/screen_size.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late LandingScreenBloc landingScreenBloc;

  @override
  void initState() {
    landingScreenBloc = LandingScreenBloc();
    landingScreenBloc.add(const LoadMedicinesEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => landingScreenBloc,
      child: Scaffold(
        backgroundColor: ThemeColours.appWhite,
        body: SafeArea(
          child: BlocConsumer<LandingScreenBloc, LandingScreenState>(
              listener: (context, state) {},
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sw * 0.03,
                    vertical: context.sh * 0.01,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: context.sw * 0.6,
                            child: Text(
                              Strings.landingScreenTitle,
                              style: TextStyles.title(context).copyWith(
                                color: ThemeColours.darkGreen,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(context.sh * 0.02),
                            child: Icon(
                              Icons.notifications,
                              color: ThemeColours.lightGreen,
                              size: context.sh * 0.03,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.sh * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            child: SuffixActionTextField(
                              hintText: Strings.searchHint,
                              onSearchPressed: (query) {
                                landingScreenBloc.add(
                                  SearchMedicinesEvent(query),
                                );
                              },
                            ),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.symmetric(
                          //       horizontal: 10, vertical: 4),
                          //   child: Icon(
                          //     Icons.tune,
                          //     color: ThemeColours.darkOrange,
                          //     size: 24,
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: context.sh * 0.02),
                      state.medicineDataResponseStatus == Status.loading
                          ? const Expanded(child: LoadingIndicator())
                          : state.medicineDataResponseStatus == Status.success
                              ? Expanded(
                                  child: GridView.builder(
                                    itemCount: state.filteredList.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, // 🔧 Number of columns
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 1 /
                                          1.3, // Width/Height ratio of each card
                                    ),
                                    itemBuilder: (context, index) {
                                      return ThemedCard(
                                        title: state
                                            .filteredList[index].medicineName,
                                        subTitle: state
                                            .filteredList[index].price
                                            .toString(),
                                      );
                                    },
                                  ),
                                )
                              : state.medicineDataResponseStatus ==
                                      Status.failure
                                  ? const Expanded(child: DataErrorWidget())
                                  : const SizedBox.shrink(),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
