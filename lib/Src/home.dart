import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:rate_raters/SecScreen/reviews2.dart';
import 'package:rate_raters/Src/favorites.dart';
import 'package:rate_raters/Src/login.dart';
import 'package:rate_raters/Src/profile.dart';
import 'package:rate_raters/Src/reviews.dart';
import 'package:rate_raters/Src/search.dart';

import '../blocs/auth_blocs.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  late StreamSubscription<User?> loginStateSubscription;
  bool? checkLogin;
  List list5 = ['1','2','3','4'];


  @override
  void initState() {
    final authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubscription = authBloc.currentUser.listen((fbUser) {
      if (fbUser != null) {
        if (mounted) {
          //User login
          checkLogin = true;
        }
      } else {
        if (mounted) {
          //User not login
          checkLogin = false;
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    loginStateSubscription.cancel();
    super.dispose();
  }

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
          var listMovies = snapshot.data?["listMovies"]??list5;
          listMovies = List.from(listMovies!.reversed);
          var listMovies1 = snapshot.data?["listMovies"];
          listMovies1?.shuffle();
          var inTheater = snapshot.data?["inTheater"];
          List<Widget> commentItems = List<Widget>.generate(
              listMovies1?.length.clamp(0, 10) ?? 0,
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
                            return GestureDetector(
                              onTap: () => {
                                checkLogin == true
                                    ? Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: ReviewsScreen(
                                              movieUid: listMovies1[index],
                                            )),
                                      )
                                    : Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: Reviews2(
                                              movieUid: listMovies1[index],
                                            )))
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Image.network(snapshot.data!)),
                                  SizedBox(
                                    height: 29,
                                    width: 270,
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Text(title),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                    checkLogin == true
                        ? Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const MyFavourite()),
                          )
                        : Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const LoginScreen()),
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
                        checkLogin == true
                            ? Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.leftToRight,
                                    child: const Profile()),
                              )
                            : Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.leftToRight,
                                    child: const LoginScreen()),
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
                      checkLogin == true
                          ? Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  child: const Profile()),
                            )
                          : Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  child: const LoginScreen()),
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
                      Center(
                        child: checkLogin == true
                            ? Container()
                            : const Text('You are not login'),
                      ),

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
                            SizedBox(
                              width: 15,
                            ),
                            SizedBox(
                                width: 40,
                                height: 40,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: AssetImage(
                                          'assets/images/majorlogo.png')),
                                ))
                          ]),
                      const Divider(
                        color: Colors.grey,
                      ),
                      //Movies in theater
                      GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  mainAxisSpacing: 25.0,
                                  crossAxisSpacing: 5.0,
                                  crossAxisCount: 2),
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
                                          return GestureDetector(
                                            onTap: () => {
                                              checkLogin == true
                                                  ? Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type:
                                                              PageTransitionType
                                                                  .rightToLeft,
                                                          child: ReviewsScreen(
                                                            movieUid: inTheater[
                                                                index],
                                                          )),
                                                    )
                                                  : Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type:
                                                              PageTransitionType
                                                                  .rightToLeft,
                                                          child: Reviews2(
                                                            movieUid: inTheater[
                                                                index],
                                                          )),
                                                    )
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: 180,
                                                    height: 180,
                                                    child: Image.network(
                                                        snapshot.data!)),
                                                SizedBox(
                                                  height: 29,
                                                  width: 270,
                                                  child: Center(
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(title),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                                  mainAxisSpacing: 11.0,
                                  crossAxisSpacing: 5.0,
                                  crossAxisCount: 2),
                          reverse: false,
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
                                          return GestureDetector(
                                            onTap: () => {
                                              checkLogin == true
                                                  ? Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type:
                                                              PageTransitionType
                                                                  .rightToLeft,
                                                          child: ReviewsScreen(
                                                            movieUid:
                                                                listMovies[
                                                                    index],
                                                          )),
                                                    )
                                                  : Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type:
                                                              PageTransitionType
                                                                  .rightToLeft,
                                                          child: Reviews2(
                                                            movieUid:
                                                                listMovies[
                                                                    index],
                                                          )),
                                                    )
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: 180,
                                                    height: 180,
                                                    child: Image.network(
                                                        snapshot.data!)),
                                                SizedBox(
                                                  height: 29,
                                                  width: 270,
                                                  child: Center(
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(title),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                      const SizedBox(
                        height: 20,
                      )
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
