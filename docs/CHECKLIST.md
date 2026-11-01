# JARVIS Development Checklist
[x] = verified working on a real phone. [~] = code written, not yet verified. [ ] = not started.

## Step 1: App shell + PIN lock
[~] Project builds on GitHub and tests pass
[~] Create PIN (4-8 digits, confirm, weak PIN refused)
[~] Unlock screen, wrong-try count, 60-second lock after 5 tries
[~] Auto-lock after 30 seconds in background, manual lock button
[~] Light and dark theme
[~] Honest "not built yet" pages for later modules
[ ] Step 1B: fingerprint unlock (after PIN is verified on phone)

## Step 2: Local-first foundation
[ ] Encrypted phone database  [ ] Sync queue  [ ] Online/Offline/Syncing badge  [ ] Mode: Auto / Online only / Offline only

## Step 3: Backend + account login + chat
[ ] FastAPI backend, keys in environment  [ ] Secure account login + sessions  [ ] Claude chat  [ ] Language detection  [ ] Cost meter and limit  [ ] Error and loading states

## Step 4: Memory
[ ] 8 memory categories  [ ] Ask before saving sensitive info  [ ] View/edit/export/delete  [ ] Memory search  [ ] Temporary vs permanent

## Step 5: Daily revision
[ ] Flashcards  [ ] Spaced repetition (FSRS)  [ ] Active recall + hints, answers hidden until attempt  [ ] Mistake notebook  [ ] Streaks  [ ] Accuracy + response time  [ ] Adaptive difficulty  [ ] Weekly report  [ ] Offline question packs  [ ] Continue where I stopped

## Step 6: Documents and knowledge
[ ] Upload (PDF, Word, Excel, PPT, TXT, CSV, MD, JSON, XML, HTML, images, code, audio, video)  [ ] Folders, preview, search  [ ] OCR  [ ] Summaries, MCQs, flashcards, notes, mind maps  [ ] Questions with citations + page numbers  [ ] Source vs own-knowledge label  [ ] Compare documents  [ ] Knowledge library + knowledge graph  [ ] Download/delete files  [ ] Malicious-file and prompt-injection protection

## Step 7: Interview coach
[ ] One question at a time, score /10, ideal answer, follow-ups  [ ] 4 difficulty levels  [ ] Resume intelligence  [ ] Job description analyzer + roadmap  [ ] Company/role-specific  [ ] Coding practice (SQL, Python, Java) with test cases  [ ] Performance tracking + revision plan  [ ] Interview simulator with timers

## Step 8: Exam module
[ ] Syllabus management (UPSC, MPSC, SSC, banking, RBI Grade B, railway, state, university, school, certifications)  [ ] Topic-wise revision  [ ] MCQs, descriptive answers + evaluation  [ ] Handwritten answer photo check  [ ] Current affairs  [ ] Daily/weekly/monthly tests, mock exams with timers  [ ] Past papers (user-provided/licensed)  [ ] Weak topics + study timetable + analysis

## Step 9: Voice and languages
[ ] Voice input  [ ] Voice output (ElevenLabs online, Android voice offline)  [ ] Speed, voice choice, pause/resume, interruption  [ ] Voice mock interviews and tests  [ ] Hindi, Marathi, English + other languages with honest availability list  [ ] Mixed-language chat  [ ] Translation  [ ] Keep technical terms

## Step 10: Productivity
[ ] Tasks, to-dos, goals, notes, bookmarks  [ ] Google Calendar (read-only first)  [ ] Gmail (read-only first, drafts, ask before send)  [ ] Personal journal  [ ] Daily/weekly plan

## Step 11: Final
[ ] Proactive suggestions with quiet hours and permissions  [ ] Dashboard  [ ] Research assistant with sources  [ ] Export/backup (PDF, Word, Excel, CSV, JSON)  [ ] Action history  [ ] Security checks  [ ] Performance + low-data mode  [ ] Deployment guide
