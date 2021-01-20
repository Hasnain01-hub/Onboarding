import 'package:flutter/material.dart';
import 'package:onboarding_demo/models/onboarding_info.dart';
import 'package:get/state_manager.dart';
import 'package:get/utils.dart';

class OnboardingController extends GetxController {
  var selectedPageIndex = 0.obs;
  bool get isLastPage => selectedPageIndex.value == onboardingPages.length - 1;
  var pageController = PageController();

  forwardAction() {
    if (isLastPage) {
      //go to home page
    } else
      pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease);
  }

  List<OnboardingInfo> onboardingPages = [
    OnboardingInfo('assets/car_loc.PNG', 'Track your Live Location',
        'Now you can send your live location where we can provide service.'),
    OnboardingInfo('assets/resell_car.png', 'Post adds to Resell your cars',
        'Now you can post adds in the application to sell your cars in a quicker time.'),
    OnboardingInfo(
        'assets/notify.jpg',
        'Gives you a Notification to service your cars',
        'The app will remind you about your cars service')
  ];
}
