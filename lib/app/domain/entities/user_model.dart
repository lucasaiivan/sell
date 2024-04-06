import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserModel {
  UserModel({
    this.inactivate = false,
    this.account = "", 
    this.email = '',  
    this.name='', 
    this.superAdmin = false,  
    this.admin = false,  
    this.personalized = false,  
    required this.creation,
    required this.lastUpdate,
    this.startTime = const {},
    this.endTime = const {},
    this.daysOfWeek = const [],
    // ... 
    this.arqueo = false,  
    this.historyArqueo = false, 
    this.transactions = false, 
    this.catalogue = false,  
    this.multiuser = false,  
    this.editAccount = false, 
  });

  bool inactivate = false; // inactivar usuario
  String account = ""; // el ID de la cuenta administrada por defecto es el ID del usuario quien lo creo
  String email = ''; // email del usuario
  String name=''; // nombre del usuario (opcaional)
  bool superAdmin = false; // Super administrador es el usaurio que creo la cuenta
  bool admin = false; // permiso de administrador 
  Timestamp creation = Timestamp.now(); // Fecha en la que se creo la cuenta
  Timestamp lastUpdate = Timestamp.now(); // Fecha en la que se actualizo la cuenta
  Map<String,dynamic> startTime = {}; // hora de acceso habilitada para el usuario
  Map<String,dynamic> endTime = {}; // hora de cierre de acceso para el usuario
  List daysOfWeek = []; // dias de la semana habilitados al acceso
  // permisos personalizados
  bool personalized = false;
  // ...  
  bool arqueo = false; // crear arqueo de caja
  bool historyArqueo = false; // ver y eliminar registros de arqueo de caja
  bool transactions = false; // ver y eliminar registros de transacciones
  bool catalogue = false;  // ver, editar y eliminar productos del catalogo
  bool multiuser = false;  // ver, editar y eliminar usuarios de la cuenta
  bool editAccount = false; // editar la cuenta


  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserModel(
      inactivate: data.containsKey("inactivate") ? doc["inactivate"] : false,
      account: doc["account"],
      email: data.containsKey("email") ? doc["email"] : '',
      name: data.containsKey('name') ? doc['name'] : '',
      superAdmin: data.containsKey("superAdmin") ? doc["superAdmin"] : false,
      admin: data.containsKey("admin") ? doc["admin"] : false,
      personalized: data.containsKey("personalized") ? doc["personalized"] : false,
      creation: data.containsKey("creation") ? doc["creation"] : Timestamp.now(),
      lastUpdate: data.containsKey("lastUpdate") ? doc["lastUpdate"] : Timestamp.now(),
      startTime: data.containsKey("startTime") ? doc["startTime"] : {},
      endTime: data.containsKey("endTime") ? doc["endTime"] : {},
      daysOfWeek: data.containsKey("daysOfWeek") ? doc["daysOfWeek"] : [],
      // ... 
      arqueo: data.containsKey("arqueo") ? doc["arqueo"] : false,
      historyArqueo: data.containsKey("historyArqueo") ? doc["historyArqueo"] : false,
      transactions: data.containsKey("transactions") ? doc["transactions"] : false,
      catalogue: data.containsKey("catalogue") ? doc["catalogue"] : false,
      multiuser: data.containsKey("multiuser") ? doc["multiuser"] : false,
      editAccount: data.containsKey("editAccount") ? doc["editAccount"] : false,

    );
    
  }

  Map<String, dynamic> toJson() => {
    "inactivate": inactivate,
    "account": account,
    "email": email,
    'name':name,
    "superAdmin": superAdmin,
    "admin": admin,
    'creation': creation,
    'lastUpdate': lastUpdate,
    'startTime': startTime,
    'endTime': endTime,
    'daysOfWeek': daysOfWeek,
    // permisos personalizados
    "personalized": personalized, 
    "arqueo": arqueo,
    "historyArqueo": historyArqueo,
    "transactions": transactions,
    "catalogue": catalogue,
    "multiuser": multiuser,
    "editAccount": editAccount,
  };

  factory UserModel.fromMap(Map data) {
    return UserModel(
      inactivate: data['inactivate'] ?? false,
      account: data['account'] ?? '',
      email: data['email'] ?? '',
      name:data['name'] ?? '',
      superAdmin: data['superAdmin'] ?? false,
      admin: data['admin'] ?? false,
      personalized: data['personalized'] ?? false,
      creation: data['creation'] ?? Timestamp.now(),
      lastUpdate: data['lastUpdate'] ?? Timestamp.now(),
      startTime: data['startTime'] ?? {},
      endTime: data['endTime'] ?? {},
      daysOfWeek: data['daysOfWeek'] ?? [],
      // ... 
      arqueo: data['arqueo'] ?? false,
      historyArqueo: data['historyArqueo'] ?? false,
      transactions: data['transactions'] ?? false,
      catalogue: data['catalogue'] ?? false,
      multiuser: data['multiuser'] ?? false,
      editAccount: data['editAccount'] ?? false,
    );
  }

  UserModel.fromDocumentSnapshot({required DocumentSnapshot documentSnapshot}) { 
    // get
    late Map data= {};
    if (documentSnapshot.data() != null) {data = documentSnapshot.data() as Map; }

    //  set
    inactivate = data.containsKey('inactivate') ? data['inactivate'] : false;
    account = data.containsKey('account') ? data['account'] : documentSnapshot.id;
    email = data.containsKey('email') ? data['email'] : '';
    name = data.containsKey('name') ? data['name'] : '';
    superAdmin = data.containsKey('superAdmin') ? data['superAdmin'] : false;
    admin = data.containsKey('admin') ? data['admin'] : false;
    personalized = data.containsKey('personalized') ? data['personalized'] : false;
    creation = data.containsKey('creation') ? data['creation'] : Timestamp.now();
    lastUpdate = data.containsKey('lastUpdate') ? data['lastUpdate'] : Timestamp.now();
    startTime = data.containsKey('startTime') ? data['startTime'] : {};
    endTime = data.containsKey('endTime') ? data['endTime'] : {};
    daysOfWeek = data.containsKey('daysOfWeek') ? data['daysOfWeek'] : [];
    // ... 
    arqueo = data.containsKey('arqueo') ? data['arqueo'] : false;
    historyArqueo = data.containsKey('historyArqueo') ? data['historyArqueo'] : false;
    transactions = data.containsKey('transactions') ? data['transactions'] : false;
    catalogue = data.containsKey('catalogue') ? data['catalogue'] : false;
    multiuser = data.containsKey('multiuser') ? data['multiuser'] : false;
    editAccount = data.containsKey('editAccount') ? data['editAccount'] : false;
  }

  UserModel copyWith({
    bool? inactivate,
    String? id,
    String? email,
    String? name,
    bool? superAdmin,
    bool? admin,
    bool? personalized,
    Timestamp? creation,
    Timestamp? lastUpdate,
    Map<String,dynamic>? startTime,
    Map<String,dynamic>? endTime,
    List<String>? daysOfWeek,
    // ...
    bool? sell,
    bool? arqueo,
    bool? historyArqueo,
    bool? transactions,
    bool? catalogue,
    bool? multiuser,
    bool? editAccount,
  }) {
    return UserModel(
      inactivate: inactivate ?? this.inactivate,
      account: id ?? account,
      email: email ?? this.email,
      name: name ?? this.name,
      superAdmin: superAdmin ?? this.superAdmin,
      admin: admin ?? this.admin,
      personalized: personalized ?? this.personalized,
      creation: creation ?? this.creation,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      // ... 
      arqueo: arqueo ?? this.arqueo,
      historyArqueo: historyArqueo ?? this.historyArqueo,
      transactions: transactions ?? this.transactions,
      catalogue: catalogue ?? this.catalogue,
      multiuser: multiuser ?? this.multiuser,
      editAccount: editAccount ?? this.editAccount,
    );
  }


  String get getAccessTimeFormat {
    // devuelve la hora de acceso del usuario con formato de 24 horas [hh:mm] 
    if (startTime.isEmpty && endTime.isEmpty) return "";
    
    return "${startTime['hour'].toString().padLeft(2, '0')}:${startTime['minute'].toString().padLeft(2, '0')} - ${endTime['hour'].toString().padLeft(2, '0')}:${endTime['minute'].toString().padLeft(2, '0')}";
  }
  bool get hasAccess{
    // var
    DateTime now = DateTime.now();
    bool hourAccess = false;
    bool dayAccess = false;
    // devuelve verdadero si el usuario tiene acceso a la cuenta dentro del horario establecido
    if (startTime.isEmpty && endTime.isEmpty) return false; 
    DateTime start = DateTime(now.year, now.month, now.day, startTime['hour'], startTime['minute']);
    DateTime end = DateTime(now.year, now.month, now.day, endTime['hour'], endTime['minute']);
    hourAccess = now.isAfter(start) && now.isBefore(end);

    // devuelve verdadero si el usuario tiene acceso a la cuenta en el día de la semana establecido
    if (daysOfWeek.isEmpty) return false; 
    String dayName = DateFormat('EEEE', 'en_US').format(now); 
    dayAccess = daysOfWeek.contains(dayName);

    return hourAccess && dayAccess;
  } 
  List get getDaysOfWeek{
    // devuelve los días de la semana en español
    List<String> days = [];
    for (var day in daysOfWeek) {
      days.add(translateDay(day: day));
    }
    return days;
  }
  String translateDay({required String day}){
    // devuelve el dia de la semana en español
    switch (day) {
      case 'monday':
        return 'Lunes';
      case 'tuesday':
        return 'Martes';
      case 'wednesday':
        return 'Miércoles';
      case 'thursday':
        return 'Jueves';
      case 'friday':
        return 'Viernes';
      case 'saturday':
        return 'Sábado';
      case 'sunday':
        return 'Domingo';
      default:
        return '';
    }
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
