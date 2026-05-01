import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/bills/domain/usecases/create_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/delete_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:financo/features/bills/domain/usecases/pay_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/update_bill_usecase.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:financo/features/chat/domain/usecases/save_chat_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/transcribe_audio_usecase.dart';
import 'package:financo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:financo/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:financo/features/chat/presentation/widgets/chat_empty_state.dart';
import 'package:financo/features/chat/presentation/widgets/chat_input.dart';
import 'package:financo/features/chat/presentation/widgets/chat_timeline.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => ChatBloc(
        sendMessage: GetIt.I<SendMessageUseCase>(),
        getChatHistory: GetIt.I<GetChatHistoryUseCase>(),
        saveChatMessage: GetIt.I<SaveChatMessageUseCase>(),
        transcribeAudio: GetIt.I<TranscribeAudioUseCase>(),
        createAccount: GetIt.I<CreateAccountUseCase>(),
        getAccounts: GetIt.I<GetAccountsUseCase>(),
        deleteAccount: GetIt.I<DeleteAccountUseCase>(),
        createCategory: GetIt.I<CreateCategoryUseCase>(),
        getCategories: GetIt.I<GetCategoriesUseCase>(),
        deleteCategory: GetIt.I<DeleteCategoryUseCase>(),
        createTransaction: GetIt.I<CreateTransactionUseCase>(),
        createTransfer: GetIt.I<CreateTransferUseCase>(),
        getBills: GetIt.I<GetBillsUseCase>(),
        createBill: GetIt.I<CreateBillUseCase>(),
        updateBill: GetIt.I<UpdateBillUseCase>(),
        deleteBill: GetIt.I<DeleteBillUseCase>(),
        payBill: GetIt.I<PayBillUseCase>(),
        userId: userId,
      ),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  // Confirmed actions are derived from the messages list (via the result
  // message's `originActionId`). Only cancellation needs ephemeral page
  // state — losing it on reload is benign since cancelled actions never
  // touched any data.
  final _cancelledActionIds = <String>{};
  String? _appliedTranscript;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatBloc>().add(const ChatLoadRequested());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMessageSent() => _appliedTranscript = null;

  void _cancelTranscript() {
    _controller.clear();
    _appliedTranscript = null;
    context.read<ChatBloc>().add(const ChatTranscriptCancelled());
  }

  void _onSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.collapsed(
      offset: suggestion.length,
    );
  }

  void _markActionCancelled(String messageId) {
    setState(() => _cancelledActionIds.add(messageId));
  }

  void _onChatStateChanged(BuildContext context, ChatState state) {
    if (state is! ChatLoaded) return;
    if (state.shouldRefreshTransactions) {
      context.read<TransactionsBloc>().add(
        TransactionsLoadRequested(forceRefresh: true),
      );
      context.read<DashboardBloc>().add(
        const DashboardRefreshRequested(),
      );
    }
    if (state.shouldRefreshBills) {
      context.read<BillsBloc>().add(
        const BillsLoadRequested(forceRefresh: true),
      );
    }
    final transcript = state.pendingTranscript;
    if (transcript != null && transcript != _appliedTranscript) {
      _controller.text = transcript;
      _controller.selection = TextSelection.collapsed(
        offset: transcript.length,
      );
      _appliedTranscript = transcript;
    }
    if (transcript == null && _appliedTranscript != null) {
      _appliedTranscript = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _ChatAppBar(),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: _onChatStateChanged,
              builder: (context, state) {
                if (state is ChatLoading) return const LoadingShimmer();
                if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return ChatEmptyState(
                      onSuggestionTap: _onSuggestionTap,
                    );
                  }
                  return ChatTimeline(
                    messages: state.messages,
                    isTyping: state.isTyping,
                    cancelledActionIds: _cancelledActionIds,
                    onActionCancelled: _markActionCancelled,
                    scrollController: _scrollController,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          ChatInput(
            controller: _controller,
            onAfterSend: _onMessageSent,
            onCancelTranscript: _cancelTranscript,
          ),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppBar(
      titleSpacing: 16,
      toolbarHeight: 72,
      title: Row(
        children: [
          const ChatAvatar(size: 40),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.chat.aiName,
                style: context.textTheme.titleMedium?.copyWith(
                  color: colors.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.chat.online,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,
    );
  }
}
