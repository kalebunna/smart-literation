# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "SQ4R Learning App" - a Flutter-based educational game application (Indonesian: "Aplikasi game edukasi") that implements the SQ4R (Survey, Question, Read, Recite, Review) learning methodology. The app provides an interactive learning experience with reading materials, quizzes, and assessment features.

## Common Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app (development)
flutter run

# Run on specific device  
flutter run -d chrome  # For web
flutter run -d <device-id>  # For specific device

# Build the app
flutter build apk        # Android APK
flutter build ios        # iOS (macOS only)  
flutter build web        # Web build

# Run tests (minimal widget tests present)
flutter test

# Analyze code (uses flutter_lints package)
flutter analyze

# Clean build artifacts
flutter clean

# Run single test file
flutter test test/widget_test.dart

# Get device list
flutter devices
```

## Architecture Overview

### State Management
- **Provider pattern** is used for state management with multiple providers registered in `main.dart`:
  - `UserProvider` - User authentication and profile management
  - `ChapterProvider` - Chapter/course management
  - `MaterialProvider` - Learning material management  
  - `QuizProvider` - Quiz and assessment state
- All providers use `ChangeNotifierProvider` and are accessible throughout the app via `MultiProvider`

### Core Structure
- **Models**: Data classes for API responses (`/lib/models/`)
  - `Chapter`, `Material`, `QuizQuestion`, `User`, `ReadingMaterial`, `SummaryParagraph`, `SummaryModel`
  - Complex quiz models with A-D choices and individual explanations per option
- **Services**: API communication and local storage (`/lib/services/`)
  - `ApiService` - Active API client with Bearer token authentication (baseUrl: `http://127.0.0.1:8000/api`)
  - `AuthService` - Legacy auth service (unused, different baseUrl: `api.sq4rapp.com`)
  - `LocalStorageService` - SharedPreferences wrapper utility
- **Screens**: UI screens following material design (`/lib/screens/`) - 20+ screens for complete learning flow
  - Quiz flow: `quiz_start_screen.dart`, `new_quiz_screen.dart`, `quiz_celebration_screen.dart`
  - Content: `material_content_screen.dart`, `material_summary_screen.dart`
- **Providers**: State management classes (`/lib/providers/`)
  - All registered in `main.dart` via `MultiProvider` for dependency injection
- **Utils**: Helper utilities including custom routing (`/lib/utils/`)
  - `RouteGenerator` - Custom routing with parameter support and regex-based dynamic routes
  - `ApiResponseHandler` - Generic API response wrapper for error handling
