import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rate_raters/services/database.dart';

class MyComment extends StatefulWidget {
  const MyComment({super.key});

  @override
  State<MyComment> createState() => _MyCommentState();
}

class _MyCommentState extends State<MyComment> {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController comment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userUid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          final commentUid = snapshot.data?['comment'];
          final countComment1 = commentUid?.length;
          if (!snapshot.hasData) {
            return Container();
          }
          return Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.white,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light),
              backgroundColor: Colors.white,
              title: Text('Comments($countComment1)'),
              centerTitle: true,
              titleTextStyle: const TextStyle(
                color: Colors.black,
              ),
              elevation: 0.0,
            ),
            backgroundColor: Colors.white,
            body: ListView.builder(
                reverse: true,
                physics: const BouncingScrollPhysics(),
                itemCount: commentUid?.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("usersComment")
                          .doc(commentUid[index])
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        var name = snapshot.data?.get('name');
                        var comment = snapshot.data?.get('comment');
                        var movieName = snapshot.data?.get('movie');
                        var profile = snapshot.data?.get('profile');
                        var movieUid = snapshot.data?.get('movieUid');
                        final vote = snapshot.data?['vote'];
                       final countVote = vote?.length;
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        return FutureBuilder(
                            future: downloadURL(profile),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                return Column(
                                  children: [
                                    const Divider(
                                      color: Colors.grey,
                                    ),
                                    InkWell(
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              12.0, //Left
                                              10.0, //top
                                              0.0, //right
                                              10.0, //bottom
                                            ),
                                            child: SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  backgroundImage: NetworkImage(
                                                      snapshot.data!),
                                                  radius: 10.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 300,
                                                  child: Text(
                                                    movieName,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                                Text(
                                                  name,
                                                ),
                                                SizedBox(
                                                  width: 270,
                                                  child: Text(
                                                    comment,
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 11),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          )
                                        ],
                                      ),
                                      onTap: () => openDialog(
                                          movieUid, commentUid[index],countVote),
                                    ),
                                    const Divider(
                                      color: Colors.grey,
                                    ),
                                  ],
                                );
                              }
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.hasData) {
                                return Container();
                              }
                              return Container();
                            });
                      });
                }),
          );
        });
  }

  Future openDialog(movieUid, commentUid,countVote) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Center(child: Text('Edit')),
            content: SizedBox(
              width: 100,
              height: 100,
              child: Column(
                children: [
                  const SizedBox(
                    height: 11,
                  ),
                  TextFormField(
                    controller: comment,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(80),
                    ],
                    decoration: const InputDecoration(
                        errorStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: 'Your though?',
                        hintStyle: TextStyle(fontSize: 12)),
                  ),
                  Text('Vote:$countVote')
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => {
                   Navigator.pop(context),
                  DataBase()
                      .deleteComment(movieUid, commentUid)
                      
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Delete comment',
                  style: TextStyle(color: Colors.red, fontSize: 16.0),
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.green, fontSize: 16.0),
                ),
              ),
              OutlinedButton(
                onPressed: () => {
                   Navigator.pop(context),
                  firestore.collection("usersComment").doc(commentUid).update({
                    'comment': comment.text,
                  })
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ),
            ],
          ));

  Future<String> downloadURL(String imageName) async {
    try {
      String downloadURL =
          await storage.ref('images/$imageName').getDownloadURL();
      // ignore: avoid_print
      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return downloadURL(imageName);
  }
}
