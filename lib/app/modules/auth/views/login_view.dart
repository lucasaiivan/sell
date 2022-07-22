import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sell/app/modules/auth/controller/login_controller.dart';
import 'package:url_launcher/url_launcher.dart';

// RELEASE
// En esta pantalla de inicio de sesión, agregaremos un logotipo, dos campos de texto y firmaremos con el botón de Google

// ignore: must_be_immutable
class AuthView extends GetView<LoginController> {
  AuthView({Key? key}) : super(key: key);

  // var
  static Color colorFondo = Colors.deepPurple, colorAccent = Colors.deepPurple;
  final PageController _controller = PageController();
  late Size
      screenSize; // Obtenemos las vavriables de la dimension de la pantalla

  @override
  Widget build(BuildContext context) {
    // Obtenemos los valores
    screenSize = MediaQuery.of(context).size;
    colorFondo = Theme.of(context).brightness == Brightness.dark
        ? Colors.deepPurple
        : Colors.white;
    colorAccent = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : colorAccent;

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: body(context: context),
    );
  }

  /// WIDGETS VIEWS
  Widget body({required BuildContext context}) {
    // Definimos los estilos de colores de los botones
    Color colorAccent = Theme.of(context).brightness == Brightness.dark
        ? Colors.deepPurple
        : Colors.white;
    Color colorButton = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.deepPurple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            child: onboarding(
                context: context,
                colorContent: colorButton,
                colorFondo: colorFondo,
                height: double.infinity,
                width: double.infinity)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.all(14.0),
              onPrimary: Colors.white,
              primary: colorButton,
              shadowColor: colorButton,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: BorderSide(color: colorButton)),
              side: BorderSide(color: colorButton),
            ),
            icon: FaIcon(FontAwesomeIcons.google, color: colorAccent),
            label: Text('iniciar sesión con google',
                style: TextStyle(
                    color: colorAccent,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold)),
            onPressed: controller.login,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: widgetCheckAcceptPrivacyAndUsePolicy(),
        ),
      ],
    );
  }

  /// WIDGETS COMPONENT
  Widget widgetCheckAcceptPrivacyAndUsePolicy() {
    TextStyle defaultStyle =
        TextStyle(color: Get.theme.textTheme.bodyText1!.color);
    TextStyle linkStyle = const TextStyle(color: Colors.blue);

    RichText text = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: defaultStyle,
        children: <TextSpan>[
          const TextSpan(
              text:
                  'Al hacer clic en INICIAR SESIÓN, usted ah leído y acepta nuestros '),
          TextSpan(
              text: 'Términos y condiciones de uso',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final Uri url = Uri.parse(
                      'https://sites.google.com/view/producto-app/t%C3%A9rminos-y-condiciones-de-uso/');
                  if (!await launchUrl(url)) throw 'Could not launch $url';
                }),
          const TextSpan(text: ' así también como la '),
          TextSpan(
              text: 'Política de privacidad',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final Uri url = Uri.parse(
                      'https://sites.google.com/view/producto-app/pol%C3%ADticas-de-privacidad');
                  if (!await launchUrl(url)) throw 'Could not launch $url';
                }),
        ],
      ),
    );

    return Obx(() => Padding(
          padding: const EdgeInsets.all(8.0),
          child: CheckboxListTile(
            checkColor: Colors.white,
            activeColor: Colors.blue,
            title: text,
            value: controller.getStateCheckAcceptPrivacyAndUsePolicy,
            onChanged: (value) =>
                controller.setStateCheckAcceptPrivacyAndUsePolicy = value!,
          ),
        ));
  }

  Widget dotsIndicator(
      {required BuildContext context,
      required PageController pageController,
      required List pages}) {
    return DotsIndicator(
      controller: pageController,
      itemCount: pages.length,
      color: colorAccent,
      onPageSelected: (int page) {
        _controller.animateToPage(page,
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      },
    );
  }

  Widget onboarding(
      {required BuildContext context,
      Color? colorContent,
      Color colorFondo = Colors.transparent,
      double width = double.infinity,
      double height = 200}) {
    // Pantallas integradas para la introducción a la aplicación

    List<Widget> pages = [
      componente(
          iconData: Icons.monetization_on,
          texto: "VENTAS",
          descripcion:'Registra tus ventas de una forma simple 😊',
          brightness: Get.theme.brightness),
      componente(
          iconData: Icons.analytics_outlined,
          texto: "TRANSACCIONES",
          descripcion:'Observa las transacciones que has realizado 💰',
          brightness: Get.theme.brightness),
      componente(
          iconData: Icons.category,
          texto: "CATÁLOGO",
          descripcion: "Arma tu catálogo y controla el stock de tus productos \n 🍫🍬🥫🍾",
          brightness: Get.theme.brightness),
    ];

    return SizedBox(
      width: width,
      height: height,
      child: Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        body: PageView(
          // Una lista desplazable que funciona página por página. */
          controller:
              _controller, //  El initialPageparámetro establecido en 0 significa que el primer elemento secundario del widget PageViewse mostrará primero (ya que es un índice basado en cero) */
          pageSnapping: true, // Deslizaiento automatico */
          scrollDirection: Axis.horizontal, // Dirección de deslizamiento */
          children: pages,
        ),
        floatingActionButton: dotsIndicator(context: context, pageController: _controller, pages: pages),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget componente(
      {required IconData iconData,
      required String texto,
      required String descripcion,
      String assetName = '',
      Brightness brightness = Brightness.light}) {
    // var
    AssetImage assetImage = AssetImage(assetName);
    Color colorPrimary = Get.theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.deepPurple;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            assetName != ''
                ? CircleAvatar(
                    backgroundImage: assetImage,
                    radius: 80,
                  )
                : Icon(iconData,
                    size: 100.0, color: colorPrimary.withOpacity(0.5)),
            const SizedBox(height: 20.0),
            Text(texto,
                style: TextStyle(fontSize: 20.0, color: colorPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 12.0),
            descripcion != ""
                ? Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: colorPrimary.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget buttonRoundAppBar(
          {required void Function() onPressed,
          required BuildContext context,
          Widget? child,
          required IconData icon,
          required EdgeInsets edgeInsets}) =>
      Material(
          color: Colors.transparent,
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Ink(
                      decoration: ShapeDecoration(
                          color: Brightness.dark == Theme.of(context).brightness
                              ? Colors.black
                              : Colors.white,
                          shape: const CircleBorder()),
                      child: child ??
                          IconButton(
                              icon: Icon(icon),
                              color: Brightness.dark ==
                                      Theme.of(context).brightness
                                  ? Colors.white
                                  : Colors.black,
                              onPressed: onPressed)))));
}

/// Un indicador que muestra la página actualmente seleccionada de un PageController
class DotsIndicator extends AnimatedWidget {
  DotsIndicator(
      {required this.controller,
      required this.itemCount,
      required this.onPageSelected,
      this.color = Colors.white})
      : super(listenable: controller);
  // El PageController que representa este DotsIndicator.
  final PageController controller;
  // La cantidad de elementos administrados por PageController
  final int itemCount;
  // Llamado cuando se toca un punto
  final ValueChanged<int> onPageSelected;

  // El color de los puntos.
  // Defaults to `Colors.white`.
  final Color color;
  // El tamaño base de los puntos
  static const double _kDotSize = 8.0;
  // El aumento en el tamaño del punto seleccionado.
  static const double _kMaxZoom = 2.0;
  // La distancia entre el centro de cada punto
  static const double _kDotSpacing = 25.0;

  Widget _buildDot(int index) {
    // values
    late double selectedness;
    try {
      selectedness = Curves.easeOut.transform(max(0.0,
          1.0 - ((controller.page ?? controller.initialPage) - index).abs()));
    } catch (_) {
      // failed: controller.page
      selectedness= 0;
    }
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;

    return SizedBox(
      width: _kDotSpacing,
      height: _kDotSpacing,
      child: Center(
        child: Material(
          color: color,
          type: MaterialType.circle,
          child: SizedBox(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: InkWell(onTap: () => onPageSelected(index)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
