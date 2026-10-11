import 'package:carkifelek/data/key_value_store.dart';
import 'package:carkifelek/data/wheel_repository.dart';
import 'package:carkifelek/models/wheel.dart';
import 'package:carkifelek/state/app_providers.dart';
import 'package:carkifelek/state/wheel_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryStore store;
  late ProviderContainer container;

  ProviderContainer buildContainer() {
    final ProviderContainer c = ProviderContainer(
      overrides: [
        wheelRepositoryProvider.overrideWithValue(WheelRepository(store)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    store = InMemoryStore();
    container = buildContainer();
  });

  test('başlangıçta liste boş', () {
    expect(container.read(wheelListProvider), isEmpty);
  });

  test('create yeni çarkı başa ekler ve diske yazar', () async {
    await container
        .read(wheelListProvider.notifier)
        .create(title: 'Ne yesek?', segments: const <String>['Pizza', 'Kebap']);

    final List<Wheel> wheels = container.read(wheelListProvider);
    expect(wheels.length, 1);
    expect(wheels.single.title, 'Ne yesek?');
    expect(wheels.single.canSpin, isTrue);
    expect(store.read(WheelRepository.storageKey), contains('Ne yesek?'));
  });

  test('create boş başlıkta varsayılan ad kullanır, boş seçenekleri atar', () async {
    await container.read(wheelListProvider.notifier).create(
      title: '   ',
      segments: const <String>[' ', 'Ali', ''],
    );

    final Wheel wheel = container.read(wheelListProvider).single;
    expect(wheel.title, 'Yeni Çark');
    expect(wheel.segments, <String>['Ali']);
    expect(wheel.canSpin, isFalse);
  });

  test('rename başlığı değiştirir, boş başlığı yok sayar', () async {
    final WheelListNotifier notifier = container.read(wheelListProvider.notifier);
    await notifier.create(title: 'A', segments: const <String>['x', 'y']);
    final String id = container.read(wheelListProvider).single.id;

    await notifier.rename(id, 'B');
    expect(container.read(wheelListProvider).single.title, 'B');

    await notifier.rename(id, '   ');
    expect(container.read(wheelListProvider).single.title, 'B');
  });

  test('duplicate aynı seçeneklerle yeni çark üretir', () async {
    final WheelListNotifier notifier = container.read(wheelListProvider.notifier);
    await notifier.create(title: 'Ne yesek?', segments: const <String>['Pizza', 'Kebap']);
    final Wheel original = container.read(wheelListProvider).single;

    await notifier.duplicate(original.id);

    final List<Wheel> wheels = container.read(wheelListProvider);
    expect(wheels.length, 2);
    final Wheel copy = wheels.firstWhere((Wheel w) => w.id != original.id);
    expect(copy.title, 'Ne yesek? (2)');
    expect(copy.segments, original.segments);
  });

  test('remove çarkı siler', () async {
    final WheelListNotifier notifier = container.read(wheelListProvider.notifier);
    await notifier.create(title: 'A', segments: const <String>['x', 'y']);
    final String id = container.read(wheelListProvider).single.id;

    await notifier.remove(id);

    expect(container.read(wheelListProvider), isEmpty);
    expect(store.read(WheelRepository.storageKey), '[]');
  });

  test('updateSegments boş metinleri temizler', () async {
    final WheelListNotifier notifier = container.read(wheelListProvider.notifier);
    await notifier.create(title: 'A', segments: const <String>['x', 'y']);
    final String id = container.read(wheelListProvider).single.id;

    await notifier.updateSegments(id, const <String>[' Ali ', '', 'Doğan']);

    expect(
      container.read(wheelListProvider).single.segments,
      <String>['Ali', 'Doğan'],
    );
  });

  test('updateSettings ayarları yazar', () async {
    final WheelListNotifier notifier = container.read(wheelListProvider.notifier);
    await notifier.create(title: 'A', segments: const <String>['x', 'y']);
    final String id = container.read(wheelListProvider).single.id;

    await notifier.updateSettings(
      id,
      eliminateMode: true,
      spinDurationMs: 7000,
      soundOn: false,
    );

    final Wheel wheel = container.read(wheelListProvider).single;
    expect(wheel.eliminateMode, isTrue);
    expect(wheel.spinDurationMs, 7000);
    expect(wheel.soundOn, isFalse);
    expect(wheel.hapticsOn, isTrue);
  });

  test('eliminateSegment kazananı listeden çıkarır', () async {
    final WheelListNotifier notifier = container.read(wheelListProvider.notifier);
    await notifier.create(
      title: 'Kim ısmarlayacak?',
      segments: const <String>['Ali', 'Doğan', 'Mehmet'],
    );
    final String id = container.read(wheelListProvider).single.id;

    await notifier.eliminateSegment(id, 'Doğan');

    expect(
      container.read(wheelListProvider).single.segments,
      <String>['Ali', 'Mehmet'],
    );
  });

  test('eleme sonrası tek seçenek kalırsa çark kilitlenir', () async {
    final WheelListNotifier notifier = container.read(wheelListProvider.notifier);
    await notifier.create(title: 'A', segments: const <String>['Ali', 'Doğan']);
    final String id = container.read(wheelListProvider).single.id;

    await notifier.eliminateSegment(id, 'Ali');

    expect(container.read(wheelListProvider).single.canSpin, isFalse);
  });

  test('olmayan seçeneği elemek listeyi bozmaz', () async {
    final WheelListNotifier notifier = container.read(wheelListProvider.notifier);
    await notifier.create(title: 'A', segments: const <String>['Ali', 'Doğan']);
    final String id = container.read(wheelListProvider).single.id;

    await notifier.eliminateSegment(id, 'Yok');

    expect(container.read(wheelListProvider).single.segments.length, 2);
  });

  test('veriler yeni oturumda (yeni container) korunur', () async {
    await container.read(wheelListProvider.notifier).create(
      title: 'Hafta sonu ne yapalım?',
      segments: const <String>['Parka gidelim', 'Yemek yiyelim'],
    );

    final ProviderContainer second = buildContainer();

    expect(second.read(wheelListProvider).single.title, 'Hafta sonu ne yapalım?');
  });
}
