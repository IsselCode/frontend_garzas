import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/sales/clean/dtos/sale_info_dto.dart';
import 'package:frontend_garzas/src/sales/clean/entities/client_entity.dart';
import 'package:frontend_garzas/src/sales/clean/enums/enums.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../../../commons/ctrl_response.dart';
import '../clean/entities/sale_info_entity.dart';

class OrderController extends ChangeNotifier {

  TabSwitcherAlignStates _state = TabSwitcherAlignStates.left;
  TabSwitcherAlignStates get state => _state;
  set state(TabSwitcherAlignStates value) {
    _state = value;
    notifyListeners();
  }
  TextEditingController quantityController = TextEditingController();

  TextEditingController clientMoneyCtrl = TextEditingController();
  double total = 0;
  double totalRemaining = 0;

  SaleInfoEntity? _saleInfoEntity;

  ClientEntity? _selectedClient;
  ClientEntity? get selectedClient => _selectedClient;
  set selectedClient(ClientEntity? value) {
    if (value == _selectedClient) {
      _selectedClient = null;
    } else {
      _selectedClient = value;
    }
    notifyListeners();
  }
  List<ClientEntity> clients = [];
  List<ClientEntity> showedClients = [];

  //! Logic Methods
  CtrlResponse calculateTotalRemaining() {
    try {

      final double? clientMoney = double.tryParse(clientMoneyCtrl.text.trim());

      if (clientMoney == null) {
        throw AppException(message: "Ingresa una cantidad valida");
      }

      if (clientMoney < total) {
        throw AppException(message: "La cantidad entregada no cubre el total de la venta");
      }

      totalRemaining = clientMoney - total;
      notifyListeners();

      return CtrlResponse(success: true);
    } on AppException catch (e) {
      totalRemaining = 0;
      notifyListeners();
      return CtrlResponse(success: false, message: e.message);
    }
  }

  // Model Methods

  // TODO: Obtener clientes más frecuentes
  Future<void> getClients() async {

    try {

      List<ClientEntity> fakeClients = [
        ClientEntity(id: 599878, user: "Juan", phone: 8344281215, galPricing: 2.5, literPricing: 1.2),
        ClientEntity(id: 599879, user: "Maria", phone: 8344281216, galPricing: 2.5, literPricing: 1.2),
        ClientEntity(id: 599880, user: "Carlos", phone: 8344281217, galPricing: 2.5, literPricing: 1.2),
        ClientEntity(id: 599881, user: "Ana", phone: 8344281218, galPricing: 2.5, literPricing: 1.2),
        ClientEntity(id: 599882, user: "Luis", phone: 8344281219, galPricing: 2.5, literPricing: 1.2),
        ClientEntity(id: 599883, user: "Sofia", phone: 8344281220, galPricing: 2.5, literPricing: 1.2),
        ClientEntity(id: 599884, user: "Pedro", phone: 8344281221, galPricing: 2.5, literPricing: 1.2),
        ClientEntity(id: 599885, user: "Lucia", phone: 8344281222, galPricing: 2.5, literPricing: 1.2),
        ClientEntity(id: 599886, user: "Diego", phone: 8344281223, galPricing: 2.5, literPricing: 1.2),
        ClientEntity(id: 599887, user: "Elena", phone: 8344281224, galPricing: 2.5, literPricing: 1.2),
      ];


      List<ClientEntity> tempClients = await Future.delayed(const Duration(milliseconds: 500), () => fakeClients,);
      clients = tempClients;
      showedClients = tempClients;

      notifyListeners();

    } on AppException catch(e) {
     rethrow;
    }

  }

  // TODO: Implementar con método obtener clientes por número de teléfono
  Future<void> getSearchClients(String phone) async {

    if (phone.isEmpty) {
      showedClients = clients;
      notifyListeners();
      return ;
    };

    try {

      List<ClientEntity> fakeClients = [
        ClientEntity(id: 599881, user: "Ana", phone: 8344281218, literPricing: 1.2, galPricing: 2.5),
        ClientEntity(id: 599883, user: "Sofia", phone: 8344281220, literPricing: 1.2, galPricing: 2.5),
        ClientEntity(id: 599884, user: "Pedro", phone: 8344281221, literPricing: 1.2, galPricing: 2.5),
        ClientEntity(id: 599887, user: "Elena", phone: 8344281224, literPricing: 1.2, galPricing: 2.5),
      ];


      List<ClientEntity> tempClients = await Future.delayed(const Duration(milliseconds: 500), () => fakeClients,);
      showedClients = tempClients;

      notifyListeners();

    } on AppException catch(e) {
      rethrow;
    }

  }

  // TODO: Implementar con método de módelo
  Future<CtrlResponse<double>> calculateTotal() async {

    try {

      double response = await Future.delayed(const Duration(milliseconds: 500), () => 250,);
      total = response;

      return CtrlResponse(success: true, element: response);

    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  // TODO: Implementar con método de módelo
  Future<CtrlResponse<SaleInfoEntity>> createSell() async {

    try {


      SaleInfoDto dto = SaleInfoDto(
        quantity: double.tryParse(quantityController.text),
        waterType: WaterType.fromTabSwitcher(state),
        estimateTotal: total,
        clientMoney: double.tryParse(clientMoneyCtrl.text),
        totalRemaining: totalRemaining,
        customerPhone: selectedClient?.phone,
      );

      print(dto.toString());

      return CtrlResponse(success: true);
      throw AppException(message: "Controlador no implementado");

    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  // TODO: Implementar Driver Impresora
  Future<void> printTicket() async {
    await Future.delayed(const Duration(seconds: 5));
  }

  @override
  void dispose() {
    quantityController.dispose();
    clientMoneyCtrl.dispose();
    super.dispose();
  }

  

}
