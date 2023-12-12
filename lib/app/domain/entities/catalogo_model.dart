import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sell/app/core/utils/fuctions.dart';


class Product {
  String id = "";
  String idMark = ""; // ID de la marca por defecto esta vacia
  String nameMark = '';
  String description = ""; // Informacion
  String image = ""; // URL imagen
  String code = "";

  int followers = 0; // seguidores
  bool outstanding = false; // producto destacado
  bool verified = false; // estado de verificación  al un moderador
  Timestamp creation =Timestamp.now(); // Marca de tiempo ( hora en que se creo el producto )
  Timestamp upgrade =Timestamp.now(); // Marca de tiempo ( hora en que se edito el producto )

  // datos del usuario y cuenta 
  String idAccount = ''; // ID del negocios que actualizo el documento
  String idUserCreation =''; // id del usuario que creo el documento
  String idUserUpgrade = '' ;

  Product({
    this.id = "",
    this.followers = 0,
    this.idUserCreation = '',
    this.idAccount = '',
    this.idUserUpgrade = '',
    this.verified = false,
    this.outstanding = false,
    this.idMark = "",
    this.nameMark = '',
    this.image = "",
    this.description = "",
    this.code = "",
    required this.upgrade,
    required this.creation,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        'followers':followers,
        'idAccount': idAccount,
        'idUserCreation': idUserCreation,
        'idUserUpgrade': idUserUpgrade,
        "verified": verified,
        "outstanding": outstanding,
        "idMark": idMark,
        'nameMark': nameMark,
        "image": image,
        "description": description,
        "code": code,
        "creation": creation,
        "upgrade": upgrade,
      };

  factory Product.fromMap(Map data) {
    return Product(
      id: data.containsKey('id')? data['id'] :'',
      followers: data.containsKey('followers')? data['followers'] : 0,
      idAccount: data.containsKey('idAccount')? data['idAccount']: '',
      idUserCreation: data.containsKey('idUserCreation')? data['idUserCreation'] : '',
      idUserUpgrade: data.containsKey('idUserUpgrade')? data['idUserUpgrade'] : '',
      verified: data.containsKey('verified')? data['verified']: false,
      outstanding: data.containsKey('outstanding')? data['outstanding'] : false,
      idMark: data.containsKey('idMark') ? data['idMark'] : data.containsKey('id_marca') ?data['id_marca'] :'',
      nameMark: data.containsKey('nameMark') ? data['nameMark'] : '',
      image: data.containsKey('image') ? data['image'] :  data.containsKey('urlimagen') ? data['urlimagen'] :'',
      description: data.containsKey('description')? data['description']: data.containsKey('descripcion')?data['descripcion']:'',
      code: data.containsKey('code') ? data['code'] :  data.containsKey('codigo') ?data['codigo']:'',
      upgrade: data.containsKey('upgrade')? data['upgrade']: Timestamp.now(),
      creation: data.containsKey('creation')? data['creation']: Timestamp.now(),
    );
    
  }
  Product.fromDocumentSnapshot({required DocumentSnapshot documentSnapshot}) {
    // convert
    Map data = documentSnapshot.data() as Map;
    // set
    id = data['id'] ?? '';
    followers = data.containsKey('followers')? data['followers'] : 0;
    idAccount = data.containsKey('idAccount')? data['idAccount']: data['id_negocio'] ?? '';
    idUserCreation = data['idUserCreation'] ?? '';
    idUserUpgrade = data['idUserUpgrade'] ?? '';
    verified = data.containsKey('verified')? data['verified']: data['verificado'] ?? false;
    outstanding = data['outstanding'] ?? false;
    idMark =data.containsKey('idMark') ? data['idMark'] : data['id_marca'] ?? '';
    nameMark = data['nameMark'] ?? '';
    image = data.containsKey('image') ? data['image'] : data['urlimagen'] ?? '';
    description = data.containsKey('description')? data['description']: data['descripcion'] ?? '';
    code = data.containsKey('code') ? data['code'] : data['codigo'] ?? '';
    upgrade = data.containsKey('upgrade')? data['upgrade']: data['timestamp_actualizacion'] ?? Timestamp.now();
    creation = data.containsKey('creation')? data['creation']: data['timestamp_creation'] ?? Timestamp.now();
  }
  ProductCatalogue convertProductCatalogue() {
    //  create value
    ProductCatalogue productCatalogue =   ProductCatalogue(upgrade: Timestamp.now(), creation: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now());
    //  set
    productCatalogue.id = id;
    productCatalogue.followers = followers;
    productCatalogue.image = image;
    productCatalogue.verified = verified;
    productCatalogue.outstanding = outstanding;
    productCatalogue.idMark = idMark;
    productCatalogue.nameMark = nameMark;
    productCatalogue.description = description;
    productCatalogue.code = code;
    productCatalogue.upgrade = upgrade;
    productCatalogue.creation = creation; 

    return productCatalogue;
  }
}

class ProductCatalogue {
  // valores del producto
  String id = "";
  bool verified = false; // estado de verificación por un moderador
  int followers = 0; // seguidores
  bool outstanding = false; // producto destacado
  bool favorite = false;
  String idMark = ""; // ID de la marca por defecto esta vacia
  String nameMark = ''; // nombre de la marca
  String image = ""; // URL imagen
  String description = ""; // Información
  String code = "";
  String category = ""; // ID de la categoria del producto
  String provider = ""; // ID del proveedor del producto
  String nameProvider = ""; // name provider
  String nameCategory = ""; // name category
  String subcategory = ""; // ID de la subcategoria del producto
  String nameSubcategory = ""; // name subcategory
  Timestamp creation =Timestamp.now(); // Marca de tiempo ( hora en que se creo el documento  )
  Timestamp upgrade = Timestamp.now(); // Marca de tiempo ( hora en que se actualizo el documento )
  Timestamp documentCreation =Timestamp.now(); // Marca de tiempo ( hora en que se creo el producto publico )
  Timestamp documentUpgrade =Timestamp.now();// Marca de tiempo ( hora en que se actualizo el producto publico )
  int quantityStock = 0;
  bool stock = false;
  int alertStock = 5;
  int sales = 0;
  double salePrice = 0.0; // precio de venta
  double purchasePrice = 0.0; // precio de compra
  String currencySign = "\$"; // signo de la moneda

