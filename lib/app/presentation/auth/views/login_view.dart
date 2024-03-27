import 'dart:async'; 
import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sell/app/presentation/auth/controller/login_controller.dart';
import 'package:url_launcher/url_launcher.dart';

// RELEASE
// En esta pantalla de inicio de sesión, agregaremos un logotipo, dos campos de texto y firmaremos con el botón de Google

// ignore: must_be_immutable
class AuthView extends GetView<LoginController> {
  // ignore: prefer_const_constructors_in_immutables
  AuthView({Key? key}) : super(key: key);

  // var
  late bool darkMode;
  final Color colorAccent=Colors.purple;
  late Size screenSize; // Obtenemos las vavriables de la dimension de la pantalla
  bool isExpandedView = false;

  @override
  Widget build(BuildContext context) {

    // Obtenemos los valores
    screenSize = MediaQuery.of(context).size;
    darkMode = Theme.of(context).brightness==Brightness.dark; 
    final AppBarTheme  appBarTheme= AppBarTheme(titleSpacing: 0, elevation: 0,toolbarHeight: 0,color: Colors.transparent ,systemOverlayStyle: darkMode?SystemUiOverlayStyle.light:SystemUiOverlayStyle.dark,iconTheme: IconThemeData(color: darkMode?Colors.white:Colors.white),titleTextStyle: TextStyle(color: darkMode?Colors.white:Colors.white));

  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {

      // var  
      screenSize = MediaQuery.of(context).size;
      isExpandedView = screenSize.width>600;

      return Theme(
          data: Theme.of(context).copyWith(primaryColor: colorAccent,appBarTheme: appBarTheme),
          child: Scaffold(
            appBar: AppBar(),
            body: body(context: context)),
        );
    }
  );
  }

  /// WIDGETS
  Widget body({required BuildContext context}) {
    // Definimos los estilos de colores de los botones
    Color colorButtonText0 = Colors.white;
    Color colorButton0 = Colors.blue;

    // widget
    List<Widget> widgets = [
      Flexible( child: Card(
        color: darkMode?Colors.white10:Colors.white,
        elevation:0, 
        child: OnboardingIntroduction(colorAccent: colorButton0,colorText: darkMode?Colors.white:Colors.black,))),
      SizedBox(
        width: isExpandedView?400:double.infinity,
        child: Padding(
          padding: EdgeInsets.all(isExpandedView?20.0:0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ 
                // check button : aceptar terminos y condiciones   
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FadeIn(
                    key:  Key((!controller.getStateCheckAcceptPrivacyAndUsePolicy).toString()),
                    animate:true,
                    child: ClipRRect( 
                      borderRadius: BorderRadius.circular(12.0),
                      child: Obx(() => AnimatedContainer( 
                        duration: const Duration(milliseconds:500),
                        color: controller.checkPolicyAlertColor.value ,
                        child: widgetCheckAcceptPrivacyAndUsePolicy(),
                        ))),
                  ),
                ),
                // buttons : login with google 
                button(callback: controller.login,text:"Iniciar sesión con google",colorButton: Colors.blueAccent,colorText: colorButtonText0),
                // button : login with anonymous
                button(callback: controller.signInAnonymously,text:"Entrar como invitado",colorButton: Colors.blueGrey,colorText: colorButtonText0),
                const SizedBox(height: 12.0),
              ],
              
          ),
        ),
      ),
    ];
    
    return isExpandedView?Row(children:widgets):Column(children: widgets);
  }

  /// WIDGETS COMPONENT
  Widget widgetCheckAcceptPrivacyAndUsePolicy() {

    // styles
    TextStyle defaultStyle = TextStyle( color: darkMode?Colors.white:Colors.black );
    TextStyle linkStyle = const TextStyle(color: Colors.blue);

    RichText text = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: defaultStyle,
        children: <TextSpan>[
          const TextSpan(text:'Al iniciar en INICIAR SESIÓN, usted ah leído y acepta nuestros '),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            selectedTileColor: Colors.transparent,
            checkColor: Colors.white,
            activeColor: Colors.blue,
            title: text,
            value: controller.getStateCheckAcceptPrivacyAndUsePolicy,
            onChanged: (value) => controller.setStateCheckAcceptPrivacyAndUsePolicy = value!,
          ),
        ));
  }

  Widget button({required Function() callback,required String text,Color colorText = Colors.white, Color colorButton = Colors.purple,double padding = 12}){
    return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding,vertical:padding),
          child: ElevatedButton(
            style:ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: colorButton, padding: const EdgeInsets.all(16.0),shadowColor: colorButton,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),side: BorderSide(color:colorButton)),
              side: BorderSide(color: colorButton),
            ),
            onPressed: callback,
            child: Text(text.toUpperCase(), style: TextStyle(color: colorText,fontSize: 18.0,fontWeight: FontWeight.bold)),
          ),
        );
  }

  Widget buttonRoundAppBar({required void Function() onPressed,required BuildContext context,Widget ?child,required IconData icon,required EdgeInsets edgeInsets})  => Material(color: Colors.transparent,child: Center( child: Padding(padding: const EdgeInsets.all(8.0),child: Ink(decoration: ShapeDecoration(color: Brightness.dark==Theme.of(context).brightness?Colors.black:Colors.white,shape: const CircleBorder()), child: child==null?IconButton(icon: Icon(icon),color:Brightness.dark==Theme.of(context).brightness?Colors.white:Colors.black,onPressed: onPressed):child))));
}




