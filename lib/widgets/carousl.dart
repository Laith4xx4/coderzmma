import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Carousl extends StatefulWidget {
  const Carousl({super.key});

  @override
  State<Carousl> createState() => _CarouslState();
}

class _CarouslState extends State<Carousl> {
  final List<Widget> products = [
    Image.asset('assets/e2.png', fit: BoxFit.cover),
    Image.asset('assets/e3.png', fit: BoxFit.cover),
    Image.asset('assets/e4.png', fit: BoxFit.cover),
    Image.asset('assets/e5.png', fit: BoxFit.cover),
    Image.asset('assets/mma4.png', fit: BoxFit.cover),
  ];

  final List<String> productNames = [
    'Boxing',
    'MMA',
    'Kickboxing',
    'Muay Thai',
    'Jiu-Jitsu',
    // 'Wrestling',
    // 'Karate',
    // 'Taekwondo',
    // 'Judo',

  ];


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return CarouselSlider.builder(
      itemCount: products.length,
      itemBuilder: (context, index, realIndex) {
        return GestureDetector(
          onTap: () {
            // هنا يمكن إضافة حدث عند الضغط على المنتج
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                products[index],
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    color: Colors.black54,
                    child: Text(
                      productNames[index],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: screenHeight * 0.25,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
    );
  }
}
