# Real Time Weather App

A beautiful Flutter weather application that shows real-time temperature, hourly forecast, and 7-day forecast using the Open-Meteo API. The app includes a modern glassmorphism UI, location search, smooth animation, and reusable widgets.

## 📱 Project Overview

This project is a real-time weather app built with Flutter. Users can search for any city or country, select a location from suggestions, and view current weather information based on that location.

The app initially loads weather data for **Chattogram, Bangladesh** and allows the user to refresh or search for a new location.



## ✨ Features

- Real-time current temperature display
- Search city or country using location suggestions
- Open-Meteo Geocoding API integration
- Open-Meteo Weather Forecast API integration
- 7-day weather forecast
- Hourly forecast section
- Tap on any day from the 7-day forecast to show that day's temperature in the main card
- Pull-to-refresh support
- Error handling with retry button
- Loading indicator while fetching data
- Modern glassmorphism UI
- Gradient background
- Animated weather hero card
- Reusable Flutter widgets
- Weather condition icons using emoji
- Clean model and service-based structure

## 🛠️ Technologies Used

- Flutter
- Dart
- HTTP package
- Intl package
- Open-Meteo Weather API
- Open-Meteo Geocoding API
- Material 3

## 📦 Packages Used

Add these dependencies in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  intl: ^0.19.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/real-time-weather-app.git
```

### 2. Go to the Project Folder

```bash
cd real-time-weather-app
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

## 🌐 API Information

This project uses free APIs from Open-Meteo.

### Weather Forecast API

Used to fetch:

- Current temperature
- Humidity
- Wind speed
- Precipitation
- Weather code
- Hourly forecast
- Daily forecast

API endpoint:

```text
https://api.open-meteo.com/v1/forecast
```

### Geocoding API

Used to search city/country suggestions.

API endpoint:

```text
https://geocoding-api.open-meteo.com/v1/search
```

No API key is required.

## 📂 Code Structure

The current project is written mainly inside `lib/main.dart`.

Recommended structure for future improvement:

```text
lib/
├── main.dart
├── models/
│   ├── weather_report.dart
│   ├── current_weather.dart
│   ├── hourly_weather.dart
│   ├── daily_weather.dart
│   └── location_result.dart
├── services/
│   └── weather_service.dart
├── widgets/
│   ├── weather_top_bar.dart
│   ├── weather_search_bar.dart
│   ├── weather_hero_card.dart
│   ├── hourly_forecast_card.dart
│   ├── daily_forecast_tile.dart
│   ├── glass_card.dart
│   ├── section_header.dart
│   └── weather_info_item.dart
└── utils/
    └── weather_code_mapper.dart
```

## 🧩 Main Components

### `WeatherApp`

The root widget of the application. It sets the app theme, disables the debug banner, and loads the home page.

### `WeatherHomePage`

The main screen of the app. It manages:

- Current latitude and longitude
- Selected city name
- Location search suggestions
- Selected daily forecast index
- Weather data loading
- Refreshing weather data

### `WeatherService`

Handles all API-related tasks:

- Searching locations
- Fetching weather data
- Decoding JSON response

### `WeatherReport`

Main weather model that contains:

- Current weather
- Hourly weather list
- Daily weather list

### `WeatherHeroCard`

Displays the main weather information, including:

- Weather icon
- Temperature
- Weather condition
- Date
- Wind speed
- Humidity
- Rain/precipitation information

### `DailyForecastTile`

Displays each day from the 7-day forecast. When a user taps on a day, the main weather card updates with that day's temperature and condition.

### `HourlyForecastCard`

Displays hourly temperature and weather icon in a horizontal scrollable list.

### `GlassCard`

A reusable card widget used to create the glassmorphism-style UI across the app.

## 🎯 How the App Works

1. The app starts with default coordinates for Chattogram.
2. `WeatherService.fetchWeather()` fetches current, hourly, and daily weather data.
3. The data is converted into Dart model classes.
4. The UI displays the current weather in the hero card.
5. The user can search for a new location.
6. Location suggestions are fetched from the geocoding API.
7. When a location is selected, the app updates latitude, longitude, city name, and reloads weather data.
8. The user can tap any day from the 7-day forecast.
9. The selected day's temperature and condition are shown in the main card.

## 🖼️ UI Highlights

- Dark gradient background
- Blue gradient weather card
- Rounded glass cards
- Smooth hero card animation
- Horizontal hourly forecast list
- Tap-selectable 7-day forecast list
- Clean and mobile-friendly layout

## ⚠️ Important Notes

- Internet connection is required.
- No API key is needed.
- The app currently uses emoji-based weather icons.
- The whole project is currently inside `main.dart`, but it can be refactored into separate files for better maintainability.

## ✅ Possible Improvements

- Add GPS-based current location detection
- Add sunrise and sunset time
- Add feels-like temperature
- Add dark/light mode toggle
- Add weather background animation
- Add local storage for last searched city
- Add debounce for search input
- Separate models, services, and widgets into different files
- Add unit tests for API service and models
- Add shimmer loading effect
- Add app launcher icon and splash screen

## 🧠 Learning Outcomes

By building this project, you will learn:

- How to work with REST APIs in Flutter
- How to parse JSON data
- How to build reusable widgets
- How to manage state with `StatefulWidget`
- How to use `FutureBuilder`
- How to handle loading and error states
- How to create modern UI using gradients, rounded cards, and animations
- How to build a location-based search feature

## 📸 Screenshots

<img width="400" height="800" alt="Screenshot_20260602-003829_weather~2" src="https://github.com/user-attachments/assets/5f814df3-fd83-4c7e-9331-2a4cf1149484" />


<img width="400" height="800" alt="Screenshot_20260602-003855_weather~2" src="https://github.com/user-attachments/assets/566b078b-d8b8-487c-9d5d-12d3f16f068e" />

## 👨‍💻 Author

Developed by **Arnob**

## 📄 License

This project is open-source.
