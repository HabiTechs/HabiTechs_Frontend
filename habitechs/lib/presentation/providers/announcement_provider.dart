import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/models/announcement.dart';
import 'package:habitechs/data/repositories/announcement_repository.dart';

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final repo = ref.watch(announcementRepoProvider);
  return repo.getAnnouncements();
});
