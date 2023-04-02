import 'dart:convert';
import 'package:crypto_curruncy_app/coin_details.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'package:http/http.dart' as http;

class CoinScreenGraph extends StatefulWidget {
  final CoinDetailsModel coinDetailsModel;
  const CoinScreenGraph({super.key, required this.coinDetailsModel});

  @override
  State<CoinScreenGraph> createState() => _CoinScreenGraphState();
}

class _CoinScreenGraphState extends State<CoinScreenGraph> {
  bool isLoading = true,
      isFirstTime = true,
      isDarkMode = AppTheme.isDarkModeEnabled;
  List<FlSpot> FlSpotList = [];
  int dayFilter = 1;

  double minX = 0.0, minY = 0.0, maxX = 0.0, maxY = 0.0;

  @override
  void initState() {
    super.initState();
    getChartData("1");
  }

  void getChartData(dayFilter) async {
    if (isFirstTime) {
      isFirstTime = false;
    } else {
      setState(() {
        isLoading = true;
      });
    }
    String apiUrl =
        "https://api.coingecko.com/api/v3/coins/${widget.coinDetailsModel.id}/market_chart?vs_currency=inr&days=$dayFilter";
    Uri uri = Uri.parse(apiUrl);
    final response = await http.get(uri);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> result = json.decode(response.body);

      List rawList = result['prices'];

      List<List> chartData = rawList.map((e) => e as List).toList();

      List<PriceAndTime> priceAndTimeList = chartData
          .map(
            (e) => PriceAndTime(price: e[1] as double, time: e[0] as int),
          )
          .toList();

      FlSpotList = [];

      for (var element in priceAndTimeList) {
        FlSpotList.add(
          FlSpot(element.time.toDouble(), element.price),
        );
      }

      minX = priceAndTimeList.first.time.toDouble();
      maxX = priceAndTimeList.last.time.toDouble();

      priceAndTimeList.sort((a, b) => a.price.compareTo(b.price));

      minY = priceAndTimeList.first.price;
      maxY = priceAndTimeList.last.price;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color.fromARGB(255, 37, 33, 33) : Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        title: Text(
          widget.coinDetailsModel.name,
          style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor:
            isDarkMode ? const Color.fromARGB(255, 58, 54, 54) : Colors.white,
      ),
      body: isLoading == false
          ? SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                            text: "${widget.coinDetailsModel.name} Price\n",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 18,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    "${widget.coinDetailsModel.currentPrice}\n",
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "${widget.coinDetailsModel.priceChangePercentage24h}%\n",
                                style: TextStyle(
                                  color: widget.coinDetailsModel
                                              .priceChangePercentage24h <
                                          0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              TextSpan(
                                text: "Rs. $maxY",
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: LineChart(
                      LineChartData(
                        minX: minX,
                        minY: minY,
                        maxX: maxX,
                        maxY: maxY,
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(show: false),
                        gridData: FlGridData(
                          getDrawingVerticalLine: (value) {
                            return FlLine(strokeWidth: 0);
                          },
                          getDrawingHorizontalLine: (value) {
                            return FlLine(strokeWidth: 0);
                          },
                        ),
                        lineBarsData: [
                          LineChartBarData(
                              spots: FlSpotList,
                              dotData: FlDotData(
                                show: false,
                              )),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buttonDay("1D", 1),
                        buttonDay("15D", 15),
                        buttonDay("30D", 30),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget buttonDay(String title, int day) {
    return ElevatedButton(
      onPressed: () {
        dayFilter = day;
        getChartData(dayFilter);
      },
      child: Text(title),
    );
  }
}

class PriceAndTime {
  late int time;
  late double price;

  PriceAndTime({
    required this.price,
    required this.time,
  });
}
