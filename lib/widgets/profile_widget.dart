import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Center(
      child:
       Stack(
        children: [Center(
          child: Container( height:200 ,width: 200,
            
            decoration: BoxDecoration(
               
                                  
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: 
                                  LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            tileMode: TileMode.clamp,
                            colors: <Color>[
                              Colors.amber,
                            
                              // Colors.teal,
                              Colors.pink,
                            ],
                          ),
                          
                          ),),
        ),
          Column(
            children: [
              Container(height: 5,),
              Center(
                child: Container(height:190 ,width: 190,
                 
                 
                
                     child: buildImage()
                  ),
              ),
            ],
          ),
          // Positioned(
          //   bottom: 0,
          //   right: 4,
          //   child: buildEditIcon(color),
          // ),
        ],
      ),
   
    );
  }

  Widget buildImage() {
    final image = NetworkImage(imagePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl:
                         imagePath,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                                   LinearProgressIndicator(
                                  value: downloadProgress.progress,color: Colors.blueGrey.shade900,),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