  // var optional app
  int quantity = 0;
  double revenue = 0.0;
  double priceTotal = 0;

  ProductCatalogue({
    // Valores del producto
    this.id = "",
    this.verified = false,
    this.followers = 0,
    this.favorite = false,
    this.outstanding = false,
    this.image = "",
    this.description = "",
    this.code = "",
    this.provider = "",
    this.nameProvider = "",
    this.category = "",
    this.nameCategory = '',
    this.subcategory = "",
    this.nameSubcategory = '',
    this.stock = false,
    this.quantityStock = 0,
    this.alertStock = 5,
    this.revenue =0.0,
    required this.creation,
    required this.upgrade,
    required this.documentCreation,
    required this.documentUpgrade,

    // value account
    this.sales = 0,
    this.salePrice = 0.0,
    this.purchasePrice = 0.0,
    this.currencySign = "\$",
    this.idMark = '',
    this.nameMark = '',
    // var app 
    this.quantity = 1,
  });

  ProductCatalogue copyWith({
  String? id,
  bool? verified,
  int? followers,
  bool? favorite,
  bool? outstanding,
  String? image,
  String? description,
  String? code,
  String? provider,
  String? nameProvider,
  String? category,
  String? nameCategory,
  String? subcategory,
  String? nameSubcategory,
  bool? stock,
  int? quantityStock,
  int? alertStock,
  double? revenue,
  Timestamp ? creation,
  Timestamp ? upgrade,
  Timestamp? documentCreation,
  Timestamp? documentUpgrade,
  int? sales,
  double? salePrice,
  double? purchasePrice,
  String? currencySign,
  String? idMark,
  String? nameMark, 
  int? quantity,
}) {
  return ProductCatalogue(
    id: id ?? this.id,
    verified: verified ?? this.verified,
    followers: followers ?? this.followers,
    favorite: favorite ?? this.favorite,
    outstanding: outstanding ?? this.outstanding,
    image: image ?? this.image,
    description: description ?? this.description,
    code: code ?? this.code,
    provider: provider ?? this.provider,
    nameProvider: nameProvider ?? this.nameProvider,
    category: category ?? this.category,
    nameCategory: nameCategory ?? this.nameCategory,
    subcategory: subcategory ?? this.subcategory,
    nameSubcategory: nameSubcategory ?? this.nameSubcategory,
    stock: stock ?? this.stock,
    quantityStock: quantityStock ?? this.quantityStock,
    alertStock: alertStock ?? this.alertStock,
    revenue: revenue ?? this.revenue,
    creation: creation ?? this.creation,
    upgrade: upgrade ?? this.upgrade,
    documentCreation: documentCreation ?? this.documentCreation,
    documentUpgrade: documentUpgrade ?? this.documentUpgrade,
    sales: sales ?? this.sales,
    salePrice: salePrice ?? this.salePrice,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    currencySign: currencySign ?? this.currencySign,
    idMark: idMark ?? this.idMark,
    nameMark: nameMark ?? this.nameMark, 
    quantity: quantity ?? this.quantity,
  );
}

