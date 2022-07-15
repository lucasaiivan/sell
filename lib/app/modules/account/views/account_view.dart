import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sell/app/modules/account/controller/account_controller.dart';

import '../../../utils/widgets_utils.dart';

class AccountView extends GetView<AccountController> {
  // VAriables

  final FocusNode focusTextEdiNombre = FocusNode();
  final FocusNode focusTextEditDescripcion = FocusNode();
  final FocusNode focusTextEditCategoriaNombre = FocusNode();
  final FocusNode focusTextEditDireccion = FocusNode();
  final FocusNode focusTextEditCiudad = FocusNode();
  final FocusNode focusTextEditProvincia = FocusNode();
  final FocusNode focusTextEditPais = FocusNode();

  @override
  Widget build(BuildContext buildContext) {
    return scaffold(buildContext: buildContext);
  }

  Widget scaffold({required BuildContext buildContext}) {
    return GetBuilder<AccountController>(
        id: 'load',
        builder: (_) {
          return Scaffold(
            appBar: appBar(context: buildContext),
            body: controller.stateLoding
                ? const Center(
                    child: Text('cargando...'),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12.0),
                    children: [
                      Column(
                        children: <Widget>[
                          controller.newAccount
                              ? widgetNewAccount()
                              : Container(),
                          const SizedBox(
                            height: 12.0,
                          ),
                          widgetsImagen(),
                          controller.getSavingIndicator
                              ? Container()
                              : TextButton(
                                  onPressed: () {
                                    if (controller.getSavingIndicator ==
                                        false) {
                                      _showModalBottomSheetCambiarImagen(
                                          context: buildContext);
                                    }
                                  },
                                  child: const Text("Cambiar imagen")),
                          const SizedBox(
                            height: 24.0,
                          ),
                          widgetFormEditText(context: buildContext),
                        ],
                      ),
                    ],
                  ),
          );
        });
  }

  // WIDGET
  PreferredSizeWidget appBar({required BuildContext context}) {
    return AppBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      elevation: 0,
      iconTheme: Theme.of(context)
          .iconTheme
          .copyWith(color: Theme.of(context).textTheme.bodyText1!.color),
      title: Text(controller.newAccount ? 'Perfil de mi negocio' : 'Perfil',
          style: TextStyle(
              fontSize: 18.0,
              color: Theme.of(context).textTheme.bodyText1!.color)),
      actions: <Widget>[
        IconButton(
          icon: controller.getSavingIndicator
              ? Container()
              : const Icon(Icons.check_sharp),
          onPressed: controller.saveAccount,
        )
      ],
      bottom: controller.getSavingIndicator ? linearProgressBarApp() : null,
    );
  }

  void _showModalBottomSheetCambiarImagen({required BuildContext context}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Capturar una imagen'),
                  onTap: () {
                    Navigator.pop(bc);
                    controller.setImageSource(imageSource: ImageSource.camera);
                  }),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Seleccionar desde la galería de fotos'),
                onTap: () {
                  Navigator.pop(bc);
                  controller.setImageSource(imageSource: ImageSource.gallery);
                },
              ),
            ],
          );
        });
  }

  Widget widgetNewAccount() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
          child: ElasticIn(
        child: const Text(
          'Hola 😃, primero dinos el nombre de tu negocio para poder crear tu catálogo \n\n 👇',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )),
    );
  }

  Widget widgetsImagen() {
    // values
    Color colorDefault = Colors.grey.withOpacity(0.2);
    return GetBuilder<AccountController>(
      id: 'image',
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              controller.getImageUpdate == false
                  ? controller.profileAccount.image == ''
                      ? CircleAvatar(
                          backgroundColor: colorDefault,
                          radius: 75.0,
                        )
                      : CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: controller.profileAccount.image == ''
                              ? 'default'
                              : controller.profileAccount.image,
                          placeholder: (context, url) => CircleAvatar(
                            backgroundColor: colorDefault,
                            radius: 75.0,
                          ),
                          imageBuilder: (context, image) => CircleAvatar(
                            backgroundImage: image,
                            radius: 75.0,
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            backgroundColor: colorDefault,
                            radius: 75.0,
                          ),
                        )
                  : CircleAvatar(
                      radius: 75.0,
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          FileImage(File(controller.getxFile.path)),
                    )
            ],
          ),
        );
      },
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget widgetFormEditText({required BuildContext context}) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              enabled: !controller.getSavingIndicator,
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              onChanged: (value) => controller.profileAccount.name = value,
              decoration: const InputDecoration(
                filled: true,
                labelText: "Nombre del Negocio",
                prefixIcon: Icon(Icons.other_houses_outlined),
              ),
              controller:
                  TextEditingController(text: controller.profileAccount.name),
              textInputAction: TextInputAction.next,
              focusNode: focusTextEdiNombre,
              onSubmitted: (term) {
                _fieldFocusChange(
                    context, focusTextEdiNombre, focusTextEditDescripcion);
              },
            ),
            const Divider(color: Colors.transparent, thickness: 1),
            TextField(
              enabled: !controller.getSavingIndicator,
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              onChanged: (value) =>
                  controller.profileAccount.description = value,
              decoration: const InputDecoration(
                filled: true,
                labelText: "Descripción (opcional)",
              ),
              controller: TextEditingController(
                  text: controller.profileAccount.description),
              textInputAction: TextInputAction.next,
              focusNode: focusTextEditDescripcion,
              onSubmitted: (term) {
                _fieldFocusChange(context, focusTextEditDescripcion,
                    focusTextEditDescripcion);
              },
            ),
            const Divider(color: Colors.transparent, thickness: 1),
            InkWell(
              onTap: () =>
                  _bottomPickerSelectCurreny(list: ["\$"], context: context),
              child: TextField(
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: "Signo de moneda",
                  filled: true,
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                controller: controller.getControllerTextEditSignoMoneda,
                onChanged: (value) =>
                    controller.profileAccount.currencySign = value,
              ),
            ),
            const SizedBox(
              height: 24.0,
            ),
            const Text("Ubicación", style: TextStyle(fontSize: 24.0)),
            const SizedBox(
              height: 24.0,
            ),
            InkWell(
              onTap: () => _bottomPickerSelectCountries(
                  list: controller.getCountries, context: context),
              child: TextField(
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: "Pais",
                  filled: true,
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                controller: controller.getControllerTextEditPais,
                onChanged: (value) => controller.profileAccount.country = value,
              ),
            ),
            const SizedBox(width: 12.0, height: 12.0),
            InkWell(
              onTap: () => controller.profileAccount.country == ''
                  ? _bottomPickerSelectCountries(
                      list: controller.getCountries, context: context)
                  : _bottomPickerSelectCities(
                      list: controller.getCities, context: context),
              child: TextField(
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Provincia",
                    filled: true,
                    prefixIcon: Icon(Icons.business),
                  ),
                  controller: controller.getControllerTextEditProvincia,
                  onChanged: (value) {
                    controller.profileAccount.province = value;
                  }),
            ),
            const Divider(color: Colors.transparent, thickness: 1),
            TextField(
              enabled: !controller.getSavingIndicator,
              onChanged: (value) => controller.profileAccount.town = value,
              decoration: const InputDecoration(
                labelText: "Ciudad (ocional)",
                filled: true,
              ),
              controller:
                  TextEditingController(text: controller.profileAccount.town),
            ),
            const Divider(color: Colors.transparent, thickness: 1),
            TextField(
              enabled: !controller.getSavingIndicator,
              onChanged: (value) => controller.profileAccount.address = value,
              decoration: const InputDecoration(
                labelText: "Dirección (ocional)",
                filled: true,
              ),
              controller: TextEditingController(
                  text: controller.profileAccount.address),
              textInputAction: TextInputAction.next,
              focusNode: focusTextEditDireccion,
              onSubmitted: (term) {
                _fieldFocusChange(
                    context, focusTextEditDireccion, focusTextEditCiudad);
              },
            ),
            const Divider(color: Colors.transparent, thickness: 1),
            
            
            
          ],
        ));
  }

  void _bottomPickerSelectCities(
      {required List list, required BuildContext context}) async {
    //  Muestra una hoja inferior de diseño de material modal
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: <Widget>[
              const ListTile(
                title: Center(
                  child: Text("Selecciona una provincia"),
                ),
              ),
              ListView(
                shrinkWrap: true,
                children: List<Widget>.generate(
                    list.length,
                    (int index) => ListTile(
                          minVerticalPadding: 12,
                          title: Text(list[index]),
                          onTap: () {
                            controller.getControllerTextEditProvincia.text = list[index];
                            controller.profileAccount.province = list[index];
                            Get.back();
                          },
                        )),
              ),
            ],
          );
        });
  }

  void _bottomPickerSelectCountries(
      {required List list, required BuildContext context}) async {
    //  Muestra una hoja inferior de diseño de material modal
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: <Widget>[
              const ListTile(
                title: Center(
                  child: Text("Seleccione un pais"),
                ),
              ),
              ListView(
                shrinkWrap: true,
                children: List<Widget>.generate(
                    list.length,
                    (int index) => ListTile(
                          minVerticalPadding: 12,
                          title: Text(list[index]),
                          onTap: () {
                            controller.profileAccount.country = list[index];
                            controller.getControllerTextEditPais.text =
                                list[index];
                            Get.back();
                          },
                        )),
              ),
            ],
          );
        });
  }

  void _bottomPickerSelectCurreny(
      {required List list, required BuildContext context}) async {
    //  Muestra una hoja inferior de diseño de material modal
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: <Widget>[
              const ListTile(
                title: Center(
                  child: Text("Selecciona el signo de la moneda"),
                ),
              ),
              ListView(
                shrinkWrap: true,
                children: List<Widget>.generate(
                    list.length,
                    (int index) => ListTile(
                          minVerticalPadding: 12,
                          title: Text(list[index]),
                          onTap: () {
                            controller.profileAccount.currencySign = list[index];
                            controller.getControllerTextEditSignoMoneda.text =list[index];
                            Get.back();
                          },
                        )),
              ),
            ],
          );
        });
  }
}
