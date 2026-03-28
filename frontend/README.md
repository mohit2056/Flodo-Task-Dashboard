# Flodo Task Management App 🚀

A visually polished, functional Task Management application built with Flutter (Frontend) and Python/FastAPI (Backend) for the Flodo AI Take-Home Assignment.

## 🎯 Project Details
* **Track Chosen:** Track A (The Full-Stack Builder)
* **Stretch Goal Completed:** #1 Debounced Autocomplete Search (with 300ms delay and Cyan text highlighting for matching strings).

## ✨ Key Features
* **Complete CRUD:** Create, Read, Update, and Delete tasks with an artificial 2-second simulated delay and loading states.
* **Blocked By Logic:** Tasks can be dependent on other tasks. Blocked tasks are visually greyed out and unclickable until the parent task is marked as "Done".
* **Drafts Preservation:** Unsaved text in the "New Task" dialog is preserved using Riverpod State Management even if the dialog is accidentally closed.
* **Debounced Search & Filter:** 300ms debounced search functionality that highlights the matching query in real-time, along with a Status filter.
* **Premium UI/UX:** Glassmorphism UI, custom neon color palette, and an integrated 3D animated background (Vanta.js) for a futuristic AI-startup feel.

## ⚙️ Setup & Installation Instructions

### 1. Start the Backend (Python/FastAPI)
Navigate to the backend directory and run the FastAPI server:
```bash
cd backend
# Make sure your virtual environment is activated and dependencies are installed
uvicorn main:app --reload

The backend will run on http://127.0.0.1:8000

2. Start the Frontend (Flutter Web)
Open a new terminal, navigate to the frontend directory, and run the Flutter app:

cd frontend
flutter clean
flutter pub get
flutter run -d chrome --profile


🤖 AI Usage Report
I strongly utilized AI (Gemini) as a pair-programming partner to accelerate development. Here is how I used it:

Helpful Prompts: I used AI to generate the boilerplate for Riverpod state management and to design the complex "Glassmorphism" UI effect for the Task Cards.

Debugging & Hallucinations: When implementing the "Drafts" feature, the AI initially hallucinated and suggested using the deprecated StateProvider from an older version of Riverpod, which caused compilation errors. I prompted the AI with the terminal error, and we successfully refactored the code to use the modern NotifierProvider instead.

Creative Collaboration: I collaborated with AI to implement an "Out of Syllabus" feature—injecting a Three.js/Vanta.js 3D animated background behind the Flutter canvas to give the app a premium, standout look.