  factory ProductCatalogue.fromMap(Map data) {
    return ProductCatalogue(
      // Valores del producto
      id: data.containsKey('id')? data['id'] :'',
      verified: data.containsKey('verified')? data['verified']: data['verificado'] ?? false,
      followers: data.containsKey('followers')? data['followers']: data['seguidores'] ?? 0,
      outstanding: data.containsKey('outstanding')? data['outstanding']: data['destacado'] ?? false,
      favorite: data.containsKey('favorite')? data['favorite']: data['favorito'] ?? false,
      idMark:data.containsKey('idMark') ? data['idMark'] : data['id_marca'] ?? '',
      nameMark: data.containsKey('nameMark') ? data['nameMark'] : data['nombre_marca'] ?? '',
      image: data.containsKey('image')? data['image']: data['urlimagen'] ?? 'https://default',
      description: data.containsKey('description')?data['description']: data['descripcion'] ?? '',
      code: data.containsKey('code') ? data['code'] : data['codigo'] ?? '',
      provider: data.containsKey('provider')?data['provider']:data['proveedor'] ?? '',
      nameProvider: data.containsKey('nameProvider')?data['nameProvider']:data['proveedorName'] ?? '',
      category: data.containsKey('category')?data['category']:data['categoria'] ?? '',
      nameCategory: data.containsKey('nameCategory')?data['nameCategory']:data['categoriaName'] ?? '',
      subcategory: data.containsKey('subcategory')?data['subcategory']:data['subcategoria'] ?? '',
      nameSubcategory: data.containsKey('nameSubcategory')?data['nameSubcategory']:data['subcategoriaName'] ?? '',
      upgrade: data.containsKey('upgrade')? data['upgrade']: data['timestamp_actualizacion'] ?? Timestamp.now(),
      creation: data.containsKey('creation')? data['creation']: data['timestamp_creation'] ?? Timestamp.now(),
      documentCreation: data.containsKey('documentCreation')? data['documentCreation']: data['documentCreation'] ?? Timestamp.now(),
      documentUpgrade: data.containsKey('documentUpgrade')? data['documentUpgrade']: data['documentUpgrade'] ?? Timestamp.now(),
      // valores de la cuenta
      salePrice: data.containsKey('salePrice') ? data['salePrice'].toDouble()??0.0.toDouble() :0.0.toDouble(),
      purchasePrice: data.containsKey('purchasePrice') ? data['purchasePrice'].toDouble()??0.0.toDouble():0.0.toDouble(),
      currencySign: data.containsKey('currencySign')?data['currencySign']:data['signo_moneda'] ?? '',
      quantityStock: data.containsKey('quantityStock')? data['quantityStock'] : 0,
      sales: data.containsKey('sales')? data['sales'] : 0,
      stock:  data.containsKey('stock')? data['stock'] : false,
      alertStock: data.containsKey('alertStock')?data['alertStock'] : 5,
      revenue: data.containsKey('revenue')?data['revenue'] : 0.0,
      // values of app
      quantity: data.containsKey('quantity') ? data['quantity'] : 1, 
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "verified": verified,
        'followers':followers,
        'outstanding':outstanding,
        "favorite": favorite,
        "idMark": idMark,
        "nameMark": nameMark,
        "image": image,
        "description": description,
        "code": code,
        "provider": provider,
        "nameProvider": nameProvider,
        "category": category,
        "nameCategory": nameCategory,
        "subcategory": subcategory,
        "nameSubcategory": nameSubcategory,
        "salePrice": salePrice,
        "purchasePrice": purchasePrice,
        "creation": creation,
        "upgrade": upgrade,
        "documentCreation": documentCreation,
        "documentUpgrade": documentUpgrade,
        "currencySign": currencySign,
        "quantity": quantity,
        "stock": stock,
        "quantityStock": quantityStock,
        "sales": sales,
        "alertStock": alertStock,
      };

  Product convertProductoDefault() {
    // convertimos en el modelo para producto global
    Product productoDefault = Product(upgrade: Timestamp.now(), creation: Timestamp.now());
    productoDefault.id = id;
    productoDefault.followers = followers;
    productoDefault.image = image;
    productoDefault.verified = verified;
    productoDefault.outstanding = outstanding;
    productoDefault.idMark =  idMark;
    productoDefault.nameMark =  nameMark;
    productoDefault.description =  description;
    productoDefault.code = code;
    return productoDefault;
  }

  ProductCatalogue updateData({required Product product}) {
    // actualizamos los datos del documento publico
    id = product.id;
    followers = product.followers;
    image = product.image;
    verified = product.verified;
    outstanding = product.outstanding;
    idMark = product.idMark;
    nameMark = product.nameMark;
    description = product.description;
    code = product.code;
    documentCreation = product.creation;
    documentUpgrade = product.upgrade;
    return this;
  }
  
  // Fuction
  String get getPorcentage{
    // description : obtenemos el porcentaje de las ganancias
    if ( purchasePrice == 0 || salePrice == 0) {
      return '';
    }
    
    double ganancia = salePrice - purchasePrice;
    double porcentajeDeGanancia = (ganancia / purchasePrice) * 100;
    
    if (ganancia % 1 != 0) {
      return '${porcentajeDeGanancia.toStringAsFixed(2)}%';
    } else {
      return '${porcentajeDeGanancia.toInt()}%';
    }
  }
  String get getBenefits{
    // description : obtenemos las ganancias 
    double ganancia = 0.0;
    if (salePrice != 0.0 && purchasePrice !=0.0) {
      ganancia = salePrice - purchasePrice;

    final String value = Publications.getFormatoPrecio(monto: ganancia);
    return value;
    }
    return'';
  }
  get isComplete => description.isNotEmpty && nameMark.isNotEmpty ;

}

class ProductPrice {
  String id = '';
  double price = 0.0;
  late Timestamp time; // marca de tiempo en la que se registro el precio
  String currencySign = ""; // signo de la moneda
  String province = ""; // provincia
  String town = ""; // ciudad o pueblo
  // data account
  String idAccount = "";
  String imageAccount = ''; // imagen de perfil de la cuenta
  String nameAccount = ''; // nombre de la cuenta

