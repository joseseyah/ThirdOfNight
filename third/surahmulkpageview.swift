import SwiftUI

struct SurahMulkPageView: View {
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Surah Al-Mulk Translation:")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 20)
                .padding(.leading, 20)
            
            ScrollView {
                Text("""
                In the name of Allah, the Entirely Merciful, the Especially Merciful.
                Blessed is He in whose hand is dominion, and He is over all things competent
                """
                )
                .foregroundColor(.black)
                .font(.body)
                .padding()
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(red: 51/255, green: 102/255, blue: 153/255)) // Darker blue background
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            withAnimation {
                isExpanded = false
            }
        }
    }
}

