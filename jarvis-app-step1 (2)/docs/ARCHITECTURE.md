# JARVIS Architecture (v1)

## Principles
- Android first (Flutter). Windows later from the same code.
- Offline-first: study data lives on the phone, encrypted. Internet is used only for smart/online features.
- AI models and services sit behind small interfaces so they can be swapped.
- No API keys inside the app. Keys live on the backend (environment variables).
- No feature is marked done until its checklist passes.

## Layers
1. App (Flutter): screens, state, local database (SQLite, encrypted), sync queue, notifications.
2. Backend (Python FastAPI): login, Claude calls, document processing/OCR, embeddings, Gmail/Calendar OAuth, cost meter.
3. Database (PostgreSQL + pgvector): accounts, synced data, document search.
4. Storage: encrypted object storage for uploaded files.
5. Services (pluggable): Claude (chat, questions, evaluation), speech-to-text, ElevenLabs (voice out), OCR.

## Offline vs online
- Offline: revision (spaced repetition runs on device), saved quizzes, mistake notebook, notes, journal, to-dos, saved documents + search, progress, local reminders.
- Online: Claude chat/question generation/answer scoring, best voice, Gmail/Calendar, research, sync/backup.
- Sync: changes queue while offline and upload later. Conflicts keep both versions and ask the user.
- Packs: while online, the app downloads tomorrow's questions, notes and summaries for offline use.
- Local AI chat (small on-device model) is optional and decided later.

## Security
- PIN stored as a salted PBKDF2 hash in Android Keystore storage (Step 1). Lock after 5 wrong tries. Auto-lock after 30 seconds in background.
- Account login with the backend in Step 3. Encryption of local data in Step 2.
- Uploaded files are never executed. Document text is treated as data, not instructions (prompt-injection guard).
- Every sensitive action (send, delete, post) asks the user first.

## Code layout
lib/core (theme, auth), lib/features/<module>, test/. Each module is small and separate.
