# Bible App

A feature-rich, cross-platform Bible application built with Flutter, designed for a fast and customizable reading experience.

## Features

- **Multiple Versions:** Includes support for various Bible versions such as KJV, ESV, CPDV, NVLG, and more.
- **Offline First:** Powered by Isar Database for fast, offline access to scripture.
- **Customizable Reading Experience:**
    - Choose from a wide variety of fonts (OpenSans, Roboto, Montserrat, etc.).
    - Adjustable font size and styles (Italic support).
    - Light and Dark mode support with persistent settings.
- **Advanced Navigation:** Easily jump between versions, chapters, and verses.
- **Search:** Quickly find specific verses or keywords across the Bible.
- **Cross-Platform:** Support for Android, Linux, and Windows.
- **State Management:** Robust state handling using `flutter_bloc` and persistent storage with `hydrated_bloc`.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10.3 or higher)
- [Dart SDK](https://dart.dev/get-started)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/bible.git
    cd bible
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Generate Isar schemas:**
    ```bash
    flutter pub run build_runner build
    ```

4.  **Run the application:**
    ```bash
    flutter run
    ```

## Project Structure

- `lib/bloc/`: Contains Bloc classes for state management (Theme, Font, Version, etc.).
- `lib/collections/`: Isar database schemas for Bible data, Cache, and Book lists.
- `lib/main/`: Main reading interface and navigation.
- `assets/`: Bible data in JSON format and custom font files.

## Dependencies

- [isar](https://isar.dev/): Ultra-fast cross-platform database.
- [flutter_bloc](https://bloclibrary.dev/): For predictable state management.
- [hydrated_bloc](https://pub.dev/packages/hydrated_bloc): Persistent state across app restarts.
- [share_plus](https://pub.dev/packages/share_plus): For sharing verses.
- [scrollable_positioned_list](https://pub.dev/packages/scrollable_positioned_list): For precise scrolling to specific verses.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

---

Developed with ❤️ using Flutter.
