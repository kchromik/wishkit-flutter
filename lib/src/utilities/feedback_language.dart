import 'detected_language.dart';

/// Unicode scripts the detector can tell apart.
///
/// Dart forbids declaring an enum inside a class body, so this lives at the
/// top level.
enum _Script {
  latin,
  japanese,
  korean,
  chinese,
  cyrillic,
  arabic,
  greek,
  hebrew,
  devanagari,
  thai,
  unknown,
}

/// Detects whether user-generated feedback is written in a different language
/// than the one the app is running in.
///
/// ## Why this is not a straight port of the iOS implementation
///
/// The iOS SDK calls `NaturalLanguage`'s `NLLanguageRecognizer`, an on-device
/// statistical model. There is no equivalent in the Dart SDK, and shipping an
/// ML model would mean megabytes of weights — the opposite of iOS, where
/// detection is free and offline.
///
/// So this is a *heuristic* detector: Unicode script identification for
/// non-Latin scripts, weighted function-word matching for Latin ones. It is
/// deliberately conservative and returns `null` whenever it is not confident,
/// because a false positive puts a "See translation" button in front of a user
/// who does not need one, and a false negative only costs a user one extra tap.
///
/// ## Where this differs observably from iOS
///
/// * **Confidence is calibrated differently.** iOS requires 0.6 from
///   `NLLanguageRecognizer`'s probability. A function-word-hit ratio is not a
///   probability, so [_minimumLatinConfidence] is far lower and the score is
///   defined as matched words / total words.
/// * **Closely related languages tie.** Danish, Norwegian and Swedish share so
///   many function words that short samples often score identically. Ties are
///   treated as "not confident" rather than broken arbitrarily — see
///   [_detectLatin].
/// * **Han script discrimination uses a curated character list**, not a
///   statistical model, so short Traditional text with no marker character
///   degrades to a plain `zh` guess. That is harmless: `zh` still differs from
///   any non-Chinese app language, so the affordance still appears.
abstract final class FeedbackLanguage {
  /// Below this length detection is too unreliable ("Dark Mode"), so the text
  /// is treated as matching the app language. Matches iOS.
  static const int minimumTextLength = 10;

  /// Minimum share of words that must be known function words before a Latin
  /// script guess is accepted. See the class docs for why this is not 0.6.
  static const double _minimumLatinConfidence = 0.20;

  /// Minimum share of Han characters that must be script-specific before we
  /// commit to Simplified vs Traditional.
  static const double _minimumHanScriptConfidence = 0.10;

  // ---------------------------------------------------------------------
  // Character sets
  // ---------------------------------------------------------------------

