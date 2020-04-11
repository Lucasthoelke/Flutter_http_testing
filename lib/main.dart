/**
 * TODO
 * - Clean up Code
 * - Document more code
 * - Make README
 */
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//Main function runs new instance of main widget (in this case 'HttpTestingApp')
void main() => runApp(HttpTestingApp());

class HttpTestingApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Http & Json Testing App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.pink,
      ),
      home: MyHomePage(title: 'Main Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<String> debug_body;
  String url = 'https://raw.githubusercontent.com/Lucasthoelke/public-json-dev-requests/master/providers.json';
  String defaultUrl = 'https://raw.githubusercontent.com/Lucasthoelke/public-json-dev-requests/master/providers.json';
  final settingsTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("_MyHomePageState::initState(): init");
    InternetRetriever ir = InternetRetriever(url);
    debug_body = ir.handleData();
  }

  void _pushSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void> (
        builder: (BuildContext context) {
          return Scaffold(
           appBar: AppBar(
             title: Text('Settings'),
           ),
            body: Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: TextField(
                          decoration: InputDecoration(hintText: 'URL'),
                          controller: settingsTextFieldController,
                        ),
                        width: MediaQuery.of(context).size.width * 0.75,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: _handleSettingsUrlSet,
                        child: Text('set', style: TextStyle(fontSize: 20)),
                      ),
                      RaisedButton(
                        onPressed: _handleSettingsUrlReset,
                        child: Text('reset', style: TextStyle(fontSize: 20)),
                      )
                    ],
                  )
                ]
              ),
            )
          );
        }
      )
    );
  }

  void _handleSettingsUrlReset() {
    url = defaultUrl;
    settingsTextFieldController.text = defaultUrl;
  }

  void _handleSettingsUrlSet() => url = settingsTextFieldController.text;

  Future<Null> _handleRefresh() async {
    print('_MyHomePageState::_handleRefresh(): Refreshing...');
    await new Future.delayed(Duration(seconds: 1));
    setState(() {
      InternetRetriever ir = InternetRetriever(url);
      debug_body = ir.handleData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings), onPressed: _pushSettings,)
        ],
      ),
      body: Center(
        child: new RefreshIndicator(
            child: PageView(
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              children: <Widget>[ Column(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Invoke "debug painting" (press "p" in the console, choose the
                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                // to see the wireframe for each widget.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      'URL:\n' + url + "\n",
                      textAlign: TextAlign.center
                  ),
                  Text(
                    'Body:',
                    textAlign: TextAlign.center,
                  ),
                  FutureBuilder(
                    future: debug_body,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Text(
                              snapshot.data
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }

                      return CircularProgressIndicator();

                    },
                  ),
                ],
              )
                ]
            ),
            onRefresh: _handleRefresh
        ),
      )
    );
  }
}

class InternetRetriever {
  //This functions handles the async requests of getting data from the internet.

  String url;

  //Constructor
  InternetRetriever(String url) {
    this.url = url;

    print('init: InternetRetriever()');

  }

  //Do the http request TODO Make this private
  Future<http.Response> fetchData() => http.get(this.url);

  Future<String> handleData() async {
    print('InternetRetriever::handleData(): Waiting for response...');
    final resp = await fetchData();
    print('InternetRetriever::handleData(): Should have response.');

    if (resp.statusCode == 200) {
      //200 OK
      print('InternetRetriever::handleData(): Status 200 OK.');
      print('InternetRetriever::handleData(): ' + resp.body);
      return resp.body;
    } else {
      print('InternetRetriever::handleData(): Unknown Error!');
      //TODO Throw exception
    }


  }


}