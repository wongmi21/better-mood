import 'package:flutter/material.dart';

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;

  final addMood;

  FancyFab(this.addMood, {this.onPressed, this.tooltip, this.icon});

  @override
  _FancyFabState createState() => _FancyFabState(addMood);
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _backgroundColor;
  Animation<Color> _foregroundColor;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  var addMood;

  _FancyFabState(this.addMood);

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _foregroundColor = ColorTween(
      begin: Colors.white,
      end: Colors.teal,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _backgroundColor = ColorTween(
      begin: Colors.teal,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget mood_5() {
    return Container(
      width: 50,
      height: 50,
      child: FloatingActionButton(
        heroTag: 'fab5',
        elevation: 0,
        onPressed: () {
          addMood(5);
        },
        child: Image(image: AssetImage('assets/mood_5.png')),
      ),
    );
  }

  Widget mood_4() {
    return Container(
      width: 50,
      height: 50,
      child: FloatingActionButton(
        heroTag: 'fab4',
        elevation: 0,
        onPressed: () {
          addMood(4);
        },
        child: Image(image: AssetImage('assets/mood_4.png')),
      ),
    );
  }

  Widget mood_3() {
    return Container(
      width: 50,
      height: 50,
      child: FloatingActionButton(
        heroTag: 'fab3',
        elevation: 0,
        onPressed: () {
          addMood(3);
        },
        child: Image(image: AssetImage('assets/mood_3.png')),
      ),
    );
  }

  Widget mood_2() {
    return Container(
      width: 50,
      height: 50,
      child: FloatingActionButton(
        heroTag: 'fab2',
        elevation: 0,
        onPressed: () {
          addMood(2);
        },
        child: Image(image: AssetImage('assets/mood_2.png')),
      ),
    );
  }

  Widget mood_1() {
    return Container(
      width: 50,
      height: 50,
      child: FloatingActionButton(
        heroTag: 'fab1',
        elevation: 0,
        onPressed: () {
          addMood(1);
        },
        child: Image(image: AssetImage('assets/mood_1.png')),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'fab0',
        backgroundColor: _backgroundColor.value,
        foregroundColor: _foregroundColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: ImageIcon(AssetImage('assets/happy_sad_icon.png')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return orientation == Orientation.portrait
            ? fabMenuVertical()
            : fabMenuHorizontal();
      },
    );
  }

  Widget fabMenuVertical() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            (-6.0 + _translateButton.value) * 5.0,
            0.0,
          ),
          child: mood_5(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            (-6.0 + _translateButton.value) * 4.0,
            0.0,
          ),
          child: mood_4(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            (-6.0 + _translateButton.value) * 3.0,
            0.0,
          ),
          child: mood_3(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            (-6.0 + _translateButton.value) * 2.0,
            0.0,
          ),
          child: mood_2(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            (-6.0 + _translateButton.value),
            0.0,
          ),
          child: mood_1(),
        ),
        toggle(),
      ],
    );
  }

  Widget fabMenuHorizontal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            (-6.0 + _translateButton.value) * 5.0,
            0.0,
            0.0,
          ),
          child: mood_5(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            (-6.0 + _translateButton.value) * 4.0,
            0.0,
            0.0,
          ),
          child: mood_4(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            (-6.0 + _translateButton.value) * 3.0,
            0.0,
            0.0,
          ),
          child: mood_3(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            (-6.0 + _translateButton.value) * 2.0,
            0.0,
            0.0,
          ),
          child: mood_2(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            (-6.0 + _translateButton.value),
            0.0,
            0.0,
          ),
          child: mood_1(),
        ),
        toggle(),
      ],
    );
  }
}
