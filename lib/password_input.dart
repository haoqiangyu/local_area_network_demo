import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class VerificationCodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => VerificationCodeState();
}

class VerificationCodeState extends State<VerificationCodePage> {
  Future<void> _loadImage(ExactAssetImage image) async {
    AssetBundleImageKey key = await image.obtainKey(ImageConfiguration());
    final ByteData data = await key.bundle.load(key.name);
    if (data == null) throw 'Unable to read data';
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    // add additional checking for number of frames etc here
    var frame = await codec.getNextFrame();
    this.image = frame.image;
  }

  ui.Image image;

  Future future;

  @override
  void initState() {
    super.initState();
    future = _loadImage(ExactAssetImage("assets/images/icon_input_bg.png"));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            var imageBorder = CustomImageInputBorder(
              letterSpace: 60.0,
              textSize: 50.0,
              textLength: 4,
              image: image,
            );
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasError) return Container();
                return VerificationCodeInput(
                  codeLength: 4,
                  textSize: 50.0,
                  letterSpace: 60.0,
                  inputBorder: imageBorder,
                );
                break;
              default:
                return Container();
                break;
            }
          });
  }
}

class VerificationCodeInput extends StatefulWidget {
  final double letterSpace;
  final double textSize;
  final int codeLength;
  final InputBorder inputBorder;

  VerificationCodeInput({
    Key key,
    this.letterSpace = 20.0,
    this.textSize = 20.0,
    this.codeLength = 4,
    this.inputBorder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => VerificationCodeInputState();
}

class VerificationCodeInputState extends State<VerificationCodeInput> {
  double textTrueWidth;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: widget.codeLength,
      keyboardType: TextInputType.number,
      style: TextStyle(
          fontSize: widget.textSize,
          color: Colors.black87,
          letterSpacing: widget.letterSpace),
      decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 14.0, letterSpacing: 0.0),
          enabledBorder: widget.inputBorder,
          focusedBorder: widget.inputBorder),
      cursorWidth: 0.0,
        enableInteractiveSelection:false,
      onChanged: (text){
//        if(text.length >=4){
//          FocusScope.of(context).unfocus(focusPrevious: true);
//        }
      },
    );
  }
}

abstract class InputBorder extends UnderlineInputBorder {
  double textSize;
  double letterSpace;
  int textLength;

  double textTrueWidth;
  final double startOffset;

  void calcTrueTextSize() {
    // 测量单个数字实际长度
    var paragraph = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: textSize))
      ..addText("0");
    var p = paragraph.build()
      ..layout(ui.ParagraphConstraints(width: double.infinity));
    textTrueWidth = p.minIntrinsicWidth;
  }

  InputBorder({
    this.textSize = 0.0,
    this.letterSpace = 0.0,
    this.textLength,
    BorderSide borderSide = const BorderSide(),
  })  : startOffset = letterSpace * 0.5,
        super(borderSide: borderSide) {
    calcTrueTextSize();
  }
}

class CustomImageInputBorder extends InputBorder {
  final ui.Image image;

  CustomImageInputBorder({
    @required this.image,
    double textSize = 0.0,
    double letterSpace,
    int textLength,
    BorderSide borderSide = const BorderSide(),
  }) : super(
      textSize: textSize,
      letterSpace: letterSpace,
      textLength: textLength,
      borderSide: borderSide);

  @override
  void paint(
      Canvas canvas,
      Rect rect, {
        double gapStart,
        double gapExtent = 0.0,
        double gapPercentage = 0.0,
        TextDirection textDirection,
      }) {
    double curStartX = textTrueWidth-10;
    for (int i = 0; i < textLength; i++) {
      canvas.drawImage(image, Offset(curStartX, 0.0), Paint());
      curStartX += (textTrueWidth + letterSpace);
    }
  }
}