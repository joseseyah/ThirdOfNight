import json

# Comprehensive translations dictionary
translations = {
    "Settings": {
        "en": "Settings",
        "ar": "الإعدادات",
        "ur": "ترتیبات",
        "ms": "Tetapan",
        "fil-PH": "Mga Setting"
    },
    "Tracker": {
        "en": "Tracker",
        "ar": "المتتبع",
        "ur": "ٹریکر",
        "ms": "Penjejak",
        "fil-PH": "Pagsubaybay"
    },
    "Qibla": {
        "en": "Qibla",
        "ar": "القبلة",
        "ur": "قبلہ",
        "ms": "Kiblat",
        "fil-PH": "Qibla"
    },
    "Summary": {
        "en": "Summary",
        "ar": "الملخص",
        "ur": "خلاصہ",
        "ms": "Ringkasan",
        "fil-PH": "Buod"
    },
    "Choose Language": {
        "en": "Choose Language",
        "ar": "اختر اللغة",
        "ur": "زبان منتخب کریں",
        "ms": "Pilih Bahasa",
        "fil-PH": "Pumili ng wika"
    },
    "Language": {
        "en": "Language",
        "ar": "اللغة",
        "ur": "زبان",
        "ms": "Bahasa",
        "fil-PH": "Wika"
    },
    "Travel Mode": {
        "en": "Travel Mode",
        "ar": "وضع السفر",
        "ur": "سفر کا موڈ",
        "ms": "Mod Perjalanan",
        "fil-PH": "Mode sa paglalakbay"
    },
    "Notifications": {
        "en": "Notifications",
        "ar": "الإشعارات",
        "ur": "اطلاعات",
        "ms": "Pemberitahuan",
        "fil-PH": "Mga notification"
    },
    "Legal": {
        "en": "Legal",
        "ar": "قانوني",
        "ur": "قانونی",
        "ms": "Undang-undang",
        "fil-PH": "Batas"
    },
    "About": {
        "en": "About",
        "ar": "حول",
        "ur": "کے بارے میں",
        "ms": "Mengenai",
        "fil-PH": "Tungkol"
    },
    "Allow notifications": {
        "en": "Allow notifications",
        "ar": "السماح بالإشعارات",
        "ur": "اطلاعات کی اجازت دیں",
        "ms": "Benarkan pemberitahuan",
        "fil-PH": "Payagan ang mga notification"
    },
    "Reminder time": {
        "en": "Reminder time",
        "ar": "وقت التذكير",
        "ur": "یاد دہانی کا وقت",
        "ms": "Masa peringatan",
        "fil-PH": "Oras ng paalala"
    },
    "Prayer-time alerts": {
        "en": "Prayer-time alerts",
        "ar": "تنبيهات وقت الصلاة",
        "ur": "نماز کے وقت کی اطلاعات",
        "ms": "Amaran waktu solat",
        "fil-PH": "Mga alerto sa oras ng panalangin"
    },
    "You're facing Makkah": {
        "en": "You're facing Makkah",
        "ar": "أنت تواجه مكة",
        "ur": "آپ مکہ کی طرف منہ کر رہے ہیں",
        "ms": "Anda menghadap Makkah",
        "fil-PH": "Nakaharap ka sa Makkah"
    },
    "to the Qibla from your current location": {
        "en": "to the Qibla from your current location",
        "ar": "إلى القبلة من موقعك الحالي",
        "ur": "آپ کے موجودہ مقام سے قبلہ کی طرف",
        "ms": "ke arah Kiblat dari lokasi semasa anda",
        "fil-PH": "sa Qibla mula sa iyong kasalukuyang lokasyon"
    },
    "Travel mode": {
        "en": "Travel mode",
        "ar": "وضع السفر",
        "ur": "سفر کا موڈ",
        "ms": "Mod perjalanan",
        "fil-PH": "Mode sa paglalakbay"
    },
    "Combining allowed": {
        "en": "Combining allowed",
        "ar": "السماح بالجمع",
        "ur": "ملاپ کی اجازت",
        "ms": "Penggabungan dibenarkan",
        "fil-PH": "Pinapayagan ang pagsasama"
    },
    "While travelling, combining prayers is permitted.": {
        "en": "While travelling, combining prayers is permitted.",
        "ar": "أثناء السفر، يُسمح بجمع الصلوات.",
        "ur": "سفر کے دوران، نمازوں کو ملا کر پڑھنا جائز ہے۔",
        "ms": "Semasa dalam perjalanan, menggabungkan solat adalah dibenarkan.",
        "fil-PH": "Habang naglalakbay, pinapayagan ang pagsasama ng mga pagdarasal."
    },
    "**Dhuhr** may be combined with **Asr**.": {
        "en": "**Dhuhr** may be combined with **Asr**.",
        "ar": "يمكن جمع **الظهر** مع **العصر**.",
        "ur": "**ظہر** کو **عصر** کے ساتھ ملا کر پڑھا جا سکتا ہے۔",
        "ms": "**Zohor** boleh digabungkan dengan **Asar**.",
        "fil-PH": "Maaaring pagsamahin ang **Dhuhr** at **Asr**."
    },
    "**Maghrib** may be combined with **Isha**.": {
        "en": "**Maghrib** may be combined with **Isha**.",
        "ar": "يمكن جمع **المغرب** مع **العشاء**.",
        "ur": "**مغرب** کو **عشاء** کے ساتھ ملا کر پڑھا جا سکتا ہے۔",
        "ms": "**Maghrib** boleh digabungkan dengan **Isha**.",
        "fil-PH": "Maaaring pagsamahin ang **Maghrib** at **Isha**."
    },
    "Your tracker highlights three groups: **Fajr** (single), **Dhuhr + Asr**, and **Maghrib + Isha** to reflect the allowed combinations.": {
        "en": "Your tracker highlights three groups: **Fajr** (single), **Dhuhr + Asr**, and **Maghrib + Isha** to reflect the allowed combinations.",
        "ar": "يبرز المتتبع ثلاث مجموعات: **الفجر** (منفرد)، **الظهر + العصر**، و **المغرب + العشاء** لتعكس التوليفات المسموح بها.",
        "ur": "آپ کا ٹریکر تین گروپس کو نمایاں کرتا ہے: **فجر** (اکیلے)، **ظہر + عصر**، اور **مغرب + عشاء** تاکہ اجازت شدہ ملاپ کو ظاہر کیا جا سکے۔",
        "ms": "Penjejak anda menyerlahkan tiga kumpulan: **Fajr** (tunggal), **Zohor + Asar**, dan **Maghrib + Isha** untuk mencerminkan kombinasi yang dibenarkan.",
        "fil-PH": "Ang iyong tracker ay nagha-highlight ng tatlong grupo: **Fajr** (single), **Dhuhr + Asr**, at **Maghrib + Isha** upang ipakita ang pinapayagang mga kombinasyon."
    },
    "Travel information": {
        "en": "Travel information",
        "ar": "معلومات السفر",
        "ur": "سفر کی معلومات",
        "ms": "Maklumat perjalanan",
        "fil-PH": "Impormasyon sa paglalakbay"
    },
    "Travel mode information. Dhuhr with Asr, Maghrib with Isha.": {
        "en": "Travel mode information. Dhuhr with Asr, Maghrib with Isha.",
        "ar": "معلومات وضع السفر. الظهر مع العصر، المغرب مع العشاء.",
        "ur": "سفر کے موڈ کی معلومات۔ ظہر عصر کے ساتھ، مغرب عشاء کے ساتھ۔",
        "ms": "Maklumat mod perjalanan. Zohor dengan Asar, Maghrib dengan Isha.",
        "fil-PH": "Impormasyon sa mode sa paglalakbay. Dhuhr kasama ang Asr, Maghrib kasama ang Isha."
    },
    "Support us": {
        "en": "Support us",
        "ar": "ادعمنا",
        "ur": "ہماری مدد کریں",
        "ms": "Sokong kami",
        "fil-PH": "Suportahan kami"
    },
    "Fajr Prayer Time": {
        "en": "Fajr Prayer Time",
        "ar": "وقت صلاة الفجر",
        "ur": "فجر کی نماز کا وقت",
        "ms": "Waktu Solat Fajr",
        "fil-PH": "Oras ng Panalangin ng Fajr"
    },
    "Dhuhr Prayer Time": {
        "en": "Dhuhr Prayer Time",
        "ar": "وقت صلاة الظهر",
        "ur": "ظہر کی نماز کا وقت",
        "ms": "Waktu Solat Zohor",
        "fil-PH": "Oras ng Panalangin ng Dhuhr"
    },
    "Asr Prayer Time": {
        "en": "Asr Prayer Time",
        "ar": "وقت صلاة العصر",
        "ur": "عصر کی نماز کا وقت",
        "ms": "Waktu Solat Asar",
        "fil-PH": "Oras ng Panalangin ng Asr"
    },
    "Maghrib Prayer Time": {
        "en": "Maghrib Prayer Time",
        "ar": "وقت صلاة المغرب",
        "ur": "مغرب کی نماز کا وقت",
        "ms": "Waktu Solat Maghrib",
        "fil-PH": "Oras ng Panalangin ng Maghrib"
    },
    "Isha Prayer Time": {
        "en": "Isha Prayer Time",
        "ar": "وقت صلاة العشاء",
        "ur": "عشاء کی نماز کا وقت",
        "ms": "Waktu Solat Isha",
        "fil-PH": "Oras ng Panalangin ng Isha"
    },
    "Sunrise Prayer Time": {
        "en": "Sunrise Prayer Time",
        "ar": "وقت شروق الشمس",
        "ur": "طلوع آفتاب کا وقت",
        "ms": "Waktu Matahari Terbit",
        "fil-PH": "Oras ng Pagsikat ng Araw"
    },
    "It's time for %@ prayer.": {
        "en": "It's time for %@ prayer.",
        "ar": "حان وقت صلاة %@.",
        "ur": "%@ کی نماز کا وقت ہو گیا ہے۔",
        "ms": "Sudah tiba masanya untuk solat %@.",
        "fil-PH": "Oras na para sa panalangin ng %@."
    }
}

print(f"Created translations dictionary with {len(translations)} keys")
