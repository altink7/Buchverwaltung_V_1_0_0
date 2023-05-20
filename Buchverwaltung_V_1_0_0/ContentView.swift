//
//  ContentView.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 20.05.23.
//

import SwiftUI

struct Book: Identifiable {
    let id = UUID()
    var title: String
    var author: String
}

class BookStore: ObservableObject {
    @Published var books = [
        Book(title: "Swift", author: "Altin Kelmendi"),
        Book(title: "Java", author: "Author 1"),
        Book(title: "Kotlin", author: "Author 2"),
        Book(title: "Python", author: "Author 3")
    ]
}

struct ContentView: View {
    @StateObject private var store = BookStore()
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.books) { book in
                    if isEditing {
                        EditableBookRow(book: $store.books[getIndex(for: book)])
                    } else {
                        NavigationLink(destination: EditBookView(book: $store.books[getIndex(for: book)])) {
                            BookRow(book: book)
                        }
                    }
                }
                .onDelete(perform: deleteBooks)
                .onMove(perform: moveBooks)
            }
            .navigationBarTitle("Book Store")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .foregroundColor(.blue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addBook) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func getIndex(for book: Book) -> Int {
        guard let index = store.books.firstIndex(where: { $0.id == book.id }) else {
            fatalError("Book not found")
        }
        return index
    }
    
    private func deleteBooks(at offsets: IndexSet) {
        store.books.remove(atOffsets: offsets)
    }
    
    private func moveBooks(from source: IndexSet, to destination: Int) {
        store.books.move(fromOffsets: source, toOffset: destination)
    }
    
    private func addBook() {
        let newBook = Book(title: "New Book", author: "New Author")
        store.books.append(newBook)
    }
}

struct BookRow: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title)
                .font(.headline)
            Text(book.author)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct EditableBookRow: View {
    @Binding var book: Book
    
    var body: some View {
        HStack {
            TextField("Title", text: $book.title)
            TextField("Author", text: $book.author)
        }
    }
}

struct EditBookView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var book: Book
    
    var body: some View {
        Form {
            TextField("Title", text: $book.title)
            TextField("Author", text: $book.author)
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
        presentationMode.wrappedValue.dismiss()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
