import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenTavern'**
  String get appTitle;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get navCharacters;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @defaultBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultBadge;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get discoverTitle;

  /// No description provided for @discoverQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get discoverQuickActions;

  /// No description provided for @discoverImportCharacter.
  ///
  /// In en, this message translates to:
  /// **'Import Character'**
  String get discoverImportCharacter;

  /// No description provided for @discoverCreateCharacter.
  ///
  /// In en, this message translates to:
  /// **'Create Character'**
  String get discoverCreateCharacter;

  /// No description provided for @discoverViewCharacters.
  ///
  /// In en, this message translates to:
  /// **'View Characters'**
  String get discoverViewCharacters;

  /// No description provided for @discoverSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get discoverSettings;

  /// No description provided for @discoverHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get discoverHelp;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search characters or conversations'**
  String get searchConversations;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet\nImport a character to start chatting'**
  String get noConversations;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching conversations found'**
  String get noSearchResults;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} conversations'**
  String selectedCount(int count);

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete Conversation'**
  String get deleteConversation;

  /// No description provided for @deleteConversationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation with \"{name}\"?'**
  String deleteConversationConfirm(String name);

  /// No description provided for @deleteConversationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete selected {count} conversations?'**
  String deleteConversationsConfirm(int count);

  /// No description provided for @reasoning.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get reasoning;

  /// No description provided for @replying.
  ///
  /// In en, this message translates to:
  /// **'Replying'**
  String get replying;

  /// No description provided for @conversationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Conversation not found'**
  String get conversationNotFound;

  /// No description provided for @inputMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get inputMessageHint;

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get selectModel;

  /// No description provided for @currentModelDefault.
  ///
  /// In en, this message translates to:
  /// **'Use current default model'**
  String get currentModelDefault;

  /// No description provided for @currentModelAssigned.
  ///
  /// In en, this message translates to:
  /// **'Conversation has assigned model'**
  String get currentModelAssigned;

  /// No description provided for @currentConversationParams.
  ///
  /// In en, this message translates to:
  /// **'Current Conversation Parameters'**
  String get currentConversationParams;

  /// No description provided for @useDefaultParams.
  ///
  /// In en, this message translates to:
  /// **'Use Default Parameters'**
  String get useDefaultParams;

  /// No description provided for @messageActions.
  ///
  /// In en, this message translates to:
  /// **'Message Actions'**
  String get messageActions;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @charactersTitle.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get charactersTitle;

  /// No description provided for @searchCharacters.
  ///
  /// In en, this message translates to:
  /// **'Search characters, tags or settings'**
  String get searchCharacters;

  /// No description provided for @selectedCharactersCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} characters'**
  String selectedCharactersCount(int count);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @deleteCharacter.
  ///
  /// In en, this message translates to:
  /// **'Delete Character'**
  String get deleteCharacter;

  /// No description provided for @deleteCharacterConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteCharacterConfirm(String name);

  /// No description provided for @characterActions.
  ///
  /// In en, this message translates to:
  /// **'Character Actions'**
  String get characterActions;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get startChat;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// No description provided for @noCharacters.
  ///
  /// In en, this message translates to:
  /// **'No characters yet\nImport or create one first'**
  String get noCharacters;

  /// No description provided for @editCharacter.
  ///
  /// In en, this message translates to:
  /// **'Edit Character'**
  String get editCharacter;

  /// No description provided for @createCharacter.
  ///
  /// In en, this message translates to:
  /// **'Create Character'**
  String get createCharacter;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @avatarSet.
  ///
  /// In en, this message translates to:
  /// **'Avatar set'**
  String get avatarSet;

  /// No description provided for @avatarNotSet.
  ///
  /// In en, this message translates to:
  /// **'Shows first character if not set'**
  String get avatarNotSet;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get pickImage;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'Separated by commas, e.g. fantasy, healing'**
  String get tagsHint;

  /// No description provided for @characterSettings.
  ///
  /// In en, this message translates to:
  /// **'Character Settings'**
  String get characterSettings;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @personality.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get personality;

  /// No description provided for @scenario.
  ///
  /// In en, this message translates to:
  /// **'Scenario'**
  String get scenario;

  /// No description provided for @dialogue.
  ///
  /// In en, this message translates to:
  /// **'Dialogue'**
  String get dialogue;

  /// No description provided for @firstMessage.
  ///
  /// In en, this message translates to:
  /// **'First Message'**
  String get firstMessage;

  /// No description provided for @characterNotFound.
  ///
  /// In en, this message translates to:
  /// **'Character not found'**
  String get characterNotFound;

  /// No description provided for @characterPreview.
  ///
  /// In en, this message translates to:
  /// **'Character Preview'**
  String get characterPreview;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @characterSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Core description, personality and scenario'**
  String get characterSettingsDesc;

  /// No description provided for @dialogueMaterials.
  ///
  /// In en, this message translates to:
  /// **'Dialogue Materials'**
  String get dialogueMaterials;

  /// No description provided for @dialogueMaterialsDesc.
  ///
  /// In en, this message translates to:
  /// **'Opening lines that affect the first round experience'**
  String get dialogueMaterialsDesc;

  /// No description provided for @alternateGreetings.
  ///
  /// In en, this message translates to:
  /// **'Alternate Greetings'**
  String get alternateGreetings;

  /// No description provided for @extendedInfo.
  ///
  /// In en, this message translates to:
  /// **'Extended Info'**
  String get extendedInfo;

  /// No description provided for @extendedInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Additional constraints, creator notes and example chats'**
  String get extendedInfoDesc;

  /// No description provided for @creatorNotes.
  ///
  /// In en, this message translates to:
  /// **'Creator Notes'**
  String get creatorNotes;

  /// No description provided for @systemPrompt.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get systemPrompt;

  /// No description provided for @postHistoryInstructions.
  ///
  /// In en, this message translates to:
  /// **'Post-history Instructions'**
  String get postHistoryInstructions;

  /// No description provided for @exampleMessages.
  ///
  /// In en, this message translates to:
  /// **'Example Messages'**
  String get exampleMessages;

  /// No description provided for @editCharacterButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Character'**
  String get editCharacterButton;

  /// No description provided for @importCharacterCard.
  ///
  /// In en, this message translates to:
  /// **'Import Character Card'**
  String get importCharacterCard;

  /// No description provided for @importMethod.
  ///
  /// In en, this message translates to:
  /// **'Import Method'**
  String get importMethod;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @parseJson.
  ///
  /// In en, this message translates to:
  /// **'Parse JSON'**
  String get parseJson;

  /// No description provided for @pasteUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste PNG / JSON character card link'**
  String get pasteUrlHint;

  /// No description provided for @fetchFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Fetch from URL'**
  String get fetchFromUrl;

  /// No description provided for @jsonContent.
  ///
  /// In en, this message translates to:
  /// **'JSON Content'**
  String get jsonContent;

  /// No description provided for @jsonContentHint.
  ///
  /// In en, this message translates to:
  /// **'Paste Tavern / SillyTavern V1/V2 JSON, or select PNG / JSON file / URL above'**
  String get jsonContentHint;

  /// No description provided for @importOnly.
  ///
  /// In en, this message translates to:
  /// **'Import Only'**
  String get importOnly;

  /// No description provided for @importAndChat.
  ///
  /// In en, this message translates to:
  /// **'Import and Start Chat'**
  String get importAndChat;

  /// No description provided for @importReview.
  ///
  /// In en, this message translates to:
  /// **'Import Review'**
  String get importReview;

  /// No description provided for @formatLabel.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get formatLabel;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorLabel;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @importReminder.
  ///
  /// In en, this message translates to:
  /// **'Import Reminder'**
  String get importReminder;

  /// No description provided for @importFormatManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get importFormatManual;

  /// No description provided for @importFormatSiteImport.
  ///
  /// In en, this message translates to:
  /// **'Site Import'**
  String get importFormatSiteImport;

  /// No description provided for @localFile.
  ///
  /// In en, this message translates to:
  /// **'Local File'**
  String get localFile;

  /// No description provided for @readFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read file: {error}'**
  String readFileFailed(String error);

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid HTTP/HTTPS link'**
  String get invalidUrl;

  /// No description provided for @onlyHttpHttps.
  ///
  /// In en, this message translates to:
  /// **'Only HTTP/HTTPS links are supported'**
  String get onlyHttpHttps;

  /// No description provided for @downloadEmpty.
  ///
  /// In en, this message translates to:
  /// **'Download content is empty'**
  String get downloadEmpty;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailed(String error);

  /// No description provided for @urlImportFailed.
  ///
  /// In en, this message translates to:
  /// **'URL import failed: {error}'**
  String urlImportFailed(String error);

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out'**
  String get connectionTimeout;

  /// No description provided for @serverReturnedStatus.
  ///
  /// In en, this message translates to:
  /// **'Server returned {statusCode}'**
  String serverReturnedStatus(int statusCode);

  /// No description provided for @provideJsonFirst.
  ///
  /// In en, this message translates to:
  /// **'Please provide character card JSON first'**
  String get provideJsonFirst;

  /// No description provided for @parseFailed.
  ///
  /// In en, this message translates to:
  /// **'Parse failed: {error}'**
  String parseFailed(String error);

  /// No description provided for @pngParseFailed.
  ///
  /// In en, this message translates to:
  /// **'PNG parse failed: {error}'**
  String pngParseFailed(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @userPersonas.
  ///
  /// In en, this message translates to:
  /// **'User Personas'**
  String get userPersonas;

  /// No description provided for @userPersonasCount.
  ///
  /// In en, this message translates to:
  /// **'{count} personas available'**
  String userPersonasCount(int count);

  /// No description provided for @models.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get models;

  /// No description provided for @modelSettings.
  ///
  /// In en, this message translates to:
  /// **'Model Settings'**
  String get modelSettings;

  /// No description provided for @modelCount.
  ///
  /// In en, this message translates to:
  /// **'{count} models'**
  String modelCount(int count);

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @enterKeyToSend.
  ///
  /// In en, this message translates to:
  /// **'Enter Key to Send'**
  String get enterKeyToSend;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @enableLogging.
  ///
  /// In en, this message translates to:
  /// **'Enable Logging'**
  String get enableLogging;

  /// No description provided for @viewLogs.
  ///
  /// In en, this message translates to:
  /// **'View Logs'**
  String get viewLogs;

  /// No description provided for @logCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String logCount(int count);

  /// No description provided for @generationParams.
  ///
  /// In en, this message translates to:
  /// **'Generation Parameters'**
  String get generationParams;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @topP.
  ///
  /// In en, this message translates to:
  /// **'Top P'**
  String get topP;

  /// No description provided for @maxTokens.
  ///
  /// In en, this message translates to:
  /// **'Max Tokens'**
  String get maxTokens;

  /// No description provided for @reasoningMode.
  ///
  /// In en, this message translates to:
  /// **'Reasoning'**
  String get reasoningMode;

  /// No description provided for @reasoningOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reasoningOff;

  /// No description provided for @reasoningAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get reasoningAutomatic;

  /// No description provided for @reasoningLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get reasoningLow;

  /// No description provided for @reasoningMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get reasoningMedium;

  /// No description provided for @reasoningHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get reasoningHigh;

  /// No description provided for @defaultGenerationParams.
  ///
  /// In en, this message translates to:
  /// **'Default Generation Parameters'**
  String get defaultGenerationParams;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @temperatureHelper.
  ///
  /// In en, this message translates to:
  /// **'Higher = more creative, lower = more stable'**
  String get temperatureHelper;

  /// No description provided for @topPHelper.
  ///
  /// In en, this message translates to:
  /// **'Controls candidate sampling range'**
  String get topPHelper;

  /// No description provided for @maxTokensHelper.
  ///
  /// In en, this message translates to:
  /// **'Limits single reply length'**
  String get maxTokensHelper;

  /// No description provided for @modelSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Model Settings'**
  String get modelSettingsTitle;

  /// No description provided for @defaultModel.
  ///
  /// In en, this message translates to:
  /// **'Default Model'**
  String get defaultModel;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @noDefaultModel.
  ///
  /// In en, this message translates to:
  /// **'No default model selected'**
  String get noDefaultModel;

  /// No description provided for @modelsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get modelsCountLabel;

  /// No description provided for @enabledCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledCountLabel;

  /// No description provided for @testAllEnabled.
  ///
  /// In en, this message translates to:
  /// **'Test All Enabled'**
  String get testAllEnabled;

  /// No description provided for @batchManage.
  ///
  /// In en, this message translates to:
  /// **'Batch Manage'**
  String get batchManage;

  /// No description provided for @noModelsYet.
  ///
  /// In en, this message translates to:
  /// **'No models yet'**
  String get noModelsYet;

  /// No description provided for @addApiModelKey.
  ///
  /// In en, this message translates to:
  /// **'Add API, model and key'**
  String get addApiModelKey;

  /// No description provided for @selectedItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedItemsCount(int count);

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing'**
  String get testing;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @untested.
  ///
  /// In en, this message translates to:
  /// **'Untested'**
  String get untested;

  /// No description provided for @editModel.
  ///
  /// In en, this message translates to:
  /// **'Edit Model'**
  String get editModel;

  /// No description provided for @addModel.
  ///
  /// In en, this message translates to:
  /// **'Add Model'**
  String get addModel;

  /// No description provided for @configureModelEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Configure a model endpoint'**
  String get configureModelEndpoint;

  /// No description provided for @cloudDescription.
  ///
  /// In en, this message translates to:
  /// **'Select cloud vendor, enter Key, then fetch available models'**
  String get cloudDescription;

  /// No description provided for @customUrlDescription.
  ///
  /// In en, this message translates to:
  /// **'Fill in compatible API address, confirm format, then test and save'**
  String get customUrlDescription;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @connectionSource.
  ///
  /// In en, this message translates to:
  /// **'Connection Source'**
  String get connectionSource;

  /// No description provided for @cloudVendor.
  ///
  /// In en, this message translates to:
  /// **'Cloud Vendor'**
  String get cloudVendor;

  /// No description provided for @apiFormat.
  ///
  /// In en, this message translates to:
  /// **'API Format'**
  String get apiFormat;

  /// No description provided for @baseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrl;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @keepExistingKey.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep existing key'**
  String get keepExistingKey;

  /// No description provided for @modelId.
  ///
  /// In en, this message translates to:
  /// **'Model ID'**
  String get modelId;

  /// No description provided for @enableSwitch.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enableSwitch;

  /// No description provided for @setDefaultSwitch.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setDefaultSwitch;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @aboutOpenTavern.
  ///
  /// In en, this message translates to:
  /// **'About OpenTavern'**
  String get aboutOpenTavern;

  /// No description provided for @currentSelected.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentSelected;

  /// No description provided for @modelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// No description provided for @paramsLabel.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get paramsLabel;

  /// No description provided for @runtimeLogs.
  ///
  /// In en, this message translates to:
  /// **'Runtime Logs'**
  String get runtimeLogs;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearLogs;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @logsExported.
  ///
  /// In en, this message translates to:
  /// **'Logs exported'**
  String get logsExported;

  /// No description provided for @addPersona.
  ///
  /// In en, this message translates to:
  /// **'Add Persona'**
  String get addPersona;

  /// No description provided for @editPersona.
  ///
  /// In en, this message translates to:
  /// **'Edit Persona'**
  String get editPersona;

  /// No description provided for @personaNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Traveler / Commander / Researcher'**
  String get personaNameHint;

  /// No description provided for @settingsSection.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSection;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Short description of this persona'**
  String get bioHint;

  /// No description provided for @profilePromptLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Prompt'**
  String get profilePromptLabel;

  /// No description provided for @profilePromptHint.
  ///
  /// In en, this message translates to:
  /// **'User-side background, tone, identity and constraints for the model'**
  String get profilePromptHint;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @systemInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Last reply interrupted by app exit or page rebuild'**
  String get systemInterrupted;

  /// No description provided for @systemSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed, tap to retry'**
  String get systemSendFailed;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed, please check API address and network'**
  String get networkError;

  /// No description provided for @requestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out, please retry later'**
  String get requestTimeout;

  /// No description provided for @invalidApiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key invalid or expired'**
  String get invalidApiKey;

  /// No description provided for @rateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests, please retry later'**
  String get rateLimited;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error, please retry later'**
  String get serverError;

  /// No description provided for @unnamedCharacter.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Character'**
  String get unnamedCharacter;

  /// No description provided for @missingNameWarning.
  ///
  /// In en, this message translates to:
  /// **'Missing name, will use \'Unnamed Character\' after import'**
  String get missingNameWarning;

  /// No description provided for @missingDescriptionWarning.
  ///
  /// In en, this message translates to:
  /// **'Missing Description'**
  String get missingDescriptionWarning;

  /// No description provided for @missingFirstMessageWarning.
  ///
  /// In en, this message translates to:
  /// **'Missing First Message'**
  String get missingFirstMessageWarning;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @thought.
  ///
  /// In en, this message translates to:
  /// **'Thought'**
  String get thought;

  /// No description provided for @cloudVendorModelExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Main model'**
  String get cloudVendorModelExample;

  /// No description provided for @customUrlExamplePrefix.
  ///
  /// In en, this message translates to:
  /// **'e.g. Self-hosted'**
  String get customUrlExamplePrefix;

  /// No description provided for @enterBaseUrlFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter Base URL first'**
  String get enterBaseUrlFirst;

  /// No description provided for @noModelsReturned.
  ///
  /// In en, this message translates to:
  /// **'No models returned'**
  String get noModelsReturned;

  /// No description provided for @enterModelName.
  ///
  /// In en, this message translates to:
  /// **'Please enter model name'**
  String get enterModelName;

  /// No description provided for @enterBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter Base URL'**
  String get enterBaseUrl;

  /// No description provided for @enterModelId.
  ///
  /// In en, this message translates to:
  /// **'Please enter model ID'**
  String get enterModelId;

  /// No description provided for @completeRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields before saving'**
  String get completeRequiredFields;

  /// No description provided for @availableModels.
  ///
  /// In en, this message translates to:
  /// **'Available Models'**
  String get availableModels;

  /// No description provided for @fetchingModels.
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get fetchingModels;

  /// No description provided for @fetchModels.
  ///
  /// In en, this message translates to:
  /// **'Fetch Models'**
  String get fetchModels;

  /// No description provided for @confirmConnectionThenFetch.
  ///
  /// In en, this message translates to:
  /// **'Confirm connection info, then tap \'Fetch Models\' to auto-fill the list'**
  String get confirmConnectionThenFetch;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: unable to connect to server. Please check Base URL and service status'**
  String get connectionFailed;

  /// No description provided for @originalError.
  ///
  /// In en, this message translates to:
  /// **'Original error'**
  String get originalError;

  /// No description provided for @requestTimeoutColon.
  ///
  /// In en, this message translates to:
  /// **'Request timed out: server response too slow'**
  String get requestTimeoutColon;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get requestCancelled;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed: invalid or missing API Key'**
  String get authFailed;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @endpointNotFound.
  ///
  /// In en, this message translates to:
  /// **'Endpoint not found: please check Base URL and API format'**
  String get endpointNotFound;

  /// No description provided for @rateLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Rate limit reached'**
  String get rateLimitReached;

  /// No description provided for @serverInternalError.
  ///
  /// In en, this message translates to:
  /// **'Server internal error'**
  String get serverInternalError;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable: server temporarily unable to process request'**
  String get serviceUnavailable;

  /// No description provided for @fetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch failed'**
  String get fetchFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