  /// High-frequency characters that occur only in Simplified Chinese.
  ///
  /// Curated rather than exhaustive: these cover the overwhelming majority of
  /// real feedback text and a short list stays auditable. A false negative
  /// degrades to a plain `zh` guess, which is still actionable.
  ///
  /// Must not overlap with [_traditionalOnly] — `test/feedback_language_test.dart`
  /// asserts that it does not.
  static const String _simplifiedOnly = '们这说时会后动务车长门见马头买卖读写电话语汉'
      '单应变队列题严乐书亲价优传关兴养军农决划则刚创删别剧劝办劳势区医华协厂厅'
      '历压县参双发号叹吗听启吴员响团园围国图圆场坏块坚声处备复够夺奖妈孙学宁'
      '宝实宠审宫宽宾对寻导寿将尔尘尝层届属岁岛岭币帅师带帮广庄庆库庙废开异张'
      '弯强归当录彻径忆忧怀态总恋恳恶恼悦悬惊惧惨惯愤愿懒戏战户扎扑执扩扫扬'
      '扰抚抛抢护报担拟拢拣拥拦拨择挂挤挥捞损捡换捣据掷揽搁搂搅摄摆摇摊撑敌敛'
      '数斗断无旧显晒晓晕暂术机杀杂权条来杨极构枪柜标栈栋栏树样档桥桨桩梦检楼'
      '横樱欢欧残殡毕气汇汉汤沟没沥沦沧沪泪泻泼泽洁洒浅浆浇测济浓涂涌涛涡涤'
      '润涨涩淀渐渔渗温游湾湿滚滞满滤滥滨滩潜澜灭灯灵灾炉点炼烂烛烟烦烧烫热'
      '焕爱爷牵犹独狭狮狱猎猪猫献环现玺琐琼电画畅疗疯痒瘫瘾皱盏盐监盖盗盘睁'
      '瞒矫矿码砖砚础硕确碍碱礼祷祸禄禅离种积称秽税稳穷窃窍窑窜窝窥竖竞笃笋'
      '笔笼筑筛筹签简箩篮篱籁类粪粮紧纠红纤约级纪纬纯纱纲纳纵纷纸纹纺纽线练组'
      '绅细织终绊绍绎经绑绒结绕绘给绚络绝绞统绢绣继绩绪续绰绳维绵绷绸综绽绿'
      '缀缄缅缆缉缎缓缔缕编缘缚缝缠缩缭缴网罗罚罢羁翘耻聂聋职联聪肃肠肤肾胁胆'
      '胜脉脏脐脑脓脚脱脸腊腻腾舰舱艰艳艺节芜芦苇苍苏苹茎茧荆荐荚荞荟荡荣荤'
      '药莱莲获莹莺萝萤营萧萨葱蒋蓝蓟蓦蔷蔺蔼蕴虏虑虚虫虽虾蚀蚁蚂蚕蛮蛰蜗蜡'
      '蝇蝉补衬袄袜装裤观规觅视览觉誉计订认讨让训议讯记讲讳许论讼讽设访诀证'
      '评识诈诉诊词译试诗诚话诞询该详诫语误说请诸读课谁调谈谊谋谎谐谓谜谢谣'
      '谦谨谱贝贞负贡财责贤败账货质贩贪贫购贯贱贴贵贷贸费贺贼贾贿赁资赋赌赎'
      '赏赐赔赖赚赛赞赠赢赵赶趋跃践跷踊踪躯轧轨轩转轮软轰轴轻载轿较辅辆辈辉'
      '辐输辕辖辗辙辞辩辫边辽达迁过迈运还进远违连迟迹适选逊递逻遗遥邓邮郑酝'
      '酱酿释鉴针钉钊钌钍钎钏钐钒钓钗钙钛钝钞钟钠钡钢钥钦钧钨钩钮钱钳钴钵'
      '钻钾铀铁铂铃铅铆铉铎铐铑铕铛铜铝铠铡铢铣铤铧铨铩铫铬铭铮铰铲铳银铸'
      '铺链铿销锁锂锄锅锆锈锉锋锌锐锑错锚锗锡锢锣锤锥锦键锯锰锲锴锵锶锻镀镁'
      '镂镇镉镊镍镏镑镖镜镝镞镠镣镤镥镧镩镪镭镯镰镱镶闩闪闫闭问闯闰闲间闷闸'
      '闹闺闻闽阀阁阂阅阈阉阎阐阑阔阕阖阙队阳阴阵际陆陇陈陕陨险随隐隶难雏雾'
      '霉霭静韦韧韩韬韵页顶顷项顺须顽顾顿颁颂预领颇颈颊颌频颓颖颗颜额颠颤飘'
      '飙飞饥饪饭饮饰饱饲饴饵饶饺饼饿馄馅馆馈馋馒驭驮驯驰驱驳驴驶驸驹驻驼'
      '驾驿骁骂骄骆骇验骏骑骗骚骤骥髅鬓鱼鲁鲂鲅鲆鲇鲈鲋鲍鲜鲟鲠鲢鲤鲨鲫鲭鲮'
      '鲱鲲鲳鲵鲶鲷鲸鳄鳅鳆鳌鳍鳕鳖鳗鳜鳝鳞鸠鸡鸣鸥鸦鸨鸪鸫鸭鸯鸳鸵鸽鸾鸿鹃'
      '鹄鹅鹈鹉鹊鹏鹑鹕鹗鹘鹚鹛鹜鹝鹞鹣鹤鹦鹧鹩鹫鹬鹭鹰鹳麦麸黄黉黡黩黪鼋'
      '鼍鼹齐齿龀龁龂龃龄龅龆龇龈龉龊龋龌龙龚龛龟';

