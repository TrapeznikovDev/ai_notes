import 'package:equatable/equatable.dart';

import '../data/summary.dart';

sealed class AiNotesState extends Equatable {
  const AiNotesState();

  @override
  List<Object?> get props => [];
}

final class AiNotesIdle extends AiNotesState {
  const AiNotesIdle();
}

final class AiNotesLoading extends AiNotesState {
  const AiNotesLoading();
}

final class AiNotesSuccess extends AiNotesState {
  final Summary summary;
  const AiNotesSuccess(this.summary);

  @override
  List<Object?> get props => [summary];
}

final class AiNotesError extends AiNotesState {
  final String message;
  const AiNotesError(this.message);

  @override
  List<Object?> get props => [message];
}
