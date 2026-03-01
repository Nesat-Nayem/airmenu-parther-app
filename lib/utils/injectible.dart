import 'package:airmenuai_partner_app/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:airmenuai_partner_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:airmenuai_partner_app/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:airmenuai_partner_app/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:airmenuai_partner_app/core/change_notifiers/language_change_notifier.dart';
import 'package:airmenuai_partner_app/utils/services/user_service.dart';
import 'package:airmenuai_partner_app/utils/services/file_picker_service.dart';
import 'package:airmenuai_partner_app/features/platform_activity/data/repositories/platform_activity_repository_impl.dart';
import 'package:airmenuai_partner_app/features/platform_activity/domain/repositories/platform_activity_repository.dart';
import 'package:airmenuai_partner_app/features/platform_activity/domain/usecases/get_platform_activities_usecase.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/bloc/platform_activity_bloc.dart';

import 'package:airmenuai_partner_app/features/tables/data/repositories/table_repository.dart';
import 'package:airmenuai_partner_app/features/tables/presentation/bloc/tables_bloc.dart';

import 'package:airmenuai_partner_app/features/staff_management/data/repositories/staff_repository.dart';
import 'package:airmenuai_partner_app/features/staff_management/domain/repositories/staff_repository_interface.dart';
import 'package:airmenuai_partner_app/features/staff_management/presentation/bloc/staff_bloc.dart';

import 'package:airmenuai_partner_app/features/category/data/datasources/category_remote_data_source.dart';
import 'package:airmenuai_partner_app/features/category/data/repositories/category_repository_impl.dart';
import 'package:airmenuai_partner_app/features/category/domain/repositories/category_repository.dart';
import 'package:airmenuai_partner_app/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:airmenuai_partner_app/features/category/domain/usecases/create_category_usecase.dart';
import 'package:airmenuai_partner_app/features/category/domain/usecases/update_category_usecase.dart';
import 'package:airmenuai_partner_app/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_bloc.dart';

// Kitchen Feature
import 'package:airmenuai_partner_app/features/kitchen/data/repositories/kitchen_repository_impl.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/get_kitchen_queue_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/get_kitchen_status_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/get_ready_orders_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/get_stations_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/update_task_status_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/get_hotels_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_bloc.dart';

// Onboarding Pipeline Feature
// Onboarding Pipeline Feature
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/repositories/kyc_repository_impl.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/domain/repositories/i_kyc_repository.dart';

// Vendor KYC Feature
import 'package:airmenuai_partner_app/features/my_kyc/data/vendor_kyc_repository.dart';
import 'package:airmenuai_partner_app/features/my_kyc/presentation/bloc/vendor_kyc_bloc.dart';

// Menu Audit Feature
import 'package:airmenuai_partner_app/features/menu_audit/data/repositories/menu_audit_repository_impl.dart';
import 'package:airmenuai_partner_app/features/menu_audit/domain/repositories/i_menu_audit_repository.dart';
import 'package:airmenuai_partner_app/features/menu_audit/presentation/bloc/menu_audit_bloc.dart';

// Marketing Feature
import 'package:airmenuai_partner_app/features/marketing/data/repositories/marketing_repository_impl.dart';
import 'package:airmenuai_partner_app/features/marketing/domain/repositories/i_marketing_repository.dart';

import 'package:airmenuai_partner_app/generated/l10n.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/secure_storage.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/auth_service.dart';
import 'package:airmenuai_partner_app/core/network/response_handler.dart';

final locator = GetIt.instance;

