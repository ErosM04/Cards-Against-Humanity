import 'package:cards_against_humanity/pages/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// A page containg random fetched images of cats, that can be refreshed by clicking on it.
class EasterEgg extends StatefulWidget {
  const EasterEgg({super.key});

  @override
  State<EasterEgg> createState() => _EasterEggState();
}

class _EasterEggState extends State<EasterEgg> {
  /// The url of the api to get cats images.
  final String _url = 'https://cataas.com/cat';

  /// The [Widget] to display in the center of the screen.
  late Widget _image;

  @override
  void initState() {
    _image = Image.network(_url);
    _updateImgWidget();
    super.initState();
  }

  /// Set the ``[_image]`` as a ``[CircularProgressIndicator]`` and meanwhile performs a request to the api.
  ///
  /// When the request is completed updates the ``[_image]`` loading an ``[Image]`` with the "memory()" constructor because
  /// uses the bytes of the response to create the image.
  _updateImgWidget() async {
    setState(() => _image = const CircularProgressIndicator());
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(_url)).load(_url))
        .buffer
        .asUint8List();
    setState(() => _image = Image.memory(bytes));
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
            child: Center(child: _image),
          ),
        ),
      );
}
