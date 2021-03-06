import 'dart:io';

import 'package:flutter/material.dart';
import 'package:messenger/models/message_model.dart';
import 'package:messenger/screens/chat_room/repos/message_manager.dart';
import 'package:messenger/config/themes/theme_config.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'custom_icon_btn.dart';
import 'more_options.dart';

class TextComposer extends StatefulWidget {
  const TextComposer();

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer>
    with TickerProviderStateMixin {
  bool _isComposing = false;
  late final AnimationController _expandAnimCtrl;
  late final AnimationController _composeAnimCtrl;

  TextEditingController _textController = TextEditingController();

  set isComposing(bool value) {
    if (value == _isComposing) return;
    _isComposing = value;
    if (!_isComposing) {
      _composeAnimCtrl.forward();
    } else {
      _composeAnimCtrl.reverse();
      changeExpansion(false);
    }
  }

  @override
  void initState() {
    super.initState();
    _expandAnimCtrl =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _composeAnimCtrl = AnimationController(
        vsync: this, duration: Duration(milliseconds: 200), value: 1);
  }

  @override
  void dispose() {
    _composeAnimCtrl.dispose();
    _expandAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageHandler = Provider.of<MessageHandler>(context);
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.tag_faces),
                onPressed: () {},
              ),
              Flexible(
                child: TextField(
                  controller: _textController,
                  onChanged: (String text) {
                    setState(() => isComposing = text.length > 0);
                  },
                  // onSubmitted: isComposing ? _handleSubmitted : null,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Send a message',
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border:
                        customOutlineInputBorder(Theme.of(context).accentColor),
                    enabledBorder:
                        customOutlineInputBorder(Theme.of(context).accentColor),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              CustomIconButton(
                visualDensity: VisualDensity.compact,
                icon: _isComposing
                    ? Icon(Icons.send)
                    : Icon(Icons.keyboard_voice),
                onPressed: _isComposing
                    ? () =>
                        sendMessage(messageHandler, text: _textController.text)
                    : () {},
              ),
              SizeTransition(
                axis: Axis.horizontal,
                axisAlignment: -1,
                sizeFactor: CurvedAnimation(
                  parent: _composeAnimCtrl,
                  curve: Curves.easeInOut,
                  reverseCurve: Curves.easeInOut,
                ),
                child: CustomIconButton(
                  visualDensity: VisualDensity.compact,
                  icon: AnimatedBuilder(
                    animation: CurvedAnimation(
                      parent: _expandAnimCtrl,
                      curve: Curves.fastOutSlowIn,
                    ),
                    child: Icon(Icons.keyboard_arrow_down),
                    builder: (context, child) => Transform.rotate(
                        child: child, angle: _expandAnimCtrl.value * -math.pi),
                  ),
                  onPressed: () =>
                      changeExpansion(!_expandAnimCtrl.isCompleted),
                ),
              ),
            ],
          ),
          MessageOptionsView(
            animationController: _expandAnimCtrl,
            sendMessage: (handler, file) => sendMessage(handler, file: file),
          ),
        ],
      ),
    );
  }

  changeExpansion(bool expand) {
    if (expand)
      _expandAnimCtrl.forward();
    else
      _expandAnimCtrl.reverse();
  }

  sendMessage(MessageHandler handler, {File? file, String? text}) {
    var message = Message(
      text: text,
      imageFile: file,
      animController: AnimationController(
          vsync: this, duration: Duration(milliseconds: 300)),
    );
    handler.sendMessage(message);
    _textController.clear();
    setState(() {
      isComposing = false;
    });
  }
}
