import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/summary.dart';
import '../data/summary_repository.dart';

class SummariesListCubit extends Cubit<List<Summary>> {
  final SummaryRepository _repository;

  SummariesListCubit(this._repository) : super(const []);

  Future<void> load() async {
    final list = await _repository.loadSummaries();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(list);
  }

  Future<void> add(Summary summary) async {
    final updated = [summary, ...state];
    emit(updated);
    await _repository.saveSummaries(updated);
  }

  Future<void> clear() async {
    emit(const []);
    await _repository.saveSummaries(const []);
  }
}
