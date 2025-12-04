class DashboardData {
  final int userId;
  final String userName;
  final String region;
  final WeatherData? weatherData;

  DashboardData({
    required this.userId,
    required this.userName,
    required this.region,
    this.weatherData,

});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
        userId: json['userId'] as int,
        userName: json['userName'] as String,
        region: json['region'] as String,
        weatherData: json['weatherData'] != null
            ? WeatherData.fromJson(json['weatherData'])
            : null,
    );
  }
}

class WeatherData {
  final String region;
  final double temperature;
  final double humidity;
  final String weatherIcon;

  WeatherData({
    required this.region,
    required this.temperature,
    required this.humidity,
    required this.weatherIcon,
});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      region: json['region'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      weatherIcon: json['weatherIcon'] as String,
    );
  }
}