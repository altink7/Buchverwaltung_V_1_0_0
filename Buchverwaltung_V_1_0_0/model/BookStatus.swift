//
//  BookStatus.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUICore


enum BookStatus: String, CaseIterable, Identifiable {
    case wantToRead = "Want to Read"
    case reading = "Reading"
    case finished = "Finished"
    
    var id: String { self.rawValue }
    
    /// Provides a color for UI elements based on status.
    var color: Color {
        switch self {
        case .wantToRead:
            return .blue
        case .reading:
            return .orange
        case .finished:
            return .green
        }
    }
}
