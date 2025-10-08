//
//  DuaSectionView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//

import SwiftUI

struct DuaSectionView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
        Text("Travel Duas")
            .font(.headline)
            .foregroundColor(Color("HighlightColor"))

        DuaView(title: "Dua for Travelling", arabic: "بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ", translation: "I begin with the Name of Allah; I trust in Allah; there is no altering of conditions but by the Power of Allah.")

        DuaView(title: "Dua When Boarding a Vehicle", arabic: "بِسْمِ اللَّهِ، وَالْحَمْدُ لِلَّهِ، سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ", translation: "In the name of Allah and all praise is for Allah. How perfect He is, the One Who has placed this (transport) at our service and we ourselves would not have been capable of that, and to our Lord is our final destiny.")

        DuaView(title: "Dua Upon Arrival", arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ", translation: "I seek refuge in Allah’s perfect words from every evil (that has been created).")

        DuaView(title: "Talbiyah Dua for Hajj or Umrah", arabic: "لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ", translation: "Here I am, O Allah, here I am, here I am. You have no partner, here I am. Verily all praise and blessings are Yours, and all sovereignty. You have no partner.")

        DuaView(title: "Dua for Return", arabic: "آيِبُونَ تَائِبُونَ عَابِدُونَ سَاجِدُونَ لِرَبِّنَا حَامِدُونَ", translation: "We return, repentant, worshipping, prostrating and praising our Lord.")

        Text("Don’t forget to make lots of Dua’s during Hajj and Umrah, asking Allah (SWT) for forgiveness. Don’t forget to include your friends, relatives, neighbours as well as the wider Ummah in your Dua during these spiritual journeys.")
            .font(.footnote)
            .foregroundColor(Color("HighlightColor"))
            .padding(.top, 10)
    }
    .padding()
  }
}
