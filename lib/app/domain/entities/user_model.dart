import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    this.superAdmin = false, // Super administrador es el usaurio que creo la cuenta
    this.admin = false, // permiso de administrador del usuario para administrar la cuenta
    this.email = '',
  });

  bool superAdmin = false;
  bool admin = false;
  String email = '';

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserModel(
      superAdmin: data.containsKey("superAdmin") ? doc["superAdmin"] : false,
      admin: data.containsKey("admin") ? doc["admin"] : false,
      email: data.containsKey("email") ? doc["email"] : '',
    );
  }

  Map<String, dynamic> toJson() => {"superAdmin": superAdmin,"email": email};

  factory UserModel.fromMap(Map data) {
    return UserModel(
      superAdmin: data['superAdmin'] ?? false,
      admin: data['admin'] ?? false,
      email: data['email'] ?? '',
    );
  }

  UserModel.fromDocumentSnapshot({required DocumentSnapshot documentSnapshot}) {
    // get
    Map data = documentSnapshot.data() as Map;

    //  set
    superAdmin = data['superAdmin'] ?? false;
    admin =superAdmin?true:data['admin'] ?? false;
    email = data["email"] ?? '';
  }
}

class ProfileAccountModel {
  // Informacion de la cuenta
  Timestamp creation = Timestamp.now(); // Fecha en la que se creo la cuenta
  String id = ""; // el ID de la cuenta por defecto es el ID del usuario quien lo creo
  String username = "";
  String image = "";
  String name = ""; 
  String currencySign = "\$";

  // account info
  bool subscribed = false;
  bool blockingAccount = false;
  String blockingMessage = "";
  bool verifiedAccount = false; // Cuenta verificada

  // location
  String countrycode = "";
  String country = "";
  String province = ""; // provincia o estado
  String town = ""; // ciudad o pueblo 

  ProfileAccountModel({
    // account info
    // informacion de cuenta
    // location
    // data user creation
    this.id = "",
    this.subscribed=true, // subcripción
    this.countrycode = "",
    this.username = '',
    this.image = "",
    this.name = "", 
    this.currencySign = "\$",
    this.blockingAccount = false,
    this.blockingMessage = "",
    this.verifiedAccount = false, // Cuenta verificada 
    this.country = "",
    this.province = "",
    this.town = "", 
    required this.creation,
  });
  ProfileAccountModel copyWith({
    // account info
    // informacion de cuenta
    // location
    // data user creation
    String? id,
    bool? subscribed,
    String? countrycode,
    String? username,
    String? image,
    String? name, 
    String? currencySign,
    bool? blockingAccount,
    String? blockingMessage,
    bool? verifiedAccount, // Cuenta verificada 
    String? country,
    String? province,
    String? town, 
    Timestamp? creation,
  }) {
    return ProfileAccountModel(
      // account info
      // informacion de cuenta
      // location
      // data user creation
      id: id ?? this.id,
      subscribed: subscribed ?? this.subscribed,
      countrycode: countrycode ?? this.countrycode,
      username: username ?? this.username,
      image: image ?? this.image,
      name: name ?? this.name, 
      currencySign: currencySign ?? this.currencySign,
      blockingAccount: blockingAccount ?? this.blockingAccount,
      blockingMessage: blockingMessage ?? this.blockingMessage,
      verifiedAccount: verifiedAccount ?? this.verifiedAccount, // Cuenta verificada 
      country: country ?? this.country,
      province: province ?? this.province,
      town: town ?? this.town, 
      creation: creation ?? this.creation,
    );
  }

  ProfileAccountModel.fromMap(Map data) {
    id = data['id'];
    username = data['username'];
    subscribed = true;// data['subscribed']??false;
    image =data.containsKey('image') ? data['image'] : data['imagen_perfil'] ?? '';
    name = data.containsKey('name') ? data['name'] : data['nombre_negocio']; 
    creation = data.containsKey('creation')? data['creation']: data['timestamp_creation']?? Timestamp.now();
    currencySign = data.containsKey('currencySign')
        ? data['currencySign']
        : data['signo_moneda'] ?? "\$";
    blockingAccount = data.containsKey('blockingAccount')
        ? data['blockingAccount']
        : data['bloqueo'];
    blockingMessage = data.containsKey('blockingMessage')
        ? data['blockingMessage']
        : data['mensaje_bloqueo'];
    verifiedAccount = data.containsKey('verifiedAccount')
        ? data['verifiedAccount']
        : data['cuenta_verificada'];
    countrycode = data.containsKey('countrycode')
        ? data['countrycode']
        : data['codigo_pais']; 
    town = data.containsKey('town') ? data['town'] : data['ciudad'];
    province =
        data.containsKey('province') ? data['province'] : data['provincia'];
    country = data.containsKey('country') ? data['country'] : data['pais'];
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        // "subscribed": subscribed,
        "username": username,
        "image": image,
        "name": name, 
        "creation": creation,
        "currencySign": currencySign,
        "blockingAccount": blockingAccount,
        "blockingMessage": blockingMessage,
        "verifiedAccount": verifiedAccount,
        "countrycode": countrycode,
        "country": country,
        "province": province,
        "town": town, 
      };

  ProfileAccountModel.fromDocumentSnapshot( {required DocumentSnapshot documentSnapshot}) {
    // get
    late Map data= {};
    if (documentSnapshot.data() != null) {data = documentSnapshot.data() as Map; }

    //  set
    creation = data["creation"]??Timestamp.now();
    // TODO: variable que se tiene que evaluar en cada inicio de la app
    subscribed = true; //data.containsKey('subscribed') ? data['subscribed'] : false;
    id = data.containsKey('id') ? data['id'] : documentSnapshot.id;
    username = data["username"] ?? '';
    image = data.containsKey('image') ? data['image'] : data["imagen_perfil"] ?? '';
    name = data.containsKey('name')
        ? data['name']
        : data["nombre_negocio"] ?? 'null'; 
    currencySign = data.containsKey('currencySign')
        ? data['currencySign']
        : data["signo_moneda"] ?? '';
    blockingAccount = data.containsKey('blockingAccount')
        ? data['blockingAccount']
        : data["bloqueo"] ?? false;
    blockingMessage = data.containsKey('blockingMessage')
        ? data['blockingMessage']
        : data["mensaje_bloqueo"] ?? '';
    verifiedAccount = data.containsKey('verifiedAccount')
        ? data['verifiedAccount']
        : data["cuenta_verificada"] ?? false;
    countrycode = data.containsKey('countrycode')
        ? data['countrycode']
        : data["codigo_pais"] ?? '';
    country =
        data.containsKey('country') ? data['country'] : data["pais"] ?? '';
    province = data.containsKey('province')
        ? data['province']
        : data["provincia"] ?? '';
    town = data.containsKey('town') ? data['town'] : data["ciudad"] ?? ''; 
  }
}
