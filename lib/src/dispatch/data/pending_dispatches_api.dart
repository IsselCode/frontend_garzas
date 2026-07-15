import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/dispatch/entities/pending_dispatch_entity.dart';

class PendingDispatchesApi {
  final ApiClient apiClient;

  PendingDispatchesApi({required this.apiClient});

  final String _pendingDispatchesPath = '/pending-dispatches';

  Future<List<PendingDispatchEntity>> listPendingDispatches({
    String? status,
    String? plateOrUnitReference,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (plateOrUnitReference != null &&
          plateOrUnitReference.trim().isNotEmpty) {
        queryParams['plate_or_unit_reference'] = plateOrUnitReference.trim();
      }

      final List response = await apiClient.get(
        _pendingDispatchesPath,
        authRequired: true,
        queryParams: queryParams.isEmpty ? null : queryParams,
      );

      return response.map((e) => PendingDispatchEntity.fromMap(e)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<PendingDispatchEntity> createPendingDispatch({
    required String plateOrUnitReference,
    required int garzaNumber,
    required UnitOfMeasurement unitOfMeasurement,
    double? quantity,
    String? customerEmployeeName,
  }) async {
    try {
      final body = <String, dynamic>{
        'plate_or_unit_reference': plateOrUnitReference,
        'garza_number': garzaNumber,
        'unit_of_measurement': unitOfMeasurement.name,
      };

      if (quantity != null) {
        body['quantity'] = quantity;
      }

      final employeeName = customerEmployeeName?.trim();
      if (employeeName != null && employeeName.isNotEmpty) {
        body['customer_employee_name'] = employeeName;
      }

      final response = await apiClient.post(
        _pendingDispatchesPath,
        authRequired: true,
        body: body,
      );

      return PendingDispatchEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<PendingDispatchEntity> cancelPendingDispatch(int id) async {
    try {
      final response = await apiClient.post(
        '$_pendingDispatchesPath/$id/cancel',
        authRequired: true,
      );

      return PendingDispatchEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<SaleEntity> settlePendingDispatch({
    required int id,
    int? clientId,
    required PaymentMethod paymentMethod,
    required double amountPaid,
    required double changeAmount,
  }) async {
    try {
      final body = <String, dynamic>{
        'client_id': clientId,
        'payment_method': paymentMethod.name,
        'amount_paid': amountPaid,
        'change_amount': changeAmount,
      };

      final response = await apiClient.post(
        '$_pendingDispatchesPath/$id/settle',
        authRequired: true,
        body: body,
      );

      return SaleEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }
}
