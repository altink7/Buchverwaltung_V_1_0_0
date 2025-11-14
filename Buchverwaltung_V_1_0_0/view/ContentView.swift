//  ContentView.swift
//  Reference Manager
//
//  Created by Altin Kelmendi on 20.05.23.
//

import SwiftUI
import Combine
import PDFKit

struct ContentView: View {
    @AppStorage("colorScheme") private var colorSchemeOption: ColorSchemeOption = .system
    @AppStorage("dynamicFontSize") private var dynamicFontSize: Double = 17.0
    @AppStorage("isTextBold") private var isTextBold: Bool = false

    @StateObject private var store = BookStore()

    var body: some View {
        TabView {

            LibraryView()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("My Library")
                }

            DiscoverView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
            
            SettingsView(
                colorSchemeOption: $colorSchemeOption,
                dynamicFontSize: $dynamicFontSize,
                isTextBold: $isTextBold
            )
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .environmentObject(store)
        .preferredColorScheme(colorSchemeOption.systemColorScheme)
        .tint(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
