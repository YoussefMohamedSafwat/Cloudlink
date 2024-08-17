import 'dart:io';

import 'package:appchat/Screens/widgets/ImageButton.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/helper/dialogs.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.currentUser});

  final ChatUser currentUser;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Profile Screen"),
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              onPressed: () async {
                Dialogs.showProgressBar(context);
                await Apis.updateActiveStatus(false);
                await Apis.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {});
                  Navigator.pop(context);
                  Apis.auth = FirebaseAuth.instance;
                  Navigator.pushReplacementNamed(context, "/");
                });
              },
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            )),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * 0.1),
                                child: Image.file(
                                  File(_image!),
                                  fit: BoxFit.fill,
                                  height: mq.height * 0.2,
                                  width: mq.height * 0.2,
                                ),
                              )
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * 0.1),
                                child: CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  height: mq.height * 0.2,
                                  width: mq.height * 0.2,
                                  imageUrl: widget.currentUser.image,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                    child: Icon(
                                      CupertinoIcons.person,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.currentUser.email,
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    initialValue: widget.currentUser.name,
                    onSaved: (val) => Apis.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'required Field',
                    decoration: InputDecoration(
                      label: const Text(
                        "Name",
                        style: TextStyle(fontSize: 18),
                      ),
                      hintText: "eg: john doe",
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    initialValue: widget.currentUser.about,
                    onSaved: (val) => Apis.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'required Field',
                    decoration: InputDecoration(
                      label: const Text(
                        "about",
                        style: TextStyle(fontSize: 18),
                      ),
                      hintText: "eg: feeling happy",
                      prefixIcon: const Icon(
                        Icons.info,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Apis.updateUserInfo();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        iconColor: Colors.white,
                        backgroundColor: Colors.blue,
                        minimumSize: Size(mq.width * 0.4, mq.height * 0.055)),
                    label: const Text(
                      "Update",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    icon: const Icon(
                      Icons.edit,
                      size: 30,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            children: [
              const Text(
                "Pick profile picture ",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: mq.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Imagebutton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                        }
                        Apis.UpdateProfilePicture(File(_image!));
                        Navigator.pop(context);
                      },
                      image: _image,
                      path: "assets/images/googlePhoto.png"),
                  Imagebutton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                        }
                        Apis.UpdateProfilePicture(File(_image!));
                        Navigator.pop(context);
                      },
                      image: _image,
                      path: "assets/images/Camera.png")
                ],
              )
            ],
          );
        });
  }
}
