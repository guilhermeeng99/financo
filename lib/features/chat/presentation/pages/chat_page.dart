import 'dart:async';

import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/budgets/presentation/cubit/budgets_cubit.dart';
import 'package:financo/features/chat/domain/action_handlers/account_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/bill_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/budget_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/category_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/transaction_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/transfer_chat_action_handler.dart';
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
        accountHandler: GetIt.I<AccountChatActionHandler>(),
        categoryHandler: GetIt.I<CategoryChatActionHandler>(),
        transactionHandler: GetIt.I<TransactionChatActionHandler>(),
        transferHandler: GetIt.I<TransferChatActionHandler>(),
        billHandler: GetIt.I<BillChatActionHandler>(),
        budgetHandler: GetIt.I<BudgetChatActionHandler>(),
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

  void _onMessageSent() {}

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
    if (state.shouldRefreshBudgets) {
      unawaited(
        context.read<BudgetsCubit>().loadBudgets(forceRefresh: true),
      );
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
