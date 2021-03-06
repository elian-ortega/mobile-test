import 'dart:convert';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:matcher/matcher.dart';
import 'package:dio/dio.dart';

import 'package:errors/errors.dart';

import 'package:qr_generator/qr_generator.dart';

import '../../fixtures/fixture_reader.dart';

class MockDio extends Mock implements Dio {}

void main() {
  final mockDioClient = MockDio();
  late RemoteDataSource dataSource;

  setUp(() {
    dataSource = RemoteDataSource(client: mockDioClient, url: '');
  });

  void setUpMockDioClientSuccess200() {
    when(
      () => mockDioClient.get(''),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: json.decode(fixture('seed_local.json')),
        statusCode: 200,
      ),
    );
  }

  void setUpMockDioClientFailure404() {
    when(
      () => mockDioClient.get(''),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: 'Something went wrong',
        statusCode: 400,
      ),
    );
  }

  group('getSeed', () {
    final tSeed = SeedModel.fromJson(json.decode(fixture('seed_local.json')));
    test(
      '''should perform a GET request on a URL with seed
       being the endpoint and with application/json header''',
      () async {
        // arrange
        setUpMockDioClientSuccess200();

        // act
        await dataSource.getSeed();

        // assert
        verify(() => mockDioClient.get(''));
      },
    );

    test(
      'should return Seed when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockDioClientSuccess200();
        // act
        final result = await dataSource.getSeed();
        // assert
        expect(result, equals(tSeed));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockDioClientFailure404();
        // act
        final call = dataSource.getSeed;
        // assert
        expect(call, throwsA(const TypeMatcher<ServerException>()));
      },
    );
  });
}
