import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_setup/model/board.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Center',
      theme: ThemeData(

        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Board> boardMessages = List();
  Board board;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference;


  @override
  void initState() {
    super.initState();

    board = Board("", "");
    databaseReference = database.reference().child("community_board");
    databaseReference.onChildAdded.listen(_onEntryAdded); // Callback to function when data added
    databaseReference.onChildChanged.listen(_onEntryChanged);


  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text("Board"),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 0,
            child: Center(

              child: Form(
                key: formKey,
                child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      initialValue: "",
                      onSaved: (val) => board.subject = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.message),
                    title: TextFormField(
                      initialValue: "",
                      onSaved: (val) => board.body = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                  ),
                  // Send or Post button
                  FlatButton(
                    child: Text("Post"),
                    color: Colors.green,
                    onPressed: () {
                      handleSubmit();
                    },
                  ),
                ],
              ),
            ),
          ),
    ),
          Flexible(
            child: FirebaseAnimatedList(
                query: databaseReference,
                itemBuilder: (_, DataSnapshot snapshot,
                    Animation<double> animation, int index){
                  return new Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red,
                      ),
                      title: Text(boardMessages[index].subject),
                      subtitle: Text(boardMessages[index].body),
                    ),
                  );
                }
            ),
          )
        ],
      )
    );
  }

  void _onEntryAdded(Event event) {
    setState(() {
      boardMessages.add(Board.fromSnapshot(event.snapshot));
    });
  }

  void handleSubmit(){
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      // save form data to the database
      databaseReference.push().set(board.toJson());
    }
  }

  void _onEntryChanged(Event event) {
    var oldEntry = boardMessages.singleWhere((ennty){
      return ennty.key == event.snapshot.key;
    });
    setState(() {
      boardMessages[boardMessages.indexOf(oldEntry)] = Board.fromSnapshot(event.snapshot);
    });
  }
}
