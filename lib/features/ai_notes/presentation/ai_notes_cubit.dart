import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/summary_repository.dart';
import 'ai_notes_state.dart';

class AiNotesCubit extends Cubit<AiNotesState> {
  static const _maxInputLength = 5000;

  final SummaryRepository _repository;

  AiNotesCubit({required SummaryRepository repository})
      : _repository = repository,
        super(const AiNotesIdle());

  Future<void> generate(String input) async {
    if (state is AiNotesLoading) return;

    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      emit(const AiNotesError('Please enter some text first.'));
      return;
    }
    if (trimmed.length > _maxInputLength) {
      emit(const AiNotesError('Input is too long ($_maxInputLength chars max).'));
      return;
    }

    emit(const AiNotesLoading());

    try {
      final summary = await _repository.generate(trimmed);
      emit(AiNotesSuccess(summary));
    } on SummaryFailure catch (e) {
      emit(AiNotesError(e.message));
    } catch (_) {
      emit(const AiNotesError('Unexpected error. Please try again.'));
    }
  }

  void reset() => emit(const AiNotesIdle());
}
