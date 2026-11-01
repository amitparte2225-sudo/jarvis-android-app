import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_app/core/auth/pin_service.dart';

import 'memory_store.dart';

void main() {
  late MemoryStore store;
  late DateTime clock;
  late PinService service;

  setUp(() {
    store = MemoryStore();
    clock = DateTime(2026, 11, 1, 10);
    service = PinService(store, iterations: 10, now: () => clock);
  });

  test('checks PIN format', () {
    expect(PinService.isValidFormat('2468'), isTrue);
    expect(PinService.isValidFormat('12'), isFalse);
    expect(PinService.isValidFormat('abcd'), isFalse);
    expect(PinService.isValidFormat('123456789'), isFalse);
    expect(PinService.isTooWeak('1111'), isTrue);
    expect(PinService.isTooWeak('2468'), isFalse);
  });

  test('rejects a bad PIN when saving', () async {
    expect(() => service.setPin('12'), throwsArgumentError);
  });

  test('correct PIN opens, wrong PIN does not', () async {
    expect(await service.hasPin(), isFalse);
    await service.setPin('2468');
    expect(await service.hasPin(), isTrue);
    expect((await service.verify('2468')).ok, isTrue);
    final wrong = await service.verify('1357');
    expect(wrong.ok, isFalse);
    expect(wrong.attemptsLeft, 4);
  });

  test('PIN is never stored as plain text', () async {
    await service.setPin('2468');
    expect(store.data.values.every((v) => v != '2468'), isTrue);
  });

  test('locks after 5 wrong tries and opens after the wait', () async {
    await service.setPin('2468');
    for (var i = 0; i < 4; i++) {
      await service.verify('0000');
    }
    final fifth = await service.verify('0000');
    expect(fifth.lockedFor, isNotNull);

    // Even the right PIN is refused while locked.
    final during = await service.verify('2468');
    expect(during.ok, isFalse);
    expect(during.lockedFor, isNotNull);

    clock = clock.add(const Duration(seconds: 61));
    expect((await service.verify('2468')).ok, isTrue);
  });
}
