# vagoflax

App for HES-SO students to find a job easily.

## App images

[tbd]

## Getting Started

```bash
git clone https://github.com/val-mon/vagoflax
cd vagoflax
flutter pub get
flutter run
```

## Tech stack
Flutter 3.47.1 (stable)
Firebase CLI 15.28.1
Fireflutter 1.4.1
Java 25.0.2
Gradle 9.3.1

## Project structure
```
lib/
├── main.dart                   # App entry point
├── models/                     # Data models (e.g., Job, User)
│   └── job_model.dart
├── providers/                  # Flutter interfaces / states
│   └── job_provider.dart
├── repositories/               # DB Interfaces
│   ├── fake_job_repository.dart
│   ├── firestore_job_repository.dart
│   └── job_repository.dart
├── services/                   # Firebase calls, API, authentication
├── utils/                      # Constants, themes, routes, utilities
│   ├── theme.dart
│   └── firebase_options.dart
├── views/                      # Screens (e.g., HomePage, LoginView)
│   ├── home_screen.dart
│   └── job_screen.dart
└── widgets/                    # Reusable UI components
    └── job_item.dart
```

## Repo policy

### Branches
` main ` : The main branch containing the releases\
` dev (default) ` : The development branch that will be merge into main when a release is created \


#### Working branches
One branch per task that will be merge into dev when the task is over
- `feat/...` - new feature
- `fix/...` - fix a bug
- `chore/...` - config, setup, ...
- `test/...` - new tests
- `docs/...` - documentation
- `refactor/...` - refactoring the code

### Commits
Commit format: 
``` md
TYPE (SCOPE): Description

example:
feat (HomePage): Add login button
```
#### Types
- `feat:` - new feature
- `fix:` - fix a bug
- `chore:` - config, setup, ...
- `test:` - new test
- `docs:` - documentation
- `refactor:` - refactoring the code

## Firebase configuration

- Install [Firebase CLI](https://firebase.google.com/docs/cli) on your computer
- Log in to your Google account via the terminal:
```bash
firebase login
```
- Install the Flutterfire CLI
```
bash
dart pub global activate flutterfire_cli
```
- Generate the needed files for **android, ios, windows and macos** :
```bash
flutterfire configure
```