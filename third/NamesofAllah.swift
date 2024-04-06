//"الله"
//  NamesofAllah.swift
//  third
//
//  Created by Joseph Hayes on 06/04/2024.
//

import Foundation

import SwiftUI

struct NamesOfAllah {
    static let data: [(arabicName: String, name: String, transliteration: String, definition: String)] = [
        ("الل َّھ", "Allah", "Allah", "The only one Almighty. He alone is worthy of worship"),
        ("الر َّحْمَنُ", "Ar-Rahman", "Ar-Rahman", "He who wills goodness and mercy for all His creatures"),
        ("الر َّحِیمُ", "Ar-Rahim", "Ar-Rahim", "He who acts with extreme kindness"),
        ("الَْملِكُ", "Al-Malik", "Al-Malik", "The Sovereign Lord, The One with the complete Dominion, the One Whose Dominion is clear from imperfection"),
        ("الُْقد ُّوسُ", "Al-Quddus", "Al-Quddus", "The One who is pure from any imperfection and clear from children and adversaries"),
        ("ال َّسلاَمُ", "As-Salam", "As-Salam", "The One who is free from every imperfection."),
        ("الُْمؤْمِنُ", "Al-Mu'min", "Al-Mu'min", "The One who witnessed for Himself that no one is God but Him. And He witnessed for His believers that they are truthful in their belief that no one is God but Him"),
        ("الْمُھَیْمِنُ", "Al-Muhaymin", "Al-Muhaymin", "The One who witnesses the saying and deeds of His creatures"),
        ("الْعَزِیزُ", "Al-'Aziz", "Al-'Aziz", "The Strong, The Defeater who is not defeated"),
        ("الْجَب َّارُ", "Al-Jabbar", "Al-Jabbar", "The One that nothing happens in His Dominion except that which He willed"),
        ("الْمُتَكَب ِّرُ", "Al-Mutakabbir", "Al-Mutakabbir", "The One who is clear from the attributes of the creatures and from resembling them."),
        ("الْخَالِقُ", "Al-Khaaliq", "Al-Khaaliq", "The One who brings everything from non- existence to existence"),
        ("الْبَارِئُ", "Al-Baari'", "Al-Baari'", "The Maker, The Creator who has the Power to turn the entities."),
        ("الُْم َصو ِّرُ", "Al-Musawwir", "Al-Musawwir", "The One who forms His creatures in different pictures."),
        ("الْغَف َّارُ", "Al-Ghaffaar", "Al-Ghaffaar", "The Forgiver, The One who forgives the sins of His slaves time and time again."),
        ("الْقَھ َّارُ", "Al-Qahhaar", "Al-Qahhaar", "The Dominant, The One who has the perfect Power and is not unable over anything."),
        // Additional names
        ("اْلوَھ َّابُ", "Al-Wahhab", "Al-Wahhab", "The One who is Generous in giving without any return. He is everything that benefits whether Halal or Haram."),
        ("الر َّز َّاق", "Ar-Razzaq", "Ar-Razzaq", "The Sustainer, The Provider."),
        ("الْفَت َّاحُ", "Al-Fattah", "Al-Fattah", "The Opener, The Reliever, The Judge, The One who opens for His slaves the closed worldy and religious matters."),
        ("العَاِیمُ", "Al-'Alim", "Al-'Alim", "The Knowledgeable; The One nothing is absent from His knowledge"),
        ("الْقَابِضُ", "Al-Qaabid", "Al-Qaabid", "The Constricter, The Withholder, The One who constricts the sustenance by His wisdomand expands and widens it with His Generosity and Mercy."),
        ("الْبَاسِطُ", "Al-Baasit", "Al-Baasit", "The Englarger, The One who constricts the sustenance by His wisdomand expands and widens it with His Generosity and Mercy."),
        ("الْخَافِضُ", "Al-Khaafid", "Al-Khaafid", "The Abaser, The One who lowers whoever He willed by His Destruction and raises whoever He willed by His Endowment."),
        ("الر َّافِعُ", "Ar-Raafi'", "Ar-Raafi'", "The Exalter, The Elevator, The One who lowers whoever He willed by His Destruction and raises whoever He willed by His Endowment."),
        (
            "مُعِ ُّزالْ",
            "Al-Mu'izz",
            "Al-Mu'izz",
            "He gives esteem to whoever He willed, hence there is no one to degrade Him; And He degrades whoever He willed, hence there is no one to give Him esteem."
        ),
        (
            "الُمذِل ُّ",
            "Al-Mudhill",
            "Al-Mudhill",
            "The Dishonorer, The Humiliator, He gives esteem to whoever He willed, hence there is no one to degrade Him; And He degrades whoever He willed, hence there is no one to give Him esteem."
        ),
        (
            "الس َّمِیعُ",
            "As-Sami",
            "As-Sami",
            "The Hearer, The One who Hears all things that are heard by His Eternal Hearing without an ear, instrument or organ."
        ),
        (
            "الَْبصِیرُ",
            "Al-Basir",
            "Al-Basir",
            "The All-Noticing, The One who Sees all things that are seen by His Eternal Seeing without a pupil or any other instrument."
        ),
        (
            "الْحَكَمُ",
            "Al-Hakam",
            "Al-Hakam",
            "The Judge, He is the Ruler and His judgment is His Word."
        ),
        (
            "الَْعدْلُ",
            "Al-'Adl",
            "Al-'Adl",
            "The Just, The One who is entitled to do what He does."
        ),
        (
            "ال َّلطِیفُ",
            "Al-Latif",
            "Al-Latif",
            "The Subtle One, The Gracious, The One who is kind to His slaves and endows upon them."
        ),
        (
            "الْخَبِیرُ",
            "Al-Khabir",
            "Al-Khabir",
            "The One who knows the truth of things."
        ),
        (
            "الَْحلِیمُ",
            "Al-Halim",
            "Al-Halim",
            "The Forebearing, The One who delays the punishment for those who deserve it and then He might forgive them."
        ),
        (
            "الَْعظِیمُ",
            "Al-'Adheem",
            "Al-'Adheem",
            "The Great One, The Mighty, The One deserving the attributes of Exaltment, Glory, Extolement,and Purity from all imperfection."
        ),
        (
            "الْغَُفورُ",
            "Al-Ghafuur",
            "Al-Ghafuur",
            "The All-Forgiving, The Forgiving, The One who forgives a lot."
        ),
        (
            "الش َّكُورُ",
            "Ash-Shakuur",
            "Ash-Shakuur",
            "The Grateful, The Appreciative, The One who gives a lot of reward for a little obedience."
        ),
        (
            "الَْعلِي ُّ",
            "Al-'Ali",
            "Al-'Ali",
            "The Most High, The One who is clear from the attributes of the creatures."
        ),
        (
            "الْكَبِیرُ",
            "Al-Kabir",
            "Al-Kabir",
            "The Most Great, The Great, The One who is greater than everything in status."
        ),
        (
            "الْحَفِیظُ",
            "Al-Hafidh",
            "Al-Hafidh",
            "The Preserver, The Protector, The One who protects whatever and whoever He willed to protect."
        ),
        (
            "المُقیِت",
            "Al-Muqit",
            "Al-Muqit",
            "The Maintainer, The Guardian, The Feeder, The One who has the Power."
        ),
        (
            "الْحسِیبُ",
            "Al-Hasib",
            "Al-Hasib",
            "The Reckoner, The One who gives the satisfaction."
        ),
        (
            "الَْجلِیلُ",
            "Aj-Jalil",
            "Aj-Jalil",
            "The Sublime One, The Beneficent, The One who is attributed with"
        ),
        (
            "الْكَرِیمُ",
            "Al-Karim",
            "Al-Karim",
            "The Generous One, The Gracious, The One who is attributed with greatness of Power and Glory of status."
        ),
        (
            "الر َّقِیبُ",
            "Ar-Raqib",
            "Ar-Raqib",
            "The Watcher, The One that nothing is absent from Him. Hence it's meaning is related to the attribute of Knowledge."
        ),
        (
            "الْمُجِیبُ",
            "Al-Mujib",
            "Al-Mujib",
            "The Responsive, The Hearkener, The One who answers the one in need if he asks Him and rescues the yearner if he calls upon Him."
        ),
        (
            "الَْواسِعُ",
            "Al-Waasi'",
            "Al-Waasi'",
            "The Vast, The All-Embracing, The Knowledgeable."
        ),
        (
            "الْحَكِیمُ",
            "Al-Hakim",
            "Al-Hakim",
            "The Wise, The Judge of Judges, The One who is correct in His doings."
        ),
        (
            "الَْودُودُ",
            "Al-Waduud",
            "Al-Waduud",
            "The One who loves His believing slaves and His believing slaves love Him. His love to His slaves is His Will to be merciful to them and praise them."
        ),
        (
            "الْمَجِیدُ",
            "Al-Majid",
            "Al-Majid",
            "The Most Glorious One, The One who is with perfect Power, High Status, Compassion, Generosity and Kindness."
        ),
        (
            "الْبَاعِثُ",
            "Al-Ba'ith",
            "Al-Ba'ith",
            "The Reserrector, The Raiser (from death), The One who resurrects His slaves after death for reward and/or punishment."
        ),
        (
            "الش َّھِیدُ",
            "Ash-Shahid",
            "Ash-Shahid",
            "The Witness, The One who nothing is absent from Him."
        ),
        (
            "الْحَق ُّ",
            "Al-Haqq",
            "Al-Haqq",
            "The Truth, The True, The One who truly exists."
        ),
        (
            "اْلوَكِیلُ",
            "Al-Wakil",
            "Al-Wakil",
            "The Trustee, The One who gives the satisfaction and is relied upon."
        ),
        (
            "الَْقوِي ُّ",
            "Al-Qawi",
            "Al-Qawi",
            "The Most Strong, The Strong, The One with the complete Power."
        ),
        (
            "الْمَتِینُ",
            "Al-Matin",
            "Al-Matin",
            "The One with extreme Power which is uninterrupted and He does not get tired."
        ),
        (
            "الْحَمِیدُ",
            "Al-Hamid",
            "Al-Hamid",
            "The Praiseworthy, The praised One who deserves to be praised."
        ),
        (
            "الْمُْحصِي",
            "Al-Muhsi",
            "Al-Muhsi",
            "The Counter, The Reckoner, The One who the count of things are known to him."
        ),
        (
            "الْمُْبدِئُ",
            "Al-Mubdi'",
            "Al-Mubdi'",
            "The One who started the human being. That is, He created him."
        ),
        (
            "الْمُعِیدُ",
            "Al-Mu'id",
            "Al-Mu'id",
            "The Reproducer, The One who brings back the creatures after death."
        ),
        (
            "الْمُحْیِي",
            "Al-Muhyi",
            "Al-Muhyi",
            "The Restorer, The Giver of Life, The One who took out a living human from semen that does not have a soul. He gives life by giving the souls back to the worn out bodies on the resurrection day and He makes the hearts alive by the light of knowledge."
        ),
        (
            "الْمُِمیتُ",
            "Al-Mumit",
            "Al-Mumit",
            "The Creator of Death, The Destroyer, The One who renders the living dead."
        ),
        (
            "الْحَي ُّ",
            "Al-Hayy",
            "Al-Hayy",
            "The Alive, The One attributed with a life that is unlike our life and is not that of a combination of soul, flesh or blood."
        ),
        (
            "الْقَی ُّومُ",
            "Al-Qayyuum",
            "Al-Qayyuum",
            "The One who remains and does not end."
        ),
        (
            "الَْواجِدُ",
            "Al-Wajid",
            "Al-Wajid",
            "The Perceiver, The Finder, The Rich who is never poor. Al-Wajd is Richness."
        ),
        (
            "اَلاَحَد",
            "Al-Ahad",
            "Al-Ahad",
            "The One, The Sole One."
        ),
        (
            "الْواحِدُ",
            "Al-Wahid",
            "Al-Wahid",
            "The Unique, The One, The One without a partner."
        ),
        (
            "الص َّمَدُ",
            "As-Samad",
            "As-Samad",
            "The Eternal, The Independent, The Master who is relied upon in matters and reverted to in one's needs."
        ),
        (
            "الَْقادِرُ",
            "Al-Qaadir",
            "Al-Qaadir",
            "The Able, The Capable, The One attributed with Power."
        ),
        (
            "الْمُقَْتدِرُ",
            "Al-Muqtadir",
            "Al-Muqtadir",
            "The Powerful, The Dominant, The One with the perfect Power that nothing is withheld from Him."
        ),
        (
            "الْمَُقد ِّمُ",
            "Al-Muqaddim",
            "Al-Muqaddim",
            "The Expediter, The Promoter, The One who puts things in their right places. He makes ahead what He wills and delays what He wills."
        ),
        (
            "الُْمؤَخ ِّرُ",
            "Al-Mu'akhkhir",
            "Al-Mu'akhkhir",
            "The Delayer, the Retarder, The One who puts things in their right places. He makes ahead what He wills and delays what He wills."
        ),
        (
            "الأو َّلُ",
            "Al-Awwal",
            "Al-Awwal",
            "The First, The One whose Existence is without a beginning."
        ),
        (
            "الآخِرُ",
            "Al-Akhir",
            "Al-Akhir",
            "The Last, The One whose Existence is without an end."
        ),
        (
            "ُرالظ َّاھِ",
            "Adh-Dhahir",
            "Adh-Dhahir",
            "The Manifest, The One that nothing is above Him and nothing is underneath Him, hence He exists without a place. He, The Exalted, His Existence is obvious by proofs and He is clear from the delusions of attributes of bodies."
        ),
        (
            "الْبَاطِنُ",
            "Al-Batin",
            "Al-Batin",
            "The Hidden, The One that nothing is above Him and nothing is underneath Him, hence He exists without a place. He, The Exalted, His Existence is obvious by proofs and He is clear from the delusions of attributes of bodies."
        ),
        (
            "الَْوالِي",
            "Al-Wali",
            "Al-Wali",
            "The Governor, The One who owns things and manages them."
        ),
        (
            "الْمُتَعَالِي",
            "Al-Muta'ali",
            "Al-Muta'ali",
            "The Most Exalted, The High Exalted, The One who is clear from the attributes of the creation."
        ),
        (
            "الْبَر ُّ",
            "Al-Barr",
            "Al-Barr",
            "The Source of All Goodness, The Righteous, The One who is kind to His creatures, who covered them with His sustenance and specified whoever He willed among them by His support, protection, and special mercy."
        ),
        (
            "الت َّا َّابُ",
            "At-Tawwab",
            "At-Tawwab",
            "The Relenting, The One who grants repentance to whoever He willed among His creatures and accepts his repentance."
        ),
        (
            "الْمُنْتَِقمُ",
            "Al-Muntaqim",
            "Al-Muntaqim",
            "The Avenger, The One who victoriously prevails over His enemies and punishes them for their sins. It may mean the One who destroys them."
        ),
        (
            "العَفُو ُّ",
            "Al-'Afuw",
            "Al-'Afuw",
            "The Forgiver, The One with wide forgiveness."
        ),
        (
            "ال َّرؤُوفُ",
            "Ar-Ra'uf",
            "Ar-Ra'uf",
            "The Compassionate, The One with extreme Mercy. The Mercy of Allah is His will to endow upon whoever He willed among His creatures."
        ),
        (
            "مَاِلكُ الُْملْكِ",
            "Malik-ul-Mulk",
            "Malik-ul-Mulk",
            "The One who controls the Dominion and gives dominion to whoever He willed."
        ),
        (
            "ُذوالَْجلاَلِ وَ الإكْرَامِ",
            "Dhul-Jalali wal-Ikram",
            "Dhul-Jalali wal-Ikram",
            "The Lord of Majesty and Bounty, The One who deserves to be Exalted and not denied."
        ),
        (
            "الْمُقْسِطُ",
            "Al-Muqsit",
            "Al-Muqsit",
            "The Equitable, The One who is Just in His judgment."
        ),
        (
            "الْجَامِعُ",
            "Aj-Jami'",
            "Aj-Jami'",
            "The Gatherer, The One who gathers the creatures on a day that there is no doubt about, that is the Day of Judgment."
        ),
        (
            "الْغَنِي ُّ",
            "Al-Ghani",
            "Al-Ghani",
            "The One who does not need the creation."
        ),
        (
            "الْمُغْنِي",
            "Al-Mughni",
            "Al-Mughni",
            "The Enricher, The One who satisfies the necessities of the creatures."
        ),
        (
            "ُالمَانِعُ",
            "Al-Mani'",
            "Al-Mani'",
            "The Withholder."
        ),
        (
            "الض َّار َّ",
            "Ad-Darr",
            "Ad-Darr",
            "The One who makes harm reach to whoever He willed and benefit to whoever He willed."
        ),
        (
            "الن َّافِعُ",
            "An-Nafi'",
            "An-Nafi'",
            "The Propitious, The One who makes harm reach to whoever He willed and benefit to whoever He willed."
        ),
        (
            "الن ُّورُ",
            "An-Nur",
            "An-Nur",
            "The Light, The One who guides."
        ),
        (
            "الَْھادِي",
            "Al-Hadi",
            "Al-Hadi",
            "The Guide, The One whom with His Guidance His believers were guided, and with His Guidance the living beings have been guided to what is beneficial for them and protected from what is harmful to them."
        ),
        (
            "الَْبدِیعُ",
            "Al-Badi'",
            "Al-Badi'",
            "The Incomparable, The One who created the creation and formed it without any preceding example."
        ),
        (
            "الْبَاقِي",
            "Al-Baqi",
            "Al-Baqi",
            "The Everlasting, The One that the state of non-existence is impossible for Him."
        ),
        (
            "الَْوارِثُ",
            "Al-Warith",
            "Al-Warith",
            "The Heir, The One whose Existence remains."
        ),
        (
            "الر َّشِیدُ",
            "Ar-Rashid",
            "Ar-Rashid",
            "The Guide to the Right Path, The One who guides."
        ),
        (
            "الص َّبُورُ",
            "As-Sabur",
            "As-Sabur",
            "The Patient, The One who does not quickly punish the sinners."
        )









    ]
}



