import 'dart:async';

import 'package:emmie/extensions/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controllers/chat_controller.dart';
import '../models/chat_model.dart';
import '../models/chatbot_model.dart';
import '../models/message_model.dart';
import '../providers/chats_providers.dart';
import '../providers/emmie_providers.dart';
import '../providers/user_providers.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import 'account_activation_screen.dart';
import 'chat_helper.dart';
import 'error_screen.dart';
import 'loading_screen.dart';
import 'settings_screen.dart';
import 'widgets/action_bar.dart';
import 'widgets/avatar.dart';
import 'widgets/bottom_sheet_bar.dart';
import 'widgets/message_list.dart';
import 'widgets/purchases_widget.dart';

class ChatScreen extends StatefulHookConsumerWidget {
  static const routeName = 'chats';
  final bool navigatedFromSearch;
  final String searchQuery;

  const ChatScreen({
    super.key,
    this.navigatedFromSearch = false,
    this.searchQuery = '',
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends ConsumerState<ChatScreen> {
  StreamSubscription? internetSubscription;
  bool _widgetInitialized = false;
  List<Package> _packages = [];
  bool _imageRecognitionIprogress = false;
  bool _showImgTxtRecognitionPayWall = false;

  final RateMyApp _rateMyApp = RateMyApp(
    minDays: 3,
    minLaunches: 3,
    googlePlayIdentifier: Constants.playstoreAppIdentifier,
    remindLaunches: 3,
    remindDays: 3,
  );

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    ref.read(userControllerStateNotifierProvider.notifier).checkSubscription();

    // Configure rate my app dialog
    _rateMyApp.init().then((value) {
      for (var condition in _rateMyApp.conditions) {
        if (condition is DebuggableCondition) {
          if (kDebugMode) {
            print(condition.valuesAsString);
          }
        }
      }

      if (_rateMyApp.shouldOpenDialog) {
        _rateMyApp.showRateDialog(
          context,
          title: AppLocalizations.of(context)!.rateMyAppTitle,
          message: AppLocalizations.of(context)!.rateMyAppMessage1,
          rateButton: AppLocalizations.of(context)!.rateMyAppRateButton,
          noButton: AppLocalizations.of(context)!.rateMyAppNoButton,
          laterButton: AppLocalizations.of(context)!.rateMyAppLaterButton,
          onDismissed: () =>
              _rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
        );
      }
    });

    // Set subscriptions packages
    final offers = ref.read(emmieAiPremiumOffers);
    _packages = offers
        .map((offer) => offer.availablePackages)
        .expand((package) => package)
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.read(userControllerStateNotifierProvider.notifier).checkSubscription();
  }

  @override
  void dispose() {
    internetSubscription?.cancel();
    super.dispose();
  }

  void _checkInternetConnection() {
    InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      ref.read(internetStateProvider.notifier).update((state) => hasInternet);
      setState(() {
        if (_widgetInitialized) {
          if (hasInternet) {
            NotificationHandler(
              context: context,
              icon: CupertinoIcons.wifi,
              color: AppColors.successGreen,
              message: AppLocalizations.of(context)!.connectionEstablished,
            ).showSnackBar();
          } else {
            NotificationHandler(
              context: context,
              icon: CupertinoIcons.wifi_exclamationmark,
              color: AppColors.errorRed,
              message: AppLocalizations.of(context)!.noInternetConnection,
            ).showSnackBar();
          }
        }
      });
      _widgetInitialized = true;
    });
  }

  void _pickImage({
    required ChatHelper chatHelper,
    required ImageSource imageSource,
    required TextEditingController textController,
  }) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final imageFile =
          await imagePicker.pickImage(source: imageSource, imageQuality: 50);

