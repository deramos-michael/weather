import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

void main() => runApp(CupertinoApp(
  debugShowCheckedModeBanner: false,
  home: Homepage(),
));

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String location = "Baguio";
  String temp = "";
  IconData? weatherStatus;
  String weather = "";
  String humidity = "";
  String windSpeed = "";

  Map<String, dynamic> weatherData = {};

  Future<void> getWeatherData(String city) async {
    try {
      String link =
          "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=a7d420a62aba5ad305ef3885c399d830";
      final response = await http.get(Uri.parse(link));

      weatherData = jsonDecode(response.body);
      if (weatherData["cod"] == 200) {
        setState(() {
          location = city;
          temp = (weatherData["main"]["temp"] - 273.15).toStringAsFixed(0) + "°";
          weather = weatherData["weather"][0]['description'];
          humidity = (weatherData["main"]["humidity"]).toString() + "%";
          windSpeed = weatherData["wind"]['speed'].toString() + " kph";

          if (weather.contains("clear")) {
            weatherStatus = CupertinoIcons.sun_max;
          } else if (weather.contains("cloud")) {
            weatherStatus = CupertinoIcons.cloud;
          } else if (weather.contains("haze")) {
            weatherStatus = CupertinoIcons.sun_haze;
          } else {
            weatherStatus = CupertinoIcons.cloud_sun;
          }
        });
      } else {
        showErrorDialog("City not Found");
      }
    } catch (e) {
      showErrorDialog("No Internet Connection");
    }
  }

  void showErrorDialog(String message) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Message'),
            content: Text(message),
            actions: [
              CupertinoButton(
                  child: Text('Close',
                      style: TextStyle(color: CupertinoColors.destructiveRed)),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getWeatherData(location);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text("iWeather"),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.settings),
              onPressed: () async {
                final newLocation = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => SettingsPage(location: location)),
                );

                if (newLocation != null && newLocation is String && newLocation != location) {
                  getWeatherData(newLocation);
                }
              },
            )),
        child: SafeArea(
            child: temp != ""
                ? Center(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Text('Location', style: TextStyle(fontSize: 35)),
                    SizedBox(height: 5),
                    Text('$location', style: TextStyle(fontSize: 25)),
                    SizedBox(height: 20),
                    Text(" $temp", style: TextStyle(fontSize: 80)),
                    Icon(weatherStatus,
                        color: CupertinoColors.systemOrange, size: 100),
                    SizedBox(height: 10),
                    Text('$weather'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('H: $humidity'),
                        SizedBox(width: 10),
                        Text('W: $windSpeed')
                      ],
                    )
                  ],
                ))
                : Center(child: CupertinoActivityIndicator())));
  }
}

class SettingsPage extends StatefulWidget {
  final String location;

  SettingsPage({required this.location});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String selectedLocation;
  bool metricSystem = true;
  bool lightMode = true;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.location;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Settings"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text("Save"),
          onPressed: () {
            Navigator.pop(context, selectedLocation);
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // Location Setting
            CupertinoListSection(
              children: [
                CupertinoListTile(
                  title: Text("Location"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(selectedLocation),
                      SizedBox(width: 8),
                      Icon(CupertinoIcons.chevron_right, size: 18),
                    ],
                  ),
                  onTap: () async {
                    final newLocation = await showCupertinoModalPopup<String>(
                      context: context,
                      builder: (context) => LocationPicker(
                        currentLocation: selectedLocation,
                      ),
                    );
                    if (newLocation != null) {
                      setState(() {
                        selectedLocation = newLocation;
                      });
                    }
                  },
                ),
              ],
            ),

            // Icon Setting
            CupertinoListSection(
              children: [
                CupertinoListTile(
                  title: Text("Icon"),
                  trailing: Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: () {
                    // Handle icon setting
                  },
                ),
              ],
            ),

            // Metric System Setting
            CupertinoListSection(
              children: [
                CupertinoListTile(
                  title: Text("Metric System"),
                  trailing: CupertinoSwitch(
                    value: metricSystem,
                    onChanged: (value) {
                      setState(() {
                        metricSystem = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            // Light Mode Setting
            CupertinoListSection(
              children: [
                CupertinoListTile(
                  title: Text("Light Mode"),
                  trailing: CupertinoSwitch(
                    value: lightMode,
                    onChanged: (value) {
                      setState(() {
                        lightMode = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            // About Setting
            CupertinoListSection(
              children: [
                CupertinoListTile(
                  title: Text("About"),
                  trailing: Text("Version: 1.0"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LocationPicker extends StatelessWidget {
  final String currentLocation;

  LocationPicker({required this.currentLocation});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = currentLocation;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        middle: Text("Change Location"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text("Save"),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CupertinoTextField(
            controller: _controller,
            placeholder: "Enter city name",
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            autofocus: true,
          ),
        ),
      ),
    );
  }
}