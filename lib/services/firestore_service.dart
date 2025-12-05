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

  // Guardar datos iniciales del usuario (CORREGIDO Y UNIFICADO)
  Future<void> saveInitialData({
    required String uid,
    required String email,
    required String displayName,
    required Map<String, Map<String, dynamic>> ingresos,
    required Map<String, Map<String, dynamic>> gastosFijos,
    required Map<String, Map<String, dynamic>> gastosVariables,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);

      // 1. Crear documento base del usuario
      await userRef.set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'isFirstTime': false,
      });

      final batch = _firestore.batch();

      // FUNCIÓN AUXILIAR PARA NO REPETIR CÓDIGO
      // Guarda en la colección específica Y en el historial de transacciones
      void agregarAlBatch(
        String coleccion,
        String tipoTransaccion,
        String nombre,
        Map<String, dynamic> datos,
      ) {
        // A. Guardar en su colección (ingresos/gastosFijos/etc)
        final docRef = userRef.collection(coleccion).doc();
        batch.set(docRef, {
          'nombre': nombre,
          'estimado': datos['estimado'] ?? 0, // Para ingresos
          'presupuestado': datos['presupuestado'] ?? 0, // Para gastos
          'actual': datos['actual'] ?? 0,
          'icon': datos['icon']?.codePoint,
          'color': datos['color']?.value,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // B. Guardar en el Historial de Transacciones (¡ESTO FALTABA!)
        // Solo si el monto actual > 0 (para no llenar el historial de ceros si es solo presupuesto)
        double montoActual = (datos['actual'] ?? 0).toDouble();
        if (montoActual > 0) {
          final transRef = userRef.collection('transacciones').doc();
          batch.set(transRef, {
            'categoria': nombre,
            'monto': montoActual,
            'concepto': coleccion == 'ingresos'
                ? 'Ingreso Inicial'
                : 'Gasto Inicial (Onboarding)',
            'fecha': DateTime.now().toIso8601String(),
            'type': tipoTransaccion, // 'income' o 'expense'
            'icon': datos['icon']?.codePoint,
            'color': datos['color']?.value,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // 2. Procesar Ingresos
      for (var entry in ingresos.entries) {
        agregarAlBatch('ingresos', 'income', entry.key, entry.value);
      }

      // 3. Procesar Gastos Fijos
      for (var entry in gastosFijos.entries) {
        agregarAlBatch('gastosFijos', 'expense', entry.key, entry.value);
      }

      // 4. Procesar Gastos Variables
      for (var entry in gastosVariables.entries) {
        agregarAlBatch('gastosVariables', 'expense', entry.key, entry.value);
      }

      // Ejecutar todo
      await batch.commit();

      // 5. Despertar al Dashboard
      await userRef.update({'lastUpdated': FieldValue.serverTimestamp()});

      print('✅ Onboarding completado: Datos y Transacciones creadas.');
    } catch (e) {
      print('❌ Error guardando datos iniciales: $e');
      rethrow;
    }
  }

  Stream<Map<String, dynamic>> streamUserData(String uid) {
    final userRef = _firestore.collection('users').doc(uid);

    return userRef.snapshots().asyncExpand((userDoc) async* {
      try {
        // 1. Cargar colecciones auxiliares (Presupuestos)
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
            ...data,
          };
        }

        // Mapear Gastos Variables
        Map<String, Map<String, dynamic>> gastosVariables = {};
        for (var doc in variablesDocs.docs) {
          final data = doc.data();
          gastosVariables[data['nombre'] ?? 'Sin Nombre'] = {
            'actual': (data['actual'] ?? 0).toDouble(),
            ...data,
          };
        }

        // 2. Cargar Transacciones (SIN ORDERBY PARA EVITAR ERROR DE ÍNDICE)
        final transaccionesSnapshot = await userRef
            .collection('transacciones')
            .get(); // <--- Aquí quitamos el orderBy que causaba el fallo

        List<Map<String, dynamic>> transacciones = [];
        for (var doc in transaccionesSnapshot.docs) {
          final data = doc.data();
          transacciones.add({
            'id': doc.id,
            // Traducción segura de datos (Español/Inglés)
            'amount': (data['monto'] ?? data['amount'] ?? 0).toDouble(),
            'description':
                (data['concepto'] ?? data['description'] ?? 'Sin descripción')
                    .toString(),
            'category': (data['categoria'] ?? data['category'] ?? 'General')
                .toString(),
            // Fecha segura
            'date':
                data['fecha'] ??
                data['date'] ??
                DateTime.now().toIso8601String(),
            'type': (data['type'] ?? 'expense').toString(),
            'icon': data['icon'],
            'color': data['color'],
          });
        }

        // Enviamos todo (El ordenamiento ya lo hace el Dashboard)
        yield {
          'ingresos': ingresos,
          'gastosFijos': gastosFijos,
          'gastosVariables': gastosVariables,
          'transacciones': transacciones,
        };
      } catch (e) {
        debugPrint('Error CRÍTICO en streamUserData: $e');
        // Si falla, devolvemos vacío para que no explote la app, pero logueamos el error
        yield {
          'ingresos': <String, Map<String, dynamic>>{},
          'gastosFijos': <String, Map<String, dynamic>>{},
          'gastosVariables': <String, Map<String, dynamic>>{},
          'transacciones': <Map<String, dynamic>>[],
        };
      }
    });
  }

  // --- AGREGAR TRANSACCIÓN (AHORA CON TIPO) ---
  Future<void> addTransaccion({
    required String uid,
    required String categoria,
    required double monto,
    required String concepto,
    required String fecha,
    required String type, // <--- NUEVO CAMPO OBLIGATORIO
    int? iconCode,
    int? colorValue,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      await userRef.collection('transacciones').add({
        'categoria': categoria,
        'monto': monto,
        'concepto': concepto,
        'fecha': fecha,
        'type': type, // Guardamos si es 'income' o 'expense'
        'icon': iconCode,
        'color': colorValue,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Forzar actualización visual
      await userRef.set({
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error agregando transacción: $e');
      rethrow;
    }
  }

  // MÉTODOS AUXILIARES (Fijos/Variables)
  Future<void> addGastoFijo({
    required String uid,
    required String nombre,
    required double actual,
    int? iconCode,
    int? colorValue,
    required double presupuestado,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('gastosFijos')
        .add({
          'nombre': nombre,
          'actual': actual,
          'presupuestado': presupuestado,
          'icon': iconCode,
          'color': colorValue,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> addGastoVariable({
    required String uid,
    required String nombre,
    required double actual,
    int? iconCode,
    int? colorValue,
    required double presupuestado,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('gastosVariables')
        .add({
          'nombre': nombre,
          'actual': actual,
          'presupuestado': presupuestado,
          'icon': iconCode,
          'color': colorValue,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateCategoriaActual({
    required String uid,
    required String categoria,
    required double monto,
  }) async {
    // (Tu lógica de actualización existente)
  }

  // Agregar un ingreso (Restaurado para la Web)
  Future<void> addIngreso({
    required String uid,
    required String nombre,
    required double estimado,
    required double actual,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      await userRef.collection('ingresos').add({
        'nombre': nombre,
        'estimado': estimado,
        'actual': actual,
        'icon': Icons.attach_money_rounded.codePoint,
        'color': 0xFF10B981, // Verde por defecto
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Actualizar timestamp global
      await userRef.set({
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error agregando ingreso: $e');
      rethrow;
    }
  }

  // Cargar datos una sola vez (para llenar los dropdowns de categorías)
  Future<Map<String, dynamic>> loadUserData(String uid) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);

      // 1. Cargar Ingresos
      final ingresosSnapshot = await userRef.collection('ingresos').get();
      Map<String, Map<String, dynamic>> ingresos = {};
      for (var doc in ingresosSnapshot.docs) {
        final data = doc.data();
        // Usamos el nombre como clave
        ingresos[data['nombre'] ?? 'Sin Nombre'] = data;
      }

      // 2. Cargar Gastos Fijos
      final fijosSnapshot = await userRef.collection('gastosFijos').get();
      Map<String, Map<String, dynamic>> gastosFijos = {};
      for (var doc in fijosSnapshot.docs) {
        final data = doc.data();
        gastosFijos[data['nombre'] ?? 'Sin Nombre'] = data;
      }

      // 3. Cargar Gastos Variables
      final variablesSnapshot = await userRef
          .collection('gastosVariables')
          .get();
      Map<String, Map<String, dynamic>> gastosVariables = {};
      for (var doc in variablesSnapshot.docs) {
        final data = doc.data();
        gastosVariables[data['nombre'] ?? 'Sin Nombre'] = data;
      }

      return {
        'ingresos': ingresos,
        'gastosFijos': gastosFijos,
        'gastosVariables': gastosVariables,
      };
    } catch (e) {
      debugPrint('❌ Error cargando datos para listas: $e');
      return {'ingresos': {}, 'gastosFijos': {}, 'gastosVariables': {}};
    }
  }
}
