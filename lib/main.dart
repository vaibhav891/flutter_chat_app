import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: MyHomePage.id,
      routes: {
        MyHomePage.id: (context) => MyHomePage(
              title: 'My Home Page',
            ),
        LogIn.id: (context) => LogIn(),
        Registeration.id: (context) => Registeration(),
        Chat.id: (context) => Chat(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const String id = "MYHOMEPAGE";
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  child: Container(
                      width: 100.0,
                      height: 100.0,
                      child: Image.asset('assets/images/logo.png')),
                  tag: "logo",
                ),
                Text(
                  "Tensor chat",
                  style: TextStyle(fontSize: 40.0),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50.0,
          ),
          CustomButton(
              text: "Log In",
              callback: () {
                Navigator.of(context).pushNamed(LogIn.id);
              }),
          CustomButton(
            text: "Register",
            callback: () {
              Navigator.of(context).pushNamed(Registeration.id);
            },
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;
  CustomButton({this.text, this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Material(
        color: Colors.lightBlueAccent,
        elevation: 6.0,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          onPressed: callback,
          minWidth: 200.0,
          height: 20,
          child: Text(text),
        ),
      ),
    );
  }
}

class LogIn extends StatefulWidget {
  static const String id = "LOGIN";

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email;
  String password;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logInUser() async {
    FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tensor chat"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: "logo",
              child: Container(
                child: Image.asset("assets/images/logo.png"),
              ),
            ),
          ),
          SizedBox(
            height: 40.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value,
              decoration: InputDecoration(
                hintText: "Enter e-mail",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: TextField(
              obscureText: true,
              autocorrect: false,
              onChanged: (value) => password = value,
              decoration: InputDecoration(
                hintText: "Enter password",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          CustomButton(
            text: 'Log In',
            callback: logInUser,
          ),
        ],
      ),
    );
  }
}

class Registeration extends StatefulWidget {
  static const String id = "REGISTRATION";

  @override
  _RegisterationState createState() => _RegisterationState();
}

class _RegisterationState extends State<Registeration> {
  String email;
  String password;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> userRegistration() async {
    FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tensor chat"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: "logo",
              child: Container(
                child: Image.asset("assets/images/logo.png"),
              ),
            ),
          ),
          SizedBox(
            height: 40.0,
          ),
          TextField(
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
              hintText: "Enter e-mail",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 40.0,
          ),
          TextField(
            obscureText: true,
            autocorrect: false,
            onChanged: (value) => password = value,
            decoration: InputDecoration(
              hintText: "Enter password",
              border: OutlineInputBorder(),
            ),
          ),
          CustomButton(
            text: 'Register',
            callback: userRegistration,
          ),
        ],
      ),
    );
  }
}

class Chat extends StatefulWidget {
  static const String id = "CHAT";
  FirebaseUser user;

  Chat({this.user});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  Future<void> callback() async {
    if (messageController.text.length > 0) {
      //Add to database
      await _firestore.collection('messages').add({
        'from': widget.user.email,
        'text': messageController.text,
      });
    }
    messageController.clear();
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 5), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: "logo",
          child: Container(
            height: 40,
            child: Image.asset("assets/images/logo.png"),
          ),
        ),
        title: Text("Tensor Chat"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _auth.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  List<DocumentSnapshot> docs = snapshot.data.documents;
                  List<Widget> messages = docs
                      .map((doc) => Message(
                            from: doc.data['from'],
                            text: doc.data['text'],
                            me: widget.user.email == doc.data['from'],
                          ))
                      .toList();
                  return ListView(
                    controller: scrollController,
                    children: <Widget>[
                      ...messages,
                    ],
                  );
                },
                stream: _firestore.collection('messages').snapshots(),
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) => callback(),
                      onChanged: null,
                      decoration: InputDecoration(
                        hintText: "Enter your message",
                        border: OutlineInputBorder(),
                      ),
                      controller: messageController,
                    ),
                  ),
                  SendButton(
                    text: "Send",
                    callback: callback,
                  )
                ])
          ],
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.orange,
      child: Text(text),
      onPressed: callback,
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;
  final bool me;

  const Message({Key key, this.from, this.text, this.me}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              text,
              style: TextStyle(fontSize: 20.0),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: me ? Colors.teal : Colors.red,
            ),
          ),
          Text(from),
        ],
      ),
    );
  }
}