  /// High-frequency characters that occur only in Traditional Chinese.
  ///
  /// The Traditional counterpart of [_simplifiedOnly].
  static const String _traditionalOnly = '們這說時會後動務車長門見馬頭買賣讀寫電'
      '話語漢單應變隊階題嚴樂書親價優傳關興養軍農決劃則剛創刪別劇勸辦勞勢區醫'
      '華協廠廳歷壓縣參雙發號嘆嗎聽啟吳員響團園圍國圖圓場壞塊堅聲處備複夠'
      '奪獎媽孫學寧寶實寵審宮寬賓對尋導壽將爾塵嘗層屆屬歲島嶺幣帥師帶幫廣'
      '莊慶庫廟廢開異張彎強歸當錄徹徑憶憂懷態總戀懇惡惱悅懸驚懼慘慣憤願懶'
      '戲戰戶紮撲執擴掃揚擾撫拋搶護報擔擬攏揀擁攔撥擇掛擠揮撈損撿換搗據擲攬'
      '擱摟攪攝擺搖攤撐敵斂數鬥斷無舊顯曬曉暈暫術機殺雜權條來楊極構槍櫃標'
      '棧棟欄樹樣檔橋槳樁夢檢樓橫櫻歡歐殘殯畢氣匯漢湯溝沒瀝淪滄滬淚瀉潑澤潔'
      '灑淺漿澆測濟濃塗湧濤渦滌潤漲澀澱漸漁滲溫遊灣濕滾滯滿濾濫濱灘潛瀾滅'
      '燈靈災爐點煉爛燭煙煩燒燙熱煥愛爺牽猶獨狹獅獄獵豬貓獻環現璽瑣瓊電畫'
      '暢療瘋癢癱癮皺盞鹽監蓋盜盤睜瞞矯礦碼磚硯礎碩確礙鹼禮禱禍祿禪離種'
      '積稱穢稅穩窮竊竅窯竄窩窺豎競篤筍筆籠築篩籌簽簡籮籃籬籟類糞糧緊糾紅'
      '纖約級紀緯純紗綱納縱紛紙紋紡紐線練組紳細織終絆紹繹經綁絨結繞繪給絢絡'
      '絕絞統絹繡繼績緒續綽繩維綿綳綢綜綻綠綴緘緬纜緝緞緩締縷編緣縛縫纏縮繚'
      '繳網羅罰罷羈翹恥聶聾職聯聰肅腸膚腎脅膽勝脈臟臍腦膿腳脫臉臘膩騰艦艙'
      '艷藝節蕪蘆葦蒼蘇蘋莖繭荊薦莢蕎薈蕩榮葷藥萊蓮獲瑩鶯蘿螢營蕭薩蔥蔣藍'
      '薊驀薔藺藹蘊虜慮虛蟲雖蝦蝕蟻螞蠶蠻蟄蝸蠟蠅蟬補襯襖襪裝褲觀規覓視'
      '覽覺譽計訂認討讓訓議訊記講諱許論諷設訪訣證評識詐訴診詞譯試詩誠話誕'
      '詢該詳誡語誤說請諸讀課誰調談誼謀謊諧謂謎謝謠謙謹譜貝貞負貢財責賢敗賬'
      '貨質販貪貧購貫賤貼貴貸貿費賀賊賈賄賃資賦賭贖賞賜賠賴賺賽贊贈贏趙趕趨'
      '躍踐蹺踴蹤軋軌軒轉輪軟轟軸輕載轎較輔輛輩輝輻輸轅轄輾轍辭辯辮邊遼達'
      '遷過邁運還進遠違連遲跡適選遜遞邏遺遙鄧郵鄭醞醬釀釋鑑針釘釗釕釷釺釧釤'
      '釩釣釵鈣鈦鈍鈔鐘鈉鋇鋼鑰欽鈞鎢鉤鈕錢鉗鈷缽鑽鉀鈾鐵鉑鈴鉛鉚鉉鐸銬銠'
      '銪鐺銅鋁鎧鍘銖銑鋌鏵銓鎩銚鉻銘錚鉸鏟銃銀鑄鋪鏈鏗銷鎖鋤鍋鋯鏽銼鋒鋅'
      '銳銻錯錨鍺錫錮鑼錘錐錦鍵鋸錳鍥鍇鏘鍶鍛鍍鎂鏤鎮鎘鑷鎳鎦鎊鏢鏡鏑鏃鏐'
      '鐐鏷鑥鑭鑹鐙鐝鏷鐲鐮鐿鑲閂閃閆閉問闖閏閑間悶閘鬧閨聞閩閥閣閡閱閾'
      '閹閻闡闌闊闋闔闕隊陽陰陣際陸隴陳陝隕險隨隱隸難雛霧黴靄靜韋韌韓韜韻頁'
      '頂頃項順須頑顧頓頒頌預領頗頸頰頜頻頹穎顆顏額顛顫飄飆飛飢飪飯飲飾飽飼'
      '飴餌饒餃餅餓餛餡館饋饞饅馭馱馴馳驅駁驢駛駙駒駐駝駕驛驍罵驕駱駭驗駿'
      '騎騙騷驟驥髏鬢魚魯魴鮁鮃鯰鱸鮒鮑鮮鱘鯁鰱鯉鯊鯽鯖鯪鯡鯤鯧鯢鯰鯛鯨鱷'
      '鰍鰒鰲鰭鱈鱉鰻鱖鱔鱗鳩雞鳴鷗鴉鴇鴣鶇鴨鴦鴛鴕鴿鸞鴻鵑鵠鵝鵜鵡鵲鵬鶉鶘'
      '鶚鶻鶿鶥鶩鷊鷂鶼鶴鸚鷓鷚鷲鷺鷹鸛麥麩黃黌黶黷黲黿鼉鼴齊齒齔齕齗齟齡齙'
      '齠齜齦齬齪齲齷龍龔龕龜';