class OnboardingIntroduction extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  OnboardingIntroduction({this.colorAccent = Colors.deepPurple,this.colorText = Colors.white,Key? key}) : super(key: key);

  late final Color colorAccent;
  late final Color colorText;

  @override
  State<OnboardingIntroduction> createState() => _OnboardingIntroductionState();
}

class _OnboardingIntroductionState extends State<OnboardingIntroduction> {

  // variables para el estilo de la pantalla
  late bool darkMode;
  late Size screenSize;

// variables para el manejo de los indicadores de progreso  
  double indicatorProgressItem01 = 0.0;
  double indicatorProgressItem02 = 0.0;
  double indicatorProgressItem03 = 0.0;
  late Timer timer;  
  int index = 0 ;
  late List<Widget> widgets;

  // fuction  : maneja el evento de toque IZQUIERDO que cambian los valores de los indicadores de progreso y cambia la vista del item
  void leftTouch(){ 
    //  primer item : si el primer item esta en 0.0 y el segundo y tercer item estan en 0.0 entonces el primer item pasa a 1.0
    if(indicatorProgressItem01 >= 0.0  &&  indicatorProgressItem02 == 0.0 &&  indicatorProgressItem03 == 0.0 ){
      indicatorProgressItem01 = 0.0;
      indicatorProgressItem02 = 0.0;
      indicatorProgressItem03 = 0.0;
      index=0;  // siguiente vista
    }
    // segundo item : si el primer item esta en 1.0 y el segundo item esta en 0.0 y el tercer item esta en 0.0 entonces el segundo item pasa a 1.0
    else if( indicatorProgressItem01 == 1.0 &&  indicatorProgressItem02 >= 0.0 &&  indicatorProgressItem03 == 0.0 ){
      indicatorProgressItem01 = 0.0;
      indicatorProgressItem02 = 0.0;
      indicatorProgressItem03 = 0.0;
      index=1; //  siguiente vista
    }
    //  tercer item : si el primer item esta en 1.0 y el segundo item esta en 1.0 y el tercer item esta en 0.0 entonces el tercer item pasa a 1.0
    else if( indicatorProgressItem01 == 1.0 &&  indicatorProgressItem02 == 1.0 &&  indicatorProgressItem03 >= 0.0 ){
      indicatorProgressItem01 = 1.0;
      indicatorProgressItem02 = 0.0;
      indicatorProgressItem03 = 0.0;
      index=2; //  siguiente vista
    } 
    // vuelve a la vista al princio
    else{
      indicatorProgressItem01 = 0.0;
      indicatorProgressItem02 = 0.0;
      indicatorProgressItem03 = 0.0;
      index=0;
    }
  }
  // fuction  : maneja el evento de toque DERECHO que cambian los valores de los indicadores de progreso
  void rightTouch() {
    // primer item : si el primer item esta en 0.0 y el segundo y tercer item estan en 0.0 entonces el primer item pasa a 1.0
    if (indicatorProgressItem01 <= 1.00 && indicatorProgressItem02 == 0.0 && indicatorProgressItem03 == 0.0) {
      indicatorProgressItem01 = 1.0;
      indicatorProgressItem02 = 0.0;
      indicatorProgressItem03 = 0.0;
      index = 1; // siguiente vista
    }
    // segundo item : si el primer item esta en 1.0 y el segundo item esta en 0.0 y el tercer item esta en 0.0 entonces el segundo item pasa a 1.0
    else if (indicatorProgressItem02 <= 1.00 && indicatorProgressItem01 > 0.0 && indicatorProgressItem03 == 0.0) {
      indicatorProgressItem01 = 1.0;
      indicatorProgressItem02 = 1.0;
      indicatorProgressItem03 = 0.0;
      index = 2; // siguiente vista
    }
    // tercer item  : si el primer item esta en 1.0 y el segundo item esta en 1.0 y el tercer item esta en 0.0 entonces el tercer item pasa a 1.0
    else if (indicatorProgressItem03 <= 1.00 && indicatorProgressItem01 > 0.0 && indicatorProgressItem02 > 0.0) {
      indicatorProgressItem01 = 1.0;
      indicatorProgressItem02 = 1.0;
      indicatorProgressItem03 = 1.0;
      index = 3; // siguiente vista
    }// vuelve a la vista al principio
    else {
      indicatorProgressItem01 = 0.0;
      indicatorProgressItem02 = 0.0;
      indicatorProgressItem03 = 0.0;
      index = 0;
    } 
  }

