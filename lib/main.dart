import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';


import 'package:uol_companion/widgets/Weather.dart';
import 'package:uol_companion/widgets/WeatherItem.dart';
import 'package:uol_companion/models/WeatherData.dart';
import 'package:uol_companion/models/ForecastData.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new HomeScreen(),
      title: 'Welcome to UoL Companion',
        theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Color(0xFF002147),
            accentColor: Color(0xFF747678),
            fontFamily: 'GoudyModern',
            textTheme: TextTheme(
              headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold,),
              title: TextStyle(fontSize: 36.0, fontWeight: FontWeight.w600),
              body1: TextStyle(fontSize: 14.0, fontFamily: 'Helvetica'),
            )
        )
    );
  }
}

class HomeScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color(0x00000000),
      appBar: AppBar(
          title: Text('Welcome to UoL Companion!')
      ),
      drawer: Drawer(
          child: ListView(
              children: <Widget>[
                ListTile(
                    title: Text("Map"),
                    trailing: Icon(Icons.map),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapPage()),
                      );
                    }
                ),
                ListTile(
                    title: Text("Notes"),
                    trailing: Icon(Icons.list),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListPage()),
                      );
                    }
                ),

                ListTile(
                  title: Text("Updates"),
                  trailing: Icon(Icons.alternate_email),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UpdatesPage()),
                    );
                    //Navigator.pop(context);
                  }  ,
                ),
                ListTile(
                  title: Text("Weather"),
                  trailing: Icon(Icons.wb_sunny),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WeatherPage()),
                    );
                    //Navigator.pop(context);
                  }  ,
                )]
          )
      ),
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/images/inb.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: null,
      )
    );
  }
}
class WeatherPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new WeatherPageState();
  }
}
class WeatherPageState extends State<WeatherPage>{
  bool isLoading = false;
  WeatherData weatherData;
  ForecastData forecastData;
  Location _location = new Location();
  String error;

  @override
  void initState() {
    super.initState();

    loadWeather();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.teal,
      appBar: AppBar(
        title: Text("Weather"),

      ),

        body: Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/images/cathedral.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: weatherData != null ? Weather(weather: weatherData) : Container(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: isLoading ? CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: new AlwaysStoppedAnimation(Color(0xFFFFFFFF)),
                          ) : IconButton(
                            icon: new Icon(Icons.refresh),
                            tooltip: 'Refresh',
                            onPressed: loadWeather,
                            color: (Color(0xFFFFFFFF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200.0,
                        child: forecastData != null ? ListView.builder(
                            itemCount: forecastData.list.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => WeatherItem(weather: forecastData.list.elementAt(index))
                        ) : Container(),
                      ),
                    ),
                  )
                ]
            )
        )
    );
  }
  loadWeather() async{
    setState(() {
      isLoading = true;
    });
    Map<String, double> location;
    try{
      location = await _location.getLocation();
      error = null;
    }
    on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED'){
        error = 'Permission denied';
      }
      else if (e.code == 'PERMISSION_DENIED_NEVER_ASK'){
        error = 'Permission denied, please enable from app settings';
      }
      location = null;
    }
    if (location!= null) {
      final lat = location['latitude'];
      final lon = location['longitude'];
      final weatherResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/weather?APPID=91096280b45382e0896f9ae94fa4e59e&units=metric&lat=${lat
            .toString()}&lon=${lon.toString()}');
      final forecastResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=91096280b45382e0896f9ae94fa4e59e&units=metric&lat=${lat
            .toString()}&lon=${lon.toString()}');
      if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200){
        return setState((){
          weatherData = new WeatherData.fromJson(jsonDecode(weatherResponse.body));
          forecastData = new ForecastData.fromJson(jsonDecode(forecastResponse.body));
          isLoading = false;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}
class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => new MapPageState();
}
class MapPageState extends State<MapPage>{
  var points = <LatLng>[
    new LatLng(53.226234, -0.539459),
    new LatLng(53.228566, -0.547744),
    new LatLng(53.227329, -0.544976),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Map"),
        ),
        backgroundColor: (Color(0x00000000)),
        body: new FlutterMap(
            options: new MapOptions(
                center: new LatLng (53.226234, -0.539459), minZoom: 5.0),
            layers:[
              new TileLayerOptions(
                urlTemplate: "https://api.mapbox.com/v4/"
                    "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
                additionalOptions: {
                  'accessToken': 'pk.eyJ1IjoiamNyb3NzbGV5NyIsImEiOiJjanY4ZzR5eTgwNTBmM3pwNzN2ZDlwYW16In0.Gm07eYfLoL_B0fpHKmBZKA',
                  'id': 'mapbox.streets',
                },
              ),
              new MarkerLayerOptions(
                  markers:[
                    new Marker(
                      width: 40.0,
                      height: 40.0,
                      point: points[0],
                      builder: (ctx) =>
                      new Container(
                        child: new FlutterLogo(),
                      ),
                    ),
                    new Marker(
                      width: 40.0,
                      height: 40.0,
                      point: points[1],
                      builder: (ctx) =>
                      new Container(
                        child: new FlutterLogo(),
                      ),
                    ),
                    new Marker(
                      width: 40.0,
                      height: 40.0,
                      point: points[2],
                      builder: (ctx) =>
                      new Container(
                        child: new FlutterLogo(),
                      ),
                    ),
                  ],

              ),

            ]));
  }
}

class UpdatesPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News"),
      ),
      backgroundColor: (Color(0x00000000)),
      body:
        new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/images/cathedral2.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            children: List.generate(
              25,
                (int index){
                return _tweetItem(index);
                },
            ),
          ),
        ),
      );
  }

  Widget _tweetItem(int index){
    return Container(
      color: (Color(0xFF9E9E9E).withOpacity(0.5)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage("assets/images/uniLogoPortrait.jpg"),
        ),
        title: Text("@unilincoln", style: const TextStyle(fontWeight: FontWeight.bold,),
        ),
        subtitle: Column(
          children: <Widget>[
            SizedBox(height:5,),
            Text("Welcome to the official University of Lincoln companion app! Expect more updates!",
              overflow: TextOverflow.clip,
              maxLines: 3,
            ),
          ],
        )
      ),
    );
  }
}
class ListPage extends StatefulWidget{
  @override
  State createState() => new DynamicList();
  }

class DynamicList extends State<ListPage>{
  List<String> litems =[];
  final TextEditingController eCtrl = new TextEditingController();
  @override
  Widget build (BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
        body: new Container(
            decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/images/cathedral2.jpg"),
              fit: BoxFit.cover,
            ),
          ),

          child: new Column(

            children: <Widget>[
              Container(
                color: (Color(0xFF9E9E9E).withOpacity(0.5)),
                child: new TextField(
                  controller: eCtrl,
                  onSubmitted: (text) {
                    litems.add(text);
                    eCtrl.clear();
                    setState(() {});
                  },
                ),
              ),
              Container(
                //color: (Color(0xFF9E9E9E).withOpacity(0.5)),
                child: new Expanded(
                    child: new Container(
                        color: (Color(0xFF9E9E9E).withOpacity(0.5)),
                        child: ListView.builder
                      (
                        itemCount: litems.length,
                        itemBuilder: (BuildContext context, int index) {

                          return new Text (litems[index]);
                        }
                    )
                    ),
                ),
              )
            ],
          ),
          ),

    );
  }
}
