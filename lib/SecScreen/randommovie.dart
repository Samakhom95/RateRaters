import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

import '../Src/reviews.dart';

class ReandomScreen extends StatefulWidget {
  const ReandomScreen({super.key});

  @override
  State<ReandomScreen> createState() => _ReandomScreenState();
}

class _ReandomScreenState extends State<ReandomScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final _random = Random();
  String screen = '';
  Future<void> delay() async {
    await Future.delayed(const Duration(
      seconds: 2,
    ));
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text("Let's us pick"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
        ),
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("movies")
              .doc('Model')
              .snapshots()
              .take(1),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            var listMovies = snapshot.data?["listMovies"] ?? 0;
            if (!snapshot.hasData) {
              return Container();
            }
              final random3 = listMovies[
                                  _random.nextInt(listMovies?.length)];
            return GestureDetector(
              onHorizontalDragEnd: (DragEndDetails details) {
                if (details.primaryVelocity! > 0) {
                  Navigator.pop(context);
                } else if (details.primaryVelocity! < 0) {}
              },
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Text("Don't know what to wacth? Let's us pick"),
                        ElevatedButton(
                          onPressed: () => {
                            setState(() {
                              screen = 'None';
                            
                            })
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.grey,
                            elevation: 0.0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child:
                              Text(screen == '' ? 'Random' : 'Already wacth?'),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      screen == ''
                          ? Container()
                          : StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("movies")
                                  .doc(
                                    random3
                                  )
                                  .snapshots()
                                  .take(1),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                var file = snapshot.data?['profile'];
                                var title = snapshot.data?['title'];
                                if (snapshot.data == null) {
                                  return Container();
                                }
                                return FutureBuilder(
                                    future: downloadURL(file),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return Column(
                                          children: [
                                            InkWell(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                      width: 150,
                                                      height: 150,
                                                      child: Image.network(
                                                          snapshot.data!)),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0),
                                                    child: Center(
                                                      child: Text(
                                                        title,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onTap: () => {
                                                Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .rightToLeft,
                                                      child: ReviewsScreen(
                                                        movieUid: random3,
                                                      )),
                                                )
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                      if (snapshot.connectionState ==
                                              ConnectionState.waiting ||
                                          snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }
                                      return Container();
                                    });
                              })
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }

  Future<String> downloadURL(String file) async {
    try {
      String downloadURL =
          await storage.ref('movieimages/$file').getDownloadURL();
      // ignore: avoid_print
      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return downloadURL(file);
  }
}
