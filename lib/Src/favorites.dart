import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rate_raters/Src/reviews.dart';

class MyFavourite extends StatefulWidget {
  const MyFavourite({super.key});

  @override
  State<MyFavourite> createState() => _MyFavouriteState();
}

class _MyFavouriteState extends State<MyFavourite> {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool? checkEmpty;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userUid)
            .snapshots()
            .take(1),
        builder: (context, snapshot) {
          var favMovies = snapshot.data?['favMovies'];
          snapshot.data?.data()?.forEach((key, value) {
            if (key == 'favMovies') {
              checkEmpty = value == '';
            }
          });
          if (!snapshot.hasData) {
            return Container();
          }
          return GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) {
              if (details.primaryVelocity! > 0) {
                Navigator.pop(context);
              } else if (details.primaryVelocity! < 0) {}
            },
            child: Scaffold(
              appBar: AppBar(
                iconTheme: const IconThemeData(
                  color: Colors.black,
                ),
                systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: Colors.white,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light),
                backgroundColor: Colors.white,
                title: const Text('My Favourites'),
                centerTitle: true,
                titleTextStyle: const TextStyle(
                  color: Colors.black,
                ),
                elevation: 0.0,
              ),
              backgroundColor: Colors.white,
              body: 
              checkEmpty!
              ? const Center(child: Text('No movies found.'))
              :
              GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 5.0, crossAxisCount: 2),
                  reverse: false,
                  physics: const BouncingScrollPhysics(),
                  itemCount: favMovies.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("movies")
                            .doc(favMovies[index])
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
                                              padding: const EdgeInsets.only(
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
                                                  movieUid: favMovies[index],
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
                                  return Container();
                                }
                                return Container();
                              });
                        });
                  }),
            ),
          );
        });
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