void initializeDependencies() {
  locator.registerFactory<LocalStorage>(() => LocalStorage());
  locator.registerFactory<SecureStorage>(() => SecureStorage());
  locator.registerFactory<LanguageChangeNotifier>(
    () => LanguageChangeNotifier(),
  );
  locator.registerLazySingleton<S>(() => S());
  locator.registerLazySingleton<ApiService>(() => ApiService());
  locator.registerLazySingleton<ResponseHandler>(() => ResponseHandler());
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<UserService>(() => UserService());

  // Platform Activity feature
  locator.registerLazySingleton<PlatformActivityRepository>(
    () => PlatformActivityRepositoryImpl(),
  );
  locator.registerLazySingleton<GetPlatformActivitiesUsecase>(
    () => GetPlatformActivitiesUsecase(locator<PlatformActivityRepository>()),
  );
  locator.registerFactory<PlatformActivityBloc>(
    () => PlatformActivityBloc(
      getPlatformActivitiesUsecase: locator<GetPlatformActivitiesUsecase>(),
    ),
  );

  // File Picker Service
  locator.registerLazySingleton<FilePickerService>(() => FilePickerService());

  // Category feature
  locator.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(apiService: locator<ApiService>()),
  );

  locator.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      remoteDataSource: locator<CategoryRemoteDataSource>(),
    ),
  );

  locator.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(locator<CategoryRepository>()),
  );

  locator.registerLazySingleton<CreateCategoryUseCase>(
    () => CreateCategoryUseCase(locator<CategoryRepository>()),
  );

  locator.registerLazySingleton<UpdateCategoryUseCase>(
    () => UpdateCategoryUseCase(locator<CategoryRepository>()),
  );

  locator.registerLazySingleton<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(locator<CategoryRepository>()),
  );

  locator.registerFactory<CategoryBloc>(
    () => CategoryBloc(
      getCategoriesUseCase: locator<GetCategoriesUseCase>(),
      createCategoryUseCase: locator<CreateCategoryUseCase>(),
      updateCategoryUseCase: locator<UpdateCategoryUseCase>(),
      deleteCategoryUseCase: locator<DeleteCategoryUseCase>(),
    ),
  );

  // Orders Feature
  locator.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(locator<ApiService>()),
  );
  locator.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(locator<OrdersRepository>()),
  );
  locator.registerLazySingleton<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(locator<OrdersRepository>()),
  );
  locator.registerFactory<OrdersBloc>(() => OrdersBloc());

  // Kitchen Feature
  locator.registerLazySingleton<KitchenRepository>(
    () => KitchenRepositoryImpl(locator<ApiService>()),
  );
  locator.registerLazySingleton<GetKitchenQueueUseCase>(
    () => GetKitchenQueueUseCase(locator<KitchenRepository>()),
  );
  locator.registerLazySingleton<GetKitchenStatusUseCase>(
    () => GetKitchenStatusUseCase(locator<KitchenRepository>()),
  );
  locator.registerLazySingleton<GetReadyOrdersUseCase>(
    () => GetReadyOrdersUseCase(locator<KitchenRepository>()),
  );
  locator.registerLazySingleton<UpdateTaskStatusUseCase>(
    () => UpdateTaskStatusUseCase(locator<KitchenRepository>()),
  );
  locator.registerLazySingleton<GetStationsUseCase>(
    () => GetStationsUseCase(locator<KitchenRepository>()),
  );
  locator.registerLazySingleton<GetHotelsUseCase>(
    () => GetHotelsUseCase(locator<KitchenRepository>()),
  );
  locator.registerFactory<KitchenBloc>(() => KitchenBloc());
  // Tables Feature
  locator.registerLazySingleton(
    () => TableRepository(apiService: locator<ApiService>()),
  );
  locator.registerFactory<TablesBloc>(
    () => TablesBloc(repository: locator<TableRepository>()),
  );

  // Staff Management Feature
  locator.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(locator<ApiService>()),
  );
  locator.registerFactory<StaffBloc>(
    () => StaffBloc(repository: locator<StaffRepository>()),
  );

  // Onboarding Pipeline Feature
  // Onboarding Pipeline Feature
  locator.registerLazySingleton<IKycRepository>(
    () => KycRepositoryImpl(locator.get<ApiService>()),
  );
  locator.registerFactory<OnboardingPipelineBloc>(
    () => OnboardingPipelineBloc(locator<IKycRepository>()),
  );

  // Vendor KYC Feature
  locator.registerLazySingleton<VendorKycRepository>(
    () => VendorKycRepository(),
  );
  locator.registerFactory<VendorKycBloc>(
    () => VendorKycBloc(locator<VendorKycRepository>()),
  );

  // Menu Audit Feature
  locator.registerLazySingleton<IMenuAuditRepository>(
    () => MenuAuditRepositoryImpl(),
  );
  locator.registerFactory<MenuAuditBloc>(
    () => MenuAuditBloc(locator<IMenuAuditRepository>()),
  );

  // Marketing Feature
  locator.registerLazySingleton<IMarketingRepository>(
    () => MarketingRepositoryImpl(),
  );
}
