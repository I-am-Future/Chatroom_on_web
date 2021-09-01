import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:web_socket_channel/html.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatroom',
      initialRoute: "/",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        "chatroom_page": (context) => ChatroomPage(title: 'Chatroom - init'),
        "/": (context) => LoginPage(title: 'Chatroom - log in page'), //HomePage
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _ipAddrController = TextEditingController();
  TextEditingController _portController = TextEditingController();
  TextEditingController _useridController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  // bool _hasLoggedIn = false;
  late Timer _timer;
  int _countDown = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            // the ip addr input box
            autofocus: true,
            controller: _ipAddrController,
            decoration: InputDecoration(
              labelText: "Server's ip address: ",
              hintText: "the ipv4 address",
              prefixIcon: Icon(Icons.info_outline),
            ),
          ),
          TextField(
            // the port nbr input box
            controller: _portController,
            decoration: InputDecoration(
              labelText: "Server's port number: ",
              hintText: "the port number",
              prefixIcon: Icon(Icons.info_outline),
            ),
          ),
          TextField(
            // the user id input box
            controller: _useridController,
            decoration: InputDecoration(
              labelText: "Chatroom's user id: ",
              hintText: "your user id",
              prefixIcon: Icon(Icons.person),
            ),
          ),
          TextField(
            // the user pw input box
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: "Chatroom's key: ",
              hintText: "your key",
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          TextButton(
            onPressed: _login,
            child: Text(
              "login",
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelTimer() {
    _timer.cancel();
  }

  void setTimer() {
    _countDown = 7;
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      print(_countDown);
      if (_countDown == 0) {
        // time's up
        _cancelTimer();
        print('connection failed.');
        Fluttertoast.showToast(
          msg:
              "The connection is INVALID: wrong host or port number! \n Please refresh the page and try again!",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.blue[100],
          fontSize: 24,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 5,
          textColor: Colors.black,
        );
        setState(() {});
      } else {
        _countDown--;
      }
    });
  }

  void _login() {
    print(_ipAddrController.text);
    print(_portController.text);
    print(_useridController.text);
    print(_passwordController.text);
    String host = _ipAddrController.text;
    String port = _portController.text;
    String userid = _useridController.text;
    //int port = int.parse(portController.text);
    String key = _passwordController.text;
    // trying to connect to the target server
    connectSocket(host, port, userid, key);
    //_clear();
  }

  void connectSocket(String host, String port, String userid, String key) {
    String address = 'ws://' + host + ':' + port;
    setTimer();
    var channel = HtmlWebSocketChannel.connect(address);
    _cancelTimer();
    //channel.stream.asBroadcastStream();
    // print('connection failed.');
    // Fluttertoast.showToast(
    //     msg: "The connection is invalid.",
    //     gravity: ToastGravity.CENTER,
    //     backgroundColor: Colors.blue[100],
    //     fontSize: 16,
    //     toastLength: Toast.LENGTH_SHORT,
    //     timeInSecForIosWeb: 5,
    //     textColor: Colors.black);
    channel.sink
        .add(jsonEncode({'type': 'trial', 'userid': userid, 'pw': key}));

    //print(channel.closeCode);
    channel.stream.listen((message) async {
      print('login' + message);
      var msg = jsonDecode(message);
      print(msg['type']);
      print(msg['content']);
      if (msg['type'] == 'cmd' && msg['content'] == '/permitted') {
        print('connected');
        _clear();
        Fluttertoast.showToast(
          msg: "You have successfully connected",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.blue[100],
          fontSize: 16,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          textColor: Colors.black,
        );
        channel.sink.close();
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatroomPage(
            title: 'Chatroom @ $host:$port',
            host: host,
            port: port,
            userid: userid,
            loginKey: key,
          );
        }));
        //Navigator.of(context).pushNamed('chatroom_page', arguments: "test");
      } else if (msg['type'] == 'cmd' && msg['content'] == '/denied') {
        print('denied');
        _clear();
        Fluttertoast.showToast(
          msg:
              "Your connection request has been denied: wrong user name or password.",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.blue[100],
          fontSize: 16,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 5,
          textColor: Colors.black,
        );
      }
    });
  }

  void _clear() {
    _ipAddrController.clear();
    _portController.clear();
    _useridController.clear();
    _passwordController.clear();
  }
}