      if (imageFile != null) {
        final detectedText = await getTextFromImage(imageFile: imageFile);
        textController.text = detectedText.trim().capitalize();

        setState(() => _imageRecognitionIprogress = false);
        _sendMessage(chatHelper: chatHelper, textController: textController);
      }
    } catch (e) {
      setState(() => _imageRecognitionIprogress = false);
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
    }
  }

  void _sendMessage(
      {required ChatHelper chatHelper,
      required TextEditingController textController}) {
    chatHelper.sendMessageHandler(
        context: context, ref: ref, textController: textController);
  }

  Future<String> getTextFromImage({required XFile imageFile}) async {
    try {
      String detectedText = '';

      setState(() => _imageRecognitionIprogress = true);
      final inputImage = InputImage.fromFilePath(imageFile.path);

      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          for (var line in line.elements) {
            detectedText += '${line.text} ';
          }
        }
      }

      textRecognizer.close();
      return detectedText;
    } catch (e) {
      // ignore: use_build_context_synchronously
      throw Exception(AppLocalizations.of(context)!.unableToRecognizeImageText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsFuture = ref.watch(contactsFutureProvider);
    final hasInternet = ref.watch(internetStateProvider);
    final appControls = ref.watch(appControlStateProvider);

    // Listen to AuthController State to show effects
    ref.listen<ChatsState>(chatsControllerStateNotifierProvider,
        (prevState, currState) {
      if (currState is ChatsStateInitial) {
        final user = ref.read(userModelStateProvider);
        if (user != null && !user.active) {
          Navigator.of(context)
              .pushReplacementNamed(AccountActivationScreen.routeName);
        }
      }
    });

    return contactsFuture.when(
      data: (contactsCollection) {
        final List<ChatbotModel> contacts = DataTransformer<ChatbotModel>(
          collection: contactsCollection,
          fromMap: (dataMap) => ChatbotModel.fromMap(dataMap),
        ).transformData();

        if (contacts.isNotEmpty) {
          final contact = contacts.first;
          final mediaQuery = MediaQuery.of(context).size;
          // Get current user
          final currentUser = ref.watch(userModelStateProvider);
          final onExploration = ref.watch(onExplorationStateProvider);

          // For some reason, should the user be null, show the error screen.
          // The loader will be shown by the Riverpod when method.
          // When you have reached here, it is assumed that the user should
          // have been set, therefore if not, then show error.
          if (currentUser == null) {
            return ErrorScreen(
              title: AppLocalizations.of(context)!.emmieAiUnavailableTitle,
              message: AppLocalizations.of(context)!.emmieAiUnavailableMessage,
              description: AppLocalizations.of(context)!.emmieAiUnavailableDesc,
            );
          }

          // Show the error screen when the engineer stop the app service
          // from operating
          if (appControls.stopService) {
            return ErrorScreen(
              title: AppLocalizations.of(context)!.serviceUnavailableTitle,
              message: AppLocalizations.of(context)!.serviceUnavailableMessage,
              description: AppLocalizations.of(context)!.serviceUnavailableDesc,
            );
          }

          final chatModel = ChatModel(
            userId: currentUser.id,
            chatBotId: contact.id,
            chatBotName: contact.name,
            changedAt: null,
            lastMessage: null,
          );

          final messagesStream = ref.watch(messagesStreamProvider(chatModel));

          return messagesStream.when(
            data: (messagesCollection) {
              final messages = DataTransformer<MessageModel>(
                collection: messagesCollection,
                fromMap: (dataMap) => MessageModel.fromMap(dataMap),
              ).transformData();

              // final prevMessages = _getPrevMessages(userId: currentUser.id, messages: messages);
              const sizedBox = SizedBox(height: 15);

              // For sending a message when a card is clicked.
              final chatHelper = ChatHelper(
                userId: currentUser.id,
                chatBotId: contact.id,
                chatBotName: contact.name,
                messages: messages,
              );
              final textController = useTextEditingController(text: '');

              return Scaffold(
                appBar: AppBar(
                  leading: InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed(SettingsScreen.routeName),
                    child: _customMenuIcon(),
                  ),
                  iconTheme: Theme.of(context).iconTheme,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: _AppBarTitle(
                    chatBuddy: contact.name,
                    mediaQuery: mediaQuery,
                  ),
                  actions: [
                    if (!currentUser.subscribed)
                      InkWell(
                        onTap: () => _subscriptionPaywallBottomSheet(
                            context: context, packages: _packages),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Colors.amber, Colors.yellow],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.buyPro,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    _imageRecognitionIprogress
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0),
                            child: LoadingAnimationWidget.inkDrop(
                              color: AppColors.primary,
                              size: 18.0,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              if (currentUser.subscribed || onExploration) {
                                showModalBottomSheet(
                                  backgroundColor: Theme.of(context).cardColor,
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  builder: (_) => SingleChildScrollView(
                                    child: _imagePickerBottomSheet(
                                        chatHelper: chatHelper,
                                        textController: textController),
                                  ),
                                );
                              } else {
                                if (_showImgTxtRecognitionPayWall) {
                                  _subscriptionPaywallBottomSheet(
                                      context: context, packages: _packages);
                                } else {
                                  NotificationHandler(
                                    context: context,
                                    icon: CupertinoIcons.info_circle,
                                    color: AppColors.primary,
                                    message: AppLocalizations.of(context)!
                                        .imageTextRecognitionFeature,
                                  ).showSnackBar();
                                  _showImgTxtRecognitionPayWall = true;
                                }
                              }
                            },
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: AppColors.primary),
                          ),
                    if (messages.isNotEmpty)
                      PopupMenuButton(
                        position: PopupMenuPosition.under,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        onSelected: (AppUserActions selectedValue) {
                          if (hasInternet) {
                            if (selectedValue == AppUserActions.clear) {
                              ref
                                  .read(chatsControllerStateNotifierProvider
                                      .notifier)
                                  .clearMessages(
                                    context: context,
                                    userId: currentUser.id,
                                    chatBotId: contact.id,
                                  );
                              // Reset previous messages state provider.
                              ref
                                  .read(previousMessagesStateProvider.notifier)
                                  .state = [];
                            }
                          } else {
                            NotificationHandler(
                              context: context,
                              icon: CupertinoIcons.wifi_exclamationmark,
                              color: AppColors.errorRed,
                              message: AppLocalizations.of(context)!
                                  .noInternetConnection,
                            ).showSnackBar();
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: AppUserActions.clear,
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.clear,
                                  color: AppColors.iconRed,
                                ),
                                const SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!
                                    .clearMessages),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(CupertinoIcons.ellipsis_vertical),
                      ),
                  ],
                ),
                backgroundColor: Theme.of(context).cardColor,
                body: Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      messages.isNotEmpty
                          ? Expanded(
                              child: MessageList(
                                messages: messages,
                                contact: contact,
                                userId: currentUser.id,
                                searchQuery: widget.searchQuery,
                              ),
                            )
                          : Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width: mediaQuery.width * 0.8,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                BorderRadius.circular(15)
                                                    .copyWith(
                                                        topLeft: const Radius
                                                            .circular(0)),
                                          ),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .welcomeMessage)),
                                        ),
                                      ),
                                      sizedBox,
                                      IntrinsicHeight(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: InkWell(
                                                onTap: () {
                                                  textController.text =
                                                      'Hello Emmie, would you please help me get an A+ in my exam?';
                                                  chatHelper.sendMessageHandler(
                                                      context: context,
                                                      ref: ref,
                                                      textController:
                                                          textController);
                                                },
                                                child: _serviceCard(
                                                  mediaQuery: mediaQuery,
                                                  icon: CupertinoIcons.book,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .academics,
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .academicsDescription,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Flexible(
                                              child: InkWell(
                                                onTap: () {
                                                  textController.text =
                                                      'Hi Emmie, would you please help me learn a new language?';
                                                  chatHelper.sendMessageHandler(
                                                      context: context,
                                                      ref: ref,
                                                      textController:
                                                          textController);
                                                },
                                                child: _serviceCard(
                                                  mediaQuery: mediaQuery,
                                                  icon: CupertinoIcons.globe,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .languages,
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .languagesDescription,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      sizedBox,
                                      IntrinsicHeight(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: InkWell(
                                                onTap: () {
                                                  textController.text =
                                                      'Hello Emmie, could you assist me in brainstorming fresh business concepts?';
                                                  chatHelper.sendMessageHandler(
                                                      context: context,
                                                      ref: ref,
                                                      textController:
                                                          textController);
                                                },
                                                child: _serviceCard(
                                                  mediaQuery: mediaQuery,
                                                  icon: CupertinoIcons.star,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .ideas,
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .ideasDescription,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Flexible(
                                              child: InkWell(
                                                onTap: () {
                                                  textController.text =
                                                      'Hello Emmie, could you please assist me in excelling during my interview?';
                                                  chatHelper.sendMessageHandler(
                                                      context: context,
                                                      ref: ref,
                                                      textController:
                                                          textController);
                                                },
                                                child: _serviceCard(
                                                  mediaQuery: mediaQuery,
                                                  icon:
                                                      CupertinoIcons.briefcase,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .interview,
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .interviewDescription,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      sizedBox,
                                      IntrinsicHeight(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: InkWell(
                                                onTap: () {
                                                  textController.text =
                                                      'Hi Emmie, Would you please help me compose a good looking professional email.';
                                                  chatHelper.sendMessageHandler(
                                                      context: context,
                                                      ref: ref,
                                                      textController:
                                                          textController);
                                                },
                                                child: _serviceCard(
                                                  mediaQuery: mediaQuery,
                                                  icon: CupertinoIcons.mail,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .emails,
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .emailsDescription,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Flexible(
                                              child: InkWell(
                                                onTap: () {
                                                  textController.text =
                                                      'Hi Emmie, I need an advise. Would you please be advise me?';
                                                  chatHelper.sendMessageHandler(
                                                      context: context,
                                                      ref: ref,
                                                      textController:
                                                          textController);
                                                },
                                                child: _serviceCard(
                                                  mediaQuery: mediaQuery,
                                                  icon:
                                                      CupertinoIcons.lightbulb,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .advice,
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .adviceDescription,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ].animate().fadeIn(duration: 1.seconds),
                                  ),
                                ),
                              ),
                            ),
                      ActionBar(
                        userId: currentUser.id,
                        chatBotId: contact.id,
                        chatBotName: contact.name,
                        messages: messages,
                        hasInternet: hasInternet,
                      ),
                    ],
                  ),
                ),
              );
            },
            error: (error, stackTrace) => ErrorScreen(
              title: AppLocalizations.of(context)!.emmieAiUnavailableTitle,
              message: AppLocalizations.of(context)!.emmieAiUnavailableMessage,
              description: AppLocalizations.of(context)!.emmieAiUnavailableDesc,
            ),
            loading: () => const LoadingScreen(),
          );
        } else {
          return ErrorScreen(
            title: AppLocalizations.of(context)!.emmieAiUnavailableTitle,
            message: AppLocalizations.of(context)!.emmieAiUnavailableMessage,
            description: AppLocalizations.of(context)!.emmieAiUnavailableDesc,
          );
        }
      },
      error: (error, stackTrace) => ErrorScreen(
        title: AppLocalizations.of(context)!.emmieAiUnavailableTitle,
        message: AppLocalizations.of(context)!.emmieAiUnavailableMessage,
        description: AppLocalizations.of(context)!.emmieAiUnavailableDesc,
      ),
      loading: () => const LoadingScreen(),
    );
  }

  Column _customMenuIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 15,
          height: 2,
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: AppColors.iconLight,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Container(
          width: 12,
          height: 2,
          margin: const EdgeInsets.symmetric(vertical: 5).copyWith(left: 10),
          decoration: BoxDecoration(
            color: AppColors.iconLight,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Container(
          width: 18,
          height: 2,
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: AppColors.iconLight,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _serviceCard({
    required Size mediaQuery,
    required IconData icon,
    required String label,
    required String text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.textLight,
              ).animate().shakeX(delay: const Duration(seconds: 1)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _imagePickerBottomSheet(
      {required ChatHelper chatHelper,
      required TextEditingController textController}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15)
          .copyWith(top: 10, bottom: 20),
      child: Column(
        children: [
          const BottomSheetBar(bottom: 10),
          Text(
            AppLocalizations.of(context)!.imageTextRecognition,
            style: const TextStyle(fontSize: 15, color: AppColors.textFaded),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _pickImage(
                    chatHelper: chatHelper,
                    imageSource: ImageSource.camera,
                    textController: textController,
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(AppLocalizations.of(context)!.camera),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _pickImage(
                    chatHelper: chatHelper,
                    imageSource: ImageSource.gallery,
                    textController: textController,
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(AppLocalizations.of(context)!.gallery),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              textAlign: TextAlign.center,
              AppLocalizations.of(context)!.imageTextRecognitionDescription,
              style: const TextStyle(fontSize: 12, color: AppColors.textFaded),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _subscriptionPaywallBottomSheet(
      {required BuildContext context, required List<Package> packages}) {
    return showModalBottomSheet(
      // useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      builder: (_) => SizedBox(
        child: SingleChildScrollView(
          child: PremiumOffers(packages: packages),
        ),
      ),
    );
  }
}

class _AppBarTitle extends ConsumerWidget {
  final String chatBuddy;
  final Size mediaQuery;

  const _AppBarTitle({
    required this.chatBuddy,
    required this.mediaQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInternet = ref.watch(internetStateProvider);

    return Row(
      children: [
        Avatar.small(
          color: Theme.of(context).cardColor,
          widget: const AssetImage(Constants.emmieIcon),
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chatBuddy,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 3),
              hasInternet
                  ? Text(
                      AppLocalizations.of(context)!.online,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primary),
                    )
                  : Text(
                      AppLocalizations.of(context)!.offline,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textFaded),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
