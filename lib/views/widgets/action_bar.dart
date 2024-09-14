import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:emmie/extensions/strings.dart';
import 'package:emmie/views/widgets/purchases_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../providers/emmie_providers.dart';
import '../../providers/user_providers.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../utils/helpers.dart';
import '../../utils/theme.dart';
import '../chat_helper.dart';
import 'banner_ads_widget.dart';
import 'bottom_sheet_bar.dart';

class ActionBar extends StatefulHookConsumerWidget {
  final String userId;
  final String chatBotId;
  final String chatBotName;
  final List<MessageModel> messages;
  final bool hasInternet;

  const ActionBar({
    super.key,
    required this.userId,
    required this.chatBotId,
    required this.chatBotName,
    required this.messages,
    required this.hasInternet,
  });

  @override
  ActionBarState createState() => ActionBarState();
}

// ignore: must_be_immutable
class ActionBarState extends ConsumerState<ActionBar> {
  bool restrictPremiumFeatureLoaded = false;
  List<Package> _packages = [];

  bool _showRecordingPayWall = false;
  bool _showVoiceAssistPayWall = false;

  final _speechToText = SpeechToText();
  String _lastWords = '';

  late ChatHelper chatHelper;

  /// Initializes speech to text.
  Future<void> _initSpeechToText() async {
    await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session.
  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  void _restrictPremiumFeatures() {
    final user = ref.read(userModelStateProvider);
    final onExploration = ref.watch(onExplorationStateProvider);

    if (user != null) {
      if (!user.subscribed && !onExploration) {
        ref.read(userControllerStateNotifierProvider.notifier).updateSettings(
              context: context,
              settingOption: SettingsOptions.voiceAssistance,
              value: false,
            );
      }
    }
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: Constants.rewardedAdsUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
        onAdFailedToLoad: (error) => setState(() => _rewardedAd = null),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initSpeechToText();

    chatHelper = ChatHelper(
      userId: widget.userId,
      chatBotId: widget.chatBotId,
      chatBotName: widget.chatBotName,
      messages: widget.messages,
    );

    // Set subscriptions packages
    final offers = ref.read(emmieAiPremiumOffers);
    _packages = offers.map((offer) => offer.availablePackages).expand((package) => package).toList();

    _createRewardedAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!restrictPremiumFeatureLoaded) {
      restrictPremiumFeatureLoaded = true;
      Future.delayed(const Duration(seconds: 5), () => _restrictPremiumFeatures());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final user = ref.watch(userModelStateProvider);
    final onExploration = ref.watch(onExplorationStateProvider);
    final textController = useTextEditingController(text: '');
    final isTyping = useState(false);
    final isRecording = useState(false);
    final focusNode = useFocusNode();

    useEffect(() {
      textController.addListener(() => isTyping.value = textController.text == '' ? false : true);
      return;
    }, [textController]);

    return SafeArea(
      top: false,
      bottom: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                children: [
                  if (!user!.subscribed && !onExploration) const BannerAds(),
                  if (!user.subscribed && !onExploration) _freeMessagesIndicator(context, mediaQuery, user),
                  if (!user.subscribed && onExploration) _showExplorationEndDate(context, mediaQuery, user),
                  ClipRRect(
                    borderRadius: (user.subscribed)
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          )
                        : BorderRadius.zero,
                    child: _messagesTextField(
                      textController,
                      focusNode,
                      context,
                      isRecording,
                      mediaQuery,
                      isTyping,
                    ).animate().fadeIn(duration: 500.milliseconds),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  RewardedAd? _rewardedAd;

  Container _freeMessagesIndicator(BuildContext context, Size mediaQuery, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
      ),
      width: mediaQuery.width,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedTextKit(
                pause: const Duration(seconds: 6),
                repeatForever: true,
                animatedTexts: [
                  TyperAnimatedText(
                    AppLocalizations.of(context)!.userRemainingMessages(user.freeMessages),
                  ),
                  TyperAnimatedText(
                    AppLocalizations.of(context)!.watchRewardedAds,
                  ),
                ],
              ).animate().fadeIn(duration: 1.seconds),
              InkWell(
                onTap: () => loadRewardedAd(),
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.watchAdButtonClick,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 1.seconds),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container _showExplorationEndDate(BuildContext context, Size mediaQuery, UserModel user) {
    final format = DateFormat('dd MMMM, yyyy', 'en_US');
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
      ),
      width: mediaQuery.width,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedTextKit(
                pause: const Duration(seconds: 6),
                repeatForever: true,
                animatedTexts: [
                  TyperAnimatedText(AppLocalizations.of(context)!.freeTrialEndDate(format.format(user.explorationEndDate))),
                  TyperAnimatedText(AppLocalizations.of(context)!.goPremiumForAllBenefits),
                  TyperAnimatedText(AppLocalizations.of(context)!.watchRewardedAds),
                  TyperAnimatedText(AppLocalizations.of(context)!.youGetLimitedMessages),
                ],
              ).animate().fadeIn(duration: 1.seconds),
            ],
          ),
        ),
      ),
    );
  }

  loadRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createRewardedAd();
        },
      );

      final userController = ref.read(userControllerStateNotifierProvider.notifier);
      _rewardedAd?.show(onUserEarnedReward: (ad, reward) {
        userController.updateUserFreeMessageCount(increaseCount: true, increaseBy: 1);
      });
      _rewardedAd = null;
    }
  }

  TextField _messagesTextField(TextEditingController textController, FocusNode focusNode, BuildContext context, ValueNotifier<bool> isRecording,
      Size mediaQuery, ValueNotifier<bool> isTyping) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      cursorColor: AppColors.textFaded,
      cursorHeight: 25,
      cursorWidth: 2.5,
      maxLines: null,
      cursorRadius: const Radius.circular(10),
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        hintText: isRecording.value ? AppLocalizations.of(context)!.recording : AppLocalizations.of(context)!.chatTextFieldPlaceholder,
        prefixIcon: isRecording.value
            ? _avatarGlow()
            : _moreOptions(
                context: context,
                ref: ref,
                mediaQuery: mediaQuery,
              ),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: 40.0,
            height: 40.0,
            child: isTyping.value
                ? _onClickSend(
                    context: context,
                    ref: ref,
                    textController: textController,
                    isTyping: isTyping,
                  )
                : _onLongPressRecording(
                    context: context,
                    ref: ref,
                    isRecording: isRecording,
                  ),
          ),
        ),
      ),
      onSubmitted: (_) => chatHelper.sendMessageHandler(
        context: context,
        ref: ref,
        textController: textController,
      ),
    );
  }

  /// Subscription paywall bottom sheet.
  Future<dynamic> _subscriptionPaywallBottomSheet({required BuildContext context, required List<Package> packages}) {
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

  Widget _moreOptions({
    required BuildContext context,
    required WidgetRef ref,
    required Size mediaQuery,
  }) {
    return IconButton(
      color: AppColors.textFaded,
      onPressed: () => showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        context: context,
        builder: (_) => SizedBox(
          child: SingleChildScrollView(child: _voiceAssistance(context: context, ref: ref)),
        ),
      ),
      icon: const Icon(CupertinoIcons.add),
    );
  }

  AvatarGlow _avatarGlow() {
    return const AvatarGlow(
      endRadius: 30,
      glowColor: AppColors.primary,
      animate: true,
      repeatPauseDuration: Duration(milliseconds: 100),
      duration: Duration(milliseconds: 1500),
      child: Material(
        shape: CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Icon(
            CupertinoIcons.waveform,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// Sends message to chatbot.
  Widget _onClickSend({
    required BuildContext context,
    required WidgetRef ref,
    required TextEditingController textController,
    required ValueNotifier<bool> isTyping,
  }) {
    return IconButton(
      onPressed: isTyping.value ? () => chatHelper.sendMessageHandler(context: context, ref: ref, textController: textController) : () {},
      color: AppColors.primary,
      icon: const Icon(
        Icons.send_rounded,
        color: AppColors.primary,
      ),
    );
  }

  /// Starts listening when user starts recording.
  void _listenOnLongPressStart({required BuildContext context, required ValueNotifier<bool> isRecording}) async {
    isRecording.value = true;

    if (!(await _speechToText.hasPermission)) {
      _initSpeechToText();
    }

    if (_speechToText.isNotListening) {
      setState(() {
        _lastWords = '';
      });
      await _startListening();
    }
  }

  /// Stops listening when user stops recording.
  void _listenOnLongPressStop({
    required BuildContext context,
    required WidgetRef ref,
    required ValueNotifier<bool> isRecording,
  }) async {
    isRecording.value = false;

    await _stopListening();
    await _startListening();
    await Future.delayed(const Duration(milliseconds: 500));

    if (_lastWords.isNotEmpty) {
      final messageModel = MessageModel(
        message: _lastWords.trim().capitalize(),
        senderId: widget.userId,
        createdAt: DateTime.now(),
      );
      await _stopListening();
      // ignore: use_build_context_synchronously
      chatHelper.sendMessage(context: context, ref: ref, messageModel: messageModel);
    }
  }

  /// Starts listening on tap.
  GestureDetector _onLongPressRecording({
    required BuildContext context,
    required WidgetRef ref,
    required ValueNotifier<bool> isRecording,
  }) {
    return GestureDetector(
      onTap: () {
        NotificationHandler(
          context: context,
          icon: CupertinoIcons.info_circle,
          color: AppColors.primary,
          message: AppLocalizations.of(context)!.recordingButtonInstruction,
        ).showSnackBar();
      },
      onLongPressStart: (_) {
        final user = ref.read(userModelStateProvider);
        final onExploration = ref.watch(onExplorationStateProvider);

        if (user!.subscribed || onExploration) {
          _listenOnLongPressStart(context: context, isRecording: isRecording);
        } else {
          if (_showRecordingPayWall) {
            _subscriptionPaywallBottomSheet(context: context, packages: _packages);
          } else {
            NotificationHandler(
              context: context,
              icon: CupertinoIcons.info_circle,
              color: AppColors.primary,
              message: AppLocalizations.of(context)!.recordingIsPremiumFeature,
            ).showSnackBar();
            _showRecordingPayWall = true;
          }
        }
      },
      onLongPressEnd: (_) => _listenOnLongPressStop(context: context, ref: ref, isRecording: isRecording),
      child: _recordingButtonChildWidget(),
    );
  }

  Widget _recordingButtonChildWidget() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: const ClipOval(
        child: Material(
          child: SizedBox(
            width: 20,
            height: 20,
            child: Icon(CupertinoIcons.mic_fill, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _voiceAssistance({required BuildContext context, required WidgetRef ref}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 10, bottom: 20),
      child: Column(
        children: [
          const BottomSheetBar(bottom: 10),
          Text(
            AppLocalizations.of(context)!.voiceAssistance,
            style: const TextStyle(fontSize: 15, color: AppColors.textFaded),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.enableVoiceAssistance,
                    style: const TextStyle(color: AppColors.textFaded),
                  ),
                  Switch(
                    activeColor: AppColors.primary,
                    value: ref.watch(settingsModelStateProvider).voiceAssistanceEnabled,
                    onChanged: (value) {
                      final user = ref.read(userModelStateProvider);
                      final onExploration = ref.watch(onExplorationStateProvider);

                      if (user!.subscribed || onExploration) {
                        ref.read(userControllerStateNotifierProvider.notifier).updateSettings(
                              context: context,
                              settingOption: SettingsOptions.voiceAssistance,
                              value: value,
                            );
                      } else {
                        if (_showVoiceAssistPayWall) {
                          _subscriptionPaywallBottomSheet(context: context, packages: _packages);
                        } else {
                          Navigator.of(context).pop();
                          NotificationHandler(
                            context: context,
                            icon: CupertinoIcons.info_circle,
                            color: AppColors.primary,
                            message: AppLocalizations.of(context)!.voiceAssistanceisPremiumFeature,
                          ).showSnackBar();
                          _showVoiceAssistPayWall = true;
                        }
                      }
                    },
                  ),
                ],
              ),
              Text(
                AppLocalizations.of(context)!.enableVoiceAssistanceDescription,
                style: const TextStyle(fontSize: 12, color: AppColors.textFaded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
