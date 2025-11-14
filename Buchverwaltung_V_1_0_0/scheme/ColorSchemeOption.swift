//
//  ColorSchemeOption.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUICore


enum ColorSchemeOption: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
    
    var systemColorScheme: ColorScheme? {
        switch self {
        case .system: return .none
        case .light: return .light
        case .dark: return .dark
        }
    }
}
