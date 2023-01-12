import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?key=47e45ed7';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const HomePage(),
    theme: ThemeData(
        hintColor: Colors.grey,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey,
          )),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        )),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double? dolar;
  double? euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Conversor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    'Carregando...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20,
                    ),
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 20,
                      ),
                    ),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 40),
                          child: Icon(
                            Icons.monetization_on_outlined,
                            size: 100,
                            color: Colors.amber,
                          ),
                        ),
                        buildTextField(
                            'Reais', 'R\$', realController, realChanged),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: buildTextField(
                              'Dólares', 'US\$', dolarController, dolarChanged),
                        ),
                        buildTextField(
                            'Euros', '€', euroController, euroChanged),
                      ],
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }

  void realChanged(String text) {
    if(text.isEmpty) {
      clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar!).toStringAsFixed(2);
    euroController.text = (real / euro!).toStringAsFixed(2);
  }

  void dolarChanged(String text) {
    if(text.isEmpty) {
      clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar!).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar! / euro!).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    if(text.isEmpty) {
      clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro!).toStringAsFixed(2);
    dolarController.text = (euro * this.euro! / dolar!).toStringAsFixed(2);
  }

  void clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

Widget buildTextField(
  String label,
  String prefix,
  TextEditingController controller,
  Function function,
) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixText: prefix,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        )),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    onChanged: (text) {
      function(text);
    },
  );
}