- **Constants**: App-wide constants (`/lib/constants/`)
  - `AppColors` - Consistent color scheme (primary: #9064F5, secondary: #FFD166)
  - `AppStrings`, `AppStyles` - Centralized UI constants

### API Integration
The app integrates with a Laravel backend API using Bearer token authentication. Key endpoints include:
- `POST /login` - User authentication with email/password
- `GET /list-babs` - Get chapters/courses  
- `GET /materi/{chapterId}` - Get materials by chapter
- `GET /soal-quiz/{materialId}` - Get quiz questions for mid-test
- `GET /final-test/{materialId}` - Get final test questions
- `GET /rangkuman/{materialId}` - Get material summaries
- `GET /soal-greeding/{materialId}` - Get greeding/open questions
- `POST /greading-assesment` - Submit grading assessments (AI-powered essay grading)
- `POST /jawaban-user` - Submit final test answers with scoring
- `GET /bahan-bacaan` - Get reading materials

**API Response Pattern**: All responses use `ApiResponse<T>` wrapper with `success`, `data`, and `error` fields for consistent error handling.

**Service Architecture**: 
- `ApiService` class is the active HTTP client used throughout the app
- `AuthService` exists but is unused (different base URL: api.sq4rapp.com vs 127.0.0.1:8000)
- Bearer tokens are automatically attached via `_getHeaders()` method

### Navigation
Uses custom `RouteGenerator` class in `/lib/utils/route_generator.dart` for declarative routing with:
- Static routes (e.g., `/dashboard`, `/chapters`, `/login`)
- Parameter-based routes using `RouteSettings.arguments` (e.g., `/materials`, `/quiz`)
- Regex-based dynamic routes (e.g., `/final-test/123` using `RegExp(r'^/final-test/(\d+)$')`)
- Type-safe parameter passing with proper error handling via `_errorRoute()`

### UI/UX Design
- **Color scheme**: Purple primary (`#9064F5`), yellow secondary (`#FFD166`)
- **Typography**: Poppins font family (Regular, Medium, SemiBold, Bold)
- **Material Design**: Uses Flutter's Material Design components
- **Assets**: Images, icons, sounds, PDFs stored in `/assets/` directories

### Key Features
1. **Reading Materials**: PDF and video content viewing
2. **Interactive Quizzes**: Multiple choice questions with explanations
3. **SQ4R Method**: Structured learning approach implementation
4. **Progress Tracking**: Material completion and scoring
5. **Assessment**: Mid-tests and final tests with grading
6. **Audio Feedback**: Sound effects for interactions (correct/wrong/complete)

## Important Notes

- **Project naming**: pubspec.yaml name is `education_game_app` but folder name is `smart_literation_v1`
- **Environment setup**: `.env` file support is implemented but commented out in `main.dart:16`
- **Authentication**: Uses Bearer token stored in `SharedPreferences`, handled automatically by `ApiService._getHeaders()`
- **API Base URLs**: Inconsistency between `ApiService` (127.0.0.1:8000) and unused `AuthService` (api.sq4rapp.com)
- **Media support**: PDF (`flutter_pdfview`), video (`video_player`, `chewie`), audio (`audioplayers`), images
- **Local storage**: `shared_preferences` for token persistence and user data
- **Asset structure**: Organized in thematic folders (`/images/`, `/icons/`, `/sounds/`, `/pdf/`, `/fonts/`)
- **Sound feedback**: Complete audio system with 4 sounds (correct.mp3, wrong.mp3, complete.mp3, select.mp3)
- **Multi-platform**: Configured for iOS, Android, macOS, web, Linux, Windows
- **Git status**: README.md contains unresolved merge conflicts indicating active development

## Development Patterns

### Error Handling
- Use `ApiResponse<T>` wrapper for all API calls with `success`, `data`, and `error` fields
- Exception handling in services throws descriptive messages for UI consumption
- Route errors handled by `RouteGenerator._errorRoute()` with user-friendly error screen

### State Management Flow
1. **Data fetching**: Services → API calls → Models
2. **State updates**: Services → Providers → UI rebuilds via `ChangeNotifier`
3. **Navigation**: Providers trigger route changes → `RouteGenerator` handles routing
4. **Persistence**: Critical data stored via `SharedPreferences` in services

### Asset Management
- **Fonts**: Poppins family with weights (Regular: 400, Medium: 500, SemiBold: 600, Bold: 700)
- **Audio**: UI feedback sounds in `/assets/sounds/` (correct.mp3, wrong.mp3, complete.mp3, select.mp3)
- **Media**: PDFs for reading materials, support for video content via Chewie player

### Code Organization
- **Screens**: Feature-based screens (20+ screens) with consistent Material Design patterns
- **Models**: Mirror backend API structure with `fromJson()` factory constructors
- **Services**: Centralized business logic with dependency injection via Provider
- **Constants**: Centralized styling (`AppColors`, `AppStyles`) for consistent UI theming

## Testing and Quality

- **Test Structure**: Minimal widget tests in `test/widget_test.dart` with basic app smoke testing
- **Code Quality**: Uses `flutter_lints` package for consistent code standards  
- **Analysis**: Run `flutter analyze` to check for issues before committing changes
- **No CI/CD**: No automated testing or deployment pipelines configured