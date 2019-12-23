import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hello_flutter/models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
    // items.add(Item(title: 'Fazer compras', done: true));
    // items.add(Item(title: 'Levar o carro para a mecânica', done: false));
    // items.add(Item(title: 'Comprar comida do cachorro', done: false));
    // items.add(Item(title: 'Limpar a calçada', done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState() {
    loadData();
  }

  var newTaskCtrl = TextEditingController();

  Future loadData() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data == null) return;

    Iterable decoded = jsonDecode(data);

    List<Item> result = decoded.map((item) => Item.fromJson(item)).toList();

    setState(() {
      widget.items = result;
    });
  }

  void saveData() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  void add() {
    if (newTaskCtrl.text.isEmpty) return;

    setState(() {
      widget.items.add(Item(
        title: newTaskCtrl.text,
        done: false,
      ));

      newTaskCtrl.text = '';
      saveData();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
          // autofocus: true,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            labelText:"Nova tarefa",
            labelStyle: TextStyle(color: Colors.white),
          )
        ),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            child: IconButton(
              icon: Icon(Icons.add_circle),
              tooltip: 'Adicionar tarefa',
              onPressed: add, // Não coloca o () porque está só passando a função e não chamando ela nesse momento
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctx, int index) {
          final item = widget.items[index];

          return Dismissible(
            key: Key(item.title), // Não precisa ter a "key" no dismissible e no checkbox
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red.withOpacity(0.5),
              alignment: Alignment(0.8, 0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: CheckboxListTile(
              // key: Key(item.title),
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                // setState está disponível apenas em state 
                setState(() {
                  item.done = value;
                });
              },
            ),
            onDismissed: (direction) {
              remove(index);
            }
          );
        },
      ),
    );
  }
}