  void positionIndicatorLogic(){
    // logica de los indicadores de posicion que cambiar cada sierto tiempo
    timer = Timer.periodic( const Duration(microseconds: 50000), (timer) {
      try{
        setState(() {
        if(indicatorProgressItem01<1 ){
          if( indicatorProgressItem01 >=0.1 && indicatorProgressItem01 <= 0.8 ){indicatorProgressItem01 += 0.02;}
          else{indicatorProgressItem01 += 0.01;}
          index=0;
        }
        if( indicatorProgressItem02<1 && indicatorProgressItem01>=1 ){
          if( indicatorProgressItem02 >=0.1 && indicatorProgressItem02 <= 0.8 ){indicatorProgressItem02 += 0.02;}
          else{indicatorProgressItem02 += 0.01;}
          index=1;
        }
        if( indicatorProgressItem03<1 && indicatorProgressItem02>=1 ){
          if( indicatorProgressItem03 >=0.1 && indicatorProgressItem03 <= 0.8 ){indicatorProgressItem03 += 0.02;}
          else{indicatorProgressItem03 += 0.01;}
          index=2;
        }
        if( indicatorProgressItem01>=1 && indicatorProgressItem02>=1 && indicatorProgressItem03>=1 ){
          indicatorProgressItem01=0.0;
          indicatorProgressItem02=0.0;
          indicatorProgressItem03=0.0;
        }

      });
      }catch(e){
        print(e);
      }
    });
  }

