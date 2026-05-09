# AI Notes

Экран для генерации AI-саммари: вводишь текст — получаешь краткий пересказ. История сохраняется локально.

Запуск через Android Studio: конфигурация `main.dart` уже настроена, API-ключ подставляется автоматически.

## Стек

- **flutter_bloc (Cubit)** — state management
- **dio** — HTTP-запросы к OpenRouter API
- **shared_preferences** — локальное хранилище истории
- **equatable** — сравнение состояний
- **uuid** — генерация ID

## Что реализовано

- Ввод текста с валидацией (пустой ввод, лимит 5000 символов)
- Состояния загрузки, успеха и ошибки
- История последних 50 саммари с возможностью очистки
- Обработка сетевых ошибок (нет сети, таймаут, rate limit)
- Mock-режим для запуска без API-ключа: `flutter run --dart-define=USE_MOCK=true`

Ссылка для скачивания apk - https://drive.google.com/file/d/1XArYlkIpq8rHHypZXuzA5WebeGVdgofv/view?usp=drive_link
