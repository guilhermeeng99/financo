import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/chat/domain/entities/chat_image_attachment.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:financo/features/chat/domain/usecases/save_chat_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/transcribe_audio_usecase.dart';
import 'package:financo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

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

  void _onMessageSent() {
    _appliedTranscript = null;
  }

  void _cancelTranscript() {
    _controller.clear();
    _appliedTranscript = null;
    context.read<ChatBloc>().add(const ChatTranscriptCancelled());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.chat.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  if (state.shouldRefreshTransactions) {
                    context.read<TransactionsBloc>().add(
                      TransactionsLoadRequested(forceRefresh: true),
                    );
                    context.read<DashboardBloc>().add(
                      const DashboardRefreshRequested(),
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
              },
              builder: (context, state) {
                if (state is ChatLoading) return const LoadingShimmer();
                if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.robot,
                              size: 64,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t.chat.welcomeTitle,
                              style: context.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.chat.welcomeBody,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final reversed = state.messages.reversed.toList();
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: reversed.length + (state.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (state.isTyping && index == 0) {
                        return const _TypingIndicator();
                      }
                      final msgIndex = state.isTyping ? index - 1 : index;
                      return _ChatBubble(message: reversed[msgIndex]);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _MessageInput(
            controller: _controller,
            onAfterSend: _onMessageSent,
            onCancelTranscript: _cancelTranscript,
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final hasAction =
        !isUser &&
        message.metadata != null &&
        message.metadata!.containsKey('actionType');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? context.colorScheme.primary
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isUser
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.onSurface,
              ),
            ),
            if (hasAction) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<ChatBloc>().add(
                      ChatActionConfirmed(message.metadata!),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.check, size: 18),
                  label: Text(t.general.confirm),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FaIcon(
                FontAwesomeIcons.solidCircle,
                size: 8,
                color: context.colorScheme.onSurfaceVariant,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _PickedImage {
  const _PickedImage({
    required this.base64Data,
    required this.mimeType,
    required this.bytes,
  });

  final String base64Data;
  final String mimeType;
  final Uint8List bytes;
}

class _MessageInput extends StatefulWidget {
  const _MessageInput({
    required this.controller,
    required this.onAfterSend,
    required this.onCancelTranscript,
  });

  final TextEditingController controller;
  final VoidCallback onAfterSend;
  final VoidCallback onCancelTranscript;

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final _recorder = AudioRecorder();
  final _imagePicker = ImagePicker();
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _tickTimer;
  String? _currentRecordingPath;
  _PickedImage? _pickedImage;

  @override
  void dispose() {
    _tickTimer?.cancel();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    final picked = _pickedImage;
    if (text.isEmpty && picked == null) return;

    context.read<ChatBloc>().add(
      ChatMessageSent(
        text,
        image: picked != null
            ? ChatImageAttachment(
                base64Data: picked.base64Data,
                mimeType: picked.mimeType,
              )
            : null,
      ),
    );
    widget.controller.clear();
    setState(() => _pickedImage = null);
    widget.onAfterSend();
  }

  Future<void> _pickFromSource(ImageSource source) async {
    try {
      final xfile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1920,
      );
      if (xfile == null || !mounted) return;
      final bytes = await xfile.readAsBytes();
      final mime = _mimeTypeFromName(xfile.name);
      setState(() {
        _pickedImage = _PickedImage(
          base64Data: base64Encode(bytes),
          mimeType: mime,
          bytes: bytes,
        );
      });
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.chat.image.pickError}: $e')),
      );
    }
  }

  String _mimeTypeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }

  Future<void> _showAttachMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.camera),
                title: Text(t.chat.image.takePhoto),
                onTap: () {
                  Navigator.pop(sheetContext);
                  unawaited(_pickFromSource(ImageSource.camera));
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.image),
                title: Text(t.chat.image.fromGallery),
                onTap: () {
                  Navigator.pop(sheetContext);
                  unawaited(_pickFromSource(ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.chat.audio.permissionDenied)),
        );
        return;
      }
      // On web, `path` is ignored by record_web (stop() returns a blob URL).
      // On mobile/desktop we write to a temp file.
      final path = kIsWeb
          ? ''
          : '${(await getTemporaryDirectory()).path}'
                '/chat_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(
          bitRate: 96000,
          numChannels: 1,
        ),
        path: path,
      );
      _currentRecordingPath = path;
      _elapsed = Duration.zero;
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _elapsed += const Duration(seconds: 1));
        }
      });
      setState(() => _isRecording = true);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.chat.audio.recordError}: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    _tickTimer?.cancel();
    _tickTimer = null;
    final stoppedPath = await _recorder.stop() ?? _currentRecordingPath;
    setState(() => _isRecording = false);
    if (stoppedPath == null || stoppedPath.isEmpty) return;

    try {
      late final List<int> bytes;
      late final String mimeType;
      if (kIsWeb) {
        // record_web returns a blob URL. Fetch the bytes via http.get.
        // The browser resolves the blob URL to the recorded audio.
        final response = await http.get(Uri.parse(stoppedPath));
        bytes = response.bodyBytes;
        mimeType = 'audio/webm';
      } else {
        final file = File(stoppedPath);
        bytes = await file.readAsBytes();
        unawaited(file.delete().catchError((_) => file));
        mimeType = 'audio/mp4';
      }
      final base64Data = base64Encode(bytes);
      if (!mounted) return;
      context.read<ChatBloc>().add(
        ChatAudioTranscriptionRequested(
          base64Data: base64Data,
          mimeType: mimeType,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.chat.audio.recordError}: $e')),
      );
    }
  }

  Future<void> _cancelRecording() async {
    _tickTimer?.cancel();
    _tickTimer = null;
    final path = await _recorder.stop() ?? _currentRecordingPath;
    if (!kIsWeb && path != null && path.isNotEmpty) {
      final file = File(path);
      unawaited(file.delete().catchError((_) => file));
    }
    if (mounted) {
      setState(() => _isRecording = false);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final isTranscribing = state is ChatLoaded && state.isTranscribing;
        final hasPendingTranscript =
            state is ChatLoaded && state.pendingTranscript != null;

        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 8,
            top: 8,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            border: Border(
              top: BorderSide(color: context.colorScheme.outlineVariant),
            ),
          ),
          child: _isRecording
              ? _buildRecordingRow(context)
              : isTranscribing
                  ? _buildTranscribingRow(context)
                  : _buildDefaultRow(
                      context,
                      hasPendingTranscript: hasPendingTranscript,
                    ),
        );
      },
    );
  }

  Widget _buildRecordingRow(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.xmark,
            color: context.colorScheme.error,
          ),
          onPressed: _cancelRecording,
          tooltip: t.chat.audio.cancel,
        ),
        Expanded(
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.solidCircle,
                size: 12,
                color: context.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                '${t.chat.audio.recording} ${_formatDuration(_elapsed)}',
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.stop,
            color: context.colorScheme.primary,
          ),
          onPressed: _stopRecording,
          tooltip: t.chat.audio.stop,
        ),
      ],
    );
  }

  Widget _buildTranscribingRow(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 12),
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            t.chat.audio.transcribing,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultRow(
    BuildContext context, {
    required bool hasPendingTranscript,
  }) {
    final picked = _pickedImage;
    final hasImage = picked != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) _buildImagePreview(context, picked),
        Row(
          children: [
            if (hasPendingTranscript)
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.xmark,
                  color: context.colorScheme.error,
                ),
                onPressed: widget.onCancelTranscript,
                tooltip: t.chat.audio.cancel,
              ),
            if (!hasPendingTranscript && !hasImage)
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.paperclip,
                  color: context.colorScheme.primary,
                ),
                onPressed: () => unawaited(_showAttachMenu()),
                tooltip: t.chat.image.attach,
              ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: hasPendingTranscript
                      ? t.chat.audio.reviewHint
                      : t.chat.placeholder,
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            if (!hasPendingTranscript && !hasImage)
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.microphone,
                  color: context.colorScheme.primary,
                ),
                onPressed: _startRecording,
                tooltip: t.chat.audio.start,
              ),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.paperPlane,
                color: context.colorScheme.primary,
              ),
              onPressed: _handleSend,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context, _PickedImage picked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              picked.bytes,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.circleXmark,
                color: context.colorScheme.error,
                size: 22,
              ),
              onPressed: () => setState(() => _pickedImage = null),
              tooltip: t.chat.image.remove,
            ),
          ),
        ],
      ),
    );
  }
}
