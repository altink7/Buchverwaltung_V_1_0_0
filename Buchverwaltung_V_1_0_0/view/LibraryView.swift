//
//  LibraryView.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUICore
import SwiftUI


struct LibraryView: View {
    @EnvironmentObject var store: BookStore
    
    /// The order in which to display the sections.
    private let statusOrder: [BookStatus] = [.reading, .wantToRead, .finished]

    var body: some View {
        NavigationView {
            List {
                ForEach(statusOrder, id: \.self) { status in
                    // Only show the section if it contains books.
                    if let booksInSection = store.booksByStatus[status], !booksInSection.isEmpty {
                        Section(header: Text(status.rawValue)) {
                            ForEach(booksInSection) { book in
                                let index = getIndex(for: book)
                                NavigationLink(destination: BookDetailView(book: $store.books[index])) {
                                    BookRow(book: book)
                                }
                            }
                            .onDelete { offsets in
                                deleteBooks(in: status, at: offsets)
                            }
                            .onMove { source, destination in
                                moveBooks(in: status, from: source, to: destination)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Reference Manager")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addBook) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    // MARK: Helper Functions
    
    private func getIndex(for book: Book) -> Int {
        guard let index = store.books.firstIndex(where: { $0.id == book.id }) else {
            fatalError("Book not found. This should never happen.")
        }
        return index
    }
    
    /// Deletes books from the correct status group.
    private func deleteBooks(in status: BookStatus, at offsets: IndexSet) {
        guard let booksInSection = store.booksByStatus[status] else { return }
        let booksToDelete = offsets.map { booksInSection[$0] }
        
        store.books.removeAll { book in
            booksToDelete.contains(where: { $0.id == book.id })
        }
    }
    
    /// Moves books within the correct status group.
    private func moveBooks(in status: BookStatus, from source: IndexSet, to destination: Int) {
        guard let booksInSection = store.booksByStatus[status] else { return }
        
        // Find the actual indices in the main `store.books` array
        let sourceIndices = source.map { getIndex(for: booksInSection[$0]) }
        
        // Find the destination book in the section
        let destinationBook = booksInSection[destination > source.first! ? destination : destination]
        let destinationIndex = getIndex(for: destinationBook)
        
        // Perform the move in the main array
        let sourceIndicesSet = IndexSet(sourceIndices)
        store.books.move(fromOffsets: sourceIndicesSet, toOffset: destinationIndex)
    }
    
    private func addBook() {
        let newBook = Book(
            title: "New Book",
            author: "New Author",
            pdfURL: nil,
            sourceURL: nil,
            status: .wantToRead,
            rating: nil,
            notes: "",
            genre: "",
            publishedDate: nil
        )
        store.books.append(newBook)
    }
}
