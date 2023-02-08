import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TowerBoxGame(),
    );
  }
}

class TowerBoxGame extends StatefulWidget {
  const TowerBoxGame({Key? key}) : super(key: key);

  @override
  State<TowerBoxGame> createState() => _TowerBoxGameState();
}

class _TowerBoxGameState extends State<TowerBoxGame> with TickerProviderStateMixin {
  TextEditingController _blockController = TextEditingController();
  late AnimationController _controller;
  double width = 50;
  double height = 70;
  int boxCount = 10;
  bool isPressed1 = false;
  bool isPressed2 = false;
  bool isTapPink = false;
  bool isTapBlue = false;
  final _random = Random();
  late Timer _timer;
  bool gameStart = false;
  Stopwatch stopwatch = Stopwatch();
  late Timer _timerCounter1;
  late Timer _timerCounter2;
  int _counter = 0;

  List<Color> _colorRandomList = [Colors.pink, Colors.blue];
  List<ShapeColorModel> _colorList = [];

  @override
  void initState() {
    _randomColor();

    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }
  // ข้อแตกต่างระหว่าง CustomPainter กับ CustomClipper คือ  CustomPainter สามารถลงสีได้
  _randomColor() async {
    stopwatch.stop();
    stopwatch.reset();

    for (int i = 1; i <= boxCount; i++) {
      var index = _random.nextInt(_colorRandomList.length);
      await Future.delayed(Duration(milliseconds: 150));

      setState(() {
        if (i == boxCount) {

          _colorList.add(ShapeColorModel(
              color: _colorRandomList[index],
              uniqueShape: true,
              widget: ClipPath(
                clipper: DiamondClipper(),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: _colorRandomList[index],
                    shape: BoxShape.rectangle,
                  ),
                  /*child: CustomPaint(
                 painter: DiamondPainter(color: _colorRandomList[index]),
               ),*/
                ),
              )));

        } else {

          _colorList.add(ShapeColorModel(
              color: _colorRandomList[index],
              uniqueShape: false,
              widget: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                      color: _colorRandomList[index],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, spreadRadius: .4, blurRadius: 1)
                      ]),
                ),
              )));
        }

      });

    }
  }

  _gameStart() {
    if (_colorList.length <= boxCount) {
      gameStart = true;
      stopwatch.start();
    } else {
      gameStart = false;
    }
  }

  _gameStop() {
    stopwatch.stop();
  }

  _removeColor({required Color color, required BuildContext ctx}) {
    setState(() {
      if (_colorList.first.color == color && _colorList.first.uniqueShape == false) {
        if (_colorList.first.uniqueShape == false && (isTapBlue && isTapPink)) {
          _counter = 0;
          isTapPink = false;
          isTapBlue = false;
          _timerCounter1.cancel();
          _timerCounter2.cancel();
          showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                    title: const Text('กดทีละปุ่ม'),
                    content: const Text('ลองใหม่'),
                    actions: [
                      CupertinoDialogAction(
                          child: const Text('ตกลง'),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  ));
        } else {
          _colorList.removeAt(0);
          _counter = 0;
          isTapPink = false;
          isTapBlue = false;
          _gameStart();
        }
      } else if ((isTapBlue && isTapPink) && _colorList.first.uniqueShape == true) {
        if (_colorList.first.uniqueShape && isPressed1 && isPressed2) {
          _colorList.removeAt(0);
          _counter = 0;

          isPressed1 = false;
          isPressed2 = false;
          isTapPink = false;
          isTapBlue = false;
          _gameStop();
          showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                    title: const Text('Congratulations'),
                    content: Column(
                      children: [
                        const Text('You Win'),
                        const Text(' 🎉 🎉'),
                        Text('เวลาที่ใช้ทั้งหมดคือ : \n${stopwatch.elapsed.toString()}'),
                      ],
                    ),
                    actions: [
                      CupertinoDialogAction(
                          child: const Text('Restart'),
                          onPressed: () {
                            _randomColor();
                            Navigator.pop(context);
                          }),
                    ],
                  ));
        }
      } else if ((isTapBlue || isTapPink) && _colorList.first.uniqueShape == true) {
        isTapPink = false;
        isTapBlue = false;
        showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: const Text('กด 2 ปุ่มพร้อมกัน'),
                  content: const Text('ลองใหม่'),
                  actions: [
                    CupertinoDialogAction(
                        child: const Text('ตกลง'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ));
      } else if ((isTapBlue || isTapPink) && _colorList.first.uniqueShape == false) {
        isTapPink = false;
        isTapBlue = false;
        showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: const Text('สีไม่ตรงปุ่ม'),
                  content: const Text('ลองใหม่'),
                  actions: [
                    CupertinoDialogAction(
                        child: const Text('ตกลง'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ));
      }
    });
  }

  void incrementCounter() {
    setState(() {
      _counter++;
    });
  }



  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    print(orientation);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: Stack(
          children: [
            _buildListColors(context),
            _buildArrowLeft(orientation, context),
            _buildArrowRight(orientation, context),
            _buildTimerToRemoveBlock(orientation, context),
            _buildStopWatch(orientation, context),
            _checkPortrait(orientation)
                ? const Positioned(child: SizedBox())
                : Positioned(left: 0, top: 0, bottom: 0, child: _removePinkButton(context)),
            _checkPortrait(orientation)
                ? const Positioned(child: SizedBox())
                : Positioned(right: 0, top: 0, bottom: 0, child: removeBlueButton(context)),
            Positioned(
                right: _checkPortrait(orientation) ? 0 : MediaQuery.of(context).size.width * .15, top: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap : (){
                      showCupertinoDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('ระบุจำนวนกล่อง'),
                            content: CupertinoTextField(
                              controller: _blockController,
                              keyboardType: TextInputType.number,
                            ),
                            actions: [
                              CupertinoDialogAction(
                                  child: const Text('ตกลง'),
                                  onPressed: () {
                                    setState(() {
                                      var count = int.parse(_blockController.text);
                                      boxCount = count;
                                    });
                                    _colorList = [];
                                    _randomColor();
                                    gameStart = false;
                                    Navigator.pop(context);
                                  }),
                            ],
                          ));
                    },
                    child: Container(
                        width: 100,
                        height: 50,
                        color: Colors.orange,
                        child: Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('จำนวนกล่อง'),
                            Text('$boxCount'),
                          ],
                        ))),
                  ),
                )),
          ],
        ),
        bottomNavigationBar: _checkPortrait(orientation)
            ? SizedBox(
                height: 150,
                child: BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [_removePinkButton(context), removeBlueButton(context)],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Positioned _buildStopWatch(Orientation orientation, BuildContext context) {
    return Positioned(
        left: _checkPortrait(orientation) ? 0 : MediaQuery.of(context).size.width * .15,
        child: Visibility(
          visible: gameStart,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 150,
                child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          stopwatch.elapsed.toString(),
                        ),
                      );
                    }),
              )),
        ));
  }

  Positioned _buildTimerToRemoveBlock(Orientation orientation, BuildContext context) {
    return Positioned(
        right: _checkPortrait(orientation) ? 0 : MediaQuery.of(context).size.width * .15,
        top: 70,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedContainer(
              width: (isTapPink || isTapBlue) ? 100 : 40,
              color: Colors.white,
              duration: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text('$_counter')),
              )),
        ));
  }

  Positioned _buildArrowRight(Orientation orientation, BuildContext context) {
    return Positioned(
        bottom: 10,
        right: isPortrait(orientation, context),
        child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 50,
              color: Colors.white,
            )));
  }

  Positioned _buildArrowLeft(Orientation orientation, BuildContext context) {
    return Positioned(
        bottom: 10,
        left: isPortrait(orientation, context),
        child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_forward_ios_sharp, size: 50, color: Colors.white)));
  }

  _buildListColors(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width   * .3,
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
            itemCount: _colorList.length,
            reverse: true,
            // physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(width: 150, child: _colorList[index].widget);
            }
      ),
      )
    );
  }

  bool _checkPortrait(Orientation orientation) => orientation == Orientation.portrait;

  removeBlueButton(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.white,
      onPressed: () {},
      child: GestureDetector(
        child: const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue,
        ),
        onTapDown: (d) {
          setState(() {
            isTapBlue = true;
          });

          _timerCounter2 = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              incrementCounter();
            });
          });
          if (isTapBlue && isTapPink) {
            _timerCounter1.cancel();
          }
          _timer = Timer(const Duration(seconds: 3), () {
            print('LongPress Event');
            setState(() {
              isPressed2 = true;
              _counter = 0;
              _timerCounter2.cancel();
              _removeColor(color: Colors.blue, ctx: context);
            });
          });
        },
        onTapUp: (_) {
          _timer.cancel();
          _timerCounter2.cancel();

          if (!isPressed2) {
            setState(() {
              isTapBlue = false;
              _counter = 0;
              _timerCounter2.cancel();
            });
            showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                      content: Column(
                        children: [
                          const Text('กดปุ่มทีสีตรงกันค้างไว้ 2 วิ เพื่อทำลาย Block'),
                        ],
                      ),
                      actions: [
                        CupertinoDialogAction(
                            child: const Text('ตกลง'),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    ));
          } else {
            setState(() {
              isTapBlue = false;
              isPressed2 = false;
              _counter = 0;
              _timerCounter2.cancel();
            });
          }
        },
      ),
    );
  }

   _removePinkButton(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      onPressed: () {},
      child: GestureDetector(
        child: const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.pink,
        ),
        onTapDown: (d) {
          setState(() {
            isTapPink = true;
          });
          _timerCounter1 = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              incrementCounter();
            });
          });
          if (isTapBlue && isTapPink) {
            _timerCounter2.cancel();
          }
          _timer = Timer(const Duration(seconds: 3), () {
            print('LongPress Event');
            setState(() {
              isPressed1 = true;
              _counter = 0;
              _timerCounter1.cancel();
              _removeColor(color: Colors.pink, ctx: context);
            });
          });
        },
        onTapUp: (_) {
          _timer.cancel();
          _timerCounter1.cancel();

          if (!isPressed1) {
            setState(() {
              isTapPink = false;
              _counter = 0;
              _timerCounter1.cancel();
            });
            showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                      content: Column(
                        children: [
                          const Text('กดปุ่มทีสีตรงกันค้างไว้ 2 วิ เพื่อทำลาย Block'),
                        ],
                      ),
                      actions: [
                        CupertinoDialogAction(
                            child: const Text('ตกลง'),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    ));
          } else {
            setState(() {
              isTapPink = false;
              isPressed1 = false;
              _counter = 0;
              _timerCounter1.cancel();
            });
          }
        },
      ),
    );
  }

  double isPortrait(Orientation orientation, BuildContext context) => _checkPortrait(orientation)
      ? MediaQuery.of(context).size.width * .11
      : MediaQuery.of(context).size.width * .2;
}

class DiamondPainter extends CustomPainter {
  final Color color;

  DiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ShapeColorModel {
  final Color color;
  final Widget widget;
  final bool uniqueShape;

  ShapeColorModel({
    required this.color,
    required this.widget,
    required this.uniqueShape,
  });
}
