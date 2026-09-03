# vagoflax

App for HES-SO students to find a job easily. You can be either an employer or a student. Employers create job offers, where students can apply.

Made for the Mobile Development Summer School (208.1).

---

## Table of contents

1.  [App images](#app-images)
2.  [What the app does](#what-the-app-does)
3.  [Tech stack](#tech-stack)
4.  [Architecture overview](#architecture-overview)
5.  [Project structure](#project-structure)
6.  [How the layers work together](#how-the-layers-work-together)
7.  [State management with Provider](#state-management-with-provider)
8.  [Data models & Firestore structure](#data-models--firestore-structure)
9.  [Getting Started](#getting-started)
10. [Run tests](#run-tests)
11. [Database mock data](#database-mock-data)
12. [Repo policy](#repo-policy)
13. [Face recognition](#face-recognition)
14. [Salary prediction](#salary-prediction)

---

## App images

<p align="center">
  <img src="assets/readme/app_overview.png" alt="Welcome page" width="1000">
  <br>
  For more see <a href="assets/readme/usermanual.pdf">user manual</a>.
</p>

---

## What the app does

- **Authentication**: register and log in with email + password using **Firebase Auth**. Users can also link their face with their account to skip writing their email on login.
- **Jobs**: employers create job listings with specific information.
- **Applications**: students apply to jobs, and employers change the application status (submitted, evaluated, accepted, rejected).
- **AI translation**: students can translate job offers using AI.
- **User reviews and ratings**: rating and review system for users of the app.
- **Salary prediction**: a locally embedded machine learning model estimates the salary of a job offer from its characteristics.

---

## Tech stack

| Concern | Technology |
| --- | --- |
| UI framework | Flutter (Material) |
| State management | `provider` (`ChangeNotifier`) |
| Authentication | `firebase_auth` |
| Database | `cloud_firestore` (real-time) |
| Image hosting | Cloudinary (via `http` upload) |
| Image picking | `image_picker` |
| Transport info | [Transport API](https://transport.opendata.ch/) |
| Translation AI | [Ollama Gemma4](https://docs.ollama.com/api/introduction) |
| Salary prediction | PyTorch + LiteRT / TFLite |
| On-device ML inference | `flutter_litert` |
| Configuration | `flutter_dotenv` (`.env` file) |
| Tests | `flutter_test` + hand-written fakes |

---

## Architecture overview

The app uses a **layered architecture**. Each layer has a single
responsibility and only talks to the layer directly below it. The UI never
talks to Firebase or Cloudinary directly.

```text
┌───────────────────────────────────────┐
│  Views & Widgets (UI)                 │  what the user sees
│  login, applications, profile, etc.   │
└───────────────┬───────────────────────┘
                │ reads state / calls methods
┌───────────────▼───────────────────────────────┐
│  Providers (state management)                 │  app logic + UI state
│  AppState, JobProvider, UserProvider, ...     │
└───────────────┬───────────────────────────────┘
                │ depends on interfaces / services
┌───────────────▼────────────────────────────────┐
│  Repositories & Services (abstractions)        │  data access / computation
│  UserRepository, JobRepository,                │
│  ApplicationRepository, SalaryPrediction       │
└───────────────┬────────────────────────────────┘
                │ implemented by
┌───────────────▼────────────────────────────────┐
│  Concrete implementations                      │  the real integrations
│  FirestoreJobRepository, FirebaseAuthService,  │
│  FirestoreApplicationRepository, LiteRT        │
└───────────────┬────────────────────────────────┘
                │
┌───────────────▼────────────────────────────────────────────┐
│ External/local services: Firebase, Cloudinary, Ollama, ML │
└────────────────────────────────────────────────────────────┘
```

---

## Project structure

```text
vagoflax/
├── .github                  # CI/CD workflows
├── .env.example             # Template for local .env
├── Makefile                 # Shortcuts for flutter commands
├── prediction_models        # Python project: salary prediction training and export
│   ├── comparison           # Comparison between trained models
│   ├── data                 # Salary dataset
│   ├── gradient_boosting_model
│   ├── NN_model             # Neural network training
│   ├── regression_model
│   ├── encoding.py          # Categorical and multi-label encoding
│   ├── preprocessing.py     # Dataset preprocessing
│   ├── export.py            # LiteRT/TFLite and preprocessing export
│   └── main.py              # Training pipeline
├── README.md                # Technical guide
├── analysis_options.yaml    # Dart/Flutter linter rules
├── android                  # Android support
├── assets                   # Icon, ML models, README resources
│   └── ml
│       ├── model.tflite
│       └── preprocessing.json
├── firestore.rules          # Firestore security rules
├── ios                      # IOS support
├── lib/
│   ├── main.dart
│   ├── models
│   │   ├── connection.dart
│   │   ├── enum
│   │   │   ├── diplomas.dart
│   │   │   ├── favorite_choice.dart
│   │   │   ├── industry.dart
│   │   │   ├── languages.dart
│   │   │   ├── perks.dart
│   │   │   ├── role.dart
│   │   │   ├── status.dart
│   │   │   └── user_role.dart
│   │   ├── face_entry.dart
│   │   ├── history.dart
│   │   ├── job.dart
│   │   ├── job_application.dart
│   │   ├── job_filters.dart
│   │   ├── review.dart
│   │   ├── salary_prediction_model.dart
│   │   ├── section.dart
│   │   ├── translation.dart
│   │   └── user.dart
│   ├── providers
│   │   ├── application.dart
│   │   ├── auth.dart
│   │   ├── job.dart
│   │   └── user.dart
│   ├── repositories         # DB Interfaces
│   │   ├── application.dart
│   │   ├── firestore_application.dart
│   │   ├── firestore_job.dart
│   │   ├── firestore_user.dart
│   │   ├── job.dart
│   │   └── user.dart
│   ├── services             # Third-party APIs, computation
│   │   ├── address.dart
│   │   ├── cloudinary.dart
│   │   ├── face.dart
│   │   ├── ollama.dart
│   │   ├── salary_prediction.dart
│   │   ├── salary_preprocessor.dart
│   │   └── transport.dart
│   ├── utils                # Constants, themes, routes, utilities
│   │   ├── date.dart
│   │   ├── firebase_options.dart
│   │   ├── router.dart
│   │   └── theme.dart
│   ├── views                # Screens
│   │   ├── about_us.dart
│   │   ├── admin.dart
│   │   ├── auth
│   │   │   ├── auth_gate.dart
│   │   │   ├── login
│   │   │   │   └── login.dart
│   │   │   ├── signup
│   │   │   │   ├── emailpw.dart
│   │   │   │   ├── employer.dart
│   │   │   │   ├── face_recognition.dart
│   │   │   │   ├── student.dart
│   │   │   │   └── type.dart
│   │   │   └── welcome.dart
│   │   ├── employer
│   │   │   ├── add_job.dart
│   │   │   ├── job_applications.dart
│   │   │   └── job_offer.dart
│   │   ├── job
│   │   │   └── details.dart
│   │   ├── loading.dart
│   │   ├── profile.dart
│   │   └── student
│   │       ├── applications.dart
│   │       ├── gate.dart
│   │       └── search.dart
│   └── widgets              # Reusable UI components
│       ├── about_icon.dart
│       ├── app_icon.dart
│       ├── application_status_dialog.dart
│       ├── job
│       │   ├── application_student_item.dart
│       │   ├── employer_item.dart
│       │   ├── filter_drawer.dart
│       │   ├── form.dart
│       │   └── student_item.dart
│       ├── leave_review_sheet.dart
│       ├── logout_button.dart
│       ├── profile_button.dart
│       ├── profile_edit_form.dart
│       ├── search_filter.dart
│       ├── status_pill.dart
│       ├── user_item.dart
│       └── user_rating_badge.dart
├── linux                    # Linux desktop support
├── macos                    # macOS desktop support
├── mock_data                # Node project: scripts for Firestore mock data
├── pubspec.yaml             # Dependencies
├── test                     # Unit & widget tests
├── web                      # Web support
└── windows                  # Windows desktop support
```

---

## How the layers work together

A concrete example: **browsing and applying to job offers in real time.**

1. `JobListScreen` (or `JobDetails`) reads `JobProvider` via `context.watch<JobProvider>()`.
2. `JobProvider` listens to `JobRepository.watchJobs()` (or fetches updates from Firestore).
3. `FirestoreJobRepository` queries the `jobs` collection via Firestore `.snapshots()`, mapping documents to `Job` models.
4. Whenever an employer creates a job, toggles visibility, or updates details in Firestore, the stream emits a new `List<Job>`.
5. `JobProvider` updates its internal state and calls `notifyListeners()`.
6. The UI rebuilds automatically to display the updated listings.

When an AI translation is requested or an application is submitted:

- The UI triggers `OllamaService.translate()` or `ApplicationProvider.applyToJob()`.
- The repository persists the new translation or application status in Firestore.
- Changes flow back through the providers, ensuring real-time consistency across all screens without manual state synchronization.

For salary prediction, the flow is local:

1. Job and employer data are converted to a `SalaryPredictionInput`.
2. `SalaryPreprocessor` reproduces the preprocessing used during Python training.
3. `SalaryPredictionService` sends the resulting feature vector to the embedded LiteRT/TFLite neural network.
4. The normalized output is converted back to CHF.
5. The predicted full-time salary is multiplied by the job workload percentage.
6. The resulting salary can be stored in `Job.predictedSalary`.

No network request is required for salary inference.

---

## State management with Provider

This project uses the **`provider`** package. The two key objects are
`ChangeNotifier`s registered in `main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => UserProvider(FirestoreUserRepository()),
    ),
    ChangeNotifierProxyProvider<UserProvider, ApplicationState>(
      create: (context) =>
          ApplicationState(userProvider: context.read<UserProvider>()),
      update: (_, userProvider, previousState) =>
          (previousState ?? ApplicationState(userProvider: userProvider))
            ..updateUserProvider(userProvider),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          ApplicationProvider(FirestoreApplicationRepository()),
    ),
    ChangeNotifierProvider(
      create: (_) => JobProvider(
        FirestoreJobRepository(
          applicationRepository: FirestoreApplicationRepository(),
        ),
      ),
    ),
  ],
  ...
)
```

- **`ChangeNotifierProvider`** exposes a `ChangeNotifier` to the widget tree.
  When it calls `notifyListeners()`, listening widgets rebuild.
- **`ChangeNotifierProxyProvider`** is used because `ApplicationState` *depends on*
  `UserProvider`: it needs the current user's id for signup step 2.
- **Dependency injection**: the providers receive their data sources through
  their constructors (`UserProvider(FirestoreUserRepository())`,
  `ApplicationProvider(FirestoreApplicationRepository())`,
  `JobProvider(FirestoreJobRepository(...))`). This is what makes them testable.

In widgets you typically:

```dart
final jobs = context.watch<JobProvider>().jobs;
context.read<JobProvider>().deleteJob(jobId);
```

---

## Data models & Firestore structure

You can see all data models in the `lib/models/` folder.

In Firestore we have three distinct collections:

### users

When signing up, a row for user data is created in `Authentication`. The row's ID is saved and reused for the user collection in `Firestore`.

`users/$id`

Users can be either students, employers or `admin`. The Firestore fields change slightly depending on the role.

Role: `student`

```text
firstName           string
lastName            string
email               string
role                UserRole        // enum
description         string
address             string
canton              string
profilePictureUrl   string?
skills              string[]
history             HistoryEntry[]  // see models
reviews             Review[]        // see models
savedSearches       string[]        // your bookmarked searches
favoriteJobs        string[]        // array of the ids of favorite jobs
createdAt           timestamp
```

Role: `employer`

```text
companyName         string
email               string
role                UserRole        // enum
description         string
canton              string
address             string
profilePictureUrl   string?
companySize         int
reviews             Review[]        // see models
createdAt           timestamp
```

Role: `admin`

```text
email       string
role        UserRole  // enum
createdAt   timestamp
```

### jobs

Jobs can only be posted by an employer.

`jobs/$jobId`

```text
userUuid            string
title               string
description         string?
diploma             Diplomas         // enum
contractTime        int?
minYearsExperience  int?
maxYearsExperience  int?
role                Role              // enum
industry            Industry          // enum
perks               Perks[]           // enum
languages           Languages[]       // enum
holidays            int?
maternityLeave      int?
paternityLeave      int?
workloadPercent     int?
salary              double?
predictedSalary     double?
visible             bool
translations        JobTranslation[]  // see models
createdAt           timestamp
```

### applications

Applications can only be submitted by a student and reviewed by the employer owning the related job.

`applications/$jobId_$studentId`

```text
jobId               string
studentUuid         string
status              string        // e.g. 'submitted', 'reviewing', 'accepted', 'rejected'
lastUpdated         timestamp
createdAt           timestamp
```

Access is restricted by `firestore.rules`.

### Models

#### Review

Used in `users/$id` -> `reviews[]`

```text
authorId            string
rating              double
comment             string
createdAt           timestamp
```

#### HistoryEntry

Used in `users/$id` -> `history[]`

```text
title               string
organization        string
startDate           string
endDate             string?
```

#### JobTranslation

Used in `jobs/$id` -> `translations[]`

```text
title               string
description         string
language            Languages         // enum
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- An editor (VS Code or Android Studio) with the Flutter plugin
- A device or emulator
- A **Firebase** project
- A free **Cloudinary** account (for image uploads)
- A free **Ollama** account (for AI translation)

### Clone the repo

```bash
git clone https://github.com/val-mon/vagoflax
cd vagoflax
```

### Install dependencies

```bash
flutter pub get
```

### Firebase configuration

- Install [Firebase CLI](https://firebase.google.com/docs/cli) on your computer.
- Log in to your Google account via the terminal:

```bash
firebase login
```

- Install the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

- Generate the needed files for **Android, iOS, Windows and macOS**:

```bash
flutterfire configure
```

Then, in the Firebase console:

- enable **Authentication → Email/Password**
- create a **Cloud Firestore** database
- deploy the security rules:

```bash
firebase deploy --only firestore:rules
```

### Environment variables configuration

Create a `.env` file at the root of your project following the structure of `.env.example`.

```text
CLOUDINARY_APIKEY=your_cloudinary_api_key
CLOUDINARY_APISECRET=your_cloudinary_api_secret
CLOUDINARY_CLOUDNAME=cloudinary_cloud_name
OLLAMA_APIKEY=ollama_api_key
```

For the translation to work, you must put your Ollama API key in the `.env` file. The app does requests to the official Ollama servers and doesn't run the LLM locally.

### Run the app

```bash
make run
```

---

## Run tests

```bash
flutter test
```

---

## Database mock data

You can setup your Firebase with mock data by using the `make mock_data` script. It requires the `serviceAccountKey.json` that you can acquire in the Firebase console.

---

## Repo policy

### Branches

`main`: The main branch containing the releases.  
`dev (default)`: The development branch that will be merged into main when a release is created.

#### Working branches

One branch per task that will be merged into `dev` when the task is over.

- `feat/...` - new feature
- `fix/...` - fix a bug
- `chore/...` - config, setup, ...
- `test/...` - new tests
- `docs/...` - documentation
- `refactor/...` - refactoring the code

### Commits

Commit format:

```text
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

---

## Face Recognition

### When it's used

- **Sign up**: the user takes a photo, its face signature is stored with their account.
- **Log in**: an optional "Find my account with my face" button takes a photo, matches it against known signatures, and pre-fills the email field. The password is still required.

### Setup

1. Add the model to `assets/model/mobile_face_net.tflite`.
2. Dependencies: `google_mlkit_face_detection`, `flutter_litert`, `image`.
3. Camera and gallery permissions must be granted (handled via `image_picker`).

### Pipeline

1. **Detect** the face in the photo with ML Kit (fails if 0 or 2+ faces).
2. **Preprocess**: crop around the face, fix rotation using the roll angle, resize to 112×112.
3. **Embed**: run the crop through MobileFaceNet (TFLite) → 192-value vector.
4. **Normalize**: L2-normalize the vector so distances are comparable.
5. **Compare** (login only): compute the Euclidean distance to every known signature; the closest one under a threshold (`0.95`) is considered a match.

---

## Salary prediction

### Purpose

The application includes an on-device machine learning model that estimates the salary associated with a job offer.

The model is trained separately in Python and exported to LiteRT/TFLite. Flutter does not retrain the model: it only reproduces the preprocessing pipeline and performs inference locally.

The salary model predicts a **full-time equivalent salary (100% workload)**. The workload percentage is deliberately excluded from the neural network inputs. Once the full-time salary has been predicted, the application converts it to the salary corresponding to the job's actual workload.

For example:

```text
Predicted full-time salary: 100,000 CHF
Job workload:                60 %

Final predicted salary:
100,000 × 0.60 = 60,000 CHF
```

### Training pipeline

The salary prediction project is located in:

```text
prediction_models/
```

The dataset is first preprocessed and encoded before being split into:

```text
70 % training
15 % validation
15 % testing
```

The validation set is used for model selection and training decisions. The test set remains separate until the final evaluation.

Three regression approaches are compared:

1. **Linear Regression**
2. **Gradient Boosting**
3. **Neural Network**

Their performance is evaluated using:

- **MAE** — Mean Absolute Error
- **RMSE** — Root Mean Squared Error
- **R²** — coefficient of determination

The final embedded model is the neural network.

### Salary target

The original dataset contains the salary associated with the workload of each job offer.

Before training, this salary is converted to a full-time equivalent:

```text
FullTimeSalaryCHF = SalaryCHF / (WorkloadPercent / 100)
```

The model therefore learns to estimate the salary value of the position independently of the percentage of employment.

`WorkloadPercent` is retained separately so it can be used for evaluation and by the Flutter application, but it is not provided as an input feature to the neural network.

### Model inputs

The model uses information describing the job and employer, including:

```text
MinYearsExperience
Contract
Holidays
IsPermanent
Diploma
Role
Industry
Canton
CompanySize
Perks
Languages
```

The categorical features are encoded before training.

Single-value nominal features such as diploma, role, industry, canton and company size are represented using one-hot encoding.

Multi-value features such as perks and languages are represented using multi-hot encoding.

Continuous numerical values are standardized using statistics learned from the training set.

### Neural network

The final salary model is implemented in PyTorch.

Its architecture is:

```text
Input
  │
  ▼
Linear(input_size → 64)
  │
ReLU
  │
Linear(64 → 32)
  │
ReLU
  │
Linear(32 → 1)
  │
  ▼
Normalized full-time salary
```

The model is trained using the Adam optimizer and mean squared error loss.

Early stopping on the validation set is used to determine an appropriate number of training epochs.

Once the epoch is selected, a fresh model is trained using the combined training and validation data before final evaluation on the untouched test set.

### Preprocessing export

The neural network alone is not sufficient for inference. Flutter must reproduce exactly the same transformation that was applied to the training data.

The Python export therefore generates two files:

```text
assets/ml/model.tflite
assets/ml/preprocessing.json
```

`model.tflite` contains the neural network.

`preprocessing.json` contains the metadata required to reconstruct its inputs, including:

```text
feature_names
scaled_numeric_columns
binary_columns
one_hot_categories
multi_hot_categories
numeric_means
numeric_stds
target_mean
target_std
```

`feature_names` is particularly important because the input vector in Flutter must use exactly the same feature order as the model used during training.

### Flutter architecture

Salary prediction is split between three Dart components:

```text
SalaryPredictionInput
        │
        ▼
SalaryPreprocessor
        │
        ▼
SalaryPredictionService
        │
        ▼
LiteRT / TFLite model
```

#### `SalaryPredictionInput`

Located in:

```text
lib/models/salary_prediction_model.dart
```

This class converts `Job` and employer information into the vocabulary expected by the machine learning preprocessing pipeline.

It also retains `workloadPercent`.

The workload is intentionally stored here rather than encoded as a model feature because it is applied only after inference.

#### `SalaryPreprocessor`

Located in:

```text
lib/services/salary_preprocessor.dart
```

The preprocessor loads:

```text
assets/ml/preprocessing.json
```

It then:

1. standardizes numerical inputs using the exported training mean and standard deviation;
2. one-hot encodes nominal categorical values;
3. multi-hot encodes list-valued features;
4. handles supported unknown categorical values;
5. constructs the final feature vector in the exact order defined by `feature_names`.

The resulting vector has exactly the input dimension expected by the TFLite model.

`WorkloadPercent` is not included in this vector.

### Salary inference

`SalaryPredictionService` is located in:

```text
lib/services/salary_prediction.dart
```

The service loads the embedded model:

```text
assets/ml/model.tflite
```

Inference follows this pipeline:

```text
Job + Employer
      │
      ▼
SalaryPredictionInput
      │
      ├──────────── workloadPercent
      │
      ▼
SalaryPreprocessor
      │
      ▼
Encoded and normalized features
      │
      ▼
TFLite neural network
      │
      ▼
Normalized full-time salary
      │
      ▼
Inverse target normalization
      │
      ▼
Full-time salary in CHF
      │
      ├── × workloadPercent / 100
      │
      ▼
Final predicted salary in CHF
```

The normalized network output is first converted back to CHF using the target statistics exported during training:

```text
fullTimeSalary =
    normalizedPrediction × targetStd + targetMean
```

The actual workload is then applied:

```text
predictedSalary =
    fullTimeSalary × (workloadPercent / 100)
```

For this reason, `WorkloadPercent` must not be standardized or sent to the neural network.

### On-device inference

Salary prediction runs entirely on the user's device using LiteRT/TFLite.

This has several advantages:

- no salary prediction API is required;
- inference does not depend on network availability;
- no job information needs to be sent to an external prediction service;
- prediction latency is low;
- the model and its preprocessing configuration are versioned with the application.

### Updating the model

When the salary model is retrained, both exported files must be updated together:

```text
model.tflite
preprocessing.json
```

The preprocessing metadata must always correspond to the exact model being deployed.

Using a new `model.tflite` with an old `preprocessing.json`, or the opposite, can change the feature order, scaling statistics or category encoding and therefore produce invalid predictions.

### Tests

The salary prediction implementation includes tests for the three main parts of the inference pipeline:

```text
salary_prediction_model_test.dart
salary_preprocessor_test.dart
salary_prediction_test.dart
```

They verify respectively:

- conversion from application models to the ML input vocabulary;
- construction and ordering of the model feature vector;
- execution of the embedded LiteRT/TFLite model and production of a valid salary prediction.

The complete Flutter test suite can be executed with:

```bash
flutter test
```