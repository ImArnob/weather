import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Time Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xff07111f),
        useMaterial3: true,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late Future<WeatherReport> weatherFuture;

  final TextEditingController searchController = TextEditingController();

  double latitude = 22.3569;
  double longitude = 91.7832;
  String cityName = 'Chattogram';

  List<LocationResult> locationSuggestions = [];
  bool isSearchingLocation = false;

  int selectedDailyIndex = 0;

  @override
  void initState() {
    super.initState();
    weatherFuture = _loadWeather();
  }

  Future<WeatherReport> _loadWeather() {
    return WeatherService().fetchWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> _refreshWeather() async {
    setState(() {
      selectedDailyIndex = 0;
      weatherFuture = _loadWeather();
    });
  }

  Future<void> _searchLocationSuggestions(String value) async {
    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        locationSuggestions = [];
        isSearchingLocation = false;
      });
      return;
    }

    setState(() {
      isSearchingLocation = true;
    });

    try {
      final results = await WeatherService().searchLocations(query);

      setState(() {
        locationSuggestions = results;
        isSearchingLocation = false;
      });
    } catch (_) {
      setState(() {
        locationSuggestions = [];
        isSearchingLocation = false;
      });
    }
  }

  void _selectLocation(LocationResult location) {
    setState(() {
      latitude = location.latitude;
      longitude = location.longitude;
      cityName = location.name;

      searchController.clear();
      locationSuggestions = [];
      selectedDailyIndex = 0;

      weatherFuture = _loadWeather();
    });

    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<WeatherReport>(
        future: weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const WeatherLoadingView();
          }

          if (snapshot.hasError) {
            return WeatherErrorView(
              message: snapshot.error.toString(),
              onRetry: _refreshWeather,
            );
          }

          final weather = snapshot.data!;

          if (selectedDailyIndex >= weather.daily.length) {
            selectedDailyIndex = 0;
          }

          final selectedDay = weather.daily[selectedDailyIndex];

          return RefreshIndicator(
            onRefresh: _refreshWeather,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff0d1b2f),
                    Color(0xff06111f),
                    Color(0xff020712),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    WeatherTopBar(
                      cityName: cityName,
                      onRefresh: _refreshWeather,
                    ),

                    const SizedBox(height: 18),

                    Column(
                      children: [
                        WeatherSearchBar(
                          controller: searchController,
                          onChanged: _searchLocationSuggestions,
                        ),

                        if (isSearchingLocation)
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),

                        if (locationSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff111c2e),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: locationSuggestions.length,
                              separatorBuilder: (_, _) => Divider(
                                color: Colors.white.withValues(alpha: 0.08),
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final location = locationSuggestions[index];

                                return ListTile(
                                  leading: const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white70,
                                  ),
                                  title: Text(
                                    location.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () => _selectLocation(location),
                                );
                              },
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    WeatherHeroCard(
                      weather: weather,
                      selectedDay: selectedDay,
                    ),

                    const SizedBox(height: 22),

                    SectionHeader(
                      title: 'Today',
                      actionText: '${weather.daily.length} days',
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: min(weather.hourly.length, 8),
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return HourlyForecastCard(
                            item: weather.hourly[index],
                            isSelected: index == 1,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    const SectionHeader(title: '7 Days Forecast'),

                    const SizedBox(height: 12),

                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Column(
                        children: List.generate(weather.daily.length, (index) {
                          final item = weather.daily[index];
                          final isSelected = selectedDailyIndex == index;

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              setState(() {
                                selectedDailyIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: DailyForecastTile(
                                item: item,
                                isSelected: isSelected,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WeatherTopBar extends StatelessWidget {
  final String cityName;
  final VoidCallback onRefresh;

  const WeatherTopBar({
    super.key,
    required this.cityName,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleGlassButton(icon: Icons.grid_view_rounded),

        const SizedBox(width: 12),

        const Icon(
          Icons.location_on_rounded,
          color: Colors.white70,
          size: 20,
        ),

        const SizedBox(width: 4),

        Expanded(
          child: Text(
            cityName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 12),

        CircleGlassButton(
          icon: Icons.refresh_rounded,
          onTap: onRefresh,
        ),
      ],
    );
  }
}

class WeatherSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const WeatherSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search city, country...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.65),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              controller.clear();
              onChanged('');
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class WeatherHeroCard extends StatelessWidget {
  final WeatherReport weather;
  final DailyWeather? selectedDay;

  const WeatherHeroCard({
    super.key,
    required this.weather,
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather.current;

    final bool isDailySelected = selectedDay != null;

    final double displayTemperature = isDailySelected
        ? selectedDay!.maxTemp
        : current.temperature;

    final String displayCondition = isDailySelected
        ? selectedDay!.condition
        : current.condition;

    final String displayDate = isDailySelected
        ? DateFormat('EEEE, d MMMM').format(selectedDay!.date)
        : DateFormat('EEEE, d MMMM').format(DateTime.now());

    final String displayIcon = isDailySelected
        ? selectedDay!.icon
        : current.icon;

    return TweenAnimationBuilder<double>(
      key: ValueKey(displayDate),
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xff29c5ff),
            Color(0xff1089ff),
            Color(0xff2468f2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          children: [
            Text(
              displayIcon,
              style: const TextStyle(fontSize: 88),
            ),

            const SizedBox(height: 12),

            Text(
              '${displayTemperature.round()}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 82,
                height: 0.95,
                fontWeight: FontWeight.w800,
              ),
            ),

            Text(
              displayCondition,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              displayDate,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WeatherInfoItem(
                  icon: Icons.air_rounded,
                  value: '${current.windSpeed.round()} km/h',
                  label: 'Wind',
                ),
                WeatherInfoItem(
                  icon: Icons.water_drop_rounded,
                  value: '${current.humidity.round()}%',
                  label: 'Humidity',
                ),
                WeatherInfoItem(
                  icon: Icons.cloudy_snowing,
                  value: '${current.precipitation.round()}%',
                  label: 'Rain',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class FloatingWeatherIcon extends StatefulWidget {
  const FloatingWeatherIcon({super.key});

  @override
  State<FloatingWeatherIcon> createState() => _FloatingWeatherIconState();
}

class _FloatingWeatherIconState extends State<FloatingWeatherIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> floatingAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    floatingAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatingAnimation.value),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '☁️',
            style: TextStyle(
              fontSize: 112,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 8,
            child: Text('⚡', style: TextStyle(fontSize: 56)),
          ),
        ],
      ),
    );
  }
}

class HourlyForecastCard extends StatelessWidget {
  final HourlyWeather item;
  final bool isSelected;

  const HourlyForecastCard({
    super.key,
    required this.item,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: 82,
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xff15bfff)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xff15bfff).withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${item.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(item.icon, style: const TextStyle(fontSize: 26)),
          Text(
            DateFormat('HH:mm').format(item.time),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyForecastTile extends StatelessWidget {
  final DailyWeather item;
  final bool isSelected;

  const DailyForecastTile({
    super.key,
    required this.item,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              DateFormat('EEE').format(item.date),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Text(
            item.icon,
            style: const TextStyle(fontSize: 24),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              item.condition,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.75),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            '+${item.maxTemp.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(width: 6),

          Text(
            '+${item.minTemp.round()}°',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherInfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const WeatherInfoItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.75), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;

  const SectionHeader({super.key, required this.title, this.actionText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (actionText != null)
          Text(
            actionText!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class CircleGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const CircleGlassButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? Colors.white.withValues(alpha: 0.06) : null,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class WeatherLoadingView extends StatelessWidget {
  const WeatherLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}

class WeatherErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const WeatherErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 44,
              ),
              const SizedBox(height: 12),
              const Text(
                'Weather loading failed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================
// API SERVICE
// =======================

class WeatherService {
  Future<List<LocationResult>> searchLocations(String query) async {
  final uri = Uri.https(
    'geocoding-api.open-meteo.com',
    '/v1/search',
    {
      'name': query,
      'count': '5',
      'language': 'en',
      'format': 'json',
    },
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception('Location search failed');
  }

  final json = jsonDecode(response.body) as Map<String, dynamic>;

  if (json['results'] == null) {
    return [];
  }

  final results = json['results'] as List;

  return results.map((item) {
    final result = item as Map<String, dynamic>;

    final name = result['name'] ?? 'Unknown';
    final country = result['country'] ?? '';
    final admin1 = result['admin1'] ?? '';

    final displayName = [
      name,
      if (admin1.toString().isNotEmpty) admin1,
      if (country.toString().isNotEmpty) country,
    ].join(', ');

    return LocationResult(
      name: displayName,
      latitude: (result['latitude'] as num).toDouble(),
      longitude: (result['longitude'] as num).toDouble(),
    );
  }).toList();
}

  Future<WeatherReport> fetchWeather({

    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,weather_code'
      '&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      '&timezone=auto',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return WeatherReport.fromJson(json);
  }
}

// =======================
// MODELS
// =======================
class LocationResult {
  final String name;
  final double latitude;
  final double longitude;

  LocationResult({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class WeatherReport {
  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  WeatherReport({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherReport.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final hourlyJson = json['hourly'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;

    final hourlyTimes = List<String>.from(hourlyJson['time']);
    final hourlyTemps = List<num>.from(hourlyJson['temperature_2m']);
    final hourlyCodes = List<num>.from(hourlyJson['weather_code']);

    final dailyTimes = List<String>.from(dailyJson['time']);
    final dailyCodes = List<num>.from(dailyJson['weather_code']);
    final dailyMax = List<num>.from(dailyJson['temperature_2m_max']);
    final dailyMin = List<num>.from(dailyJson['temperature_2m_min']);

    return WeatherReport(
      current: CurrentWeather(
        temperature: (currentJson['temperature_2m'] as num).toDouble(),
        humidity: (currentJson['relative_humidity_2m'] as num).toDouble(),
        windSpeed: (currentJson['wind_speed_10m'] as num).toDouble(),
        precipitation: (currentJson['precipitation'] as num).toDouble(),
        weatherCode: currentJson['weather_code'] as int,
      ),
      hourly: List.generate(min(hourlyTimes.length, 24), (index) {
        final code = hourlyCodes[index].toInt();

        return HourlyWeather(
          time: DateTime.parse(hourlyTimes[index]),
          temperature: hourlyTemps[index].toDouble(),
          weatherCode: code,
        );
      }),
      daily: List.generate(min(dailyTimes.length, 7), (index) {
        final code = dailyCodes[index].toInt();

        return DailyWeather(
          date: DateTime.parse(dailyTimes[index]),
          maxTemp: dailyMax[index].toDouble(),
          minTemp: dailyMin[index].toDouble(),
          weatherCode: code,
        );
      }),
    );
  }
}


class CurrentWeather {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double precipitation;
  final int weatherCode;

  CurrentWeather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.weatherCode,
  });

  String get condition => WeatherCodeMapper.condition(weatherCode);
  String get icon => WeatherCodeMapper.icon(weatherCode);
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });

  String get icon => WeatherCodeMapper.icon(weatherCode);
}

class DailyWeather {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });

  String get condition => WeatherCodeMapper.condition(weatherCode);
  String get icon => WeatherCodeMapper.icon(weatherCode);
}

class WeatherCodeMapper {
  static String condition(int code) {
    if (code == 0) return 'Clear Sky';
    if ([1, 2, 3].contains(code)) return 'Cloudy';
    if ([45, 48].contains(code)) return 'Fog';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Drizzle';
    if ([61, 63, 65, 66, 67].contains(code)) return 'Rainy';
    if ([71, 73, 75, 77].contains(code)) return 'Snow';
    if ([80, 81, 82].contains(code)) return 'Rain Shower';
    if ([95, 96, 99].contains(code)) return 'Thunderstorm';
    return 'Unknown';
  }

  static String icon(int code) {
    if (code == 0) return '☀️';
    if ([1, 2, 3].contains(code)) return '⛅';
    if ([45, 48].contains(code)) return '🌫️';
    if ([51, 53, 55, 56, 57].contains(code)) return '🌦️';
    if ([61, 63, 65, 66, 67].contains(code)) return '🌧️';
    if ([71, 73, 75, 77].contains(code)) return '❄️';
    if ([80, 81, 82].contains(code)) return '🌦️';
    if ([95, 96, 99].contains(code)) return '⛈️';
    return '☁️';
  }
}
