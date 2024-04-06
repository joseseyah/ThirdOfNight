import SwiftUI

struct NameOfAllahDetailView: View {
    let name: (arabicName: String, name: String, transliteration: String, definition: String)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("99 Names of Allah")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Circle()
                .frame(width: 200, height: 200)
                .foregroundColor(.blue)
                .overlay(
                    Text(name.arabicName)
                        .foregroundColor(.white)
                        .font(.system(size: 48, weight: .bold))
                )
            
            Text(name.transliteration)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(name.definition)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding()
    }
}

