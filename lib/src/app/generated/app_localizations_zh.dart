// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'OpenTavern';

  @override
  String get navChat => '聊天';

  @override
  String get navCharacters => '角色';

  @override
  String get navMore => '更多';

  @override
  String get done => '完成';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get save => '保存';

  @override
  String get edit => '编辑';

  @override
  String get selectAll => '全选';

  @override
  String get search => '搜索';

  @override
  String get clear => '清除';

  @override
  String get copy => '复制';

  @override
  String get retry => '重试';

  @override
  String get import => '导入';

  @override
  String get create => '新建';

  @override
  String get addNew => '新增';

  @override
  String get status => '状态';

  @override
  String get enable => '启用';

  @override
  String get disable => '停用';

  @override
  String get defaultBadge => '默认';

  @override
  String get discoverTitle => '更多';

  @override
  String get discoverQuickActions => '快捷操作';

  @override
  String get discoverImportCharacter => '导入角色卡';

  @override
  String get discoverCreateCharacter => '新建角色';

  @override
  String get discoverViewCharacters => '查看角色库';

  @override
  String get discoverSettings => '设置';

  @override
  String get discoverHelp => '帮助';

  @override
  String get chatTitle => '聊天';

  @override
  String get searchConversations => '搜索角色或对话';

  @override
  String get noConversations => '还没有对话\n导入角色后可以直接开始聊天';

  @override
  String get noSearchResults => '没有找到相关对话';

  @override
  String selectedCount(int count) {
    return '已选择 $count 个对话';
  }

  @override
  String get deleteConversation => '删除对话';

  @override
  String deleteConversationConfirm(String name) {
    return '确定删除「$name」的对话吗？';
  }

  @override
  String deleteConversationsConfirm(int count) {
    return '确定删除选中的 $count 个对话吗？';
  }

  @override
  String get reasoning => '思考中…';

  @override
  String get replying => '正在回复';

  @override
  String get conversationNotFound => '对话不存在';

  @override
  String get inputMessageHint => '输入消息';

  @override
  String get selectModel => '选择模型';

  @override
  String get currentModelDefault => '使用当前默认模型';

  @override
  String get currentModelAssigned => '当前对话已指定模型';

  @override
  String get currentConversationParams => '当前对话参数';

  @override
  String get useDefaultParams => '使用默认参数';

  @override
  String get messageActions => '消息操作';

  @override
  String get editMessage => '编辑消息';

  @override
  String get regenerate => '重新生成';

  @override
  String get charactersTitle => '角色';

  @override
  String get searchCharacters => '搜索角色、标签或设定';

  @override
  String selectedCharactersCount(int count) {
    return '已选择 $count 个角色';
  }

  @override
  String get all => '全部';

  @override
  String get favorites => '收藏';

  @override
  String get deleteCharacter => '删除角色';

  @override
  String deleteCharacterConfirm(String name) {
    return '确定删除「$name」吗？';
  }

  @override
  String get characterActions => '角色操作';

  @override
  String get startChat => '开始聊天';

  @override
  String get favorite => '收藏';

  @override
  String get unfavorite => '取消收藏';

  @override
  String get noCharacters => '还没有角色\n先导入或新建一个';

  @override
  String get editCharacter => '编辑角色';

  @override
  String get createCharacter => '新建角色';

  @override
  String get basicInfo => '基本信息';

  @override
  String get avatar => '头像';

  @override
  String get avatarSet => '当前已设置角色头像';

  @override
  String get avatarNotSet => '未设置时会显示名称首字';

  @override
  String get pickImage => '选择图片';

  @override
  String get name => '名称';

  @override
  String get creator => '作者';

  @override
  String get tags => '标签';

  @override
  String get tagsHint => '用逗号分隔，例如：奇幻, 治愈';

  @override
  String get characterSettings => '角色设定';

  @override
  String get description => '描述';

  @override
  String get personality => '性格';

  @override
  String get scenario => '场景';

  @override
  String get dialogue => '对话';

  @override
  String get firstMessage => '开场白';

  @override
  String get characterNotFound => '角色不存在';

  @override
  String get characterPreview => '角色预览';

  @override
  String get more => '更多';

  @override
  String get characterSettingsDesc => '角色本体的核心描述、性格和场景信息';

  @override
  String get dialogueMaterials => '对话素材';

  @override
  String get dialogueMaterialsDesc => '聊天开场和候选问候语，会直接影响第一轮体验';

  @override
  String get alternateGreetings => '其他开场白';

  @override
  String get extendedInfo => '扩展信息';

  @override
  String get extendedInfoDesc => '补充约束、作者备注和示例对话等附加内容';

  @override
  String get creatorNotes => '作者备注';

  @override
  String get systemPrompt => '系统提示词';

  @override
  String get postHistoryInstructions => '历史后指令';

  @override
  String get exampleMessages => '示例对话';

  @override
  String get editCharacterButton => '编辑角色';

  @override
  String get importCharacterCard => '导入角色卡';

  @override
  String get importMethod => '导入方式';

  @override
  String get selectFile => '选择文件';

  @override
  String get parseJson => '解析 JSON';

  @override
  String get pasteUrlHint => '粘贴 PNG / JSON 角色卡链接';

  @override
  String get fetchFromUrl => '从 URL 获取';

  @override
  String get jsonContent => 'JSON 内容';

  @override
  String get jsonContentHint =>
      '粘贴 Tavern / SillyTavern V1/V2 JSON，或上方选择 PNG / JSON 文件 / URL';

  @override
  String get importOnly => '仅导入';

  @override
  String get importAndChat => '导入并开始聊天';

  @override
  String get importReview => '导入审阅';

  @override
  String get formatLabel => '格式';

  @override
  String get authorLabel => '作者';

  @override
  String get notProvided => '未提供';

  @override
  String get none => '无';

  @override
  String get importReminder => '导入提醒';

  @override
  String get importFormatManual => '手动';

  @override
  String get importFormatSiteImport => '站点导入';

  @override
  String get localFile => '本地文件';

  @override
  String readFileFailed(String error) {
    return '读取文件失败：$error';
  }

  @override
  String get invalidUrl => '请输入有效的 HTTP/HTTPS 链接';

  @override
  String get onlyHttpHttps => '仅支持 HTTP/HTTPS 链接';

  @override
  String get downloadEmpty => '下载内容为空';

  @override
  String downloadFailed(String error) {
    return '下载失败：$error';
  }

  @override
  String urlImportFailed(String error) {
    return 'URL 导入失败：$error';
  }

  @override
  String get connectionTimeout => '连接超时';

  @override
  String serverReturnedStatus(int statusCode) {
    return '服务器返回 $statusCode';
  }

  @override
  String get provideJsonFirst => '请先提供角色卡 JSON';

  @override
  String parseFailed(String error) {
    return '解析失败：$error';
  }

  @override
  String pngParseFailed(String error) {
    return 'PNG 解析失败：$error';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get appearance => '外观';

  @override
  String get themeMode => '颜色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get user => '用户';

  @override
  String get userPersonas => '用户人设';

  @override
  String userPersonasCount(int count) {
    return '$count 个可用人设';
  }

  @override
  String get models => '模型';

  @override
  String get modelSettings => '模型设置';

  @override
  String modelCount(int count) {
    return '$count 个模型';
  }

  @override
  String get chat => '聊天';

  @override
  String get enterKeyToSend => '回车键发送';

  @override
  String get logs => '日志';

  @override
  String get enableLogging => '记录运行日志';

  @override
  String get viewLogs => '查看运行日志';

  @override
  String logCount(int count) {
    return '$count 条';
  }

  @override
  String get generationParams => '生成参数';

  @override
  String get temperature => 'Temperature';

  @override
  String get topP => 'Top P';

  @override
  String get maxTokens => 'Max Tokens';

  @override
  String get reasoningMode => '思考';

  @override
  String get reasoningOff => '关闭';

  @override
  String get reasoningAutomatic => '自动';

  @override
  String get reasoningLow => '低';

  @override
  String get reasoningMedium => '中';

  @override
  String get reasoningHigh => '高';

  @override
  String get defaultGenerationParams => '默认生成参数';

  @override
  String get resetToDefault => '恢复内置默认';

  @override
  String get temperatureHelper => '越高越发散，越低越稳定';

  @override
  String get topPHelper => '控制候选词采样范围';

  @override
  String get maxTokensHelper => '限制单次回复长度';

  @override
  String get modelSettingsTitle => '模型设置';

  @override
  String get defaultModel => '默认模型';

  @override
  String get notSet => '未设置';

  @override
  String get noDefaultModel => '未选择默认模型';

  @override
  String get modelsCountLabel => '模型';

  @override
  String get enabledCountLabel => '启用';

  @override
  String get testAllEnabled => '测试全部启用模型';

  @override
  String get batchManage => '批量管理';

  @override
  String get noModelsYet => '还没有模型';

  @override
  String get addApiModelKey => '添加 API、模型和 Key';

  @override
  String selectedItemsCount(int count) {
    return '已选择 $count 个';
  }

  @override
  String get testing => '测试中';

  @override
  String get test => '测试';

  @override
  String get setAsDefault => '设为默认';

  @override
  String get available => '可用';

  @override
  String get failed => '失败';

  @override
  String get untested => '未测试';

  @override
  String get editModel => '编辑模型';

  @override
  String get addModel => '新增模型';

  @override
  String get configureModelEndpoint => '配置一个模型入口';

  @override
  String get cloudDescription => '选择云厂商、填写 Key，然后从接口拉取可用模型';

  @override
  String get customUrlDescription => '填写兼容接口地址，确认协议格式后测试并保存';

  @override
  String get connection => '连接';

  @override
  String get connectionSource => '连接来源';

  @override
  String get cloudVendor => '云厂商';

  @override
  String get apiFormat => '协议格式';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get apiKey => 'API Key';

  @override
  String get keepExistingKey => '留空则保持已保存的 Key';

  @override
  String get modelId => '模型 ID';

  @override
  String get enableSwitch => '启用';

  @override
  String get setDefaultSwitch => '设为默认';

  @override
  String get helpTitle => '帮助';

  @override
  String get aboutOpenTavern => '关于 OpenTavern';

  @override
  String get currentSelected => '当前';

  @override
  String get modelLabel => '模型';

  @override
  String get paramsLabel => '参数';

  @override
  String get runtimeLogs => '运行日志';

  @override
  String get export => '导出';

  @override
  String get clearLogs => '清空';

  @override
  String get noLogsYet => '还没有日志';

  @override
  String get logsExported => '日志已导出';

  @override
  String get addPersona => '新增人设';

  @override
  String get editPersona => '编辑人设';

  @override
  String get personaNameHint => '例如：旅行者 / 指挥官 / 研究员';

  @override
  String get settingsSection => '设定';

  @override
  String get bio => '简介';

  @override
  String get bioHint => '对这个用户人设做简短描述';

  @override
  String get profilePromptLabel => '人设提示词';

  @override
  String get profilePromptHint => '写给模型的用户侧背景、口吻、身份、限制等';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => '英文';

  @override
  String get languageChinese => '中文';

  @override
  String get systemInterrupted => '上次回复因应用退出或页面重建而中断';

  @override
  String get systemSendFailed => '发送失败，点击重试';

  @override
  String get networkError => '网络连接失败，请检查 API 地址和网络';

  @override
  String get requestTimeout => '请求超时，请稍后重试';

  @override
  String get invalidApiKey => 'API Key 无效或已过期';

  @override
  String get rateLimited => '请求过于频繁，请稍后再试';

  @override
  String get serverError => '服务器错误，请稍后重试';

  @override
  String get unnamedCharacter => '未命名角色';

  @override
  String get missingNameWarning => '缺少名称，导入后将使用“未命名角色”';

  @override
  String get missingDescriptionWarning => '缺少 Description';

  @override
  String get missingFirstMessageWarning => '缺少 First Message';

  @override
  String get thinking => '思考中';

  @override
  String get thought => '已思考';

  @override
  String get cloudVendorModelExample => '例如：云厂商主力模型';

  @override
  String get customUrlExamplePrefix => '例如：自建';

  @override
  String get enterBaseUrlFirst => '先填写 Base URL';

  @override
  String get noModelsReturned => '没有返回模型';

  @override
  String get enterModelName => '请输入模型名称';

  @override
  String get enterBaseUrl => '请输入 Base URL';

  @override
  String get enterModelId => '请输入模型 ID';

  @override
  String get completeRequiredFields => '还有必填项未完成，保存前请先修正';

  @override
  String get availableModels => '可用模型';

  @override
  String get fetchingModels => '拉取中';

  @override
  String get fetchModels => '拉取模型';

  @override
  String get confirmConnectionThenFetch => '先确认连接信息，再点「拉取模型」自动填充可选模型列表';

  @override
  String get connectionFailed => '连接失败：无法连接到服务器，请检查 Base URL 是否正确，以及服务是否正在运行';

  @override
  String get originalError => '原始错误';

  @override
  String get requestTimeoutColon => '请求超时：服务器响应时间过长';

  @override
  String get requestCancelled => '请求已取消';

  @override
  String get authFailed => '认证失败：API Key 无效或缺失';

  @override
  String get permissionDenied => '权限不足：无权访问此资源';

  @override
  String get endpointNotFound => '接口不存在：请检查 Base URL 和接口类型是否匹配';

  @override
  String get rateLimitReached => '请求过于频繁：已达到速率限制';

  @override
  String get serverInternalError => '服务器内部错误';

  @override
  String get serviceUnavailable => '服务不可用：服务器暂时无法处理请求';

  @override
  String get fetchFailed => '拉取失败';
}
