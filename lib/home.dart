import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int temparature = 0;
  String location = 'Jakarta';
  int woeid = 1047378;
  String weather = 'clear';
  String abbreviation = 'c';
  String errorMessage = '';

  var minTemperature = List.filled(7, 0);
  var maxTemperature = List.filled(7, 0);
  var abbreviationForecast = List.filled(7, '');

  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(Uri.parse(searchApiUrl + input));
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result['title'];
        woeid = result['woeid'];
        errorMessage = '';
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Sorry, City Not Found';
      });
    }
  }

  void fetchLocation() async {
    var locationResult =
    await http.get(Uri.parse(locationApiUrl + woeid.toString()));
    var result = json.decode(locationResult.body);
    var consolidated_weather = result['consolidated_weather'];
    var data = consolidated_weather[0];

    setState(() {
      temparature = data['the_temp'].round();
      weather = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
      abbreviation = data['weather_state_abbr'];
    });
  }

  void fetchLocationDay() async {
    var today = DateTime.now();
    for (var i = 0; i < 7; i++) {
      var locationDayResult = await http.get(Uri.parse(
          locationApiUrl + woeid.toString() + '/' +
              DateFormat('y/M/d')
                  .format(today.add(Duration(days: i + 1)))
                  .toString()));
      var result = json.decode(locationDayResult.body);

      setState(() {
        minTemperature[i] = result['min_temp'];
        maxTemperature[i] = result['max_temp'];
        abbreviationForecast[i] = result['weather_state_abbr'];
      });
    }
  }

  void onTextFieldSubmitted(String input) {
    fetchSearch(input);
    fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/$weather.png'), fit: BoxFit.cover),
      ),
      child: temparature == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Center(
                  child: Image.network(
                    'https://www.metaweather.com/static/img/weather/png/$abbreviation.png',
                    width: 100,
                  ),
                ),
                Center(
                  child: Text(
                    temparature.toString() + 'ºC',
                    style: const TextStyle(
                      fontSize: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    location,
                    style: const TextStyle(
                        fontSize: 40, color: Colors.white),
                  ),
                )
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    onSubmitted: (String input) {
                      onTextFieldSubmitted(input);
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                    decoration: const InputDecoration(
                        hintText: "Search the Another Location...",
                        hintStyle: TextStyle(
                            color: Colors.white, fontSize: 16.0),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white,
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: Platform.isAndroid ? 15.0 : 20.0),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget forecastElement(daysFromNow) {
  var now = DateTime.now();
  var oneDayFromNow = now.add(Duration(days: daysFromNow));

  return Container(
    decoration: BoxDecoration(
        color: Color.fromRGBO(205, 212, 228, 0.2),
        borderRadius: BorderRadius.circular(10)
    ),
    child: Column(
      children: [],
    ),
  );
}