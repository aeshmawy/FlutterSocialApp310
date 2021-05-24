import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:socialapp310/routes/search/searchWidget.dart';
import 'package:socialapp310/utils/color.dart';
import 'package:socialapp310/utils/styles.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({Key key, this.analytics, this.observer})
      : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(screenName: 'Search Location Page');
    _setLogEvent();
    print("SCS : Search Location Page succeeded");
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
        name: 'Search_Location_Page_Success',
        parameters: <String, dynamic>{
          'name': 'Search Location Page',
        });
  }

  final _formKey = GlobalKey<FormState>();
  String mapKey = 'AIzaSyD0fvZRggBM27RQzg6oxAcpWidUzQ_vB1k';
  String query = '';
  Map<String, dynamic> res;
  String hintText = 'Search Location';
  ValueChanged<String> onChanged;

  Future<dynamic> findPlace(String placeName) async {
    // print('here');
    // print(placeName);
    final response = await http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      res = json.decode(response.body);
      // (res);
      return res;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Stream<dynamic> getFindView(place) async* {
    //await Future.delayed(Duration(seconds: 1));
    yield await findPlace(place);
  }

  @override
  void initState() {
    // Assign that variable your Future.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String text = "";
    final controller = TextEditingController();
    final styleActive = TextStyle(color: Colors.black);
    final styleHint = TextStyle(color: Colors.black54);
    final style = text == "" ? styleHint : styleActive;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Search Location',
            style: kAppBarTitleTextStyle,
          ),
          backgroundColor: AppColors.darkpurple,
          centerTitle: true,
        )
    )
    ,
    body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
    Widget>[
    SizedBox(
    height: 20,
    ),
    Form(
    key: _formKey,
    child: Column(
    children: [
    Container(
    height: 42,
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: Colors.white,
    border: Border.all(color: Colors.black26),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: TextFormField(
    controller: controller,
    decoration: InputDecoration(
    icon: Icon(Icons.search, color: style.color),
    suffixIcon: text.isNotEmpty
    ? GestureDetector(
    child: Icon(Icons.close, color: style.color),
    onTap: () {
    controller.clear();
    onChanged('');
    FocusScope.of(context).requestFocus(FocusNode());
    },
    )
        : null,
    hintText: hintText,
    hintStyle: style,
    border: InputBorder.none,
    ),
    style: style,
    onSaved: (String value) {
    query = value;
    },
    ),
    ),
    OutlinedButton(
    style: OutlinedButton.styleFrom(
    backgroundColor: AppColors.primarypurple,
    ),
    onPressed: () async {
    _formKey.currentState.save();
    findPlace(query);
    setState(() {
    });
    },
    child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Text(
    'Search',
    style: kButtonDarkTextStyle,
    ),
    ),
    ),
    ],
    ),
    ),
    FutureBuilder(
    future: findPlace(query),
    builder: (context, snapshot) {
    if (snapshot.hasError) {
    return Text('There was an error :(');
    } else if (snapshot.hasData || snapshot.data == null) {
    return Expanded(
    child: Padding(
    padding: const EdgeInsets.symmetric(),
    child: ListView.builder(
    itemCount:
    snapshot.data == null ? 0 : snapshot.data["predictions"].length,
    itemBuilder: (context, index) => Column(
    children: [
    ListTile(
    title:
    Text(snapshot.data["predictions"][index]["description"]),
    leading: Icon(Icons.add_location_alt),
    ),
    Divider(color: Colors.black)
    ],
    ),
    ),
    ),
    );
    } else {
    // print(snapshot.data);
    return (Center(
    child: CircularProgressIndicator(
    valueColor: new AlwaysStoppedAnimation<Color>(
    AppColors.darkpurple))));
    }
    })
    ]
    )
    ,
    );
  }
}
