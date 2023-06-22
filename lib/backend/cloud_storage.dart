import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final db = FirebaseFirestore.instance;
// final ingredientCollectionRef = db.collection('raw-materials');
final ingredientCollectionRef = db.collection('raw-materials');

class Ingredient {
  Ingredient(this.name, this.subUnit, this.quantity, this.rate);

  final String name;
  final String subUnit;
  num quantity;
  num rate;
}

Future<dynamic> addPurchaseRecord(
  String rawMaterialName,
  num previousQuantity,
  num addedQuantity,
  num rate,
) async {
  try {
    CollectionReference collectionRef = db.collection('purchase-history');
    var docRef = await collectionRef.add({
      "date": DateTime.now(),
      "name": rawMaterialName,
      "previousQuantity": previousQuantity,
      "addedQuantity": addedQuantity,
      "pricePerUnit": rate,
    });
    print('New record added with ID: ${docRef.id}');
    return docRef.id;
  } catch (error) {
    print('Error adding record: $error');
  }
}

Future<List<Ingredient>> fetchIngredientsData() async {
  final querySnapshot = await ingredientCollectionRef.get();

  return querySnapshot.docs
      .map(
        (doc) => Ingredient(
            doc.id, doc['unit'], doc['quantity'], doc['pricePerUnit']),
      )
      .toList();
}

Future<void> updateIngredientDetails(
    String ingredientName,num previousQuantity, num addedQuantity, num previousRate, num? totalPrice) async {
    num newRate = double.parse((totalPrice! / addedQuantity).toStringAsFixed(2));
    num avarageRate = double.parse(
      (((previousRate * previousQuantity) + totalPrice) /
              (previousQuantity + addedQuantity))
          .toStringAsFixed(2),
    );
    await db
      .collection('raw-materials')
      .doc(ingredientName)
      .update({'quantity': FieldValue.increment(addedQuantity), 'pricePerUnit': avarageRate});

    await addPurchaseRecord(ingredientName,previousQuantity,addedQuantity,newRate);
}

class PurchaseHistory {
  final String name;
  final String date;
  final num previousQuantity;
  final num addedQuantity;
  final num totalPrice;
  final num rate;

  const PurchaseHistory(
    this.name,
    this.date,
    this.previousQuantity,
    this.addedQuantity,
    this.rate,
    this.totalPrice,
  );

  factory PurchaseHistory.fromMap(Map<String, dynamic> map) {
    return PurchaseHistory(
      map['name'],
      DateFormat('d MMMM, yyyy').format(map['date'] as DateTime),
      map['previousQuantity'],
      map['addedQuantity'],
      map['pricePerUnit'],
      map['addedQuantity'] * map['pricePerUnit'],
    );
  }
}

Future<List<PurchaseHistory>> fetchPurchaseRecords(
    DateTime startDate, DateTime endDate) async {
  final querySnapshot = await db
      .collection('purchase-record')
      .where('date', isGreaterThanOrEqualTo: startDate)
      .where('date', isLessThanOrEqualTo: endDate)
      .orderBy('date')
      .get();

  return querySnapshot.docs
      .map(
        (document) => PurchaseHistory.fromMap(document.data()),
      )
      .toList();
}
