import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Verificar si es primera vez del usuario
  Future<bool> isFirstTime(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return !doc.exists;
    } catch (e) {
      return true;
    }
  }

  // Guardar datos iniciales (ACTUALIZADO CON MONEDA)
  Future<void> saveInitialData({
    required String uid,
    required String email,
    required String displayName,
    required String currency, // <--- NUEVO CAMPO
    required Map<String, Map<String, dynamic>> ingresos,
    required Map<String, Map<String, dynamic>> gastosFijos,
    required Map<String, Map<String, dynamic>> gastosVariables,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);

      // 1. Documento base con la moneda seleccionada
      await userRef.set({
        'email': email,
        'displayName': displayName,
        'currency': currency, // <--- GUARDAMOS LA MONEDA AQUÍ
        'createdAt': FieldValue.serverTimestamp(),
        'isFirstTime': false,
      });

      final batch = _firestore.batch();

      // 2. Guardar Colecciones (Se mantiene igual)
      for (var entry in ingresos.entries) {
        final docRef = userRef.collection('ingresos').doc();
        batch.set(docRef, {
          'nombre': entry.key,
          'estimado': entry.value['estimado'] ?? 0,
          'actual': entry.value['actual'] ?? 0,
          'icon': entry.value['icon']?.codePoint,
          'color': entry.value['color']?.value,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if ((entry.value['actual'] ?? 0) > 0) {
          final transRef = userRef.collection('transacciones').doc();
          batch.set(transRef, {
            'categoria': entry.key,
            'monto': entry.value['actual'],
            'concepto': 'Saldo Inicial',
            'fecha': DateTime.now().toIso8601String(),
            'type': 'income',
            'icon': entry.value['icon']?.codePoint,
            'color': entry.value['color']?.value,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      for (var entry in gastosFijos.entries) {
        final docRef = userRef.collection('gastosFijos').doc();
        batch.set(docRef, {
          'nombre': entry.key,
          'presupuestado': entry.value['presupuestado'] ?? 0,
          'actual': 0,
          'icon': entry.value['icon']?.codePoint,
          'color': entry.value['color']?.value,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      for (var entry in gastosVariables.entries) {
        final docRef = userRef.collection('gastosVariables').doc();
        batch.set(docRef, {
          'nombre': entry.key,
          'presupuestado': entry.value['presupuestado'] ?? 0,
          'actual': 0,
          'icon': entry.value['icon']?.codePoint,
          'color': entry.value['color']?.value,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      await userRef.update({'lastUpdated': FieldValue.serverTimestamp()});
    } catch (e) {
      debugPrint('❌ Error onboarding: $e');
      rethrow;
    }
  }

  // --- STREAM DE DATOS (ACTUALIZADO) ---
  Stream<Map<String, dynamic>> streamUserData(String uid) {
    final userRef = _firestore.collection('users').doc(uid);

    return userRef.snapshots().asyncExpand((userDoc) async* {
      try {
        // LEER MONEDA DEL USUARIO
        final currencySymbol = userDoc.data()?['currency'] ?? '\$'; // Default $

        // Cargar colecciones
        final ingresosDocs = await userRef.collection('ingresos').get();
        final fijosDocs = await userRef.collection('gastosFijos').get();
        final variablesDocs = await userRef.collection('gastosVariables').get();

        // Mapear Ingresos
        Map<String, Map<String, dynamic>> ingresos = {};
        for (var doc in ingresosDocs.docs) {
          final data = doc.data();
          ingresos[data['nombre'] ?? 'Sin Nombre'] = {
            'actual': (data['actual'] ?? 0).toDouble(),
            ...data,
          };
        }

        // Mapear Gastos Fijos
        Map<String, Map<String, dynamic>> gastosFijos = {};
        for (var doc in fijosDocs.docs) {
          final data = doc.data();
          gastosFijos[data['nombre'] ?? 'Sin Nombre'] = {
            'actual': (data['actual'] ?? 0).toDouble(),
            'presupuestado': (data['presupuestado'] ?? 0).toDouble(),
            ...data,
          };
        }

        // Mapear Gastos Variables
        Map<String, Map<String, dynamic>> gastosVariables = {};
        for (var doc in variablesDocs.docs) {
          final data = doc.data();
          gastosVariables[data['nombre'] ?? 'Sin Nombre'] = {
            'actual': (data['actual'] ?? 0).toDouble(),
            'presupuestado': (data['presupuestado'] ?? 0).toDouble(),
            ...data,
          };
        }

        // Cargar Transacciones
        final transaccionesSnapshot = await userRef
            .collection('transacciones')
            .get();
        List<Map<String, dynamic>> transacciones = [];
        for (var doc in transaccionesSnapshot.docs) {
          final data = doc.data();
          transacciones.add({
            'id': doc.id,
            'amount': (data['monto'] ?? data['amount'] ?? 0).toDouble(),
            'description':
                (data['concepto'] ?? data['description'] ?? 'Sin descripción')
                    .toString(),
            'category': (data['categoria'] ?? data['category'] ?? 'General')
                .toString(),
            'date':
                data['fecha'] ??
                data['date'] ??
                DateTime.now().toIso8601String(),
            'type': (data['type'] ?? 'expense').toString(),
            'icon': data['icon'],
            'color': data['color'],
          });
        }

        yield {
          'currency': currencySymbol, // <--- ENVIAMOS LA MONEDA
          'ingresos': ingresos,
          'gastosFijos': gastosFijos,
          'gastosVariables': gastosVariables,
          'transacciones': transacciones,
        };
      } catch (e) {
        debugPrint('Error streamUserData: $e');
        yield {
          'currency': '\$',
          'ingresos': {},
          'gastosFijos': {},
          'gastosVariables': {},
          'transacciones': [],
        };
      }
    });
  }

  // --- MÉTODOS DE ESCRITURA (Transacciones y Categorías) ---

  Future<void> addTransaccion({
    required String uid,
    required String categoria,
    required double monto,
    required String concepto,
    required String fecha,
    required String type,
    int? iconCode,
    int? colorValue,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);

    // 1. Guardar en historial
    await userRef.collection('transacciones').add({
      'categoria': categoria,
      'monto': monto,
      'concepto': concepto,
      'fecha': fecha,
      'type': type,
      'icon': iconCode,
      'color': colorValue,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Notificar cambio visual
    await userRef.update({'lastUpdated': FieldValue.serverTimestamp()});
  }

  // CREAR NUEVO PRESUPUESTO (Solo crea la "caja", no gasta dinero)
  Future<void> addCategoriaPresupuesto({
    required String uid,
    required String tipo, // 'fixed' o 'variable'
    required String nombre,
    required double presupuestado,
    int? iconCode,
    int? colorValue,
  }) async {
    final collectionName = tipo == 'fixed' ? 'gastosFijos' : 'gastosVariables';

    await _firestoreServiceRef(uid).collection(collectionName).add({
      'nombre': nombre,
      'presupuestado': presupuestado,
      'actual': 0, // Empieza vacío
      'icon': iconCode,
      'color': colorValue,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestoreServiceRef(
      uid,
    ).update({'lastUpdated': FieldValue.serverTimestamp()});
  }

  // Agregar Ingreso (Nuevo o existente)
  Future<void> addIngreso({
    required String uid,
    required String nombre,
    required double estimado,
    required double actual,
    int? iconCode,
    int? colorValue,
  }) async {
    // Verificar si ya existe para no duplicar (Opcional, por ahora agregamos)
    await _firestoreServiceRef(uid).collection('ingresos').add({
      'nombre': nombre,
      'estimado': estimado,
      'actual': actual,
      'icon': iconCode,
      'color': colorValue,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _firestoreServiceRef(
      uid,
    ).update({'lastUpdated': FieldValue.serverTimestamp()});
  }

  // --- LA PIEZA CLAVE: Sincronizar Gasto -> Categoría ---
  // Cuando gastas 500 en "Comida", esto busca la categoría "Comida" y le suma 500 a "actual"
  Future<void> updateCategoriaActual({
    required String uid,
    required String categoria,
    required double monto,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);

    // Buscar en Fijos
    final fijosQ = await userRef
        .collection('gastosFijos')
        .where('nombre', isEqualTo: categoria)
        .get();
    for (var doc in fijosQ.docs) {
      await doc.reference.update({'actual': FieldValue.increment(monto)});
    }

    // Buscar en Variables
    final varQ = await userRef
        .collection('gastosVariables')
        .where('nombre', isEqualTo: categoria)
        .get();
    for (var doc in varQ.docs) {
      await doc.reference.update({'actual': FieldValue.increment(monto)});
    }

    // Si es un ingreso extra, actualizamos la colección ingresos
    // (Lógica inversa: si registras un ingreso que ya existe)
    final ingQ = await userRef
        .collection('ingresos')
        .where('nombre', isEqualTo: categoria)
        .get();
    for (var doc in ingQ.docs) {
      // Si es ingreso, también sumamos al acumulado
      await doc.reference.update({'actual': FieldValue.increment(monto)});
    }
  }

  // Helper privado
  DocumentReference _firestoreServiceRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  // Cargar datos para listas desplegables
  Future<Map<String, dynamic>> loadUserData(String uid) async {
    // Reutilizamos la lógica de stream pero una sola vez
    final stream = streamUserData(uid);
    return await stream.first;
  }
}
