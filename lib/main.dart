import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_setup/model/board.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth - Firebase',
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

  String _imageURL = "";

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
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(

          title: Text("Board"),
        ),
        body: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  child: Text("Google Login"),
                  onPressed: () => _googleSignin(),
                  color: Colors.red,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  child: Text("eMail Login"),
                  onPressed: () => {},
                  color: Colors.blue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  child: Text("Create Account"),
                  onPressed: () => _createUser(),
                  color: Colors.green,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton (
                  child: Text("Signout"),
                  onPressed: () => _logout(),
                  color: Colors.orange,
                  
                ),
              ),
              new Image.network(_imageURL == null || _imageURL.isEmpty ?
              "https://picsum.photos/250?image=9" : _imageURL)
            ],
          ),
        )
    );
  }

  Future<FirebaseUser> _googleSignin() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    print("User is: ${user.photoUrl}");

    setState(() {
      _imageURL = user.photoUrl;
    });

    return user;

  }

  Future _createUser() async {
    FirebaseUser user = await _auth.createUserWithEmailAndPassword(
        email: "paulEximos@gmail.com", password: "check12345")
        .then((user) {
          print("User created is: ${user.user.email}");
    });
  }

  _logout() {
    setState(() {
      _googleSignIn.signOut();
      _imageURL = null;
    });
  }
}
