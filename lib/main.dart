import 'dart:ui';
import 'package:app2/contracts/project.dart';
import 'package:app2/contracts/source.dart';
import 'package:app2/screens/landing.dart';
import 'package:app2/screens/myassets.dart';
import 'package:app2/screens/node.dart';
import 'package:app2/screens/projectview.dart';
import 'package:app2/services.dart/chain.dart';
import 'package:app2/widgets/agent_card.dart';
import 'package:app2/widgets/agent_details.dart';
import 'package:app2/widgets/mainmenu.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:intl/date_time_patterns.dart';

Chain chain = new Chain();
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  DateTime now = DateTime.now();
  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  bool lumina = false;
  bool bypass = false;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (!bypass) {
      now.hour < 7 || now.hour >= 21 ? lumina = false : lumina = true;
    }
    print("ora este" + now.hour.toString());
    ThemeData light = ThemeData(
        brightness: Brightness.light,
        dividerColor: createMaterialColor(Color(0xff4454238)),
        primaryColor: createMaterialColor(Color(0xffffffff)),
        primarySwatch: createMaterialColor(Color(0xff4d4d4d)),
        highlightColor: Color(0xff6e6e6e),
        accentColor: Color(0xffe0deda),
        canvasColor: Color(0xfff0f0f0));

    ThemeData dark = ThemeData(
      buttonColor: createMaterialColor(Color(0xff505663)),
      dividerColor: createMaterialColor(Color(0xffcfc099)),
      brightness: Brightness.dark,
      accentColor: createMaterialColor(Color(0xff383736)),
      primaryColor: createMaterialColor(Color(0xff4d4d4d)),
      primarySwatch: createMaterialColor(Color(0xffefefef)),
      highlightColor: Color(0xff6e6e6e),
    );

    return MaterialApp(
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/node':
              return PageTransition(
                  child: Node(
                    appstate: this,
                  ),
                  type: PageTransitionType.fade);

            case '/market':
              return PageTransition(
                  child: Market(
                    appstate: this,
                  ),
                  type: PageTransitionType.fade);
            case '/assets':
              return PageTransition(
                  child: MyAssets(
                    appstate: this,
                  ),
                  type: PageTransitionType.fade);
            default:
              return PageTransition(
                  child: Landing(title: 'AUTONET', appstate: this),
                  type: PageTransitionType.fade);
          }
        },
        debugShowCheckedModeBanner: false,
        // routes: {
        //   Landing.route: (context) => Landing(appstate: this, title: "Autonet"),
        //   Node.route: (context) => Node(appstate: this, title: "Hopa"),
        //   MyAssets.route: (context) => MyAssets(
        //         appstate: this,
        //       ),
        //   ProjectView.route: (context) => ProjectView(
        //         appstate: this,
        //       ),
        //   Market.route: (context) => Market(
        //         appstate: this,
        //       ),
        // },
        title: 'Autonet',
        theme: lumina ? light : dark,
        home: Landing(title: 'AUTONET', appstate: this));
  }
}

// ignore: must_be_immutable
class Market extends StatefulWidget {
  static String route = "/market";
  Market({Key key, this.title, this.appstate}) : super(key: key);
  final String title;
  MyAppState appstate;
  @override
  _MarketState createState() => _MarketState();
}

class _MarketState extends State<Market> {
  var apiUrl = "https://rinkeby.infura.io/v3/e697a6a0ac0a4a7b94b09c88770f14e6";
  final EthereumAddress sourceAddr =
      EthereumAddress.fromHex('0x6af227B1d0B976a71eb21f21Dc4C22218257a0C8');
  final EthereumAddress projAddr =
      EthereumAddress.fromHex('0x0670C0357432Ac4812463A73907Da8f94E34Ab78');
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("lungimea la proiecte ${chain.projects.length}");
    List<Widget> proiectili = [];
    ScrollController sc = ScrollController();
    return MainMenu(
        care: "market",
        appstate: widget.appstate,
        porc: Container(
          padding: EdgeInsets.all(3),
          width: MediaQuery.of(context).size.width,
          child: Stack(children: [
            Scrollbar(
              controller: sc,
              child: Container(
                  height: MediaQuery.of(context).size.height - 30,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                      child: Container(
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              SizedBox(height: 50),
                              FutureBuilder(
                                  future: chain.populate(),
                                  builder: (context, snapshot) {
                                    if (chain.populating == true) {
                                      return Center(
                                          child: Container(
                                              padding: EdgeInsets.all(100),
                                              child:
                                                  CircularProgressIndicator()));
                                    } else {
                                      proiectili = [];
                                      for (Project p in chain.projects) {
                                        print("hai cu primul");
                                        proiectili.add(
                                          ProjectCard(
                                            p: p,
                                            appstate: widget.appstate,
                                          ),
                                        );
                                      }
                                      return Wrap(children: proiectili);
                                    }
                                  }),
                            ],
                          )))),
            ),
            Opacity(
                opacity: 0.91,
                child: Container(
                  height: 40,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    border: Border(
                        bottom: BorderSide(
                            width: 0.3, color: Theme.of(context).primaryColor)),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () {},
                          child: Text("Production",
                              style: TextStyle(
                                fontFamily: "OCR-A",
                              ))),
                      TextButton(
                          onPressed: () {},
                          child: Text("Training",
                              style: TextStyle(
                                fontFamily: "OCR-A",
                              ))),
                      TextButton(
                          onPressed: () {},
                          child: Text("Developers",
                              style: TextStyle(
                                fontFamily: "OCR-A",
                              ))),
                      TextButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Text(
                                "FILTER",
                                style: TextStyle(fontSize: 12),
                              ),
                              Icon(Icons.sort)
                            ],
                          )),
                    ],
                  )),
                )),
          ]),
        ));
  }
}
