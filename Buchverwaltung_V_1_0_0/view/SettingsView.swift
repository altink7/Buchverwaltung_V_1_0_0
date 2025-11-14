//
//  SettingsView.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUICore
import SwiftUI


struct SettingsView: View {
    @Binding var colorSchemeOption: ColorSchemeOption
    @Binding var dynamicFontSize: Double
    @Binding var isTextBold: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    Picker("Theme", selection: $colorSchemeOption) {
                        ForEach(ColorSchemeOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    HStack {
                        Text("Designed By")
                        Spacer()
                        
                        VStack {
                            Text("Altin Kelmendi")
                                .foregroundColor(.gray)
                            Text("Julian Hoffmann")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Online Library")
                        Spacer()
                        Text("Powered by Gutendex")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
