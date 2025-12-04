import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // ← AGREGAR ESTA LÍNEA

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Verificar si es primera vez del usuario
  Future<bool> isFirstTime(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return !doc.exists;
    } catch (e) {
      print('Error checking first time: $e');
      return true;
    }
  }

  // Guardar datos iniciales del usuario
  Future<void> saveInitialData({
    required String uid,
    required String email,
    required String displayName,
    required Map<String, Map<String, dynamic>>
    ingresos, // ← CAMBIAR double por dynamic
    required Map<String, Map<String, dynamic>>
    gastosFijos, // ← CAMBIAR double por dynamic
    required Map<String, Map<String, dynamic>>
    gastosVariables, // ← CAMBIAR double por dynamic
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);

      // Guardar perfil
      await userRef.set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'isFirstTime': false,
      });

      // Guardar ingresos
      for (var entry in ingresos.entries) {
        await userRef.collection('ingresos').add({
          'nombre': entry.key,
          'estimado': entry.value['estimado'] ?? 0,
          'actual': entry.value['actual'] ?? 0,
          'icon':
              entry.value['icon']?.codePoint ??
              Icons.attach_money_rounded.codePoint, // ← AGREGAR
          'color': entry.value['color']?.value ?? 0xFF10B981, // ← AGREGAR
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Guardar gastos fijos
      for (var entry in gastosFijos.entries) {
        await userRef.collection('gastosFijos').add({
          'nombre': entry.key,
          'presupuestado': entry.value['presupuestado'] ?? 0,
          'actual': entry.value['actual'] ?? 0,
          'icon':
              entry.value['icon']?.codePoint ??
              Icons.attach_money_rounded.codePoint, // ← AGREGAR
          'color': entry.value['color']?.value ?? 0xFFF59E0B, // ← AGREGAR
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Guardar gastos variables
      for (var entry in gastosVariables.entries) {
        await userRef.collection('gastosVariables').add({
          'nombre': entry.key,
          'presupuestado': entry.value['presupuestado'] ?? 0,
          'actual': entry.value['actual'] ?? 0,
          'icon':
              entry.value['icon']?.codePoint ??
              Icons.attach_money_rounded.codePoint, // ← AGREGAR
          'color': entry.value['color']?.value ?? 0xFF3B82F6, // ← AGREGAR
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      print('✅ Datos iniciales guardados exitosamente');
    } catch (e) {
      print('❌ Error guardando datos iniciales: $e');
      rethrow;
    }
  }

  // Cargar datos del usuario
  // Cargar datos del usuario
  Future<Map<String, dynamic>> loadUserData(String uid) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);

      // Cargar ingresos
      final ingresosSnapshot = await userRef.collection('ingresos').get();
      Map<String, Map<String, dynamic>> ingresos = {};
      for (var doc in ingresosSnapshot.docs) {
        final data = doc.data();
        ingresos[data['nombre']] = {
          'estimado': (data['estimado'] ?? 0).toDouble(),
          'actual': (data['actual'] ?? 0).toDouble(),
          'icon': IconData(
            data['icon'] ?? Icons.attach_money_rounded.codePoint,
            fontFamily: 'MaterialIcons',
          ),
          'color': Color(data['color'] ?? 0xFF10B981),
        };
      }

      // Cargar gastos fijos
      final gastosFijosSnapshot = await userRef.collection('gastosFijos').get();
      Map<String, Map<String, dynamic>> gastosFijos = {};
      for (var doc in gastosFijosSnapshot.docs) {
        final data = doc.data();
        gastosFijos[data['nombre']] = {
          'presupuestado': (data['presupuestado'] ?? 0).toDouble(),
          'actual': (data['actual'] ?? 0).toDouble(),
          'icon': IconData(
            data['icon'] ?? Icons.attach_money_rounded.codePoint,
            fontFamily: 'MaterialIcons',
          ),
          'color': Color(data['color'] ?? 0xFFF59E0B),
        };
      }

      // Cargar gastos variables
      final gastosVariablesSnapshot = await userRef
          .collection('gastosVariables')
          .get();
      Map<String, Map<String, dynamic>> gastosVariables = {};
      for (var doc in gastosVariablesSnapshot.docs) {
        final data = doc.data();
        gastosVariables[data['nombre']] = {
          'presupuestado': (data['presupuestado'] ?? 0).toDouble(),
          'actual': (data['actual'] ?? 0).toDouble(),
          'icon': IconData(
            data['icon'] ?? Icons.attach_money_rounded.codePoint,
            fontFamily: 'MaterialIcons',
          ),
          'color': Color(data['color'] ?? 0xFF3B82F6),
        };
      }

      // Dentro de streamUserData (y loadUserData)...
      // Cargar transacciones
      final transaccionesSnapshot = await userRef
          .collection('transacciones')
          .orderBy('createdAt', descending: true)
          .get(); // Ojo: en stream usas snapshots(), ajusta según tu lógica de stream

      List<Map<String, dynamic>> transacciones = [];
      for (var doc in transaccionesSnapshot.docs) {
        // Ojo: si es stream usa el evento
        final data = doc.data();
        transacciones.add({
          'id': doc.id,
          'categoria': data['categoria'] ?? '',
          'monto': (data['monto'] ?? 0).toDouble(),
          'concepto': data['concepto'] ?? '',
          'fecha': data['fecha'] ?? '',
          // RECUPERAR DATOS VISUALES
          'icon': data['icon'], // int?
          'color': data['color'], // int?
        });
      }

      return {
        'ingresos': ingresos,
        'gastosFijos': gastosFijos,
        'gastosVariables': gastosVariables,
        'transacciones': transacciones,
      };
    } catch (e) {
      print('❌ Error cargando datos: $e');
      return {
        'ingresos': <String, Map<String, dynamic>>{},
        'gastosFijos': <String, Map<String, dynamic>>{},
        'gastosVariables': <String, Map<String, dynamic>>{},
        'transacciones': [],
      };
    }
  }

  Stream<Map<String, dynamic>> streamUserData(String uid) {
    final userRef = _firestore.collection('users').doc(uid);

    // Escuchar cambios en el documento padre Y en las subcolecciones
    return userRef.snapshots().asyncExpand((userDoc) async* {
      try {
        // Cargar ingresos
        final ingresosSnapshot = await userRef.collection('ingresos').get();
        Map<String, Map<String, dynamic>> ingresos = {};
        for (var doc in ingresosSnapshot.docs) {
          final data = doc.data();
          ingresos[data['nombre']] = {
            'estimado': (data['estimado'] ?? 0).toDouble(),
            'actual': (data['actual'] ?? 0).toDouble(),
            'icon': IconData(
              data['icon'] ?? Icons.attach_money_rounded.codePoint,
              fontFamily: 'MaterialIcons',
            ),
            'color': Color(data['color'] ?? 0xFF10B981),
          };
        }

        // Cargar gastos fijos
        final gastosFijosSnapshot = await userRef
            .collection('gastosFijos')
            .get();
        Map<String, Map<String, dynamic>> gastosFijos = {};
        for (var doc in gastosFijosSnapshot.docs) {
          final data = doc.data();
          gastosFijos[data['nombre']] = {
            'presupuestado': (data['presupuestado'] ?? 0).toDouble(),
            'actual': (data['actual'] ?? 0).toDouble(),
            'icon': IconData(
              data['icon'] ?? Icons.attach_money_rounded.codePoint,
              fontFamily: 'MaterialIcons',
            ),
            'color': Color(data['color'] ?? 0xFFF59E0B),
            // Guardamos los valores crudos también por si acaso
            'iconCode': data['icon'],
            'colorValue': data['color'],
          };
        }

        // Cargar gastos variables
        final gastosVariablesSnapshot = await userRef
            .collection('gastosVariables')
            .get();
        Map<String, Map<String, dynamic>> gastosVariables = {};
        for (var doc in gastosVariablesSnapshot.docs) {
          final data = doc.data();
          gastosVariables[data['nombre']] = {
            'presupuestado': (data['presupuestado'] ?? 0).toDouble(),
            'actual': (data['actual'] ?? 0).toDouble(),
            'icon': IconData(
              data['icon'] ?? Icons.attach_money_rounded.codePoint,
              fontFamily: 'MaterialIcons',
            ),
            'color': Color(data['color'] ?? 0xFF3B82F6),
            // Guardamos los valores crudos también
            'iconCode': data['icon'],
            'colorValue': data['color'],
          };
        }

        // Cargar transacciones
        final transaccionesSnapshot = await userRef
            .collection('transacciones')
            .orderBy('createdAt', descending: true)
            .get();
        List<Map<String, dynamic>> transacciones = [];
        for (var doc in transaccionesSnapshot.docs) {
          final data = doc.data();
          transacciones.add({
            'id': doc.id,
            'categoria': data['categoria'] ?? '',
            'monto': (data['monto'] ?? 0).toDouble(),
            'concepto': data['concepto'] ?? '',
            'fecha': data['fecha'] ?? '',
            // Aquí leemos el icono y color guardados
            'icon': data['icon'],
            'color': data['color'],
          });
        }

        yield {
          'ingresos': ingresos,
          'gastosFijos': gastosFijos,
          'gastosVariables': gastosVariables,
          'transacciones': transacciones,
        };
      } catch (e) {
        print('❌ Error en stream: $e');
        yield {
          'ingresos': <String, Map<String, dynamic>>{},
          'gastosFijos': <String, Map<String, dynamic>>{},
          'gastosVariables': <String, Map<String, dynamic>>{},
          'transacciones': [],
        };
      }
    });
  }

  Future<void> addGastoFijo({
    required String uid,
    required String nombre,
    required double presupuestado,
    required double actual,
    int? iconCode,
    int? colorValue,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      await userRef.collection('gastosFijos').add({
        'nombre': nombre,
        'presupuestado': presupuestado,
        'actual': actual,
        'icon': iconCode ?? Icons.attach_money_rounded.codePoint,
        'color': colorValue ?? 0xFFF59E0B,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Gasto fijo agregado: $nombre');
      // Forzar actualización del stream
      await userRef.set({
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error agregando gasto fijo: $e');
      rethrow;
    }
  }

  Future<void> addGastoVariable({
    required String uid,
    required String nombre,
    required double presupuestado,
    required double actual,
    int? iconCode,
    int? colorValue,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      await userRef.collection('gastosVariables').add({
        'nombre': nombre,
        'presupuestado': presupuestado,
        'actual': actual,
        'icon': iconCode ?? Icons.attach_money_rounded.codePoint,
        'color': colorValue ?? 0xFF3B82F6,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Gasto variable agregado: $nombre');
      await userRef.set({
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error agregando gasto variable: $e');
      rethrow;
    }
  }

  // Agregar un ingreso
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
        'color': 0xFF10B981,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Ingreso agregado: $nombre');
      // Forzar actualización del stream tocando el documento padre
      await userRef.set({
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error agregando ingreso: $e');
      rethrow;
    }
  }

  // Archivo: lib/services/firestore_service.dart

  Future<void> addTransaccion({
    required String uid,
    required String categoria,
    required double monto,
    required String concepto,
    required String fecha,
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
        'icon': iconCode,
        'color': colorValue,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Transacción agregada: $categoria');
      await userRef.set({
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error agregando transacción: $e');
      rethrow;
    }
  }

  // Eliminar una transacción
  Future<void> deleteTransaccion({
    required String uid,
    required String transaccionId,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      await userRef.collection('transacciones').doc(transaccionId).delete();
      debugPrint('✅ Transacción eliminada');
      // Forzar actualización del stream
      await userRef.set({
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error eliminando transacción: $e');
      rethrow;
    }
  }

  // INCREMENTAR el monto "actual" de una categoría existente
  Future<void> updateCategoriaActual({
    required String uid,
    required String categoria,
    required double monto,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);

      // 1. Buscar y actualizar en Gastos Fijos
      final fijosSnapshot = await userRef
          .collection('gastosFijos')
          .where('nombre', isEqualTo: categoria)
          .get();

      if (fijosSnapshot.docs.isNotEmpty) {
        for (var doc in fijosSnapshot.docs) {
          await doc.reference.update({'actual': FieldValue.increment(monto)});
          debugPrint('✅ Gasto Fijo actualizado: $categoria (+ $monto)');
        }
      }

      // 2. Buscar y actualizar en Gastos Variables
      final variablesSnapshot = await userRef
          .collection('gastosVariables')
          .where('nombre', isEqualTo: categoria)
          .get();

      if (variablesSnapshot.docs.isNotEmpty) {
        for (var doc in variablesSnapshot.docs) {
          await doc.reference.update({'actual': FieldValue.increment(monto)});
          debugPrint('✅ Gasto Variable actualizado: $categoria (+ $monto)');
        }
      }

      // Actualizar timestamp global para refrescar la UI
      await userRef.set({
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error actualizando categoría: $e');
      // No lanzamos error (rethrow) aquí para no interrumpir el flujo si no se encuentra la categoría
    }
  }
}
