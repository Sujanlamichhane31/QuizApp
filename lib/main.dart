import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizapp/quizmodel.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  Padding errorData(AsyncSnapshot snapshot){
    return Padding(
      padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Error: ${snapshot.error}",
            ),
            SizedBox(height: 20.0,),
            RaisedButton(
                child: Text("Try Again"),
                onPressed: (){
                  fetchquestions();
                  setState(() {
                  
                  });
                })
          ],
        ),
    );
  }
  
  ListView questionList(){
    return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index){
        return Card(
          color: Colors.white,
          elevation: 0.0,
          child: ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(results[index].question,
                      style: TextStyle(
                      fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilterChip(
                            backgroundColor: Colors.grey[100],
                              label: Text(results[index].category),
                              onSelected: (b){
                              
                              }),
                          SizedBox(
                            width: 10.0,
                          ),
                          FilterChip(
                              backgroundColor: Colors.grey[100],
                              label: Text(results[index].difficulty),
                              onSelected: (b){
        
                              }),
                        ],
                      ),
                    )
                  ],
                
                ),
              ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Text(results[index].type.startsWith("m")?"M":"B"),
            ),
            children: results[index].allAnswers.map((e) {
              return AnswerWidget(
                results: results,
                index: index,
                m: e,
              );
            }).toList(),
          ),
        );
        });
  }
  
  QuizModel quizModel;
  List<Results> results;
  final String url = "https://opentdb.com/api.php?amount=40";
Future<void> fetchquestions() async{
  var result= await http.get(url);
  var decodedResults= jsonDecode(result.body);
  print(decodedResults);
  quizModel = QuizModel.fromJson(decodedResults);
  results= quizModel.results ;
  
}

@override
  void initState() {
  fetchquestions();
  // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Quiz App")),
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchquestions,
        child: FutureBuilder(
          future: fetchquestions(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
           switch (snapshot.connectionState){
             case ConnectionState.none:
               return Text("Press button to Start.");
             case ConnectionState.active:
             case ConnectionState.waiting:
               return Center(
                 child: CircularProgressIndicator(),
               );
             case ConnectionState.done:
               if(snapshot.hasError) return errorData(snapshot);
               return questionList();
               
           }return null;
          },
        ),
      ),
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;

  const AnswerWidget({Key key,
    this.results,
    this.index,
    this.m})
      : super(key: key);
  
  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color c= Colors.black;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        setState(() {
          if(widget.m== widget.results[widget.index].correctAnswer){
            c= Colors.green;
          }else{
            c= Colors.red;
          }
        });
      },
      title: Text(
        widget.m,
      textAlign: TextAlign.center,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
