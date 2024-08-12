import 'package:cards_against_humanity/pages/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EasterEgg extends StatefulWidget {
  const EasterEgg({super.key});

  @override
  State<EasterEgg> createState() => _EasterEggState();
}

class _EasterEggState extends State<EasterEgg> {
  String url = 'https://cataas.com/cat';
  late Widget _pic;

  @override
  void initState() {
    _pic = Image.network(url);
    _updateImgWidget();
    super.initState();
  }

  _updateImgWidget() async {
    setState(() => _pic = const CircularProgressIndicator());
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(url)).load(url))
        .buffer
        .asUint8List();
    setState(() => _pic = Image.memory(bytes));
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: true,
        child: Scaffold(
          appBar: CustomAppBar(
              leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          )),
          body: GestureDetector(
            onTap: () => _updateImgWidget(),
            child: Center(child: _pic),
          ),
        ),
      );
}