  ProductPrice({
    required this.id,
    required this.idAccount,
    required this.imageAccount,
    required this.nameAccount,
    required this.price,
    required this.time,
    required this.currencySign,
    this.province = '',
    this.town = '',
  });

  ProductPrice.fromMap(Map data) {
    id = data['id'] ?? '';
    idAccount = data['idAccount'] ?? '';
    imageAccount = data.containsKey('imageAccount')
        ? data['imageAccount']
        : data['urlImageAccount'] ?? '';
    nameAccount = data['nameAccount'] ?? '';
    price = data.containsKey('price') ? data['price'] : data['precio'] ?? 0.0;
    time = data.containsKey('time') ? data['time'] : data['timestamp'];
    currencySign = data.containsKey('currencySign')
        ? data['currencySign']
        : data['moneda'] ?? '';
    province = data.containsKey('province')
        ? data['province']
        : data['provincia'] ?? '';
    town = data.containsKey('town') ? data['town'] : data['ciudad'] ?? '';
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        "idAccount": idAccount,
        "imageAccount": imageAccount,
        "nameAccount": nameAccount,
        "price": price,
        "time": time,
        "currencySign": currencySign,
        "province": province,
        "town": town,
      };
}

class Category {
  String id = "";
  String name = "";
  Map<String, dynamic> subcategories = Map<String, dynamic>();