  /// Function words per Latin-script language, stored as *stems*.
  ///
  /// A word counts as a hit when it is exactly [stem], or when it starts with
  /// [stem] and is at least two characters longer. That extension is what makes
  /// inflected languages work at all — `aplicación`/`aplicaciones` for Spanish,
  /// `sovellus`/`sovellukseen` for Finnish — while the two-character margin
  /// stops short stems from bleeding across languages (`favor` must not match
  /// Italian `favore`, `de` must not match French `déjà`).
  ///
  /// Stems shorter than five characters are matched exactly. Short function
  /// words are the backbone of their language, so they are also the ones most
  /// likely to be a false positive if extended.
  static const Map<String, Set<String>> _functionWords = {
    'en': {
      'the', 'and', 'is', 'it', 'of', 'to', 'in', 'for', 'with', 'that',
      'this', 'you', 'are', 'was', 'have', 'not', 'but', 'from', 'would',
      'can', 'could', 'should', 'please', 'want', 'need', 'like', 'when',
      'feature', 'request', 'app', 'application', 'add', 'make', 'support',
      'there', 'here', 'also', 'just', 'does', 'what', 'why', 'how', 'about',
    },
    'de': {
      'der', 'die', 'das', 'und', 'ist', 'nicht', 'ein', 'eine', 'einen', 'mit',
      'für', 'auf', 'von', 'ich', 'wir', 'auch', 'aber', 'wenn', 'dass', 'bitte',
      'wäre', 'könn', 'schon', 'wunsch', 'wünsch', 'funktion', 'app', 'feature',
      'hinzu', 'danke', 'gern', 'möchte', 'sollte', 'haben', 'werden', 'sehr',
      'gute', 'nütz',
    },
    'es': {
      'el', 'la', 'de', 'que', 'por', 'con', 'para', 'una', 'los', 'las',
      'como', 'más', 'pero', 'este', 'esta', 'muy', 'cuando', 'porque',
      'puede', 'sería', 'quiero', 'necesito', 'solicitud', 'función', 'app',
      'favor', 'gracias', 'también', 'está', 'hacer', 'añade', 'añadir',
      'aplicación', 'sigo', 'estoy',
    },
    'fr': {
      'le', 'de', 'un', 'une', 'et', 'à', 'il', 'elle', 'ne', 'je', 'son',
      'que', 'qui', 'ce', 'dans', 'du', 'au', 'pour', 'pas', 'vous', 'par',
      'sur', 'faire', 'plus', 'avec', 'tout', 'mais', 'est', 'merci',
      'besoin', 'vouloir', 'voudr', 'fonctionnalité', 'application', 'souhait',
      'cette', 'pourquoi', 'comment', 'j\'aimerais', 'pouvoir', 'améliorer',
    },
    'it': {
      'il', 'di', 'che', 'e', 'la', 'per', 'in', 'un', 'è', 'non', 'una',
      'con', 'si', 'sono', 'da', 'lo', 'le', 'come', 'più', 'ma', 'questo',
      'fare', 'quando', 'dove', 'perché', 'può', 'vorrei', 'bisogno',
      'funzionalità', 'applicazione', 'grazie', 'favore', 'essere', 'anche',
      'aggiungi', 'maggior', 'miglior',
    },
    'nl': {
      'de', 'het', 'een', 'en', 'van', 'is', 'dat', 'in', 'te', 'niet', 'op',
      'zijn', 'met', 'voor', 'aan', 'als', 'maar', 'door', 'ook', 'naar',
      'bij', 'nog', 'geen', 'kunnen', 'willen', 'hebben', 'zou', 'graag',
      'functie', 'applicatie', 'bedankt', 'waarom', 'hoe', 'wanneer', 'ik',
      'wil', 'voeg', 'appen', 'toevoeg',
    },
    'pt': {
      'de', 'que', 'não', 'para', 'com', 'uma', 'dos', 'das', 'por', 'você',
      'está', 'são', 'como', 'mais', 'mas', 'ao', 'isso', 'quero', 'preciso',
      'aplicação', 'funcionalidade', 'obrigado', 'favor', 'quando', 'onde',
      'porque', 'pode', 'seria', 'fazer', 'muito', 'aplicativo', 'adicio',
      'gostaria', 'gosto', 'teria',
    },
    'sv': {
      'och', 'att', 'det', 'som', 'en', 'på', 'är', 'av', 'för', 'med', 'till',
      'den', 'har', 'inte', 'om', 'ett', 'men', 'var', 'jag', 'från', 'vi',
      'så', 'kan', 'när', 'där', 'hur', 'vad', 'vill', 'skulle', 'gärna',
      'tack', 'funktion', 'applikation', 'behöver', 'mycket', 'även', 'bra',
      'göra', 'lägga',
    },
    'da': {
      'og', 'at', 'det', 'en', 'den', 'til', 'er', 'som', 'på', 'med', 'af',
      'for', 'ikke', 'der', 'var', 'han', 'men', 'et', 'har', 'om', 'vi',
      'kan', 'når', 'hvor', 'hvad', 'skal', 'vil', 'kunne', 'ind', 'være',
      'funktion', 'app', 'tak', 'gerne', 'meget', 'ogsa', 'jeg', 'min',
      'venligst', 'mørk',
    },
    'nb': {
      'og', 'i', 'det', 'på', 'som', 'en', 'til', 'er', 'av', 'for', 'med',
      'ikke', 'om', 'var', 'han', 'men', 'et', 'har', 'vi', 'fra', 'så', 'kan',
      'når', 'hvor', 'hva', 'skal', 'vil', 'bli', 'kunne', 'funksjon', 'app',
      'takk', 'gjerne', 'mye', 'også', 'jeg', 'min', 'dere', 'meget',
      'vennligst', 'legg', 'appen', 'mørk',
    },
    'fi': {
      'ja', 'on', 'ei', 'se', 'että', 'oli', 'hän', 'mutta', 'niin', 'kuin',
      'jos', 'kun', 'tai', 'ovat', 'myös', 'vain', 'tämä', 'tämän', 'koska',
      'jo', 'sekä', 'sekään', 'eli', 'kaikki', 'voi', 'pitää', 'saada',
      'tehdä', 'olis', 'olisin', 'halua', 'haluan', 'lisätä', 'toivomus',
      'ominaisuus', 'sovellus', 'kiitos', 'tarvitsen', 'tärkeä', 'yksi',
    },
    'pl': {
      'nie', 'na', 'z', 'do', 'to', 'że', 'się', 'jak', 'tak', 'ale', 'po',
      'za', 'dla', 'od', 'być', 'jest', 'czy', 'już', 'bardzo', 'można',
      'chcę', 'potrzebuję', 'proszę', 'dziękuję', 'funkcja', 'aplikac',
      'oraz', 'lub', 'więc', 'gdy', 'kiedy', 'dlaczego', 'wolałbym', 'jestem',
      'dodać', 'ważne', 'również',
    },
    'tr': {
      've', 'bir', 'bu', 'için', 'ile', 'de', 'da', 'çok', 'daha', 'olan',
      'olarak', 'ama', 'her', 'ben', 'istiyorum', 'lazım', 'lütfen',
      'teşekkür', 'özellik', 'uygulama', 'ancak', 'veya', 'gibi', 'sonra',
      'önce', 'ne', 'var', 'yok', 'değil', 'mi', 'mı', 'istiyoruz', 'ekleyin',
      'ekle', 'gerekli',
    },
    'id': {
      'yang', 'dan', 'di', 'untuk', 'dengan', 'ini', 'itu', 'dari', 'tidak',
      'akan', 'pada', 'adalah', 'saya', 'ingin', 'perlu', 'bisa', 'tolong',
      'terima', 'kasih', 'fitur', 'aplikasi', 'tetapi', 'atau', 'ketika',
      'sangat', 'sudah', 'boleh', 'mohon', 'tambahkan', 'penting',
    },
    'vi': {
      'và', 'của', 'là', 'có', 'được', 'cho', 'không', 'trong', 'một', 'các',
      'những', 'với', 'để', 'tôi', 'muốn', 'cần', 'xin', 'cảm', 'ơn',
      'tính', 'năng', 'ứng', 'dụng', 'nhưng', 'hoặc', 'khi', 'nào', 'rất',
      'hãy', 'thêm', 'thành', 'vào', 'tối', 'chế', 'độ', 'chúng', 'quý',
      'vấn', 'quan', 'trọng',
    },
  };

