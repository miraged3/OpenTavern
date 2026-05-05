// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OpenTavern';

  @override
  String get navChat => 'Chat';

  @override
  String get navCharacters => 'Characters';

  @override
  String get navMore => 'More';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get selectAll => 'Select All';

  @override
  String get search => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String get copy => 'Copy';

  @override
  String get retry => 'Retry';

  @override
  String get import => 'Import';

  @override
  String get create => 'Create';

  @override
  String get addNew => 'Add New';

  @override
  String get status => 'Status';

  @override
  String get enable => 'Enable';

  @override
  String get disable => 'Disable';

  @override
  String get defaultBadge => 'Default';

  @override
  String get discoverTitle => 'More';

  @override
  String get discoverQuickActions => 'Quick Actions';

  @override
  String get discoverImportCharacter => 'Import Character';

  @override
  String get discoverCreateCharacter => 'Create Character';

  @override
  String get discoverViewCharacters => 'View Characters';

  @override
  String get discoverSettings => 'Settings';

  @override
  String get discoverHelp => 'Help';

  @override
  String get chatTitle => 'Chat';

  @override
  String get searchConversations => 'Search characters or conversations';

  @override
  String get noConversations =>
      'No conversations yet\nImport a character to start chatting';

  @override
  String get noSearchResults => 'No matching conversations found';

  @override
  String selectedCount(int count) {
    return 'Selected $count conversations';
  }

  @override
  String get deleteConversation => 'Delete Conversation';

  @override
  String deleteConversationConfirm(String name) {
    return 'Delete conversation with \"$name\"?';
  }

  @override
  String deleteConversationsConfirm(int count) {
    return 'Delete selected $count conversations?';
  }

  @override
  String get reasoning => 'Thinking…';

  @override
  String get replying => 'Replying';

  @override
  String get conversationNotFound => 'Conversation not found';

  @override
  String get inputMessageHint => 'Type a message';

  @override
  String get selectModel => 'Select Model';

  @override
  String get currentModelDefault => 'Use current default model';

  @override
  String get currentModelAssigned => 'Conversation has assigned model';

  @override
  String get currentConversationParams => 'Current Conversation Parameters';

  @override
  String get useDefaultParams => 'Use Default Parameters';

  @override
  String get messageActions => 'Message Actions';

  @override
  String get editMessage => 'Edit Message';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get charactersTitle => 'Characters';

  @override
  String get searchCharacters => 'Search characters, tags or settings';

  @override
  String selectedCharactersCount(int count) {
    return 'Selected $count characters';
  }

  @override
  String get all => 'All';

  @override
  String get favorites => 'Favorites';

  @override
  String get deleteCharacter => 'Delete Character';

  @override
  String deleteCharacterConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get characterActions => 'Character Actions';

  @override
  String get startChat => 'Start Chat';

  @override
  String get favorite => 'Favorite';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get noCharacters => 'No characters yet\nImport or create one first';

  @override
  String get editCharacter => 'Edit Character';

  @override
  String get createCharacter => 'Create Character';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get avatar => 'Avatar';

  @override
  String get avatarSet => 'Avatar set';

  @override
  String get avatarNotSet => 'Shows first character if not set';

  @override
  String get pickImage => 'Choose Image';

  @override
  String get name => 'Name';

  @override
  String get creator => 'Creator';

  @override
  String get tags => 'Tags';

  @override
  String get tagsHint => 'Separated by commas, e.g. fantasy, healing';

  @override
  String get characterSettings => 'Character Settings';

  @override
  String get description => 'Description';

  @override
  String get personality => 'Personality';

  @override
  String get scenario => 'Scenario';

  @override
  String get dialogue => 'Dialogue';

  @override
  String get firstMessage => 'First Message';

  @override
  String get characterNotFound => 'Character not found';

  @override
  String get characterPreview => 'Character Preview';

  @override
  String get more => 'More';

  @override
  String get characterSettingsDesc =>
      'Core description, personality and scenario';

  @override
  String get dialogueMaterials => 'Dialogue Materials';

  @override
  String get dialogueMaterialsDesc =>
      'Opening lines that affect the first round experience';

  @override
  String get alternateGreetings => 'Alternate Greetings';

  @override
  String get extendedInfo => 'Extended Info';

  @override
  String get extendedInfoDesc =>
      'Additional constraints, creator notes and example chats';

  @override
  String get creatorNotes => 'Creator Notes';

  @override
  String get systemPrompt => 'System Prompt';

  @override
  String get postHistoryInstructions => 'Post-history Instructions';

  @override
  String get exampleMessages => 'Example Messages';

  @override
  String get editCharacterButton => 'Edit Character';

  @override
  String get importCharacterCard => 'Import Character Card';

  @override
  String get importMethod => 'Import Method';

  @override
  String get selectFile => 'Select File';

  @override
  String get parseJson => 'Parse JSON';

  @override
  String get pasteUrlHint => 'Paste PNG / JSON character card link';

  @override
  String get fetchFromUrl => 'Fetch from URL';

  @override
  String get jsonContent => 'JSON Content';

  @override
  String get jsonContentHint =>
      'Paste Tavern / SillyTavern V1/V2 JSON, or select PNG / JSON file / URL above';

  @override
  String get importOnly => 'Import Only';

  @override
  String get importAndChat => 'Import and Start Chat';

  @override
  String get importReview => 'Import Review';

  @override
  String get formatLabel => 'Format';

  @override
  String get authorLabel => 'Author';

  @override
  String get notProvided => 'Not provided';

  @override
  String get none => 'None';

  @override
  String get importReminder => 'Import Reminder';

  @override
  String get importFormatManual => 'Manual';

  @override
  String get importFormatSiteImport => 'Site Import';

  @override
  String get localFile => 'Local File';

  @override
  String readFileFailed(String error) {
    return 'Failed to read file: $error';
  }

  @override
  String get invalidUrl => 'Please enter a valid HTTP/HTTPS link';

  @override
  String get onlyHttpHttps => 'Only HTTP/HTTPS links are supported';

  @override
  String get downloadEmpty => 'Download content is empty';

  @override
  String downloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String urlImportFailed(String error) {
    return 'URL import failed: $error';
  }

  @override
  String get connectionTimeout => 'Connection timed out';

  @override
  String serverReturnedStatus(int statusCode) {
    return 'Server returned $statusCode';
  }

  @override
  String get provideJsonFirst => 'Please provide character card JSON first';

  @override
  String parseFailed(String error) {
    return 'Parse failed: $error';
  }

  @override
  String pngParseFailed(String error) {
    return 'PNG parse failed: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeMode => 'Color';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get user => 'User';

  @override
  String get userPersonas => 'User Personas';

  @override
  String userPersonasCount(int count) {
    return '$count personas available';
  }

  @override
  String get models => 'Models';

  @override
  String get modelSettings => 'Model Settings';

  @override
  String modelCount(int count) {
    return '$count models';
  }

  @override
  String get chat => 'Chat';

  @override
  String get enterKeyToSend => 'Enter Key to Send';

  @override
  String get logs => 'Logs';

  @override
  String get enableLogging => 'Enable Logging';

  @override
  String get viewLogs => 'View Logs';

  @override
  String logCount(int count) {
    return '$count entries';
  }

  @override
  String get generationParams => 'Generation Parameters';

  @override
  String get temperature => 'Temperature';

  @override
  String get topP => 'Top P';

  @override
  String get maxTokens => 'Max Tokens';

  @override
  String get reasoningMode => 'Reasoning';

  @override
  String get reasoningOff => 'Off';

  @override
  String get reasoningAutomatic => 'Automatic';

  @override
  String get reasoningLow => 'Low';

  @override
  String get reasoningMedium => 'Medium';

  @override
  String get reasoningHigh => 'High';

  @override
  String get defaultGenerationParams => 'Default Generation Parameters';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get temperatureHelper => 'Higher = more creative, lower = more stable';

  @override
  String get topPHelper => 'Controls candidate sampling range';

  @override
  String get maxTokensHelper => 'Limits single reply length';

  @override
  String get modelSettingsTitle => 'Model Settings';

  @override
  String get defaultModel => 'Default Model';

  @override
  String get notSet => 'Not set';

  @override
  String get noDefaultModel => 'No default model selected';

  @override
  String get modelsCountLabel => 'Models';

  @override
  String get enabledCountLabel => 'Enabled';

  @override
  String get testAllEnabled => 'Test All Enabled';

  @override
  String get batchManage => 'Batch Manage';

  @override
  String get noModelsYet => 'No models yet';

  @override
  String get addApiModelKey => 'Add API, model and key';

  @override
  String selectedItemsCount(int count) {
    return '$count selected';
  }

  @override
  String get testing => 'Testing';

  @override
  String get test => 'Test';

  @override
  String get setAsDefault => 'Set as Default';

  @override
  String get available => 'Available';

  @override
  String get failed => 'Failed';

  @override
  String get untested => 'Untested';

  @override
  String get editModel => 'Edit Model';

  @override
  String get addModel => 'Add Model';

  @override
  String get configureModelEndpoint => 'Configure a model endpoint';

  @override
  String get cloudDescription =>
      'Select cloud vendor, enter Key, then fetch available models';

  @override
  String get customUrlDescription =>
      'Fill in compatible API address, confirm format, then test and save';

  @override
  String get connection => 'Connection';

  @override
  String get connectionSource => 'Connection Source';

  @override
  String get cloudVendor => 'Cloud Vendor';

  @override
  String get apiFormat => 'API Format';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get apiKey => 'API Key';

  @override
  String get keepExistingKey => 'Leave blank to keep existing key';

  @override
  String get modelId => 'Model ID';

  @override
  String get enableSwitch => 'Enable';

  @override
  String get setDefaultSwitch => 'Set as Default';

  @override
  String get helpTitle => 'Help';

  @override
  String get aboutOpenTavern => 'About OpenTavern';

  @override
  String get currentSelected => 'Current';

  @override
  String get modelLabel => 'Model';

  @override
  String get paramsLabel => 'Parameters';

  @override
  String get runtimeLogs => 'Runtime Logs';

  @override
  String get export => 'Export';

  @override
  String get clearLogs => 'Clear';

  @override
  String get noLogsYet => 'No logs yet';

  @override
  String get logsExported => 'Logs exported';

  @override
  String get addPersona => 'Add Persona';

  @override
  String get editPersona => 'Edit Persona';

  @override
  String get personaNameHint => 'e.g. Traveler / Commander / Researcher';

  @override
  String get settingsSection => 'Settings';

  @override
  String get bio => 'Bio';

  @override
  String get bioHint => 'Short description of this persona';

  @override
  String get profilePromptLabel => 'Profile Prompt';

  @override
  String get profilePromptHint =>
      'User-side background, tone, identity and constraints for the model';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get systemInterrupted =>
      'Last reply interrupted by app exit or page rebuild';

  @override
  String get systemSendFailed => 'Send failed, tap to retry';

  @override
  String get networkError =>
      'Network connection failed, please check API address and network';

  @override
  String get requestTimeout => 'Request timed out, please retry later';

  @override
  String get invalidApiKey => 'API Key invalid or expired';

  @override
  String get rateLimited => 'Too many requests, please retry later';

  @override
  String get serverError => 'Server error, please retry later';

  @override
  String get unnamedCharacter => 'Unnamed Character';

  @override
  String get missingNameWarning =>
      'Missing name, will use \'Unnamed Character\' after import';

  @override
  String get missingDescriptionWarning => 'Missing Description';

  @override
  String get missingFirstMessageWarning => 'Missing First Message';

  @override
  String get thinking => 'Thinking';

  @override
  String get thought => 'Thought';

  @override
  String get cloudVendorModelExample => 'e.g. Main model';

  @override
  String get customUrlExamplePrefix => 'e.g. Self-hosted';

  @override
  String get enterBaseUrlFirst => 'Please enter Base URL first';

  @override
  String get noModelsReturned => 'No models returned';

  @override
  String get enterModelName => 'Please enter model name';

  @override
  String get enterBaseUrl => 'Please enter Base URL';

  @override
  String get enterModelId => 'Please enter model ID';

  @override
  String get completeRequiredFields =>
      'Please complete all required fields before saving';

  @override
  String get availableModels => 'Available Models';

  @override
  String get fetchingModels => 'Fetching...';

  @override
  String get fetchModels => 'Fetch Models';

  @override
  String get confirmConnectionThenFetch =>
      'Confirm connection info, then tap \'Fetch Models\' to auto-fill the list';

  @override
  String get connectionFailed =>
      'Connection failed: unable to connect to server. Please check Base URL and service status';

  @override
  String get originalError => 'Original error';

  @override
  String get requestTimeoutColon =>
      'Request timed out: server response too slow';

  @override
  String get requestCancelled => 'Request cancelled';

  @override
  String get authFailed => 'Authentication failed: invalid or missing API Key';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get endpointNotFound =>
      'Endpoint not found: please check Base URL and API format';

  @override
  String get rateLimitReached => 'Rate limit reached';

  @override
  String get serverInternalError => 'Server internal error';

  @override
  String get serviceUnavailable =>
      'Service unavailable: server temporarily unable to process request';

  @override
  String get fetchFailed => 'Fetch failed';
}
