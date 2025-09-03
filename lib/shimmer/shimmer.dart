import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CoinShimmer extends StatelessWidget {
  const CoinShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10, // show 10 shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              title: Container(
                height: 12,
                width: double.infinity,
                color: Colors.white,
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(top: 6),
                height: 12,
                width: 100,
                color: Colors.white,
              ),
              trailing: Icon(Icons.heart_broken, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