  /// Stems of at least this length may match as a prefix of a longer word.
  static const int _prefixStemLength = 5;

  /// A prefix stem must be followed by at least this many characters, which
  /// keeps `favor` from matching Italian `favore`.
  static const int _prefixExtraLength = 2;

  // ---------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------

  /// Codepoints that mark Simplified Chinese.
  ///
  /// Exposed so `test/feedback_language_test.dart` can assert the two marker
  /// sets are disjoint. An overlap would make a character count for both
  /// scripts at once and every detection would collapse onto `zh-Hans`.
  static Set<int> get simplifiedMarkers => _simplifiedOnly.runes.toSet();

  /// Codepoints that mark Traditional Chinese. See [simplifiedMarkers].
  static Set<int> get traditionalMarkers => _traditionalOnly.runes.toSet();

  /// Whether [text] appears to be written in a language other than the app's.
  ///
  /// Returns `false` whenever detection is not confident, which is the same
  /// outcome as iOS: no translate affordance.
  static bool differsFromAppLanguage(
    String text, {
    required String appLanguage,
    String? appScript,
  }) {
    final detected = dominantLanguage(text);
    if (detected == null) return false;
    return !matches(detected, appLanguage, appScript);
  }

  /// Guesses the language of [text], or `null` when not confident.
  static DetectedLanguage? dominantLanguage(String text) {
    final trimmed = text.trim();
    if (trimmed.length < minimumTextLength) return null;

    switch (_dominantScript(trimmed)) {
      case _Script.latin:
        return _detectLatin(trimmed);
      case _Script.japanese:
        return const DetectedLanguage(languageCode: 'ja', confidence: 0.9);
      case _Script.korean:
        return const DetectedLanguage(languageCode: 'ko', confidence: 0.9);
      case _Script.chinese:
        return _detectHan(trimmed);
      // Scripts WishKit has no translation bundle for. iOS would still offer
      // to translate these, so report them as a distinct language rather than
      // returning null — that is what makes the button appear.
      case _Script.cyrillic:
        return const DetectedLanguage(languageCode: 'ru', confidence: 0.85);
      case _Script.arabic:
        return const DetectedLanguage(languageCode: 'ar', confidence: 0.85);
      case _Script.greek:
        return const DetectedLanguage(languageCode: 'el', confidence: 0.85);
      case _Script.hebrew:
        return const DetectedLanguage(languageCode: 'he', confidence: 0.85);
      case _Script.devanagari:
        return const DetectedLanguage(languageCode: 'hi', confidence: 0.85);
      case _Script.thai:
        return const DetectedLanguage(languageCode: 'th', confidence: 0.85);
      case _Script.unknown:
      case null:
        return null;
    }
  }

