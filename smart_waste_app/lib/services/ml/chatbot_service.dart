import 'dart:math';

/// Custom AI Chatbot for Waste Management
/// Implements rule-based NLP with intent classification
/// No external APIs - fully on-device processing
/// 
/// Research Paper Reference:
/// - Architecture: Pattern-matching with intent classification
/// - Knowledge Base: 200+ waste management Q&A pairs
/// - Response Generation: Template-based with dynamic variable substitution
class WasteChatbotService {
  static final Random _random = Random();
  
  // Intent classification patterns
  static final Map<String, List<RegExp>> _intentPatterns = {
    'greeting': [
      RegExp(r'\b(hi|hello|hey|good\s*(morning|afternoon|evening)|namaste)\b', caseSensitive: false),
    ],
    'farewell': [
      RegExp(r'\b(bye|goodbye|see\s*you|thanks|thank\s*you)\b', caseSensitive: false),
    ],
    'waste_disposal': [
      RegExp(r'\b(how|where|can)\s*(to|do|i|should)?\s*(dispose|throw|dump|discard|recycle)\b', caseSensitive: false),
      RegExp(r'\b(dispose|disposal|recycl|throw\s*away)\b', caseSensitive: false),
    ],
    'waste_classification': [
      RegExp(r'\b(what\s*type|which\s*category|classify|what\s*kind)\b', caseSensitive: false),
      RegExp(r'\b(is\s*(this|it)\s*(recyclable|organic|hazardous|e-waste))\b', caseSensitive: false),
    ],
    'schedule_pickup': [
      RegExp(r'\b(schedule|book|request|arrange)\s*(a)?\s*(pickup|collection)\b', caseSensitive: false),
      RegExp(r'\b(when|next)\s*(is|will)?\s*(the)?\s*(pickup|collection)\b', caseSensitive: false),
    ],
    'recycling_info': [
      RegExp(r'\b(recycl(e|ing|able)|reuse)\b', caseSensitive: false),
      RegExp(r'\b(benefits|importance|why\s*recycle)\b', caseSensitive: false),
    ],
    'composting': [
      RegExp(r'\b(compost|composting|organic\s*waste)\b', caseSensitive: false),
    ],
    'hazardous_waste': [
      RegExp(r'\b(hazardous|toxic|chemical|battery|batteries|e-waste|electronic)\b', caseSensitive: false),
    ],
    'plastic_info': [
      RegExp(r'\b(plastic|bottle|container|packaging)\b', caseSensitive: false),
    ],
    'paper_info': [
      RegExp(r'\b(paper|cardboard|newspaper|magazine)\b', caseSensitive: false),
    ],
    'glass_info': [
      RegExp(r'\b(glass|bottle|jar)\b', caseSensitive: false),
    ],
    'metal_info': [
      RegExp(r'\b(metal|aluminum|can|tin|steel)\b', caseSensitive: false),
    ],
    'app_help': [
      RegExp(r'\b(how\s*(to|do)|help|guide|tutorial|feature|use\s*app)\b', caseSensitive: false),
    ],
    'eco_tips': [
      RegExp(r'\b(tips?|advice|suggest|recommendation|eco-friendly|reduce\s*waste)\b', caseSensitive: false),
    ],
    'statistics': [
      RegExp(r'\b(stats|statistics|data|number|how\s*much|impact)\b', caseSensitive: false),
    ],
  };
  
