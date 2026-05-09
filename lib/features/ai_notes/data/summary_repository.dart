import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'summary.dart';

sealed class SummaryFailure implements Exception {
  final String message;

  const SummaryFailure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends SummaryFailure {
  const NetworkFailure([String? msg]) : super(msg ?? 'No internet connection. Check your network.');
}

class RateLimitFailure extends SummaryFailure {
  const RateLimitFailure() : super('Too many requests. Try again in a minute.');
}

class ServerFailure extends SummaryFailure {
  const ServerFailure([String? msg]) : super(msg ?? 'Something went wrong. Try again.');
}

class SummaryRepository {
  static const _prefsKey = 'ai_notes.summaries';
  static const _maxStoredSummaries = 50;

  final Dio _dio;
  final SharedPreferences _prefs;
  final bool _useMock;
  final String? _apiKey;

  SummaryRepository({required Dio dio, required SharedPreferences prefs, required bool useMock, String? apiKey})
    : _dio = dio,
      _prefs = prefs,
      _useMock = useMock,
      _apiKey = apiKey;

  Future<Summary> generate(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const ServerFailure('Input is empty.');
    }

    final output = _useMock ? await _generateMock(trimmed) : await _generateRemote(trimmed);

    return Summary(id: _generateId(), input: trimmed, output: output, createdAt: DateTime.now());
  }

  Future<String> _generateMock(String input) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (Random().nextInt(10) == 0) {
      throw const ServerFailure('Mock: simulated failure');
    }
    final words = input.split(RegExp(r'\s+'));
    final preview = words.take(8).join(' ');
    return 'Summary: $preview${words.length > 8 ? '...' : ''} '
        '(${words.length} words processed)';
  }

  Future<String> _generateRemote(String input) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw const ServerFailure('API key is not configured.');
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://openrouter.ai/api/v1/chat/completions',
        data: {
          'model': 'nvidia/nemotron-3-super-120b-a12b:free',
          'messages': [
            {'role': 'user', 'content': 'Summarize the following text concisely:\n\n$input'},
          ],
        },
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Authorization': 'Bearer $_apiKey', 'Content-Type': 'application/json'},
        ),
      );

      final choices = response.data?['choices'] as List?;
      final text = choices?.firstOrNull?['message']?['content'] as String?;

      if (text == null || text.isEmpty) {
        throw const ServerFailure('Empty response from API.');
      }
      return text.trim();
    } on DioException catch (e) {
      dev.log('DioException: type=${e.type}, status=${e.response?.statusCode}, data=${e.response?.data}', name: 'SummaryRepository');
      throw _mapDioError(e);
    } on SummaryFailure {
      rethrow;
    } catch (e, st) {
      dev.log('Unknown error: $e', name: 'SummaryRepository', error: e, stackTrace: st);
      throw const ServerFailure();
    }
  }

  SummaryFailure _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const NetworkFailure('Request timed out. Try again.'),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badResponse => switch (e.response?.statusCode) {
        429 => const RateLimitFailure(),
        final int code when code >= 500 => const ServerFailure(),
        _ => ServerFailure('API error: ${e.response?.statusCode}'),
      },
      _ => const ServerFailure(),
    };
  }

  Future<List<Summary>> loadSummaries() async {
    final raw = _prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Summary.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      await _prefs.remove(_prefsKey);
      return const [];
    }
  }

  Future<void> saveSummaries(List<Summary> summaries) async {
    final trimmed = summaries.take(_maxStoredSummaries).toList();
    final raw = jsonEncode(trimmed.map((s) => s.toJson()).toList());
    await _prefs.setString(_prefsKey, raw);
  }

  String _generateId() => const Uuid().v4();
}
