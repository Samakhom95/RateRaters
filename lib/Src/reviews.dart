import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rate_raters/SecScreen/stars.dart';
import 'package:rate_raters/services/database.dart';
import 'package:uuid/uuid.dart';

class ReviewsScreen extends StatefulWidget {
  final String movieUid;
  const ReviewsScreen({super.key, required this.movieUid});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();
  bool? admin = false;
  final TextEditingController comment = TextEditingController();
  final TextEditingController movieTitle = TextEditingController();

  int num = 15;
  String? shuffle = '';

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
             var stars1 = snapshot.data?.data()?['1Stars'];
              var countStars1 = stars1?.length??0;
            
               var stars2 = snapshot.data?.data()?['2Stars'];
              var countStars2 = stars2?.length??0;

              var stars3 = snapshot.data?.data()?['3Stars'];
              var countStars3 = stars3?.length??0;

              var stars4 = snapshot.data?.data()?['4Stars'];
              var countStars4 = stars4?.length??0;

              var stars5 = snapshot.data?.data()?['5Stars'];
              var countStars5 = stars5?.length??0; 
          var title = snapshot.data?.get('title');
          var id = snapshot.data?.get('id');
          final usersComment = snapshot.data?['usersComment'];
          final usersComment1 = snapshot.data?['usersComment'];
          usersComment1?.shuffle();
          final countComment = usersComment?.length;
          final upvote = snapshot.data?['upvote'];
          final countUpVote = upvote?.length;
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
                                  height: 60,
                                  width: 60,
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
                                ),
                              ),
                              SizedBox(
                                width: 270,
                                child: Center(
                                  child: Text(
                                    comment,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 15),
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

          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(userUid)
                  .snapshots()
                  .take(1),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                var userName = snapshot.data?.get('fullName');
                var profileUid = snapshot.data?.get('profileUrl');
                var favMovies = snapshot.data?['favMovies'];
                snapshot.data?.data()?.forEach((key, value) {
                  if (key == 'admin') {
                    admin = value == '';
                  }
                });
                if (!snapshot.hasData) {
                  return Container();
                }
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("movies")
                        .doc('Model')
                        .snapshots()
                        .take(1),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      final inTheater = snapshot.data?['inTheater'];
                      if (!snapshot.hasData) {
                        return Container();
                      }

                      return Scaffold(
                        appBar: AppBar(
                          actions: <Widget>[
                            IconButton(
                                tooltip: 'Rate',
                                icon: const Icon(Icons.rate_review_outlined),
                                iconSize: 25,
                                onPressed: () => {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            child: RatingStars(
                                              movieUid: id,
                                            )),
                                      )
                                    }),
                            IconButton(
                                tooltip: 'Shuffle',
                                icon: const Icon(
                                    Icons.screen_rotation_alt_rounded),
                                iconSize: 25,
                                onPressed: () => {
                                      setState(() {
                                        shuffle = 'None';
                                      })
                                    }),
                            IconButton(
                              icon: Icon(
                                  upvote.toString().contains(userUid) == true
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_alt_outlined),
                              iconSize: 25,
                              onPressed: () => {
                                if (upvote.toString().contains(userUid))
                                  {
                                    firestore
                                        .collection("movies")
                                        .doc(widget.movieUid)
                                        .update({
                                      'upvote':
                                          FieldValue.arrayRemove([userUid])
                                    }).then((value) => toast())
                                  }
                                else
                                  {
                                    firestore
                                        .collection("movies")
                                        .doc(widget.movieUid)
                                        .update({
                                      'upvote': FieldValue.arrayUnion([userUid])
                                    }).then((value) => toast())
                                  }
                              },
                            ),
                            IconButton(
                              icon: Icon(favMovies
                                          .toString()
                                          .contains(widget.movieUid) ==
                                      true
                                  ? Icons.star
                                  : Icons.star_border),
                              iconSize: 25,
                              onPressed: () => {
                                if (favMovies
                                    .toString()
                                    .contains(widget.movieUid))
                                  {
                                    firestore
                                        .collection("users")
                                        .doc(userUid)
                                        .update({
                                      'favMovies': FieldValue.arrayRemove(
                                          [widget.movieUid])
                                    }).then((value) => toast())
                                  }
                                else
                                  {
                                    firestore
                                        .collection("users")
                                        .doc(userUid)
                                        .update({
                                      'favMovies': FieldValue.arrayUnion(
                                          [widget.movieUid])
                                    }).then((value) => toast())
                                  }
                              },
                            ),
                          ],
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
                        floatingActionButton: Builder(builder: (context) {
                          return FloatingActionButton(
                            onPressed: () {
                              openDialog(userName, profileUid, title);
                            },
                            backgroundColor: Colors.grey,
                            elevation: 0,
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 35),
                          );
                        }),
                        backgroundColor: Colors.white,
                        body: RefreshIndicator(
                          onRefresh: () =>
                              refreshList().then((value) => setState(() {})),
                          child: ScrollConfiguration(
                            behavior: const ScrollBehavior()
                                .copyWith(overscroll: false),
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
                                      const Divider(
                                        color: Colors.grey,
                                      ),
                                      Center(
                                        child: GestureDetector(
                                          onTap: () => openDialog1(countUpVote,countStars1,countStars2,countStars3,countStars4,countStars5),
                                          child: Text(title,
                                              style: const TextStyle(
                                                  fontSize: 15.0)),
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      admin!
                                          ? Container()
                                          : Column(
                                              children: [
                                                Center(
                                                  child: ElevatedButton(
                                                    onPressed: () =>
                                                        openDialog2(
                                                            widget.movieUid),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.black,
                                                      backgroundColor:
                                                          Colors.grey,
                                                      elevation: 0.0,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.zero,
                                                      ),
                                                    ),
                                                    child: const Text('Edit'),
                                                  ),
                                                ),
                                                Center(
                                                  child: ElevatedButton(
                                                    onPressed: () => {
                                                      if (inTheater
                                                          .toString()
                                                          .contains(
                                                              widget.movieUid))
                                                        {
                                                          firestore
                                                              .collection(
                                                                  "movies")
                                                              .doc('Model')
                                                              .update({
                                                            'inTheater':
                                                                FieldValue
                                                                    .arrayRemove([
                                                              widget.movieUid
                                                            ])
                                                          }).then((value) =>
                                                                  toast())
                                                        }
                                                      else
                                                        {
                                                          firestore
                                                              .collection(
                                                                  "movies")
                                                              .doc('Model')
                                                              .update({
                                                            'inTheater':
                                                                FieldValue
                                                                    .arrayUnion([
                                                              widget.movieUid
                                                            ])
                                                          }).then((value) =>
                                                                  toast())
                                                        }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.black,
                                                      backgroundColor:
                                                          Colors.grey,
                                                      elevation: 0.0,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.zero,
                                                      ),
                                                    ),
                                                    child: Text(inTheater
                                                                .toString()
                                                                .contains(widget
                                                                    .movieUid) ==
                                                            true
                                                        ? 'Remove movie from "inTheater"'
                                                        : 'Add movie to "inTheater"'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      CarouselSlider(
                                        options: CarouselOptions(
                                          autoPlay: true,
                                          reverse: false,
                                          enlargeCenterPage: false,
                                          scrollDirection: Axis.horizontal,
                                          autoPlayInterval:
                                              const Duration(seconds: 6),
                                          autoPlayAnimationDuration:
                                              const Duration(seconds: 2),
                                        ),
                                        items: commentItems,
                                      ),
                                      ListView.builder(
                                          //all comment
                                          reverse: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: shuffle == ''
                                              ? usersComment.length
                                                  .clamp(0, num)
                                              : usersComment1.length
                                                  .clamp(0, num),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection("usersComment")
                                                    .doc(shuffle == ''
                                                        ? usersComment[index]
                                                        : usersComment1[index])
                                                    .snapshots()
                                                    .take(1),
                                                builder: (context,
                                                    AsyncSnapshot snapshot) {
                                                  var name = snapshot.data
                                                      ?.get('name');
                                                  var comment = snapshot.data
                                                      ?.get('comment');
                                                  var profile = snapshot.data
                                                      ?.get('profile');
                                                  final vote =
                                                      snapshot.data?['vote'];
                                                  final countVote =
                                                      vote?.length ?? 0;

                                                  if (!snapshot.hasData) {
                                                    return Container();
                                                  }

                                                  return FutureBuilder(
                                                      future:
                                                          downloadURL(profile),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<String>
                                                              snapshot) {
                                                        if (snapshot.connectionState ==
                                                                ConnectionState
                                                                    .done &&
                                                            snapshot.hasData) {
                                                          return Column(
                                                            children: [
                                                              const Divider(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .fromLTRB(
                                                                      12.0, //Left
                                                                      10.0, //top
                                                                      0.0, //right
                                                                      10.0, //bottom
                                                                    ),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          50,
                                                                      width: 50,
                                                                      child:
                                                                          FittedBox(
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        child:
                                                                            CircleAvatar(
                                                                          backgroundColor:
                                                                              Colors.transparent,
                                                                          backgroundImage:
                                                                              NetworkImage(snapshot.data!),
                                                                          radius:
                                                                              10.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            15.0),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          name,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              250,
                                                                          child:
                                                                              Text(
                                                                            comment,
                                                                            style:
                                                                                const TextStyle(color: Colors.grey, fontSize: 11),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Column(
                                                                    children: [
                                                                      IconButton(
                                                                        icon: Icon(vote.toString().contains(userUid) ==
                                                                                true
                                                                            ? Icons.upload
                                                                            : Icons.upload_outlined),
                                                                        iconSize:
                                                                            25,
                                                                        onPressed:
                                                                            () =>
                                                                                {
                                                                          if (vote
                                                                              .toString()
                                                                              .contains(userUid))
                                                                            {
                                                                              firestore.collection("usersComment").doc(shuffle == '' ? usersComment[index] : usersComment1[index]).update({
                                                                                'vote': FieldValue.arrayRemove([
                                                                                  userUid
                                                                                ])
                                                                              }).then((value) => toast())
                                                                            }
                                                                          else
                                                                            {
                                                                              firestore.collection("usersComment").doc(shuffle == '' ? usersComment[index] : usersComment1[index]).update({
                                                                                'vote': FieldValue.arrayUnion([
                                                                                  userUid
                                                                                ])
                                                                              }).then((value) => toast())
                                                                            }
                                                                        },
                                                                      ),
                                                                      ////
                                                                      Text(
                                                                        countVote
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 9),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              const Divider(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                        return Container();
                                                      });
                                                });
                                          }),
                                      countComment > num
                                          ? Center(
                                              child: GestureDetector(
                                                  onTap: () => setState(() {
                                                        num += 5;
                                                      }),
                                                  child:
                                                      const Text('Load more')))
                                          : Container(),
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
              });
        });
  }

//Add comment
  Future openDialog(userName, profileUid, title) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            //title: const Center(child: Text('')),
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
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => {
                  Navigator.pop(context),
                  DataBase()
                      .addComment(userUid, comment.text, userName, profileUid,
                          widget.movieUid, uuid.v1(), title)
                      .then((value) => comment.clear())
                      .then((value) => toast())
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ),
            ],
          ));

//Dialog show movie info
  Future openDialog1(upvoteCount,countStars1,countStars2,countStars3,countStars4,countStars5) => showDialog(
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
                    children: [const Icon(Icons.star), Text(countStars1.toString())],
                  ),

                  Row(
                    children: [const Icon(Icons.star), const Icon(Icons.star), Text(countStars2.toString())],
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
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Ok',
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ),
            ],
          ));

//Edit movie title
  Future openDialog2(movieUid) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SizedBox(
              width: 100,
              height: 100,
              child: Column(
                children: [
                  const SizedBox(
                    height: 11,
                  ),
                  TextFormField(
                    controller: movieTitle,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        errorStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: 'New Movie Title',
                        hintStyle: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => firestore
                    .collection("movies")
                    .doc(movieUid)
                    .update({'title': movieTitle.text})
                    .then((value) => toast())
                    .then((value) => Navigator.pop(context)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Send',
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
