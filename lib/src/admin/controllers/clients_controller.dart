import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/commons/entities/client_entity.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/data/clients_api.dart';

class ClientsController extends ChangeNotifier {

  ClientsApi clientsApi;

  ClientsController({
    required this.clientsApi,
  });

  List<ClientEntity> allClients = [];
  List<ClientEntity> showedClients = [];

  Future<CtrlResponse> getClients() async {

    try {

      if (allClients.isNotEmpty) {
        return CtrlResponse(success: true);
      }

      List<ClientEntity> tempClients = await clientsApi.listClients();
      allClients = tempClients;
      showedClients = tempClients;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> getClientsByPhone(String phone) async {

    try {

      if (phone.isEmpty) {
       showedClients = allClients;
       notifyListeners();
       return CtrlResponse(success: true);
      }

      ClientEntity tempClient = await clientsApi.getClientByPhone(phone);
      showedClients = [tempClient];
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> createClient(String name, String phone, double potableM3Pricing, double potableGallonPricing, double pozoM3Pricing, double pozoGallonPricing) async {

    try {

      ClientEntity tempClient = await clientsApi.createClient(name.trim(), phone, potableGallonPricing, potableM3Pricing, pozoGallonPricing, pozoM3Pricing);
      allClients.insert(0, tempClient);
      showedClients = allClients;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> updateClientByPhone(String clientPhone, String name, String newPhone, double potableM3Pricing, double potableGallonPricing, double pozoM3Pricing, double pozoGallonPricing) async {

    try {
      ClientEntity tempClient = await clientsApi.updateClientByPhone(clientPhone, name.trim(), newPhone, potableGallonPricing, potableM3Pricing, pozoGallonPricing, pozoM3Pricing);
      int tempIndexClient = allClients.indexWhere((element) => element.phone == clientPhone,);
      allClients[tempIndexClient] = tempClient;
      showedClients = allClients;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e) {
      return CtrlResponse(success: false, message: e.message);
    }

  }

  Future<CtrlResponse> deleteClientByPhone(String phone) async {

    try {

      await clientsApi.deleteClientByPhone(phone);
      allClients.removeWhere((element) => element.phone == phone,);
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch(e){
      return CtrlResponse(success: false, message: e.message);
    }

  }

}