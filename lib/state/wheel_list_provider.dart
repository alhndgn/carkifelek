import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ids.dart';
import '../data/wheel_repository.dart';
import '../models/wheel.dart';
import 'app_providers.dart';

/// Çarkların listesi: oluşturma, düzenleme, silme ve eleme modu mantığı.
/// Tek doğruluk kaynağı burasıdır; her değişiklik diske yazılır.
class WheelListNotifier extends Notifier<List<Wheel>> {
  WheelRepository get _repository => ref.read(wheelRepositoryProvider);

  @override
  List<Wheel> build() => ref.watch(wheelRepositoryProvider).loadAll();

  Wheel? wheelById(String id) {
    for (final Wheel wheel in state) {
      if (wheel.id == id) return wheel;
    }
    return null;
  }

  Future<void> create({
    required String title,
    required List<String> segments,
  }) async {
    final String cleanTitle = title.trim().isEmpty ? 'Yeni Çark' : title.trim();
    final Wheel wheel = Wheel(
      id: newId(),
      title: cleanTitle,
      segments: Wheel.normalizeSegments(segments),
      updatedAt: DateTime.now(),
    );
    // Yeni çark listenin başında görünür (repository de böyle sıralar).
    await _commit(<Wheel>[wheel, ...state]);
  }

  Future<void> rename(String id, String title) {
    final String clean = title.trim();
    if (clean.isEmpty) return Future<void>.value();
    return _replace(id, (Wheel w) => w.copyWith(title: clean, updatedAt: DateTime.now()));
  }

  /// Aynı seçeneklerle, listenin hemen ardına yeni bir çark ekler.
  Future<void> duplicate(String id) async {
    final Wheel? source = wheelById(id);
    if (source == null) return;

    final Wheel copy = source.copyWith(
      title: _copyTitle(source.title),
      updatedAt: DateTime.now(),
    );
    final Wheel renamed = Wheel(
      id: newId(),
      title: copy.title,
      segments: List<String>.of(source.segments),
      eliminateMode: source.eliminateMode,
      spinDurationMs: source.spinDurationMs,
      soundOn: source.soundOn,
      hapticsOn: source.hapticsOn,
      updatedAt: copy.updatedAt,
    );

    final List<Wheel> next = <Wheel>[];
    for (final Wheel wheel in state) {
      next.add(wheel);
      if (wheel.id == id) next.add(renamed);
    }
    await _commit(next);
  }

  Future<void> remove(String id) {
    return _commit(state.where((Wheel w) => w.id != id).toList());
  }

  Future<void> updateSegments(String id, List<String> segments) {
    return _replace(
      id,
      (Wheel w) => w.copyWith(
        segments: Wheel.normalizeSegments(segments),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateSettings(
    String id, {
    bool? eliminateMode,
    int? spinDurationMs,
    bool? soundOn,
    bool? hapticsOn,
  }) {
    return _replace(
      id,
      (Wheel w) => w.copyWith(
        eliminateMode: eliminateMode,
        spinDurationMs: spinDurationMs,
        soundOn: soundOn,
        hapticsOn: hapticsOn,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Eleme modu: kazanan seçeneği listeden çıkarır (ilk eşleşme).
  /// Çark 1 seçeneğe düşerse `canSpin` false olur, çevirme devre dışı kalır.
  Future<void> eliminateSegment(String id, String segment) {
    final Wheel? wheel = wheelById(id);
    if (wheel == null) return Future<void>.value();

    final int index = wheel.segments.indexOf(segment);
    if (index == -1) return Future<void>.value();

    final List<String> next = List<String>.of(wheel.segments)..removeAt(index);
    return _replace(
      id,
      (Wheel w) => w.copyWith(segments: next, updatedAt: DateTime.now()),
    );
  }

  Future<void> _replace(String id, Wheel Function(Wheel) transform) {
    bool changed = false;
    final List<Wheel> next = <Wheel>[];
    for (final Wheel wheel in state) {
      if (wheel.id == id) {
        changed = true;
        next.add(transform(wheel));
      } else {
        next.add(wheel);
      }
    }
    if (!changed) return Future<void>.value();
    return _commit(next);
  }

  Future<void> _commit(List<Wheel> next) async {
    state = next;
    await _repository.saveAll(next);
  }

  String _copyTitle(String title) {
    final RegExp pattern = RegExp(r'^(.*) \((\d+)\)$');
    final RegExpMatch? match = pattern.firstMatch(title);
    if (match == null) return '$title (2)';
    final int nextIndex = (int.tryParse(match.group(2) ?? '1') ?? 1) + 1;
    return '${match.group(1)} ($nextIndex)';
  }
}

final NotifierProvider<WheelListNotifier, List<Wheel>> wheelListProvider =
    NotifierProvider<WheelListNotifier, List<Wheel>>(WheelListNotifier.new);
