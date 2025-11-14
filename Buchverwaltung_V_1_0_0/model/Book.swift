//
//  Book.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import Foundation

/// Represents a single book in the user's local library.
/// This model has been expanded to include tracking and more details.
struct Book: Identifiable {
    let id = UUID()
    var title: String
    var author: String
    
    // Core Links
    var pdfURL: URL?
    var sourceURL: URL? // The "book site" URL
    
    // Tracking & Metadata
    var status: BookStatus
    var rating: Int? // 1-5 stars, nil if not rated
    var notes: String
    var genre: String
    var publishedDate: Date?
    
    /// Helper to provide a non-nil date for DatePickers,
    /// while still storing the actual value as optional.
    var nonNilPublishedDate: Date {
        get { publishedDate ?? Date() }
        set { publishedDate = newValue }
    }
}