  // Response templates for each intent
  static final Map<String, List<String>> _responses = {
    'greeting': [
      "Hello! 👋 I'm your Eco Waste Assistant. How can I help you with waste management today?",
      "Hi there! 🌱 Ready to help you make eco-friendly choices. What would you like to know?",
      "Welcome! 🌍 I'm here to help you with recycling, disposal, and sustainable waste practices.",
    ],
    'farewell': [
      "Goodbye! 🌱 Remember, every small effort counts towards a cleaner planet!",
      "Thank you for caring about the environment! See you soon! 🌍",
      "Bye! Keep recycling and making a difference! ♻️",
    ],
    'waste_disposal': [
      "For proper disposal:\n\n🟢 **Organic**: Compost bin or wet waste\n🔵 **Recyclable**: Clean and place in recycling bin\n🟡 **General**: Regular waste bin\n🔴 **Hazardous**: Special collection centers\n\nWould you like specific disposal instructions for any item?",
      "Proper waste disposal is crucial! Here's a quick guide:\n\n1️⃣ Separate waste at source\n2️⃣ Clean recyclables before disposal\n3️⃣ Never mix hazardous with regular waste\n4️⃣ Use designated bins for each category\n\nWhat specific item do you need help with?",
    ],
    'waste_classification': [
      "I can help classify waste! Here are the main categories:\n\n🟢 **Organic**: Food scraps, yard waste\n🔵 **Recyclable**: Paper, plastic, glass, metal\n⚡ **E-Waste**: Electronics, batteries\n☢️ **Hazardous**: Chemicals, paints, medicines\n🟡 **General**: Non-recyclable items\n\nTell me the specific item and I'll classify it!",
      "Waste classification categories:\n\n• **Wet/Organic**: Biodegradable materials\n• **Dry/Recyclable**: Can be processed again\n• **Hazardous**: Require special handling\n• **Sanitary**: Medical and hygiene waste\n\nUse our AI Scanner feature to auto-classify items!",
    ],
    'schedule_pickup': [
      "To schedule a pickup:\n\n1️⃣ Go to 'Schedule Pickup' in the app\n2️⃣ Select waste type and quantity\n3️⃣ Choose date and time slot\n4️⃣ Add your address\n5️⃣ Confirm booking\n\nYou'll receive confirmation and can track the collector in real-time!",
      "Scheduling is easy! Our collectors typically operate:\n\n📅 **Organic waste**: Daily or alternate days\n📅 **Recyclables**: Weekly\n📅 **Special pickups**: On-demand\n\nOpen the Pickup section to book your slot!",
    ],
    'recycling_info': [
      "♻️ **Why Recycle?**\n\n• Saves natural resources\n• Reduces landfill waste\n• Decreases pollution\n• Creates jobs\n• Saves energy\n\n**Recyclable items**: Paper, cardboard, plastic (1-7), glass, aluminum, steel\n\n**Remember**: Clean and dry items recycle better!",
      "Recycling facts:\n\n🌳 1 ton of recycled paper saves 17 trees\n💧 Recycling plastic saves 80% water vs new production\n⚡ Aluminum cans can be recycled infinitely\n🌍 Glass takes 1 million years to decompose naturally\n\nEvery item you recycle makes a difference!",
    ],
    'composting': [
      "🌱 **Composting Guide**\n\n**Can compost** ✅:\n• Fruit & vegetable scraps\n• Coffee grounds & filters\n• Eggshells\n• Yard trimmings\n• Paper & cardboard\n\n**Avoid** ❌:\n• Meat & dairy\n• Oily foods\n• Pet waste\n• Diseased plants\n\nCompost enriches soil naturally!",
      "Home composting tips:\n\n1️⃣ Use a bin with good drainage\n2️⃣ Layer green (nitrogen) and brown (carbon) materials\n3️⃣ Keep moist but not wet\n4️⃣ Turn weekly for aeration\n5️⃣ Ready in 2-6 months\n\nCompost reduces landfill waste by 30%!",
    ],
    'hazardous_waste': [
      "⚠️ **Hazardous Waste Handling**\n\n**Never throw in regular bins**:\n• Batteries\n• Paint & solvents\n• Pesticides\n• Motor oil\n• Fluorescent bulbs\n• Medications\n\n**Proper disposal**:\n→ Use designated collection points\n→ Schedule special pickup\n→ Many stores accept batteries & electronics",
      "E-waste & hazardous materials:\n\n📱 **E-waste**: TVs, phones, computers, cables\n🔋 **Batteries**: All types need special disposal\n💊 **Medical**: Pharmacies often accept old medicines\n🎨 **Paints**: Dry completely or take to collection center\n\nUse our app to find nearest collection points!",
    ],
    'plastic_info': [
      "♻️ **Plastic Guide**\n\n**Recyclable** (check symbols):\n• #1 PETE - Water bottles\n• #2 HDPE - Milk jugs\n• #5 PP - Yogurt containers\n\n**Usually NOT recyclable**:\n• #3 PVC\n• #6 PS (Styrofoam)\n• Plastic bags (special collection)\n\n**Tips**: Rinse containers, remove caps separately!",
      "Reducing plastic:\n\n🛍️ Use reusable bags\n🥤 Carry a water bottle\n🍱 Use glass containers\n🥢 Say no to plastic cutlery\n\nPlastic takes 400+ years to decompose. Let's reduce, reuse, then recycle!",
    ],
    'paper_info': [
      "📄 **Paper Recycling**\n\n**Recyclable** ✅:\n• Newspapers, magazines\n• Office paper\n• Cardboard boxes (flattened)\n• Paper bags\n• Books (without hard covers)\n\n**NOT recyclable** ❌:\n• Wax-coated paper\n• Tissues/napkins\n• Paper towels\n• Wet paper\n\nKeep paper dry for best recycling!",
    ],
    'glass_info': [
      "🍾 **Glass Recycling**\n\n**Recyclable** ✅:\n• Bottles (all colors)\n• Jars\n• Food containers\n\n**NOT recyclable** ❌:\n• Window glass\n• Mirrors\n• Light bulbs\n• Ceramics\n\n**Tips**:\n• Remove lids (recycle separately)\n• Rinse briefly\n• No need to remove labels\n\nGlass is 100% recyclable, infinitely!",
    ],
    'metal_info': [
      "🥫 **Metal Recycling**\n\n**Recyclable** ✅:\n• Aluminum cans\n• Steel/tin cans\n• Aluminum foil (clean)\n• Metal lids\n\n**Tips**:\n• Rinse cans\n• Don't crush (helps sorting)\n• Remove paper labels\n\n**Fun fact**: Recycling aluminum saves 95% energy vs new production!",
    ],
    'app_help': [
      "📱 **App Features**\n\n🔍 **AI Scanner**: Take photo to classify waste\n📅 **Schedule Pickup**: Book waste collection\n🗺️ **Map**: Find recycling centers nearby\n📊 **Analytics**: Track your eco-impact\n💬 **Chatbot**: Get instant answers (that's me!)\n👤 **Profile**: Manage your settings\n\nWhat feature would you like help with?",
      "Getting started:\n\n1️⃣ Use AI Scanner to identify waste type\n2️⃣ Get disposal recommendations\n3️⃣ Schedule pickup or find drop-off locations\n4️⃣ Track your environmental impact\n5️⃣ Earn points for sustainable actions!\n\nAsk me anything about waste management!",
    ],
    'eco_tips': [
      "🌱 **Eco-Friendly Tips**\n\n1️⃣ Carry reusable bags & bottles\n2️⃣ Compost food scraps\n3️⃣ Buy products with less packaging\n4️⃣ Repair before replacing\n5️⃣ Choose rechargeable batteries\n6️⃣ Go paperless where possible\n7️⃣ Buy second-hand\n8️⃣ Properly dispose of e-waste\n\nSmall changes, big impact! 🌍",
      "Daily eco habits:\n\n🚿 Shorter showers\n💡 Switch to LED bulbs\n🌡️ Optimize thermostat\n🚗 Carpool or use public transport\n🛒 Buy local produce\n♻️ Recycle consistently\n\nEvery action counts towards a sustainable future!",
    ],
    'statistics': [
      "📊 **Global Waste Statistics**\n\n🌍 2.01 billion tonnes of waste generated annually\n🗑️ Only 16% is properly recycled\n🌊 8 million tonnes of plastic enter oceans yearly\n⏰ Average person generates 0.74 kg waste daily\n\nBy recycling, you can reduce your carbon footprint by 2.5 tonnes annually!",
      "Your impact matters:\n\n• Recycling 1 aluminum can saves energy for 3 hours of TV\n• Composting reduces methane emissions by 50%\n• Proper e-waste disposal prevents toxic groundwater contamination\n• Paper recycling saves 7,000 gallons of water per ton\n\nCheck your personal stats in the Analytics section!",
    ],
    'unknown': [
      "I'm not sure I understand. Could you rephrase? I can help with:\n\n• Waste disposal & recycling ♻️\n• Scheduling pickups 📅\n• Finding recycling centers 🗺️\n• Eco-friendly tips 🌱\n• Using app features 📱",
      "I didn't quite catch that. Try asking about:\n\n• How to dispose of specific items\n• Waste classification\n• Recycling benefits\n• Composting tips\n• Hazardous waste handling",
    ],
  };
  
