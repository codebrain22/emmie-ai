class Constants {
  static const playstoreAppIdentifier = 'com.enactify.emmie';
  static const playstoreAppURL = 'https://play.google.com/store/apps/details?id=com.enactify.emmie&hl=en-US&ah=CdByNORFr61QcOOZZz5LSm9YFkY&pli=1';
  static const playstoreSubscriptionsUrl =
      'https://play.google.com/store/account/subscriptions?package=com.enactify.emmie&hl=en-US&ah=CdByNORFr61QcOOZZz5LSm9YFkY&pli=1';
  static const emmieAiTermsAndConditions = 'https://codebrain22.github.io/emmie-ai-privacy-policy/';

  static const bannerAdsUnitId = 'ca-app-pub-3940256099942544/6300978111';
  // static const bannerAdsUnitId = 'ca-app-pub-9766198417111710/5279944898';

  static const rewardedAdsUnitId = 'ca-app-pub-3940256099942544/5224354917';
  // static const rewardedAdsUnitId = 'ca-app-pub-9766198417111710/6018311498';

  static const appDefaultLanguage = 'en';
  static const appControlDocumentId = 'iVmhNwqZdEGO37kbLLOi';
  // User constants.
  static const emmieStartAIProfileImage = '';
  static const emmieFriendProfileImage = '';
  static const emmieQandAProfileImage = '';

  // Authentication providers
  static const providerGoogle = 'Google';
  static const providerFacebook = 'Facebook';

  // Images constants.
  static const userDefaultIcon = '';
  static const emmieIcon = 'assets/images/emmie_icon.png';
  static const emmieIconAlt = 'assets/images/emmie_icon_alt.png';
  static const googleImage = 'assets/images/google.png';
  static const facebookImage = 'assets/images/facebook.png';
  static const emptyChatsImage = 'assets/images/empty_chats.png';
  static const emptyNotificationsImage = 'assets/images/empty_notifications.png';
  static const premiumImage = 'assets/images/premium.png';
  static const freeVersionImage = 'assets/images/free_version.png';
  static const onboardingPageOneImage = 'assets/images/onboarding_page_one_image.png';
  static const onboardingPageTwoImage = 'assets/images/onboarding_page_two_image.png';
  static const onboardingPageThreeImage = 'assets/images/onboarding_page_three_image.png';
  static const accountActivationImage = 'assets/images/account_activation.png';
  static const errorImage = 'assets/images/error.png';
  static const recordingSound = 'assets/sound/recording_sound.mp3';

  // Firebase collections constants.
  static const users = 'users';
  static const contactsCollection = 'chatbots';
  static const chats = 'chats';
  static const messages = 'messages';
  static const notifications = 'notifications';
  static const appControl = 'app_control';

  // Firestore User fields constants.
  static const messageCreateAt = 'createdAt';
  static const chatChangedAt = 'changedAt';
  static const notificationCreateAt = 'createdAt';
  static const chatLastMessage = 'lastMessage';
  static const userName = 'username';
  static const subscribed = 'subscribed';
  static const freeMessages = 'freeMessages';
  static const userPhotoURL = 'photoURL';
  static const userdeviceToken = 'deviceToken';
  static const active = 'active';

  // App settings fields
  static const darkModeEnabled = 'darkModeEnabled';
  static const voiceAssistanceEnabled = 'voiceAssistanceEnabled';
  static const notifictionsMuted = 'notifictionsMuted';
  static const notificationsPaused = 'notificationsPaused';
  static const language = 'language';
  static const appSettings = 'emmiAIAppSettings';
  static const appUser = 'emmiAIAppUser';
  static const userOnboarded = 'userOnboarded';

  // Firebase storage contants
  static const userImagePath = 'emmie_ai/user_photos';
  static const chatbotImagePath = 'chatbot/images';

  // Emmie Api endpoints
  static const emmieBaseUrl = 'http://192.168.0.112:3000/api/v1';
  static const messageRoute = 'prompt';

  // API fields
  static const apiURL = 'https://api.openai.com/v1/chat/completions';
  static const chatModelName = 'gpt-3.5-turbo';
  static const modelResponseMessageSurfix = "Upgrade to premium and enjoy unlimited responses and messages!";
  static const chatErrorMessage =
      "I apologize for the inconvenience! I seem to be encountering issues. Please try restarting or refreshing the app. Thank you for your patience.";
  static const emmieAiDeclaration = 'By using the app, you acknowledge and agree to our terms and conditions.';
}
