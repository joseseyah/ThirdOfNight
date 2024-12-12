import SwiftUI

struct SurahMulkView: View {
    @State private var isEnglishText = false  // State to toggle between Arabic and English
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)
            
            VStack {
                // Toggle to switch between Arabic and English
                Toggle(isOn: $isEnglishText) {
                    Text(isEnglishText ? "English" : "Arabic")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()
                
                ScrollView {
                    // Display the Arabic or English text based on the toggle
                    Text(isEnglishText ? englishText : arabicText)
                        .font(isEnglishText ? .body : .custom("ScheherazadeNew-Regular", size: 24))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color("PageBackgroundColor"))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }
            }
            .padding(.top, 20)
        }
    }
    
    // English Text of Surah Mulk
    let englishText = """
                         In the name of Allah, the Entirely Merciful, the Especially Merciful.
                                        
                        1. Blessed is He in Whose Hand is the dominion, and He is Able to do all things.

                        2. Who has created death and life, that He may test you which of you is best in deed. And He is the All-Mighty, the Oft-Forgiving;

                        3. Who has created the seven heavens one above another, you can see no fault in the creations of the Most Beneficent. Then look again: "Can you see any rifts?"

                        4. Then look again and yet again, your sight will return to you in a state of humiliation and worn out.

                        5. And indeed We have adorned the nearest heaven with lamps, and We have made such lamps (as) missiles to drive away the Shayatin (devils), and have prepared for them the torment of the blazing Fire.

                        6. And for those who disbelieve in their Lord (Allah) is the torment of Hell, and worst indeed is that destination.

                        7. When they are cast therein, they will hear the (terrible) drawing in of its breath as it blazes forth.

                        8. It almost bursts up with fury. Every time a group is cast therein, its keeper will ask: "Did no warner come to you?"

                        9. They will say: "Yes indeed; a warner did come to us, but we belied him and said: 'Allah never sent down anything (of revelation), you are only in great error.'"

                        10. And they will say: "Had we but listened or used our intelligence, we would not have been among the dwellers of the blazing Fire!"

                        11. Then they will confess their sin. So, away with the dwellers of the blazing Fire.

                        12. Verily! Those who fear their Lord unseen (i.e. they do not see Him, nor His Punishment in the Hereafter, etc.), theirs will be forgiveness and a great reward (i.e. Paradise).

                        13. And whether you keep your talk secret or disclose it, verily, He is the All-Knower of what is in the breasts (of men).

                        14. Should not He Who has created know? And He is the Most Kind and Courteous (to His slaves) All-Aware (of everything).

                        15. He it is, Who has made the earth subservient to you (i.e. easy for you to walk, to live and to do agriculture on it, etc.), so walk in the path thereof and eat of His provision, and to Him will be the Resurrection.

                        16. Do you feel secure that He, Who is over the heaven (Allah), will not cause the earth to sink with you, then behold it shakes (as in an earthquake)?

                        17. Or do you feel secure that He, Who is over the heaven (Allah), will not send against you a violent whirlwind? Then you shall know how (terrible) has been My Warning?

                        18. And indeed those before them belied (the Messengers of Allah), then how terrible was My denial (punishment)?

                        19. Do they not see the birds above them, spreading out their wings and folding them in? None upholds them except the Most Beneficent (Allah). Verily, He is the All-Seer of everything.

                        20. Who is he besides the Most Beneficent that can be an army to you to help you? The disbelievers are in nothing but delusion.

                        21. Who is he that can provide for you if He should withhold His provision? Nay, but they continue to be in pride, and (they) flee (from the truth).

                        22. Is he who walks without seeing on his face, more rightly guided, or he who (sees and) walks on a Straight Way (i.e. Islamic Monotheism).

                        23. Say it is He Who has created you, and endowed you with hearing (ears), seeing (eyes), and hearts. Little thanks you give.

                        24. Say: "It is He Who has created you from the earth, and to Him shall you be gathered (in the Hereafter)."

                        25. They say: "When will this promise (i.e. the Day of Resurrection) come to pass? if you are telling the truth."

                        26. Say (O Muhammad ): "The knowledge (of its exact time) is with Allah only, and I am only a plain warner."

                        27. But when they will see it (the torment on the Day of Resurrection) approaching, the faces of those who disbelieve will be different (black, sad, and in grieve), and it will be said (to them): "This is (the promise) which you were calling for!"

                        28. Say (O Muhammad ): "Tell me! If Allah destroys me, and those with me, or He bestows His Mercy on us, - who can save the disbelievers from a painful torment?"

                        29. Say: "He is the Most Beneficent (Allah), in Him we believe, and in Him we put our trust. So you will come to know who is it that is in manifest error."

                        30. Say (O Muhammad ): "Tell me! If (all) your water were to be sunk away, who then can supply you with flowing (spring) water?"
    """

    // Arabic Text of Surah Mulk
    let arabicText = """
    بسم الله الرحمن الرحيمبسم الله الرحمن الرحيم
                    تَبَٰرَكَ ٱلَّذِى بِيَدِهِ ٱلْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَىْءٍۢ قَدِيرٌ
                    ٱلَّذِى خَلَقَ ٱلْمَوْتَ وَٱلْحَيَوٰةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًۭا ۚ وَهُوَ ٱلْعَزِيزُ ٱلْغَفُورُ
                    ٱلَّذِى خَلَقَ سَبْعَ سَمَٰوَٰتٍۢ طِبَاقًۭا ۖ مَّا تَرَىٰ فِى خَلْقِ ٱلرَّحْمَٰنِ مِن تَفَٰوُتٍۢ ۖ فَٱرْجِعِ ٱلْبَصَرَ هَلْ تَرَىٰ مِن فُطُورٍۢ
                    ثُمَّ ٱرْجِعِ ٱلْبَصَرَ كَرَّتَيْنِ يَنقَلِبْ إِلَيْكَ ٱلْبَصَرُ خَاسِئًۭا وَهُوَ حَسِيرٌۭ
                    وَلَقَدْ زَيَّنَّا ٱلسَّمَآءَ ٱلدُّنْيَا بِمَصَٰبِيحَ وَجَعَلْنَٰهَا رُجُومًۭا لِّلشَّيَٰطِينِ ۖ وَأَعْتَدْنَا لَهُمْ عَذَابَ ٱلسَّعِيرِ
                    وَلِلَّذِينَ كَفَرُوا۟ بِرَبِّهِمْ عَذَابُ جَهَنَّمَ ۖ وَبِئْسَ ٱلْمَصِيرُ
                    إِذَآ أُلْقُوا۟ فِيهَا سَمِعُوا۟ لَهَا شَهِيقًۭا وَهِىَ تَفُورُ
                    تَكَادُ تَمَيَّزُ مِنَ ٱلْغَيْظِ ۖ كُلَّمَآ أُلْقِىَ فِيهَا فَوْجٌۭ سَأَلَهُمْ خَزَنَتُهَآ أَلَمْ يَأْتِكُمْ نَذِيرٌۭ
                    قَالُوا۟ بَلَىٰ قَدْ جَآءَنَا نَذِيرٌۭ فَكَذَّبْنَا وَقُلْنَا مَا نَزَّلَ ٱللَّهُ مِن شَىْءٍ إِنْ أَنتُمْ إِلَّا فِى ضَلَٰلٍۢ كَبِيرٍۢ
                    وَقَالُوا۟ لَوْ كُنَّا نَسْمَعُ أَوْ نَعْقِلُ مَا كُنَّا فِىٓ أَصْحَٰبِ ٱلسَّعِيرِ
                    فَٱعْتَرَفُوا۟ بِذَنۢبِهِمْ فَسُحْقًۭا لِّأَصْحَٰبِ ٱلسَّعِيرِ
                    إِنَّ ٱلَّذِينَ يَخْشَوْنَ رَبَّهُم بِٱلْغَيْبِ لَهُم مَّغْفِرَةٌۭ وَأَجْرٌۭ كَبِيرٌۭ
                    وَأَسِرُّوا۟ قَوْلَكُمْ أَوِ ٱجْهَرُوا۟ بِهِۦٓ ۖ إِنَّهُۥ عَلِيمٌۢ بِذَاتِ ٱلصُّدُورِ
                    أَلَا يَعْلَمُ مَنْ خَلَقَ وَهُوَ ٱللَّطِيفُ ٱلْخَبِيرُ
                    هُوَ ٱلَّذِى جَعَلَ لَكُمُ ٱلْأَرْضَ ذَلُولًۭا فَٱمْشُوا۟ فِى مَنَاكِبِهَا وَكُلُوا۟ مِن رِّزْقِهِۦ ۖ وَإِلَيْهِ ٱلنُّشُورُ
                    ءَأَمِنتُم مَّن فِى ٱلسَّمَآءِ أَن يَخْسِفَ بِكُمُ ٱلْأَرْضَ فَإِذَا هِىَ تَمُورُ
                    أَمْ أَمِنتُم مَّن فِى ٱلسَّمَآءِ أَن يُرْسِلَ عَلَيْكُمْ حَاصِبًۭا ۖ فَسَتَعْلَمُونَ كَيْفَ نَذِيرِ
                    وَلَقَدْ كَذَّبَ ٱلَّذِينَ مِن قَبْلِهِمْ فَكَيْفَ كَانَ نَكِيرِ
                    أَوَلَمْ يَرَوْا۟ إِلَى ٱلطَّيْرِ فَوْقَهُمْ صَٰٓفَّٰتٍۢ وَيَقْبِضْنَ ۚ مَا يُمْسِكُهُنَّ إِلَّا ٱلرَّحْمَٰنُ ۚ إِنَّهُۥ بِكُلِّ شَىْءٍۭ بَصِيرٌ
                    أَمَّنْ هَٰذَا ٱلَّذِى هُوَ جُندٌۭ لَّكُمْ يَنصُرُكُم مِّن دُونِ ٱلرَّحْمَٰنِ ۚ إِنِ ٱلْكَٰفِرُونَ إِلَّا فِى غُرُورٍ
                    أَمَّنْ هَٰذَا ٱلَّذِى يَرْزُقُكُمْ إِنْ أَمْسَكَ رِزْقَهُۥ ۚ بَل لَّجُّوا۟ فِى عُتُوٍّۢ وَنُفُورٍ
                    أَفَمَن يَمْشِى مُكِبًّا عَلَىٰ وَجْهِهِۦٓ أَهْدَىٰٓ أَمَّن يَمْشِى سَوِيًّا عَلَىٰ صِرَٰطٍۢ مُّسْتَقِيمٍۢ
                    قُلْ هُوَ ٱلَّذِىٓ أَنشَأَكُمْ وَجَعَلَ لَكُمُ ٱلسَّمْعَ وَٱلْأَبْصَٰرَ وَٱلْأَفْـِٔدَةَ ۖ قَلِيلًۭا مَّا تَشْكُرُونَ
                    قُلْ هُوَ ٱلَّذِى ذَرَأَكُمْ فِى ٱلْأَرْضِ وَإِلَيْهِ تُحْشَرُونَ
                    وَيَقُولُونَ مَتَىٰ هَٰذَا ٱلْوَعْدُ إِن كُنتُمْ صَٰدِقِينَ
                    قُلْ إِنَّمَا ٱلْعِلْمُ عِندَ ٱللَّهِ وَإِنَّمَآ أَنَا۠ نَذِيرٌۭ مُّبِينٌۭ
                    فَلَمَّا رَأَوْهُ زُلْفَةًۭ سِيٓـَٔتْ وُجُوهُ ٱلَّذِينَ كَفَرُوا۟ وَقِيلَ هَٰذَا ٱلَّذِى كُنتُم بِهِۦ تَدَّعُونَ
                    قُلْ أَرَءَيْتُمْ إِنْ أَهْلَكَنِىَ ٱللَّهُ وَمَن مَّعِىَ أَوْ رَحِمَنَا فَمَن يُجِيرُ ٱلْكَٰفِرِينَ مِنْ عَذَابٍ أَلِيمٍۢ
                    قُلْ هُوَ ٱلرَّحْمَٰنُ ءَامَنَّا بِهِۦ وَعَلَيْهِ تَوَكَّلْنَا ۖ فَسَتَعْلَمُونَ مَنْ هُوَ فِى ضَلَٰلٍۢ مُّبِينٍۢ
                    قُلْ أَرَءَيْتُمْ إِنْ أَصْبَحَ مَآؤُكُمْ غَوْرًۭا فَمَن يَأْتِيكُم بِمَآءٍۢ مَّعِينٍۭ

    """
}

// Preview
struct SurahMulkView_Previews: PreviewProvider {
    static var previews: some View {
        SurahMulkView()
    }
}