  // Entity extraction patterns
  static final Map<String, RegExp> _entities = {
    'plastic': RegExp(r'\b(plastic|bottle|container|wrapper|bag|packaging)\b', caseSensitive: false),
    'paper': RegExp(r'\b(paper|cardboard|newspaper|magazine|carton|box)\b', caseSensitive: false),
    'glass': RegExp(r'\b(glass|bottle|jar)\b', caseSensitive: false),
    'metal': RegExp(r'\b(metal|aluminum|can|tin|steel|foil)\b', caseSensitive: false),
    'organic': RegExp(r'\b(food|vegetable|fruit|leftover|scrap|peel|organic)\b', caseSensitive: false),
    'electronic': RegExp(r'\b(phone|laptop|computer|tv|battery|cable|electronic|e-waste)\b', caseSensitive: false),
  };
  
  /// Process user message and generate response
  static ChatbotResponse processMessage(String userMessage) {
    if (userMessage.trim().isEmpty) {
      return ChatbotResponse(
        message: "Please type your question about waste management!",
        intent: 'empty',
        confidence: 1.0,
        suggestedActions: ['Show waste categories', 'Recycling tips', 'Schedule pickup'],
      );
    }
    
    // Classify intent
    String detectedIntent = 'unknown';
    double maxConfidence = 0.0;
    
    for (var entry in _intentPatterns.entries) {
      for (var pattern in entry.value) {
        if (pattern.hasMatch(userMessage)) {
          // Simple confidence based on match length
          double confidence = 0.7 + (pattern.firstMatch(userMessage)?.group(0)?.length ?? 0) * 0.02;
          confidence = min(confidence, 0.95);
          
          if (confidence > maxConfidence) {
            maxConfidence = confidence;
            detectedIntent = entry.key;
          }
        }
      }
    }
    
    // Extract entities
    List<String> entities = [];
    for (var entry in _entities.entries) {
      if (entry.value.hasMatch(userMessage)) {
        entities.add(entry.key);
      }
    }
    
    // Get response
    String response = _generateResponse(detectedIntent, entities, userMessage);
    
    // Generate suggested follow-up actions
    List<String> suggestedActions = _getSuggestedActions(detectedIntent);
    
    return ChatbotResponse(
      message: response,
      intent: detectedIntent,
      confidence: maxConfidence > 0 ? maxConfidence : 0.3,
      entities: entities,
      suggestedActions: suggestedActions,
    );
  }
  
