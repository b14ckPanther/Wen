// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/businesses/application/business_repository_provider.dart';
import 'package:mobile/features/businesses/application/business_search_controller.dart';
import 'package:mobile/features/businesses/data/models/business_category.dart';
import 'package:mobile/features/businesses/data/repositories/business_repository.dart';
import 'package:mobile/features/businesses/domain/business_query_filters.dart';
import 'package:mobile/features/explore/presentation/screens/explore_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('shows explore tab by default', (tester) async {
    final fakeFirestore = FakeFirebaseFirestore();
    final now = Timestamp.now();

    kForceExploreTestMode = true;

    await fakeFirestore.collection('categories').doc('restaurants').set({
      'name': 'Restaurants',
      'parentId': null,
    });

    await fakeFirestore.collection('businesses').doc('business-001').set({
      'name': 'Al Madina Bistro',
      'description': 'Modern Emirati fusion cuisine.',
      'categoryId': 'restaurants',
      'location': const GeoPoint(25.2048, 55.2708),
      'ownerId': 'owner-001',
      'plan': 'standard',
      'approved': true,
      'images': <String>[],
      'searchKeywords': ['al', 'madina', 'bistro'],
      'createdAt': now,
      'updatedAt': now,
    });

    final repository = BusinessRepository(
      fakeFirestore,
      FirebaseStorage.instanceFor(bucket: 'gs://stub-bucket'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          businessRepositoryProvider.overrideWithValue(repository),
          businessCategoriesProvider.overrideWith(
            (ref) => Stream.value([
              const BusinessCategory(
                id: 'restaurants',
                name: 'Restaurants',
                parentId: null,
              ),
            ]),
          ),
          nearbyBusinessesProvider.overrideWith((ref) async {
            final repo = ref.watch(businessRepositoryProvider);
            final page = await repo.fetchBusinesses(
              filters: BusinessQueryFilters(
                center: const GeoPoint(25.2048, 55.2708),
              ),
            );
            return page.items;
          }),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ExploreScreen(),
        ),
      ),
    );

    await tester.pump();

    kForceExploreTestMode = false;

    expect(find.text('Discover trending businesses near you'), findsOneWidget);
  });
}

void setupFirebaseCoreMocks() {
  TestFirebaseCoreHostApi.setUp(_MockFirebaseApp());
}

class _MockFirebaseApp implements TestFirebaseCoreHostApi {
  @override
  Future<CoreInitializeResponse> initializeApp(
    String appName,
    CoreFirebaseOptions initializeAppRequest,
  ) async {
    return CoreInitializeResponse(
      name: appName,
      options: CoreFirebaseOptions(
        apiKey: '123',
        projectId: '123',
        appId: '123',
        messagingSenderId: '123',
      ),
      pluginConstants: const {},
    );
  }

  @override
  Future<List<CoreInitializeResponse>> initializeCore() async {
    return [
      CoreInitializeResponse(
        name: defaultFirebaseAppName,
        options: CoreFirebaseOptions(
          apiKey: '123',
          projectId: '123',
          appId: '123',
          messagingSenderId: '123',
        ),
        pluginConstants: const {},
      ),
    ];
  }

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async {
    return CoreFirebaseOptions(
      apiKey: '123',
      projectId: '123',
      appId: '123',
      messagingSenderId: '123',
    );
  }
}