class ChatroomPage extends StatefulWidget {
  ChatroomPage(
      {Key? key,
      required this.title,
      String? this.host,
      String? this.port,
      String? this.userid,
      String? this.loginKey})
      : super(key: key);

  final String title;
  final host;
  final port;
  final userid;
  final loginKey;

  @override
  _ChatroomState createState() => _ChatroomState();
}

class _ChatroomState extends State<ChatroomPage> {
  List<String> allMessages = [];
  double height = 100;
  late var width;
  bool isFirstFrame = true;
  TextEditingController inputController = TextEditingController();
  FocusNode inputFocusNode = FocusNode();
  var msgChannel;

  @override
  void initState() {
    super.initState();
    print(widget.title);
    String address = 'ws://' + widget.host + ':' + widget.port;
    this.msgChannel = HtmlWebSocketChannel.connect(address);
    print(widget.loginKey);
    this.msgChannel.sink.add(jsonEncode({
          'type': 'formalLogin',
          'userid': widget.userid,
          'pw': widget.loginKey,
        }));
    Timer(Duration(milliseconds: 100), () {
      setState(() {
        final size = MediaQuery.of(context).size;
        this.height = size.height;
        isFirstFrame = false;
      });
    });
    msgChannel.stream.listen((message) {
      var msg = jsonDecode(message);
      if (msg['type'] == 'cmd' && msg['content'] == '/permitted') {
      } else if (msg['type'] == 'msg') {
        // listen for message
        print('received');
        print(msg);

        setState(() {
          String tempMsg =
              msg['fromid'] + '@' + msg['time'] + ': ' + msg['content'];
          // String tempMsg = 'future';
          print(tempMsg);
          allMessages.add(tempMsg);
        });
      }
    });
  }

  void _send() {
    if (inputController.text.isNotEmpty) {
      msgChannel.sink.add(jsonEncode(
        {
          'type': 'msg',
          'fromid': widget.userid,
          'content': inputController.text,
        },
      ));
      setState(() {
        inputController.clear();
      });
    }
  }

  List<Widget> getAllMsgLines() {
    List<Widget> tempList = [];
    final size = MediaQuery.of(context).size;
    this.width = size.width;
    this.height = size.height;

    var item;
    for (item in this.allMessages) {
      tempList.add(
        Text(
          item,
          style: TextStyle(fontSize: 24),
        ),
      );
    }
    return tempList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(child: Text("Exit"), value: "/exit"),
              ];
            },
            onSelected: (Object object) {
              if (object == '/exit') {
                msgChannel.sink.close();
                Fluttertoast.showToast(
                  msg: "You have successfully disconnected",
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.blue[100],
                  fontSize: 16,
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 3,
                  textColor: Colors.black,
                );
                // inputFocusNode.dispose();
                // Navigator.pop(context);
                Navigator.of(context).pop();
                return;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: // input text box
                    Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  padding: EdgeInsets.all(10.0),
                  height: 100,
                  //decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                  child: TextField(
                    controller: inputController,
                    focusNode: inputFocusNode,
                    //maxLines: 2,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Your text here: (press `Enter` to send)',
                      prefixIcon: Icon(Icons.message),
                    ),
                    onSubmitted: (String value) {
                      print('submitted.');
                      _send();
                      FocusScope.of(context).requestFocus(inputFocusNode);
                    },
                  ),
                ),
              ),
              // send button
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                width: 60,
                height: 30,
                child: TextButton(
                  onPressed: _send,
                  child: Text(
                    'send',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
          // message box
          Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            height: isFirstFrame ? 10 : this.height / 2,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              children: isFirstFrame ? [] : getAllMsgLines(),
            ),
          ),
        ],
      ),
    );
  }
}
