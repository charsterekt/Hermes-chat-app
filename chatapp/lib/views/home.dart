import 'package:chatapp/helperfunctions/sharedpref_helper.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/ai_chat.dart';
import 'package:chatapp/views/chatscreen.dart';
import 'package:chatapp/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  String myName, myProfilePic, myUserName, myEmail;
  Stream usersStream;
  TextEditingController searchUsernameEditingController =
      TextEditingController();
  Stream chatRoomsStream;

  // TODO: Add pagination, fix null sign in issues

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  getMyInfoFromSharedPreference() async {
    myUserName = await SharedPreferenceHelper().getUserName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myName = await SharedPreferenceHelper().getDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    setState(() {});
    //print("Sharedprefs called");
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods(myUserName).getUserByUserName(
        searchUsernameEditingController.text.trim().toLowerCase());
    setState(() {});
  }

  Widget chatRoomsList() {
    //print("StreamBuilder called!!!");
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data.docs.isEmpty) {
              return Center(child: Text("No user found"));
            }
            //print("ListView created");
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                QueryDocumentSnapshot ds = snapshot.data.docs[index];
                if (myUserName != null) {
                  return ChatRoomListTile(
                      ds.data()["lastMessage"], ds.id, myUserName);
                } else {
                  //print("Going into null-check");
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => SignIn()));
                  });
                  return Text(
                    "Loading...",
                    style: TextStyle(color: Colors.white),
                  );
                }
              },
            );
          } else {
            //print("ListView not created");
            return Text("");
          }
        });
  }

  Widget searchListUserTile({String profileUrl, name, username}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };

        DatabaseMethods(myUserName).createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl,
              height: 40,
              width: 40,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(color: Color(0xffF4C2C2)),
              ),
              Text(
                username,
                style: TextStyle(color: Color(0xffF4C2C2)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget searchUsersList() {
    return StreamBuilder(
        stream: usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data.docs.isEmpty) {
              return Center(
                  child: Text(
                snapshot.error,
                style: TextStyle(color: Color(0xffF4C2C2)),
              ));
            }

            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                QueryDocumentSnapshot ds = snapshot.data.docs[index];
                return searchListUserTile(
                    profileUrl: ds.data()["imgurl"],
                    name: ds.data()["name"],
                    username: ds.data()["username"]);
              },
            );
          } else {
            return Text("");
          }
        });
  }

  getChatRooms() {
    chatRoomsStream = DatabaseMethods(myUserName).getChatRooms();
    //print("Chatroom Stream gotten");
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    setState(() {});
    getChatRooms();
  }

  @override
  void initState() {
    super.initState();
    onScreenLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1d1d1d),
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xff232323),
            statusBarIconBrightness: Brightness.light),
        title: Text(
          "Hermes",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xffF4C2C2)),
        ),
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((s) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.exit_to_app,
                  color: Color(0xffF4C2C2),
                )),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover)),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  isSearching
                      ? GestureDetector(
                          onTap: () {
                            isSearching = false;
                            searchUsernameEditingController.text = "";
                            setState(() {});
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Color(0xffF4C2C2),
                            ),
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color(0xffF4C2C2),
                              width: 1.0,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                            controller: searchUsernameEditingController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search by username",
                                hintStyle: TextStyle(
                                    color: Color(0xffF4C2C2).withOpacity(0.5))),
                            style: TextStyle(color: Color(0xffF4C2C2)),
                          )),
                          GestureDetector(
                              onTap: () {
                                if (searchUsernameEditingController.text !=
                                    "") {
                                  onSearchBtnClick();
                                }
                              },
                              child: Icon(
                                Icons.search,
                                color: Color(0xffF4C2C2),
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isSearching ? searchUsersList() : chatRoomsList()
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffF4C2C2),
        child: new Tab(
          icon: new Image.asset("assets/images/athena.png"),
        ),
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Chat(myName)));
        },
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    //print("DEBUG ${widget.myUsername}");
    try {
      username = widget.chatRoomId
          .replaceAll(widget.myUsername, "")
          .replaceAll("_", "");
      QuerySnapshot querySnapshot =
          await DatabaseMethods(widget.myUsername).getUserInfo(username);
      name = "${querySnapshot.docs[0].data()["name"]}";
      profilePicUrl = "${querySnapshot.docs[0].data()["imgurl"]}";
      //debug:
      //print(
      //    "TEST ${querySnapshot.docs[0].id} ${querySnapshot.docs[0].data()["name"]} ${querySnapshot.docs[0].data()["imgurl"]}");
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getThisUserInfo();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
        setState(() {});
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: profilePicUrl != null
                ? Image.network(
                    profilePicUrl,
                    height: 40,
                    width: 40,
                  )
                : Container(),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 18),
              name != null
                  ? Text(name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffF4C2C2)))
                  : Container(),
              SizedBox(
                height: 3,
              ),
              SizedBox(
                width: 300,
                child: Text(
                  widget.lastMessage,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xffF4C2C2)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
