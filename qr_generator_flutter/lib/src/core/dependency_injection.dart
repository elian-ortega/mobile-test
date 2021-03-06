// ignore_for_file: cascade_invocations
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'package:network_manager/network_manager.dart';
import 'package:qr_generator/qr_generator.dart';
import 'package:qr_generator_flutter/src/features/qr_generator/logic/qr_generator_cubit.dart';
import 'package:qr_generator_flutter/src/features/qr_scanner/logic/qr_scanner_cubit.dart';

import 'env/enviroment_config.dart';

/// Variable to access DI
final getIt = GetIt.instance;

/// Method that facilitates the `dependency injection` for easier access
Future<void> setUpDI() async {
  //* Inject Repository
  getIt.registerLazySingleton<IQrGeneratorRepository>(
    () => QrGeneratorRepository(
      remoteDataSource: RemoteDataSource(
        client: Dio(),
        url: '${EnvironmentConfig.apiUrl}/seed',
      ),
      localDataSource: LocalDataSource(),
      networkManager: NetworkManager(
        DataConnectionChecker(),
      ),
    ),
  );

  //* Inject UseCases
  getIt.registerLazySingleton<QrScanner>(
    () => QrScanner(
      repository: getIt<IQrGeneratorRepository>(),
    ),
  );

  //* Inject Logic Generator Code Holder / Cubit
  getIt.registerLazySingleton<QrGeneratorCubit>(
    () => QrGeneratorCubit(
      getSeed: getIt<QrScanner>(),
    ),
  );

  //* Inject Logic Scanner Code Holder / Cubit
  getIt.registerLazySingleton<QrScannerCubit>(
    () => QrScannerCubit(),
  );
}
