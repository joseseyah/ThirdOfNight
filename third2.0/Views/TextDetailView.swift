import Foundation
import SwiftUI

// Text detail view for Our Mission and Privacy Policy
struct TextDetailView: View {
    var title: String
    var content: String

    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                Text(content)
                    .foregroundColor(.white)
                    .padding()

                Spacer()
            }
            .padding()
        }
    }
}
