import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/font.dart';
import '../bloc/italic.dart';
import '../bloc/size.dart';
import '../globals.dart';
import './list.dart';

final String ps23 =
    "The Lord is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters, he refreshes my soul. He guides me along the right paths for his name’s sake. Even though I walk through the darkest valley, I will fear no evil, for you are with me; your rod and your staff, they comfort me. You prepare a table before me in the presence of my enemies. You anoint my head with oil; my cup overflows. Surely your goodness and love will follow me all the days of my life, and I will dwell in the house of the Lord forever.";

class FontsPage extends StatefulWidget {
  const FontsPage({super.key});

  @override
  State<FontsPage> createState() => _FontsPageState();
}

class _FontsPageState extends State<FontsPage> {

  late int selectedFont;
  late int fontNumber;
  late bool italicIsOn;
  late double textSize;

  @override
  void initState() {
    super.initState();
    selectedFont = context.read<FontBloc>().state;
    italicIsOn = context.read<ItalicBloc>().state;
    textSize = context.read<SizeBloc>().state;
  }

  Future<dynamic> fontConfirmDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(fontsList[fontNumber]),
          content: Text(
            ps23,
            softWrap: true,
            style: TextStyle(
              fontFamily: fontsList[fontNumber],
              fontStyle: (italicIsOn) ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<FontBloc>().add(
                        UpdateFont(font: fontNumber),
                      );
                      Future.delayed(
                        Duration(milliseconds: Globals.navigatorDelay),
                            () {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                          setState(() {
                            selectedFont = fontNumber;
                          });
                        },
                      );
                    },
                    child: Text('Yes'),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: GestureDetector(
            child: const Icon(Icons.arrow_back),
            onTap: () {
              //backButton(context);
              Future.delayed(
                Duration(milliseconds: Globals.navigatorDelay),
                    () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
          //elevation: 16,
          title: Text(
            "Font Size $textSize",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
          ],
        ),
        body: Center(
          child: ListView.builder(
            itemCount: fontsList.length,
            itemBuilder: (BuildContext context, int index) {
              String t = (italicIsOn) ? 'Italic' : 'Normal';

              return ListTile(
                title: Text(
                  "${fontsList[index]} $t",
                  style: TextStyle(
                    fontStyle: (italicIsOn)
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
                subtitle: Text(
                  'The Lord is my shepherd.',
                  style: TextStyle(
                    backgroundColor: (index == selectedFont)
                        ? Theme.of(context).colorScheme.tertiaryContainer
                        : null,
                    fontStyle: (italicIsOn)
                        ? FontStyle.italic
                        : FontStyle.normal,
                    fontFamily: fontsList[index],
                    fontSize: textSize,
                  ),
                ),
                onTap: () {
                  fontNumber = index;

                  fontConfirmDialog(context);
                },
              );
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: "size",
              icon: const Icon(Icons.format_size),
              label: Text("${textSize.toInt()}"),
              onPressed: changeFontSize,
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: "italic",
              icon: Icon(italicIsOn ? Icons.format_italic : Icons.text_fields),
              label: Text(italicIsOn ? "Italic" : "Normal"),
              onPressed: () {
                context.read<ItalicBloc>().add(
                  ChangeItalic(italicIsOn: !italicIsOn),
                );
                setState(() => italicIsOn = !italicIsOn);
              },
            ),
          ],
        ),
        floatingActionButtonLocation: const EndTopFloatingActionButtonLocation(
          horizontalMargin: 16.0,
          verticalOffset: 10.0,
        ),
      ),
    );
  }

  void changeFontSize() {
    double tempSize = textSize;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Adjust Font Size"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (tempSize > 12) setState(() => tempSize -= 2);
                    },
                  ),
                  Text(
                    tempSize.toInt().toString(),
                    style: const TextStyle(fontSize: 24),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (tempSize < 32) setState(() => tempSize += 2);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<SizeBloc>().add(UpdateSize(size: tempSize));
                setState(() => textSize = tempSize);
                Navigator.pop(context);
              },
              child: const Text("OK", style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }
}

class EndTopFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const EndTopFloatingActionButtonLocation({
    required this.horizontalMargin,
    required this.verticalOffset,
  });

  final double horizontalMargin;
  final double verticalOffset;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Size fabSize = scaffoldGeometry.floatingActionButtonSize;

    // x: place at right side with margin and respect insets (e.g. keyboard)
    final double x =
        scaffoldGeometry.scaffoldSize.width -
            fabSize.width -
            horizontalMargin -
            scaffoldGeometry.minInsets.right;

    // y: use the top inset (status bar) plus the toolbar height and a small offset
    final double y =
        scaffoldGeometry.minInsets.top + kToolbarHeight + verticalOffset;

    return Offset(x, y);
  }
}
