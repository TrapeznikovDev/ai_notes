import 'package:equatable/equatable.dart';

class Summary extends Equatable {
  final String id;
  final String input;
  final String output;
  final DateTime createdAt;

  const Summary({
    required this.id,
    required this.input,
    required this.output,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'input': input,
        'output': output,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        id: json['id'] as String,
        input: json['input'] as String,
        output: json['output'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [id, input, output, createdAt];
}
