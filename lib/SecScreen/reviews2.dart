import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Reviews2 extends StatefulWidget {
  final String movieUid;
  const Reviews2({super.key, required this.movieUid});

  @override
  State<Reviews2> createState() => _Reviews2State();
}

class _Reviews2State extends State<Reviews2> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool? checkEmpty = false;
  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 2));
  }

  Future<void> toast() async {
    Fluttertoast.showToast(
      msg: 'Done!! refresh to see change',
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.transparent,
      textColor: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("movies")
            .doc(widget.movieUid)
            .snapshots()
            .take(1),
        builder: (context, AsyncSnapshot snapshot) {
          snapshot.data?.data()?.forEach((key, value) {
            if (key == 'usersComment') {
              checkEmpty = value.length == 0;
            }
          });
          var stars1 = snapshot.data?.data()?['1Stars'];
          var countStars1 = stars1?.length ?? 0;

          var stars2 = snapshot.data?.data()?['2Stars'];
          var countStars2 = stars2?.length ?? 0;

          var stars3 = snapshot.data?.data()?['3Stars'];
          var countStars3 = stars3?.length ?? 0;

          var stars4 = snapshot.data?.data()?['4Stars'];
          var countStars4 = stars4?.length ?? 0;

          var stars5 = snapshot.data?.data()?['5Stars'];
          var countStars5 = stars5?.length ?? 0;
          var title = snapshot.data?.get('title');

          final usersComment = snapshot.data?['usersComment'];
          final countComment = usersComment?.length ?? 0;
          final usersComment1 = snapshot.data?['usersComment'];
          usersComment1?.shuffle();

          final upvote = snapshot.data?['upvote'];
          final countUpVote = upvote?.length;
          if (!snapshot.hasData) {
            return Container();
          }
          //For CouracelSlider
          List<Widget> commentItems = List<Widget>.generate(
            usersComment1?.length.clamp(0, 5) ?? 0,
            (index) => StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("usersComment")
                    .doc(usersComment1[index])
                    .snapshots()
                    .take(1),
                builder: (context, AsyncSnapshot snapshot) {
                  var name = snapshot.data?.get('name');
                  var comment = snapshot.data?.get('comment');
                  var profile = snapshot.data?.get('profile');
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return FutureBuilder(
                      future: downloadURL(profile),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12.0, //Left
                                  10.0, //top
                                  0.0, //right
                                  10.0, //bottom
                                ),
                                child: SizedBox(
                                  height: 55,
                                  width: 55,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      backgroundImage:
                                          NetworkImage(snapshot.data!),
                                      radius: 10.0,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: 270,
                                child: Center(
                                  child: Text(
                                    comment,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Container();
                      });
                }),
          );
          //For All Comment
          List<Widget> allComment = List<Widget>.generate(
              usersComment1?.length ?? 0,
              (index) => StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("usersComment")
                      .doc(usersComment1[index])
                      .snapshots()
                      .take(1),
                  builder: (context, AsyncSnapshot snapshot) {
                    var name = snapshot.data?.get('name');
                    var comment = snapshot.data?.get('comment');
                    var profile = snapshot.data?.get('profile');

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
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12.0, //Left
                                        10.0, //top
                                        0.0, //right
                                        10.0, //bottom
                                      ),
                                      child: SizedBox(
                                        height: 55,
                                        width: 55,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage:
                                                NetworkImage(snapshot.data!),
                                            radius: 10.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          SizedBox(
                                            width: 260,
                                            child: Text(
                                              comment,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          return Container();
                        });
                  }));

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
              title: Text('Comments($countComment)'),
              centerTitle: true,
              titleTextStyle: const TextStyle(
                color: Colors.black,
              ),
              elevation: 0.0,
            ),
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              onRefresh: () => refreshList().then((value) => setState(() {})),
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: GestureDetector(
                  onHorizontalDragEnd: (DragEndDetails details) {
                    if (details.primaryVelocity! > 0) {
                      Navigator.pop(context);
                    } else if (details.primaryVelocity! < 0) {}
                  },
                  child: ListView(
                    children: [
                      Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () => openDialog1(
                                  countUpVote,
                                  countStars1,
                                  countStars2,
                                  countStars3,
                                  countStars4,
                                  countStars5),
                              child: SizedBox(
                                width: 270,
                                child: Center(
                                  child: Text(title,
                                      style: const TextStyle(fontSize: 15.0)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          checkEmpty!
                              ? Container()
                              : CarouselSlider(
                                  options: CarouselOptions(
                                      autoPlay: true,
                                      enlargeCenterPage: false,
                                      scrollDirection: Axis.horizontal,
                                      autoPlayInterval:
                                          const Duration(seconds: 6),
                                      autoPlayAnimationDuration:
                                          const Duration(seconds: 2),
                                      height: 200),
                                  items: commentItems,
                                ),
                          checkEmpty!
                              ? const Center(
                                  child: Text(
                                      'No comment yet. Be the first to comment'))
                              : CarouselSlider(
                                  options: CarouselOptions(
                                      autoPlay: false,
                                      viewportFraction: 0.19,
                                      enlargeCenterPage: false,
                                      reverse: false,
                                      padEnds: false,
                                      enableInfiniteScroll: false,
                                      scrollDirection: Axis.vertical,
                                      height: 560),
                                  items: allComment,
                                ),
                          const SizedBox(
                            height: 50,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

//Dialog show movie info
  Future openDialog1(upvoteCount, countStars1, countStars2, countStars3,
          countStars4, countStars5) =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Center(child: Text('Movie Info')),
                content: SizedBox(
                  height: 220,
                  child: Column(
                    children: [
                      (SelectableText(
                          // ignore: prefer_interpolation_to_compose_strings
                          'Movie Uid:'
                                  '\n' +
                              widget.movieUid +
                              '\n' '($upvoteCount) Liked this movie')),
                      // 1
                      Row(
                        children: [
                          const Icon(Icons.star),
                          Text(countStars1.toString())
                        ],
                      ),

                      Row(
                        children: [
                          const Icon(Icons.star),
                          const Icon(Icons.star),
                          Text(countStars2.toString())
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star),
                          const Icon(Icons.star),
                          const Icon(Icons.star),
                          Text(countStars3.toString())
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star),
                          const Icon(Icons.star),
                          const Icon(Icons.star),
                          const Icon(Icons.star),
                          Text(countStars4.toString())
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star),
                          const Icon(Icons.star),
                          const Icon(Icons.star),
                          const Icon(Icons.star),
                          const Icon(Icons.star),
                          Text(countStars5.toString())
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          width: 5.0, color: Colors.transparent),
                    ),
                    child: const Text(
                      'Ok',
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
