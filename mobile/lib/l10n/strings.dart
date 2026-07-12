import 'app_language.dart';

class S {
  static const Map<String, String> _en = {
    'checking': 'Checking your fish...',
    'title': 'Take a photo of\nyour fish',
    'subtitle': 'We will check if it is healthy or sick,\nand tell you what to do.',
    'open_camera': 'Open Camera',
    'choose_gallery': 'Choose from Gallery',
    'result': 'Result',
    'healthy_fish': 'Healthy Fish',
    'disease_found': 'Disease Found',
    'possible': 'Possible',
    'confidence_note': "confidence — not fully certain, use as a guide",
    'what_it_means': 'What it means',
    'signs_to_look_for': 'Signs to look for',
    'what_to_do': 'What to do',
    'how_to_prevent': 'How to prevent',
    'check_another': 'Check Another Fish',
  };

  static const Map<String, String> _bn = {
    'checking': 'আপনার মাছ পরীক্ষা করা হচ্ছে...',
    'title': 'আপনার মাছের\nছবি তুলুন',
    'subtitle': 'আমরা দেখব এটি সুস্থ নাকি অসুস্থ,\nএবং কী করতে হবে তা জানাব।',
    'open_camera': 'ক্যামেরা খুলুন',
    'choose_gallery': 'গ্যালারি থেকে বেছে নিন',
    'result': 'ফলাফল',
    'healthy_fish': 'সুস্থ মাছ',
    'disease_found': 'রোগ শনাক্ত হয়েছে',
    'possible': 'সম্ভবত',
    'confidence_note': 'নিশ্চয়তা — পুরোপুরি নিশ্চিত নয়, নির্দেশিকা হিসেবে ব্যবহার করুন',
    'what_it_means': 'এর অর্থ কী',
    'signs_to_look_for': 'যেসব লক্ষণ দেখবেন',
    'what_to_do': 'কী করতে হবে',
    'how_to_prevent': 'কীভাবে প্রতিরোধ করবেন',
    'check_another': 'আরেকটি মাছ পরীক্ষা করুন',
  };

  static String of(String key, [AppLanguage? lang]) {
    final l = lang ?? appLanguage.value;
    final table = l == AppLanguage.bn ? _bn : _en;
    return table[key] ?? _en[key] ?? key;
  }
}
