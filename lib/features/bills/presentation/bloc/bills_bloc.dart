import 'package:financo/features/bills/domain/usecases/delete_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:financo/features/bills/domain/usecases/pay_bill_usecase.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillsBloc extends Bloc<BillsEvent, BillsState> {
  BillsBloc({
    required GetBillsUseCase getBills,
    required DeleteBillUseCase deleteBill,
    required PayBillUseCase payBill,
    required String userId,
  }) : _getBills = getBills,
       _deleteBill = deleteBill,
       _payBill = payBill,
       _userId = userId,
       super(const BillsInitial()) {
    on<BillsLoadRequested>(_onLoadRequested);
    on<BillDeleteRequested>(_onDeleteRequested);
    on<BillPaymentRequested>(_onPaymentRequested);
  }

  final GetBillsUseCase _getBills;
  final DeleteBillUseCase _deleteBill;
  final PayBillUseCase _payBill;
  final String _userId;

  Future<void> _onLoadRequested(
    BillsLoadRequested event,
    Emitter<BillsState> emit,
  ) async {
    if (state is BillsLoaded && !event.forceRefresh) {
      final loaded = state as BillsLoaded;
      if (loaded.statusFilter == event.status) return;
    }
    emit(const BillsLoading());

    final result = await _getBills(
      userId: _userId,
      status: event.status,
      forceRefresh: event.forceRefresh,
    );

    result.fold(
      (failure) => emit(BillsError(failure)),
      (bills) => emit(BillsLoaded(bills, statusFilter: event.status)),
    );
  }

  Future<void> _onDeleteRequested(
    BillDeleteRequested event,
    Emitter<BillsState> emit,
  ) async {
    final current = state;
    final result = await _deleteBill(event.id);
    result.fold(
      (failure) => emit(BillsError(failure)),
      (_) {
        final filter = current is BillsLoaded ? current.statusFilter : null;
        add(BillsLoadRequested(forceRefresh: true, status: filter));
      },
    );
  }

  Future<void> _onPaymentRequested(
    BillPaymentRequested event,
    Emitter<BillsState> emit,
  ) async {
    final current = state;
    final result = await _payBill(
      billId: event.billId,
      accountId: event.accountId,
      categoryId: event.categoryId,
    );
    result.fold(
      (failure) => emit(BillsError(failure)),
      (paymentResult) {
        emit(BillPaid(paymentResult));
        final filter = current is BillsLoaded ? current.statusFilter : null;
        add(BillsLoadRequested(forceRefresh: true, status: filter));
      },
    );
  }
}
