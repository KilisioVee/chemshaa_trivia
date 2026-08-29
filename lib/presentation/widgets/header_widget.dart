import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 61,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Text(
            'ChemShaa',
            style: TextStyle(
              color: Color(0xFF101010),
              fontFamily: 'serif',
              fontSize: 25,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: IconButton(
              tooltip: 'More options',
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF101010),
                size: 29,
              ),
            ),
          ),
        ],
      ),
    );
  }
}