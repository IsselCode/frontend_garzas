import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/core/services/server_status_controller.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/sales/clean/dtos/sale_info_dto.dart';

void main() {
  test('createSale sends the idempotency key header', () async {
    final apiClient = _RecordingApiClient();
    final salesApi = SalesApi(apiClient: apiClient);
    final dto = SaleInfoDto(
      waterType: WaterType.potable,
      unitOfMeasurement: UnitOfMeasurement.liters,
      quantity: 100,
      paymentMethod: PaymentMethod.card,
      amountPaid: 0,
      changeAmount: 0,
    );

    await salesApi.createSale(
      dto,
      idempotencyKey: '8f1c2c1e-0c0d-4b55-9a10-7b9a3ef3d2c1',
    );

    expect(apiClient.lastPath, '/sales');
    expect(
      apiClient.lastHeaders,
      containsPair('Idempotency-Key', '8f1c2c1e-0c0d-4b55-9a10-7b9a3ef3d2c1'),
    );
    expect(apiClient.lastBody, dto.toJson());
  });
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient()
    : super(serverStatusController: ServerStatusController());

  String? lastPath;
  Map<String, String>? lastHeaders;
  Map<String, dynamic>? lastBody;

  @override
  Future<dynamic> post(
    String path, {
    bool authRequired = true,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    lastPath = path;
    lastHeaders = headers;
    lastBody = body;
    return <String, dynamic>{
      'id': 1,
      'folio': 'F-1',
      'dispatch_code': 'D-1',
      'cash_cut_id': 1,
      'seller_uid': 'seller-1',
      'seller_username': 'Seller',
      'client_id': null,
      'commercial_name': null,
      'water_type': 'potable',
      'unit_of_measurement': 'liters',
      'quantity': 100.0,
      'unit_price': 1.0,
      'total': 100.0,
      'payment_method': 'card',
      'amount_paid': 0.0,
      'change_amount': 0.0,
      'is_dispatched': false,
      'created_at': '2026-08-04T18:30:10Z',
      'pending_amount': 0.0,
      'is_paid': true,
      'paid_at': null,
      'paid_by_uid': null,
      'paid_by_username': null,
      'total_liters': 100.0,
      'dispatched_liters': 0.0,
      'remaining_liters': 100.0,
      'dispatch_duration_ms': 0,
      'customer_employee_name': null,
      'dispatch_status': 'pending',
    };
  }
}
