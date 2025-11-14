//
//  EditBookView.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUI


struct EditBookView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var book: Book
    @State private var pdfURLString: String
    @State private var sourceURLString: String
    @State private var hasPublishedDate: Bool

    init(book: Binding<Book>) {
        self._book = book
        let wrappedBook = book.wrappedValue
    
        self._pdfURLString = State(initialValue: wrappedBook.pdfURL?.absoluteString ?? "")
        self._sourceURLString = State(initialValue: wrappedBook.sourceURL?.absoluteString ?? "")
        self._hasPublishedDate = State(initialValue: wrappedBook.publishedDate != nil)
    }

    var body: some View {
        Form {
    
            Section(header: Text("Book Details")) {
                TextField("Title", text: $book.title)
                TextField("Author", text: $book.author)
                TextField("Genre", text: $book.genre)
            }
            

            Section(header: Text("Tracking")) {
                Picker("Status", selection: $book.status) {
                    ForEach(BookStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                
                // Show rating only if the book is "Finished"
                if book.status == .finished {
                    VStack(alignment: .leading) {
                        Text("Rating")
                        StarRatingView(rating: $book.rating)
                    }
                }
                
                // Date Picker with Toggle
                Toggle("Add Published Date", isOn: $hasPublishedDate.animation())
                if hasPublishedDate {
                    DatePicker(
                        "Published",
                        selection: $book.nonNilPublishedDate,
                        displayedComponents: .date
                    )
                }
            }
            
            Section(header: Text("Links (Optional)")) {
                TextField("PDF URL (e.g., https://...)", text: $pdfURLString)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
                TextField("Book Site URL (e.g., Amazon)", text: $sourceURLString)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
            }

            Section(header: Text("My Notes")) {
                // Use TextEditor for multi-line input
                TextEditor(text: $book.notes)
                    .frame(minHeight: 150)
            }
        }
        .navigationTitle("Edit Book")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveChanges) {
                    Text("Save")
                }
            }
        }
    }
    
    private func saveChanges() {
        // When saving, update the book's URLs from the strings.
        book.pdfURL = URL(string: pdfURLString)
        book.sourceURL = URL(string: sourceURLString)
        
        // If the user unchecked the date, set it back to nil.
        if !hasPublishedDate {
            book.publishedDate = nil
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}
