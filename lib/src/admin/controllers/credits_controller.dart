import 'package:flutter/material.dart';
import '../../../commons/ctrl_response.dart';
import '../../../commons/paged_list_state.dart';
import '../../../commons/entities/page_result.dart';
import '../clean/entities/credit_payment_entity.dart';
import '../clean/enums/credit_status.dart';
import '../data/sales_api.dart';
import '../../sales/clean/entities/credit_entity.dart';

class CreditsController extends ChangeNotifier {
  CreditsController({required this.salesApi}) {
    paging = PagedListState(
      onChanged: () {
        allCredits = showedCredits = paging.items;
        notifyListeners();
      },
    );
    paymentsPaging = PagedListState(
      onChanged: () {
        creditPayments = paymentsPaging.items;
        notifyListeners();
      },
    );
  }
  final SalesApi salesApi;
  late final PagedListState<CreditEntity> paging;
  late final PagedListState<CreditPaymentEntity> paymentsPaging;
  List<CreditEntity> allCredits = [], showedCredits = [];
  List<CreditPaymentEntity> creditPayments = [];
  CreditEntity? selectedCredit;
  static const _defaults = (
    status: CreditStatus.pending,
    search: '',
    start: null as DateTime?,
    end: null as DateTime?,
  );
  ({
    CreditStatus status,
    String search,
    DateTime? start,
    DateTime? end,
  }) _filters = _defaults,
      _committedFilters = _defaults;
  CreditStatus get status => _filters.status;
  String get search => _filters.search;
  int _request = 0;
  bool _disposed = false;

  Future<CtrlResponse> getCredits({int page = 1}) async {
    final request = ++_request;
    final filters = _filters;
    final response = await paging.load(
      (number) => salesApi.getPendingCreditsPage(
        page: number,
        status: filters.status,
        search: filters.search,
        startDate: filters.start,
        endDate: filters.end,
      ),
      page: page,
    );
    if (!_disposed && request == _request) {
      if (response.success) {
        _committedFilters = filters;
      } else {
        _filters = _committedFilters;
        notifyListeners();
      }
    }
    return response;
  }

  Future<CtrlResponse> filterCredits({
    CreditStatus? status,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    bool updateDates = false,
  }) {
    _filters = (
      status: status ?? _filters.status,
      search: search?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? _filters.search,
      start: updateDates ? startDate : _filters.start,
      end: updateDates ? endDate : _filters.end,
    );
    clearSelectedCredit();
    return getCredits();
  }

  Future<CtrlResponse> resetFilters() {
    _filters = _defaults;
    clearSelectedCredit();
    return getCredits();
  }

  Future<CtrlResponse> getCutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) =>
      filterCredits(startDate: startDate, endDate: endDate, updateDates: true);

  Future<CtrlResponse> clearSalesDateRange() =>
      filterCredits(updateDates: true);

  void clearSelectedCredit() {
    selectedCredit = null;
    paymentsPaging.replace(PageResult.empty(limit: paymentsPaging.data.limit));
  }

  Future<CtrlResponse> loadCreditPayments(CreditEntity credit, {int page = 1}) {
    selectedCredit = credit;
    return paymentsPaging.load(
      (number) =>
          salesApi.getCreditPaymentsPage(credit.saleFolio, page: number),
      page: page,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _request++;
    paging.dispose();
    paymentsPaging.dispose();
    super.dispose();
  }
}
