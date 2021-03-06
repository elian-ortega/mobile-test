import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:dartz/dartz.dart';

import 'package:errors/errors.dart';

import 'package:qr_generator/qr_generator.dart';

class MockQrGeneratorRepository extends Mock implements IQrGeneratorRepository {
}

void main() {
  final mockQrGeneratorRepository = MockQrGeneratorRepository();

  late QrScanner usecase;

  setUp(() {
    usecase = QrScanner(repository: mockQrGeneratorRepository);
  });

  const tSeed = 'seed';
  final tExpirationDate = DateTime.now().add(const Duration(seconds: 15));
  final tSeedEntity = SeedModel(seed: tSeed, expiresAt: tExpirationDate);

  test(
    'should get seed from the repository',
    () async {
      // arrange
      when(() => mockQrGeneratorRepository.getSeed())
          .thenAnswer((_) async => Right(tSeedEntity));

      // act
      final Either<Failure, Seed>? result = await usecase();

      // assert
      expect(result, Right(tSeedEntity));
      verify(() => mockQrGeneratorRepository.getSeed());
      verifyNoMoreInteractions(mockQrGeneratorRepository);
    },
  );

  test(
    'should get ServerFailure from the repository',
    () async {
      // arrange
      when(() => mockQrGeneratorRepository.getSeed())
          .thenAnswer((_) async => Left(ServerFailure()));

      // act
      final Either<Failure, Seed>? result = await usecase();

      // assert
      expect(result, equals(Left(ServerFailure())));
      verify(() => mockQrGeneratorRepository.getSeed());
      verifyNoMoreInteractions(mockQrGeneratorRepository);
    },
  );
}