  /// Whether a detected language counts as the app's language.
  ///
  /// Mirrors iOS's `FeedbackLanguage.matches`: language codes must match, and
  /// scripts only break a match when *both* sides have one, so `zh-Hans`
  /// feedback does not match a `zh` app but `zh` feedback matches a `zh-Hant`
  /// app that carries no script.
  static bool matches(
    DetectedLanguage detected,
    String appLanguage, [
    String? appScript,
  ]) {
    if (detected.languageCode != appLanguage) return false;
    if (appScript == null || detected.scriptCode == null) return true;
    return detected.scriptCode == appScript;
  }

  // ---------------------------------------------------------------------
  // Script identification
  // ---------------------------------------------------------------------

  /// Counts letters per script and returns the winner.
  ///
  /// Japanese is scored on kana only and Korean on hangul only, so shared
  /// Kanji cannot make a Japanese sentence look Chinese.
  static _Script? _dominantScript(String text) {
    var latin = 0, kana = 0, hangul = 0, han = 0;
    var cyrillic = 0, arabic = 0, greek = 0, hebrew = 0, devanagari = 0;
    var thai = 0;

    for (final rune in text.runes) {
      if ((rune >= 0x3040 && rune <= 0x309F) || // Hiragana
          (rune >= 0x30A0 && rune <= 0x30FF) || // Katakana
          (rune >= 0x31F0 && rune <= 0x31FF)) {
        // Katakana Phonetic Extensions.
        kana++;
      } else if ((rune >= 0xAC00 && rune <= 0xD7AF) || // Hangul syllables
          (rune >= 0x1100 && rune <= 0x11FF) || // Hangul Jamo
          (rune >= 0x3130 && rune <= 0x318F)) {
        // Hangul Compatibility Jamo.
        hangul++;
      } else if ((rune >= 0x4E00 && rune <= 0x9FFF) || // CJK Unified
          (rune >= 0x3400 && rune <= 0x4DBF) || // Extension A
          (rune >= 0xF900 && rune <= 0xFAFF)) {
        // CJK Compatibility Ideographs.
        han++;
      } else if (_isLatinLetter(rune)) {
        latin++;
      } else if (rune >= 0x0400 && rune <= 0x04FF) {
        cyrillic++;
      } else if (rune >= 0x0600 && rune <= 0x06FF) {
        arabic++;
      } else if (rune >= 0x0370 && rune <= 0x03FF) {
        greek++;
      } else if (rune >= 0x0590 && rune <= 0x05FF) {
        hebrew++;
      } else if (rune >= 0x0900 && rune <= 0x097F) {
        devanagari++;
      } else if (rune >= 0x0E00 && rune <= 0x0E7F) {
        thai++;
      }
    }

    final candidates = <_Script, int>{
      if (kana > 0) _Script.japanese: kana,
      if (hangul > 0) _Script.korean: hangul,
      if (han > 0) _Script.chinese: han,
      if (latin > 0) _Script.latin: latin,
      if (cyrillic > 0) _Script.cyrillic: cyrillic,
      if (arabic > 0) _Script.arabic: arabic,
      if (greek > 0) _Script.greek: greek,
      if (hebrew > 0) _Script.hebrew: hebrew,
      if (devanagari > 0) _Script.devanagari: devanagari,
      if (thai > 0) _Script.thai: thai,
    };
    if (candidates.isEmpty) return _Script.unknown;

    // A stray accented character in an otherwise Cyrillic sentence should not
    // flip the result, so require a clear majority of *letter* characters.
    final total = candidates.values.fold<int>(0, (a, b) => a + b);
    final ranked = candidates.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (ranked.first.value / total < 0.5) return _Script.unknown;
    return ranked.first.key;
  }

