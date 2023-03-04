import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rate_raters/Src/favorites.dart';
import 'package:rate_raters/Src/profile.dart';
import 'package:rate_raters/Src/reviews.dart';
import 'package:rate_raters/Src/search.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("movies")
            .doc('Model')
            .snapshots()
            .take(1),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          var listMovies = snapshot.data?["listMovies"];
          var listMovies1 = snapshot.data?["listMovies"];
          listMovies1?.shuffle();
          var inTheater = snapshot.data?["inTheater"];
          List<Widget> commentItems = List<Widget>.generate(
              listMovies1?.length.clamp(0, 5) ?? 0,
              (index) => StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("movies")
                      .doc(listMovies1[index])
                      .snapshots()
                      .take(1),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: 150,
                                          height: 150,
                                          child: Image.network(snapshot.data!)),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
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
                                          type: PageTransitionType.rightToLeft,
                                          child: ReviewsScreen(
                                            movieUid: listMovies1[index],
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
                  }));
          if (!snapshot.hasData) {
            return Container();
          }
          return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.star),
                  iconSize: 25,
                  onPressed: () => {
                    Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const MyFavourite()),
                    )
                  },
                ),
                IconButton(
                    icon: const Icon(Icons.search),
                    iconSize: 25,
                    onPressed: () => {
                          Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const SearchScreen()),
                          )
                        }),
              ],
              leading: IconButton(
                  icon: const Icon(Icons.person),
                  iconSize: 25,
                  onPressed: () => {
                        Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.leftToRight,
                              child: const Profile()),
                        )
                      }),
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.white,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light),
              backgroundColor: Colors.white,
              title: const Text('RateRaters'),
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
                      Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRight,
                            child: const Profile()),
                      );
                    } else if (details.primaryVelocity! < 0) {
                      Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const SearchScreen()),
                      );
                    }
                  },
                  child: ListView(
                    children: [
                      const Divider(
                        color: Colors.grey,
                      ),
                      const Center(
                        child:
                            Text('Our Picks', style: TextStyle(fontSize: 15.0)),
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          reverse: false,
                          enlargeCenterPage: false,
                          scrollDirection: Axis.horizontal,
                          autoPlayInterval: const Duration(seconds: 6),
                          autoPlayAnimationDuration: const Duration(seconds: 2),
                        ),
                        items: commentItems,
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                           Text('Now Showing',
                               style: TextStyle(fontSize: 15.0)),
                            SizedBox(width: 15,),
                            SizedBox(
                            width: 40,
                            height: 40,
                            child: FittedBox(
                                    fit: BoxFit.contain,
                              child: CircleAvatar(
                                backgroundImage: AssetImage('assets/images/majorlogo.png')
                                                  ),
                            ))
                    ])
                    ,
                      const Divider(
                        color: Colors.grey,
                      ),
                      //Movies in theater
                      GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 5.0, crossAxisCount: 2),
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: inTheater.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("movies")
                                    .doc(inTheater[index])
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
                                                          movieUid:
                                                              inTheater[index],
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
                      const Divider(
                        color: Colors.grey,
                      ),
                      const Center(
                        child: Text('All Movies',
                            style: TextStyle(fontSize: 15.0)),
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      //All Movies
                      GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 5.0, crossAxisCount: 2),
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: listMovies.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("movies")
                                    .doc(listMovies[index])
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
                                                          movieUid:
                                                              listMovies[index],
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
                    ],
                  ),
                ),
              ),
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
