-- Live flyer prices: ₹40 / ₹45 per half litre = ₹80 / ₹90 per litre.
-- WhatsApp from the current order HTML + flyer (9087282939).

insert into products (
  key, name_en, name_hi, name_ta,
  breed_en, breed_hi, breed_ta,
  tagline_en, tagline_hi, tagline_ta,
  bullets, price_per_litre, price_per_half_litre, sort
) values
  (
    'cow',
    'A2 Cow Milk', 'A2 गाय का दूध', 'A2 பசும் பால்',
    'Sahiwal breed', 'साहीवाल नस्ल', 'சிவால் இனம்',
    'Light & gentle for everyday wellness',
    'रोज़ की सेहत के लिए हल्का और सौम्य',
    'தினசரி நலனுக்கு இலகுவான, மென்மையான பால்',
    '{
      "en": ["From Sahiwal breed", "Easy to digest", "Rich in calcium & nutrients", "100% natural & unprocessed"],
      "hi": ["साहीवाल नस्ल से", "पचने में आसान", "कैल्शियम और पोषक तत्वों से भरपूर", "100% प्राकृतिक, बिना प्रोसेस"],
      "ta": ["சிவால் இனத்திலிருந்து", "செரிமானத்திற்கு எளிது", "கால்சியம் மற்றும் ஊட்டச்சத்து நிறைந்தது", "100% இயற்கை, பதப்படுத்தப்படாதது"]
    }'::jsonb,
    80.00, 40.00, 1
  ),
  (
    'buffalo',
    'A2 Buffalo Milk', 'A2 भैंस का दूध', 'A2 எருமை பால்',
    'Murrah breed', 'मुर्रा नस्ल', 'முர்ரா இனம்',
    'Rich & nourishing for a stronger you',
    'मज़बूती के लिए गाढ़ा और पोषक',
    'வலுவான உடலுக்கு சத்தான, நிறைவான பால்',
    '{
      "en": ["From Murrah breed", "Naturally rich in fat & minerals", "Great taste & energy", "100% natural & unprocessed"],
      "hi": ["मुर्रा नस्ल से", "स्वाभाविक रूप से वसा और खनिजों से भरपूर", "स्वाद और ऊर्जा", "100% प्राकृतिक, बिना प्रोसेस"],
      "ta": ["முர்ரா இனத்திலிருந்து", "இயற்கையாகவே கொழுப்பு மற்றும் கனிமங்கள் நிறைந்தது", "சுவையும் சக்தியும்", "100% இயற்கை, பதப்படுத்தப்படாதது"]
    }'::jsonb,
    90.00, 45.00, 2
  );

insert into site_settings (key, value) values
  ('wa_number', '919087282939'),
  ('contact_email', 'meenakshidairyfarms@gmail.com'),
  ('upi_vpa', ''),
  ('upi_name', 'Meenakshi Dairy Farms');

insert into usps (sort, title_en, title_hi, title_ta) values
  (1, 'Naturally grazed on green fodder', 'हरे चारे पर चरते हैं', 'பசுந்தீவனத்தில் இயற்கையாக மேய்கின்றன'),
  (2, 'Direct from our farm — no middlemen', 'सीधे हमारे फार्म से — कोई बिचौलिया नहीं', 'எங்கள் பண்ணையிலிருந்து நேரடி — இடைத்தரகர் இல்லை'),
  (3, 'Ethical and humane animal care', 'नैतिक और दयालु पशु देखभाल', 'நெறிமுறை, அன்பான கால்நடைப் பராமரிப்பு'),
  (4, 'Freshly milked and handled hygienically', 'रोज़ दुहा, साफ़-सुथरे तरीके से संभाला', 'தினமும் கறந்து சுகாதாரமாக கையாளப்படுகிறது'),
  (5, 'Regular quality testing for purity and safety', 'शुद्धता और सुरक्षा के लिए नियमित जाँच', 'தூய்மை மற்றும் பாதுகாப்புக்கு வழக்கமான தரச் சோதனை'),
  (6, 'Supports local farmers and sustainable farming', 'स्थानीय किसानों और टिकाऊ खेती का साथ', 'உள்ளூர் விவசாயிகளுக்கும் நிலையான வேளாண்மைக்கும் ஆதரவு'),
  (7, 'Cold chain from farm to your home', 'फार्म से आपके घर तक कोल्ड चेन', 'பண்ணையிலிருந்து உங்கள் வீடு வரை குளிர்ச்சங்கிலி'),
  (8, 'Trusted by hundreds of families', 'सैकड़ों परिवारों का भरोसा', 'நூற்றுக்கணக்கான குடும்பங்களின் நம்பிக்கை');
