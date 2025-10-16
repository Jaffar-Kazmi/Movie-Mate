# Movie Watchlist App

A comprehensive Flutter application for discovering movies and managing personal watchlists, developed as a mid-semester project for Mobile Application Development course at Riphah International University.

## Project Overview

This Flutter application provides users with the ability to search for movies, view detailed information, and maintain a personal watchlist. The app integrates with the OMDb API to fetch real-time movie data and uses local storage for persistent watchlist management.

## Features

### Core Functionality
- **Movie Search**: Real-time movie search using OMDb API integration
- **Movie Details**: Comprehensive movie information including plot, cast, ratings, and release information
- **Watchlist Management**: Add and remove movies from personal watchlist with local persistence
- **Offline Storage**: Watchlist data persists across app sessions using SharedPreferences
- **Responsive Design**: Adaptive layout supporting both grid and list views

### User Interface
- **Dark Theme**: Modern dark mode interface with purple and pink accent colors
- **Smooth Animations**: Staggered animations, fade transitions, and interactive feedback
- **Bottom Navigation**: Three-tab navigation system (Home, Search, Watchlist)
- **Pull-to-Refresh**: Refresh functionality for updating movie data
- **Error Handling**: User-friendly error messages and retry mechanisms

### Technical Features
- **API Integration**: RESTful API calls with proper error handling
- **State Management**: Efficient state management using StatefulWidget
- **Image Caching**: Network image caching for improved performance
- **Local Storage**: Persistent data storage using SharedPreferences
- **Clean Architecture**: Organized code structure with separation of concerns

## Technical Stack

### Framework and Language
- **Flutter SDK**: Cross-platform mobile development framework
- **Dart**: Programming language
- **Material Design**: UI/UX design system

### External APIs
- **OMDb API**: Online Movie Database for movie information

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── theme/
│   └── app_theme.dart          # Application theme and styling
├── models/
│   └── movie.dart              # Data models for movie objects
├── services/
│   ├── api_service.dart        # OMDb API integration
│   └── storage_service.dart    # Local storage management
├── screens/
│   ├── home_screen.dart        # Home screen with trending movies  
│   ├── search_screen.dart      # Movie search functionality
│   ├── watchlist_screen.dart   # Personal watchlist display
│   └── movie_detail_screen.dart # Detailed movie information
└── widgets/
    ├── movie_card.dart         # Reusable movie card component
    └── animated_movie_grid.dart # Animated grid/list layout
```

## Installation and Setup

### Prerequisites
- Flutter SDK (version 3.0.0 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extension
- Android Emulator or physical device

### Setup Instructions

1. **Clone or Download Project**
   ```bash
   git clone https://github.com/Jaffar-Kazmi/Movie-Mate.git
   cd Movie-Mate
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **API Configuration**
    - Visit [OMDb API](http://www.omdbapi.com/apikey.aspx)
    - Register for a free API key
    - Create **.env** file in your project root folder
      ```
      // .env
      OMDB_API_KEY=your_api_key
      ```
    - Replace `your_api_key` with your actual API key

4. **Run Application**
   ```bash
   flutter run
   ```

## Architecture and Design Patterns

### Clean Architecture
The application follows clean architecture principles with clear separation of concerns:

- **Models**: Data structures and API response models
- **Services**: Business logic and external API communication
- **Widgets**: Reusable UI components
- **Screens**: Main application screens and navigation
- **Theme**: Centralized styling and theming

### API Integration
- RESTful API communication using HTTP package
- JSON serialization and deserialization
- Error handling with user feedback
- Network image caching for performance

## Key Learning Outcomes

This project demonstrates proficiency in:

1. **Flutter Development**: Cross-platform mobile app development
2. **API Integration**: RESTful API consumption and data handling
3. **State Management**: Managing application state across components
4. **Local Storage**: Persistent data storage implementation
5. **UI/UX Design**: Modern mobile interface design principles
6. **Animation**: Implementing smooth transitions and interactions
7. **Error Handling**: Robust error management and user feedback
8. **Code Organization**: Clean, maintainable code structure

## Usage Guide

### Home Screen
- Browse trending movies automatically loaded on startup
- Pull down to refresh movie list
- Tap movie cards to view detailed information
- Use heart icon to add/remove from watchlist

### Search Screen
- Enter movie titles in search bar
- Use quick search suggestions for popular searches
- Toggle between grid and list view layouts
- View animated search results

### Watchlist Screen
- View all saved movies in organized layout
- Remove movies using heart icon or menu options
- Clear entire watchlist with confirmation dialog
- Navigate to other screens when watchlist is empty

### Movie Details
- View comprehensive movie information
- See high-resolution movie posters
- Read plot summaries and cast information
- Manage watchlist status with single tap

## API Configuration Details

The application uses OMDb API (Online Movie Database) for movie data:

- **Base URL**: `https://www.omdbapi.com/`
- **Rate Limit**: 1000 requests per day (free tier)
- **Response Format**: JSON
- **Required Parameters**: API key, search query or IMDb ID

Example API endpoints:
- Search: `/?apikey=KEY&s=batman&type=movie`
- Details: `/?apikey=KEY&i=tt0372784&plot=full`

## License

This project is developed for academic purposes as part of coursework at Riphah International University.
