//
//  BookStore.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import Combine
import Foundation


/// Manages the collection of books for the entire app.
class BookStore: ObservableObject {
    @Published var books: [Book]
    
    /// Groups the books by their status for the LibraryView.
    var booksByStatus: [BookStatus: [Book]] {
        Dictionary(grouping: books, by: { $0.status })
    }

    init() {
        // Sample data, including all new fields.
        self.books = [
            Book(
                title: "SwiftUI Essentials",
                author: "Altin Kelmendi",
                pdfURL: nil,
                sourceURL: URL(string: "https://www.apple.com/swift/"),
                status: .reading,
                rating: nil,
                notes: "Working through the basics. Concurrency is next.",
                genre: "Programming",
                publishedDate: Calendar.current.date(from: .init(year: 2023, month: 1, day: 1))
            ),
            Book(
                title: "Sample PDF",
                author: "Apple Inc.",
                pdfURL: URL(string: "https://share.google/1yl9KQtltZFkcPbsx"),
                sourceURL: nil,
                status: .wantToRead,
                rating: nil,
                notes: "Need to review this for work.",
                genre: "Technical Document",
                publishedDate: nil
            ),
            Book(
                title: "The Art of Java",
                author: "Author 1",
                pdfURL: nil,
                sourceURL: nil,
                status: .finished,
                rating: 4,
                notes: "Great book, a bit dated but the fundamentals are solid.",
                genre: "Programming",
                publishedDate: Calendar.current.date(from: .init(year: 2010, month: 5, day: 10))
            ),
            Book(
                title: "Advanced Python",
                author: "Author 3",
                pdfURL: nil,
                sourceURL: nil,
                status: .wantToRead,
                rating: nil,
                notes: "",
                genre: "Programming",
                publishedDate: nil
            )
        ]
    }
    
    /// Adds a book from the online search results to the local library.
    func addOnlineBook(_ onlineBook: BookResult) {
        let pdfURLString = onlineBook.formats.pdfURL
        
        let newBook = Book(
            title: onlineBook.title,
            author: onlineBook.authors.first?.name ?? "Unknown Author",
            pdfURL: URL(string: pdfURLString ?? ""),
            sourceURL: URL(string: onlineBook.formats.htmlURL ?? ""),
            status: .wantToRead,
            rating: nil,
            notes: "Found on Project Gutenberg.",
            genre: "Classic",
            publishedDate: nil // Gutenberg API doesn't provide a reliable date
        )
        books.append(newBook)
    }
}