  Category({
    this.id = "",
    this.name = "",
    this.subcategories = const {},
  });
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "subcategories": subcategories,
      };
  factory Category.fromMap(Map<String, dynamic> data) {
    return Category(
      id: data['id'] ?? '',
      name: data.containsKey('name') ? data['name'] : data['nombre'] ?? '',
      subcategories: data.containsKey('subcategories')
          ? data['subcategories']
          : data['subcategorias'] ?? new Map<String, dynamic>(),
    );
  }
  Category.fromDocumentSnapshot({required DocumentSnapshot documentSnapshot}) {
    Map data = documentSnapshot.data() as Map;

    id = data['id'] ?? '';
    name = data.containsKey('name') ? data['name'] : data['nombre'] ?? '';
    subcategories = data.containsKey('subcategories')
        ? data['subcategories']
        : data['subcategorias'] ?? new Map<String, dynamic>();
  }
}

class Mark {
  String id = "";
  String name = "";
  String description = "";
  String image = "";
  bool verified = false;
  // Datos de la creación
  String idUsuarioCreador = ""; // ID el usuaruio que creo el productos
  Timestamp creation =
      Timestamp.now(); // Marca de tiempo de la creacion del documento
  Timestamp upgrade =
      Timestamp.now(); // Marca de tiempo de la ultima actualizacion

  Mark({
    this.id = "",
    this.name = "",
    this.description = "",
    this.image = "",
    this.verified = false,
    required this.upgrade,
    required this.creation,
  });
  Mark.fromMap(Map data) {
    id = data['id'] ?? '';
    name = data.containsKey('name') ? data['name'] : data['titulo'] ?? '';
    description = data.containsKey('description')
        ? data['description']
        : data['descripcion'] ?? '';
    image =
        data.containsKey('image') ? data['image'] : data['url_imagen'] ?? '';
    verified = data.containsKey('verified')
        ? data['verified']
        : data['verificado'] ?? false;
    creation = data.containsKey('creation')
        ? data['creation']
        : data['timestampCreacion'] ?? Timestamp.now();
    upgrade = data.containsKey('upgrade')
        ? data['upgrade']
        : data['timestampUpdate'] ?? Timestamp.now();
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "image": image,
        "verified": verified,
        "creation": creation,
        "upgrade": upgrade,
      };

  // Sobreescribir el operador ==
  @override
  bool operator ==(other) {
    return other is Mark && other.id == id && other.name == name;
  }
  // Sobreescribir el metodo hashCode
  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class ReportProduct {
  String id = ''; // idUser=idUserReport
  String idProduct = '';
  String idUserReport = '';
  String description = '';
  late Timestamp time; // Marca de tiempo ( hora en que se reporto el producto )

  ReportProduct({
    this.id = "",
    this.idProduct = "",
    this.idUserReport = "",
    this.description = "",
    required this.time,
  });
  Map<String, dynamic> toJson() => {
        "id": id,
        "idProduct": idProduct,
        "idUserReport": idUserReport,
        "description": description,
        "time": time,
      };
  factory ReportProduct.fromMap(Map<String, dynamic> data) {
    return ReportProduct(
      id: data['id'] ?? '',
      idProduct: data['name'] ?? '',
      idUserReport: data['idUserReport'] ?? '',
      description: data['description'] ?? '',
      time: data['time'],
    );
  }
  ReportProduct.fromDocumentSnapshot(
      {required DocumentSnapshot documentSnapshot}) {
    Map data = documentSnapshot.data() as Map;

    id = data['id'] ?? '';
    idProduct = data['name'] ?? '';
    idUserReport = data['idUserReport'] ?? '';
    description = data['description'] ?? '';
    time = data['time'];
  }
}

// class Supplier: proveedor de productos  
class Provider {
  String id = ""; 
  String name = ""; 
  Provider({
    this.id = "", 
    this.name = "", 
  });
  Provider.fromMap(Map data) {
    id = data['id'] ?? ''; 
    name = data['name'] ?? ''; 
  }
  Map<String, dynamic> toJson() => {
        "id": id, 
        "name": name, 
      }; 
  Provider.fromDocumentSnapshot({required DocumentSnapshot documentSnapshot}) {
    Map data = documentSnapshot.data() as Map;

    id = data['id'] ?? ''; 
    name = data['name'] ?? ''; 
  }
 
}