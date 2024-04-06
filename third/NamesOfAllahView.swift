import SwiftUI

struct NamesOfAllahView: View {
    @State private var isPresented = false

    var body: some View {
        TabView {
            ForEach(NamesOfAllah.data, id: \.name) { name in
                NameOfAllahDetailView(name: name)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .navigationTitle("Names of Allah")
        .sheet(isPresented: $isPresented) {
            NamesOfAllahView()
        }
    }
}