  /// ASCII, Latin-1 Supplement, Latin Extended-A/B and Latin Extended
  /// Additional, plus combining marks.
  ///
  /// The range past `U+024F` is not decoration: Vietnamese `ệ`, `ộ`, `ố` and
  /// `ụ` all live in Latin Extended Additional, and dropping them would split
  /// Vietnamese words into fragments.
  static bool _isLatinLetter(int rune) {
    return (rune >= 0x0041 && rune <= 0x005A) || // A-Z
        (rune >= 0x0061 && rune <= 0x007A) || // a-z
        (rune >= 0x00C0 && rune <= 0x024F) || // Latin-1 Sup + Extended-A/B
        (rune >= 0x1E00 && rune <= 0x1EFF) || // Latin Extended Additional
        (rune >= 0x0300 && rune <= 0x036F); // Combining Diacritical Marks
  }

  // ---------------------------------------------------------------------
  // Per-script refinement
  // ---------------------------------------------------------------------

  /// Scores Latin text against the function-word tables.
  static DetectedLanguage? _detectLatin(String text) {
    final words = _tokenize(text);
    if (words.isEmpty) return null;

    var best = '';
    var bestHits = 0;
    var ties = 0;

    for (final entry in _functionWords.entries) {
      final hits = words
          .where((word) => entry.value.any((stem) => _matchesStem(word, stem)))
          .length;
      if (hits > bestHits) {
        bestHits = hits;
        best = entry.key;
        ties = 1;
      } else if (hits == bestHits && bestHits > 0) {
        ties++;
      }
    }

    if (bestHits == 0) return null;

    // Danish, Norwegian and Swedish are mutually unintelligible to a word list
    // this small. When two languages score identically we genuinely do not
    // know, and guessing wrong hides a button the user needs — so bail out.
    if (ties > 1) return null;

    final confidence = bestHits / words.length;
    if (confidence < _minimumLatinConfidence) return null;

    return DetectedLanguage(languageCode: best, confidence: confidence);
  }