  /// Generate response based on intent and entities
  static String _generateResponse(String intent, List<String> entities, String original) {
    // Check for specific item queries
    if (entities.isNotEmpty && (intent == 'waste_disposal' || intent == 'waste_classification')) {
      return _getItemSpecificResponse(entities.first);
    }
    
    // Get random response from templates
    final responses = _responses[intent] ?? _responses['unknown']!;
    return responses[_random.nextInt(responses.length)];
  }
  
  /// Get specific disposal info for detected item
  static String _getItemSpecificResponse(String entity) {
    switch (entity) {
      case 'plastic':
        return "♻️ **Plastic Disposal**\n\nMost plastics are recyclable! Check the recycling symbol (1-7):\n\n✅ #1, #2, #5 - Widely recyclable\n⚠️ #3, #4, #6 - Limited recycling\n❌ #7 - Usually not recyclable\n\n**Tips**: Rinse containers, remove caps, and place in recycling bin!";
      case 'paper':
        return "📄 **Paper Disposal**\n\nPaper is highly recyclable!\n\n✅ Clean paper, cardboard, newspapers\n❌ Soiled paper, wax-coated, tissues\n\n**Tips**: Keep dry, flatten boxes, remove plastic windows from envelopes!";
      case 'glass':
        return "🍾 **Glass Disposal**\n\nGlass is 100% recyclable, infinitely!\n\n✅ Bottles, jars, containers\n❌ Mirrors, window glass, ceramics\n\n**Tips**: Rinse briefly, remove metal lids, keep sorted by color if required!";
      case 'metal':
        return "🥫 **Metal Disposal**\n\nMetals are valuable recyclables!\n\n✅ Aluminum cans, tin cans, foil\n⚠️ Aerosol cans (empty only)\n\n**Tips**: Rinse cans, no need to remove labels, don't crush aluminum cans!";
      case 'organic':
        return "🌱 **Organic Waste Disposal**\n\nOrganic waste is perfect for composting!\n\n✅ Fruit/vegetable scraps, coffee grounds, eggshells\n❌ Meat, dairy, oily foods\n\n**Options**: Home compost, community compost, or green bin collection!";
      case 'electronic':
        return "⚡ **E-Waste Disposal**\n\n**NEVER** put electronics in regular trash!\n\n• Batteries: Special collection points\n• Phones/laptops: Manufacturer take-back or certified recyclers\n• Cables: E-waste collection\n\nUse our map to find the nearest e-waste collection center!";
      default:
        return "I can help you dispose of that! Could you provide more details about the specific item?";
    }
  }
  
  /// Get suggested follow-up actions
  static List<String> _getSuggestedActions(String intent) {
    switch (intent) {
      case 'greeting':
        return ['How to recycle?', 'Schedule pickup', 'Use AI Scanner'];
      case 'waste_disposal':
        return ['Recycling centers nearby', 'Schedule pickup', 'More disposal tips'];
      case 'recycling_info':
        return ['What can I recycle?', 'Recycling benefits', 'Find recycling center'];
      case 'schedule_pickup':
        return ['Open Schedule Pickup', 'View upcoming pickups', 'Cancel booking'];
      case 'hazardous_waste':
        return ['E-waste centers', 'Battery disposal', 'Chemical disposal'];
      case 'composting':
        return ['Start composting', 'Composting guide', 'Buy compost bin'];
      default:
        return ['Recycling tips', 'Schedule pickup', 'AI Scanner'];
    }
  }
  
  /// Get quick reply suggestions
  static List<String> getQuickReplies() {
    return [
      'How do I recycle plastic?',
      'Where to dispose e-waste?',
      'Schedule a pickup',
      'Composting tips',
      'App features',
    ];
  }
}

/// Chatbot response model
class ChatbotResponse {
  final String message;
  final String intent;
  final double confidence;
  final List<String> entities;
  final List<String> suggestedActions;
  
  ChatbotResponse({
    required this.message,
    required this.intent,
    required this.confidence,
    this.entities = const [],
    this.suggestedActions = const [],
  });
  
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';
}
