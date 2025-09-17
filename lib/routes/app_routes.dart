import 'package:flutter/material.dart';
import '../presentation/settings/settings.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/add_client/add_client.dart';
import '../presentation/search_client/search_client.dart';
import '../presentation/generate_report/generate_report.dart';
import '../presentation/add_service/add_service.dart';
import '../presentation/photo_gallery/photo_gallery.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String splash = '/splash-screen';
  static const String addClient = '/add-client';
  static const String searchClient = '/search-client';
  static const String generateReport = '/generate-report';
  static const String addService = '/add-service';
  static const String photoGallery = '/photo-gallery';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    settings: (context) => const Settings(),
    splash: (context) => const SplashScreen(),
    addClient: (context) => const AddClient(),
    searchClient: (context) => const SearchClient(),
    generateReport: (context) => const GenerateReport(),
    addService: (context) => const AddService(),
    photoGallery: (context) => const PhotoGallery(),
    // TODO: Add your other routes here
  };
}