  /// Splits [text] into lowercased Latin words.
  ///
  /// A hand-rolled scanner rather than a regex because the interesting ranges
  /// (`1E00`–`1EFF` for Vietnamese, `00C0`–`0FFF` for European languages) are
  /// not expressible as a tidy character class without either a `unicode`
  /// dependency or a maintenance hazard.
  static List<String> _tokenize(String text) {
    final words = <String>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        words.add(buffer.toString());
        buffer.clear();
      }
    }

    for (final rune in text.toLowerCase().runes) {
      if (_isLatinLetter(rune)) {
        buffer.writeCharCode(rune);
      } else {
        // Combining marks attach to the preceding letter rather than starting
        // a new word, so they must not break the token.
        final isMark = rune >= 0x0300 && rune <= 0x036F;
        if (!isMark || buffer.isEmpty) flush();
        if (isMark && buffer.isNotEmpty) buffer.writeCharCode(rune);
      }
    }
    flush();
    return words;
  }

  /// Whether [word] is or starts with [stem].
  static bool _matchesStem(String word, String stem) {
    if (word == stem) return true;
    if (stem.length < _prefixStemLength) return false;
    if (!word.startsWith(stem)) return false;
    return word.length >= stem.length + _prefixExtraLength;
  }

  /// Separates Simplified from Traditional Chinese by marker-character share.
  static DetectedLanguage? _detectHan(String text) {
    var simplified = 0, traditional = 0, total = 0;
    for (final rune in text.runes) {
      if (rune < 0x4E00 || rune > 0x9FFF) continue;
      total++;
      if (_simplifiedOnly.runes.contains(rune)) simplified++;
      if (_traditionalOnly.runes.contains(rune)) traditional++;
    }

    // No Han characters at all means kana or hangul already won the script
    // contest and we should not be here.
    if (total == 0) {
      return const DetectedLanguage(languageCode: 'zh', confidence: 0.5);
    }

    final markers = simplified + traditional;
    if (markers == 0 || markers / total < _minimumHanScriptConfidence) {
      return DetectedLanguage(
        languageCode: 'zh',
        confidence: markers == 0 ? 0.6 : 0.7,
      );
    }

    final isSimplified = simplified >= traditional;
    return DetectedLanguage(
      languageCode: 'zh',
      scriptCode: isSimplified ? 'Hans' : 'Hant',
      confidence: markers / total,
    );
  }
}