  @override
  void initState() {

    // logicas de los indicadores de posicion
    positionIndicatorLogic(); 

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Getx controller <LoginController>
    final LoginController loginController = Get.find();
    // Obtenemos los valores
    darkMode = Theme.of(context).brightness==Brightness.dark;
    screenSize = MediaQuery.of(context).size;
 
    // lista de widgets con las vistas
    widgets = [
      pageView( context:context,colorContent:Colors.transparent,textColor: Colors.white,colorIcon: Colors.orange.shade300,iconData: Icons.monetization_on,titulo:"VENTAS",subtitulo:"Registra tus ventas de una forma simple 😊"),
      pageView( context:context,colorContent:Colors.transparent,textColor: Colors.white,colorIcon: Colors.teal.shade300,iconData: Icons.analytics_outlined,titulo:"TRANSACCIONES",subtitulo:"Observa las transacciones que has realizado 💰"),
      pageView( context:context,colorContent:Colors.transparent,textColor: Colors.white,colorIcon: Colors.deepPurple.shade300,iconData: Icons.category,titulo:"CATÁLOGO",subtitulo:"Arma tu catálogo y controla el stock de tus productos \n 🍫🍬🥫🍾"),
    ];

    String uriImage = index==0?loginController.sellImagen:index==1?loginController.transactionImage:loginController.catalogueImage;


    
    return Stack(
      children: [
        // Imagen background
        ClipRRect( borderRadius: BorderRadius.circular(10.0), child: Opacity(opacity: 0.8,child: Image(image: AssetImage(uriImage),width: double.infinity,height:double.infinity,fit: BoxFit.cover))) ,
        // view : contenidos
        Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //  indicador de las vistas
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: LinearProgressIndicator(
                            minHeight: 5,
                            color: Colors.white,
                            backgroundColor: darkMode?Colors.white12:Colors.black12,
                            value: indicatorProgressItem01,
                          ),
                        ),
                      ),
                    ),
                    //  indicador de vista
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: LinearProgressIndicator(
                            minHeight: 5,
                            color: Colors.white,
                            backgroundColor: darkMode?Colors.white12:Colors.black12,
                            value: indicatorProgressItem02,
                          ),
                        ),
                      ),
                    ),
                    //  indicador de vista
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: LinearProgressIndicator(
                            minHeight: 5,
                            color: Colors.white,
                            backgroundColor: darkMode?Colors.white12:Colors.black12,
                            value: indicatorProgressItem03,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(child: widgets[index] ),
          ],
        ),
        // controlamos los toques del usuario
        Row(
          children: [
            // toque izquierdo
            Flexible(child: InkWell(onTap: leftTouch,highlightColor: Colors.transparent,splashColor: Colors.transparent,focusColor: Colors.transparent,hoverColor: Colors.transparent,)),
            //  toque derecho
            Flexible(child: InkWell(onTap: rightTouch,highlightColor: Colors.transparent,splashColor: Colors.transparent,focusColor: Colors.transparent,hoverColor: Colors.transparent,)),
            //  touch
          ],
        ),
      ],
    );
  }

  Widget pageView({required BuildContext context,Color ?colorContent,Color textColor = Colors.black, AssetImage ?assetImage,IconData ?iconData,Color ?colorIcon, String titulo="",String subtitulo=""}) {

    // Definimos los estilos
    colorContent ??= Theme.of(context).brightness==Brightness.dark?Colors.white:Colors.black;
    colorIcon ??= colorContent;
    final estiloTitulo = TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold,color: textColor);
    final estiloSubTitulo = TextStyle(fontSize: 24.0,fontWeight: FontWeight.bold,color: textColor.withOpacity(0.8));

    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              const Spacer(),
              // view : si existe mostramos una imagen de asset
              assetImage!=null?Padding(padding: const EdgeInsets.all(12.0),child: Image(image: assetImage,width: screenSize.width / 2,height: screenSize.height / 2,fit: BoxFit.contain),):Container(),
              // icon : un icono con animion
              iconData!=null?Container(padding:const EdgeInsets.all(12.0),child:FadeInDown(key: Key(titulo),duration: const Duration(milliseconds: 500),child: Icon(iconData,size: screenSize.height*0.10,color: colorIcon))):Container(),
              Text(titulo,style: estiloTitulo,textAlign: TextAlign.center),
              const SizedBox(height: 12.0),
              // text : un texto con animacion
              FadeInUp(key: Key(subtitulo),animate: true,delay: const Duration(milliseconds: 700), child: Text(subtitulo,style: estiloSubTitulo,textAlign: TextAlign.center)),  
              const SizedBox(height: 12.0),
              const Spacer(),
            ],
          ),
        ));
  }
}
