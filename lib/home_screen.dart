import 'dart:convert';
import 'package:crypto_curruncy_app/app_theme.dart';
import 'package:crypto_curruncy_app/coin_details.dart';
import 'package:crypto_curruncy_app/coin_graph_screen.dart';
import 'package:crypto_curruncy_app/update_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String url =
      "https://api.coingecko.com/api/v3/coins/markets?vs_currency=inr&order=market_cap_desc&per_page=100&page=1&sparkline=false";
  String name = "", email = "", age = "";
  bool isDarkMode = AppTheme.isDarkModeEnabled;
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  List<CoinDetailsModel> coinDetailsList = [];
  late Future<List<CoinDetailsModel>> coinDetailsFuture;
  bool isFirstTimeDataAccess = true;

  @override
  void initState() {
    super.initState();
    getUserDetail();
    coinDetailsFuture = getCoinDetails();
  }

  void getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

// set state used to update data in real time
    setState(() {
      name = prefs.getString('name') ??
          ""; //iname is nullable so if we get null then it will print value inside ""
      email = prefs.getString('email') ?? "";
      age = prefs.getString('age') ?? "";
    });
  }

  Future<List<CoinDetailsModel>> getCoinDetails() async {
    Uri uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode == 200 || response.statusCode == 201) {
      List coinData = json.decode(response.body);
      List<CoinDetailsModel> data =
          coinData.map((e) => CoinDetailsModel.fromJson(e)).toList();

      return data;
    } else {
      return <CoinDetailsModel>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor:
          isDarkMode ? const Color.fromARGB(255, 37, 33, 33) : Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              _globalKey.currentState!.openDrawer();
            },
            icon: Icon(
              Icons.menu,
              color: isDarkMode ? Colors.white : Colors.black,
            )),
        backgroundColor:
            isDarkMode ? const Color.fromARGB(255, 58, 54, 54) : Colors.white,
        title: Text(
          "Crypto Curruncy App",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor:
            isDarkMode ? const Color.fromARGB(255, 37, 33, 33) : Colors.white,
        child: Column(children: [
          UserAccountsDrawerHeader(
            decoration: (BoxDecoration(
              color: isDarkMode
                  ? const Color.fromARGB(255, 58, 54, 54)
                  : Colors.blue,
            )),
            accountName: Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            accountEmail: Text(
              "Email: $email\nAge: $age",
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            currentAccountPicture: const Icon(
              Icons.account_circle,
              size: 70,
              color: Colors.white,
            ),
          ),
          ListTile(
            onTap: () {
              _globalKey.currentState!.closeDrawer();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProfileScreen(),
                ),
              );
            },
            leading: Icon(
              Icons.account_box,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            title: Text(
              "Update Profile",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 17,
              ),
            ),
          ),
          ListTile(
            onTap: () async {
              _globalKey.currentState!.closeDrawer();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              setState(() {
                isDarkMode = !isDarkMode;
              });
              AppTheme.isDarkModeEnabled = isDarkMode;
              await prefs.setBool('isDarkMode', isDarkMode);
            },
            leading: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            title: Text(
              isDarkMode ? "Light Mode" : "Dark Mode",
              style: TextStyle(
                fontSize: 17,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          )
        ]),
      ),
      body: FutureBuilder(
        future: coinDetailsFuture,
        builder: (context, AsyncSnapshot<List<CoinDetailsModel>> snapshot) {
          if (snapshot.hasData) {
            if (isFirstTimeDataAccess) {
              coinDetailsList = snapshot.data!;
              isFirstTimeDataAccess = false;
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 20.0,
                  ),
                  child: TextField(
                    onChanged: (query) {
                      List<CoinDetailsModel> searchResult =
                          snapshot.data!.where(
                        (element) {
                          String coinName = element.name + element.symbol;
                          bool isItemFound = coinName.contains(query);
                          return isItemFound;
                        },
                      ).toList();

                      setState(() {
                        coinDetailsList = searchResult;
                      });
                    },
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      hintText: "Search Coin",
                      hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: coinDetailsList.isEmpty
                      ? const Center(
                          child: Text("No Coin Found"),
                        )
                      : ListView.builder(
                          itemCount: coinDetailsList.length,
                          itemBuilder: (context, index) {
                            return coinsDetails(coinDetailsList[index]);
                          },
                        ),
                )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget coinsDetails(CoinDetailsModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoinScreenGraph(coinDetailsModel: model),
            ),
          );
        },
        leading: SizedBox(
          height: 50,
          width: 50,
          child: Image.network(
            model.image,
          ),
        ),
        title: Text(
          "${model.name}\n${model.symbol}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        trailing: RichText(
          textAlign: TextAlign.end,
          text: TextSpan(
            text: "Rs. ${model.currentPrice}\n",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            children: [
              TextSpan(
                text: "${model.priceChangePercentage24h}%",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: model.priceChangePercentage24h < 0
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
