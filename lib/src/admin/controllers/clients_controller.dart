import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/data/clients_api.dart';

class ClientsController extends ChangeNotifier {
  ClientsApi clientsApi;

  ClientsController({required this.clientsApi});

  List<ClientEntity> allClients = [];
  List<ClientEntity> showedClients = [];

  Future<CtrlResponse> getClients() async {
    try {
      List<ClientEntity> tempClients = await clientsApi.listClients();
      allClients = tempClients;
      showedClients = tempClients;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> searchClients(String commercialName) async {
    try {
      if (commercialName.trim().isEmpty) {
        showedClients = allClients;
        notifyListeners();
        return CtrlResponse(success: true);
      }

      showedClients = await clientsApi.listClients(search: commercialName);
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> createClient(
    String commercialName,
    double potableLiterPricing,
    double potableGallonPricing,
    double pozoLiterPricing,
    double pozoGallonPricing,
    double creditLimit,
    bool creditEnabled
  ) async {
    try {
      ClientEntity tempClient = await clientsApi.createClient(
        commercialName.trim(),
        potableGallonPricing,
        potableLiterPricing,
        pozoGallonPricing,
        pozoLiterPricing,
        creditLimit,
        creditEnabled,
      );
      allClients.insert(0, tempClient);
      showedClients = allClients;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> updateClientById(
    int clientId,
    String commercialName,
    double potableLiterPricing,
    double potableGallonPricing,
    double pozoLiterPricing,
    double pozoGallonPricing,
    double creditLimit,
    bool creditEnabled,
  ) async {
    try {
      ClientEntity tempClient = await clientsApi.updateClientById(
        clientId,
        commercialName.trim(),
        potableGallonPricing,
        potableLiterPricing,
        pozoGallonPricing,
        pozoLiterPricing,
        creditLimit,
        creditEnabled,
      );
      int tempIndexClient = allClients.indexWhere(
        (element) => element.id == clientId,
      );
      allClients[tempIndexClient] = tempClient;
      showedClients = allClients;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> deleteClientById(int id) async {
    try {
      await clientsApi.deleteClientById(id);
      allClients.removeWhere((element) => element.id == id);
      showedClients.removeWhere((element) => element.id == id);
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }
}
