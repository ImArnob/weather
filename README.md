# 🌦️ Real-Time Weather App

A modern and beautifully animated Flutter weather application that shows real-time temperature, weather conditions, hourly forecast, and 7-day forecast based on the user’s searched location.

The app is designed with reusable widgets, clean UI structure, smooth animations, and API-based live weather data.

---

## 📱 App Preview

This app is inspired by a modern glassmorphism weather UI design.

Main features include:

- Real-time temperature display
- Search location by city/country
- Location-based weather update
- Weather condition icon
- Hourly forecast
- 7-day forecast
- Clickable daily forecast
- Selected day weather preview
- Smooth UI animations
- Reusable Flutter widgets
- Responsive layout with overflow handling

<img width="400" height="800" alt="Screenshot_20260602-003829_weather~2" src="https://github.com/user-attachments/assets/5f814df3-fd83-4c7e-9331-2a4cf1149484" />


<img width="400" height="800" alt="Screenshot_20260602-003855_weather~2" src="https://github.com/user-attachments/assets/566b078b-d8b8-487c-9d5d-12d3f16f068e" />


## ✨ Features

### 🌍 Location Search

Users can search for any city or country from the search bar.

Example:

```text
Dhaka
Chattogram
Dubai
London
New York
Minsk
```

🌡️ Real-Time Weather

The app shows current weather information including:

Current temperature
Weather condition
Wind speed
Humidity
Rain/precipitation
Current date
🕒 Hourly Forecast

Users can view today’s hourly forecast in a horizontal scrollable list.

Each hourly card shows:

Temperature
Weather icon
Time
📅 7-Day Forecast

The app includes a 7-day forecast section.

Each forecast item shows:

Day name
Weather condition
Weather icon
Maximum temperature
Minimum temperature

Users can tap any day from the 7-day forecast list to preview that day’s temperature and weather condition in the main weather card.

🎨 Modern UI Design

The app uses a dark weather-themed interface with:

Gradient background
Glassmorphism cards
Rounded corners
Soft shadows
Smooth animations
Clean spacing
Mobile-friendly layout
🛠️ Built With
Flutter
Dart
Open-Meteo Weather API
Open-Meteo Geocoding API
HTTP package
Intl package
📦 Packages Used

Add these dependencies inside your pubspec.yaml file:

dependencies:
  flutter:
    sdk: flutter

  http: ^1.2.2
  intl: ^0.19.0

Then run:

flutter pub get
📁 Project Structure

A simple structure for this project:

lib/
│
├── main.dart
│
├── models/
│   ├── weather_report.dart
│   ├── current_weather.dart
│   ├── hourly_weather.dart
│   ├── daily_weather.dart
│   └── location_result.dart
│
├── services/
│   └── weather_service.dart
│
├── widgets/
│   ├── weather_top_bar.dart
│   ├── weather_search_bar.dart
│   ├── weather_hero_card.dart
│   ├── hourly_forecast_card.dart
│   ├── daily_forecast_tile.dart
│   ├── weather_info_item.dart
│   ├── glass_card.dart
│   └── circle_glass_button.dart
│
└── screens/
    └── weather_home_page.dart

For beginners, you can keep everything inside main.dart first. Later, you can separate the code into folders like the structure above.

🚀 Getting Started
1. Clone the repository
git clone https://github.com/your-username/weather-app.git
2. Go to the project folder
cd weather-app
3. Install dependencies
flutter pub get
4. Run the app
flutter run
🌐 API Information

This project uses Open-Meteo APIs.

Weather Forecast API

Used for fetching:

Current temperature
Humidity
Wind speed
Precipitation
Hourly forecast
Daily forecast
Geocoding API

Used for converting city names into latitude and longitude.

Example:

Dhaka -> latitude and longitude -> weather data
🔎 How Location Search Works

When the user types a city name:

The app sends the search text to the geocoding API.
The API returns matching location suggestions.
The user selects a location.
The app gets the selected location’s latitude and longitude.
The weather API loads the temperature and forecast for that location.
🧩 Reusable Widgets

This project uses reusable widgets to keep the code clean and easy to maintain.

Important widgets:

Widget	Purpose
WeatherTopBar	Shows location name and refresh button
WeatherSearchBar	Allows user to search location
WeatherHeroCard	Shows main temperature and condition
HourlyForecastCard	Shows hourly weather data
DailyForecastTile	Shows one day forecast item
GlassCard	Reusable glass-style container
WeatherInfoItem	Shows wind, humidity, and rain info
CircleGlassButton	Reusable circular icon button
🎯 Main Functionalities
Search Location
searchLocations(query);

This method fetches location suggestions based on user input.

Fetch Weather
fetchWeather(latitude: latitude, longitude: longitude);

This method fetches real-time weather data using latitude and longitude.

Select Daily Forecast
selectedDailyIndex = index;

This updates the main weather card when a user taps a day from the 7-day forecast list.

📌 Future Improvements

Possible improvements for this app:

Add GPS-based current location weather
Add city search history
Add favorite locations
Add weather background animation
Add dark/light theme switch
Add loading shimmer effect
Add detailed hourly forecast page
Add sunrise and sunset time
Add air quality index
Add unit switch between Celsius and Fahrenheit
🧑‍💻 Author

Developed by Arnob
