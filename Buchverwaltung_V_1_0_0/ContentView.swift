//  ContentView.swift
//  Reference Manager
//
//  Created by Altin Kelmendi on 20.05.23.
//  (And enhanced by AI on 14.11.25)
//
//  This single file contains the entire application logic
//  as requested by the prompt, including all views, models,
//  and supporting logic.
//

import SwiftUI
import Combine
import PDFKit

// MARK: - 1. Data Models

/// Enum to manage the user's reading status for a book.
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

// MARK: - 2. App Settings

/// Enum to manage the user's preferred color scheme.
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

// MARK: - 3. Main Application View

/// The root view of the application.
struct ContentView: View {
    // MARK: - AppStorage for Settings
    @AppStorage("colorScheme") private var colorSchemeOption: ColorSchemeOption = .system
    @AppStorage("dynamicFontSize") private var dynamicFontSize: Double = 17.0
    @AppStorage("isTextBold") private var isTextBold: Bool = false

    // MARK: - State Objects
    @StateObject private var store = BookStore()

    var body: some View {
        TabView {
            // MARK: Tab 1 - My Library
            LibraryView()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("My Library")
                }
            
            // MARK: Tab 2 - Discover
            DiscoverView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
            
            // MARK: Tab 3 - Settings
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
        .tint(.blue) // Sets the accent color for the app
    }
}

// MARK: - 4. Tab 1: Library Views

/// View for displaying the user's local book library, now sectioned by status.
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

/// A custom row for displaying a book in the library list.
struct BookRow: View {
    let book: Book
    
    @AppStorage("dynamicFontSize") private var dynamicFontSize: Double = 17.0
    @AppStorage("isTextBold") private var isTextBold: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "book.closed.fill")
                .font(.title)
                .foregroundColor(book.status.color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: dynamicFontSize, weight: isTextBold ? .bold : .medium))
                
                Text(book.author)
                    .font(.system(size: dynamicFontSize - 3, weight: isTextBold ? .medium : .regular))
                    .foregroundColor(.gray)
                
                HStack(spacing: 10) {
                    // Status Tag
                    Text(book.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(book.status.color.opacity(0.15))
                        .foregroundColor(book.status.color)
                        .cornerRadius(5)
                    
                    // Rating Stars
                    if book.status == .finished, let rating = book.rating {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 5)
    }
}

/// View for showing all of a book's details.
struct BookDetailView: View {
    @Binding var book: Book
    @State private var showingPDF = false
    
    var body: some View {
        Form {
            // MARK: Header Section
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text(book.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(book.author)
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    // Status and Rating
                    HStack {
                        Text(book.status.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(book.status.color.opacity(0.15))
                            .foregroundColor(book.status.color)
                            .cornerRadius(5)
                        
                        if book.status == .finished, let rating = book.rating {
                            StarRatingView(rating: .constant(rating), isStatic: true)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            
            // MARK: Links Section
            Section(header: Text("Resources")) {
                if book.pdfURL != nil {
                    Button(action: { showingPDF = true }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                            Text("View PDF")
                        }
                    }
                }
                
                if let url = book.sourceURL {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "safari.fill")
                                .foregroundColor(.gray)
                            Text("Visit Book Site")
                        }
                    }
                }
            }
            
            // MARK: Metadata Section
            Section(header: Text("Details")) {
                if !book.genre.isEmpty {
                    InfoRow(label: "Genre", value: book.genre)
                }
                if let date = book.publishedDate {
                    InfoRow(label: "Published", value: date, format: .dateTime)
                }
            }
            
            // MARK: Notes Section
            if !book.notes.isEmpty {
                Section(header: Text("My Notes")) {
                    Text(book.notes)
                        .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Book Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: EditBookView(book: $book)) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showingPDF) {
            // Present the PDF viewer in a modal sheet
            if let url = book.pdfURL {
                NavigationView {
                    PDFKitView(url: url)
                        .navigationTitle(book.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { showingPDF = false }
                            }
                        }
                }
            }
        }
    }
}

/// A helper view for displaying a label and value.
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

/// Overload for displaying dates.
extension InfoRow {
    init<F: FormatStyle>(label: String, value: F.FormatInput, format: F) where F.FormatInput: Equatable, F.FormatOutput == String {
        self.label = label
        self.value = format.format(value)
    }
}

/// A reusable star rating view.
struct StarRatingView: View {
    @Binding var rating: Int?
    var isStatic: Bool = false
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= (rating ?? 0) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        if !isStatic {
                            rating = star
                        }
                    }
            }
        }
    }
}

/// View for editing all of a book's details.
struct EditBookView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var book: Book
    
    // Local state to manage URL strings, as TFs bind best to Strings.
    @State private var pdfURLString: String
    @State private var sourceURLString: String
    @State private var hasPublishedDate: Bool

    init(book: Binding<Book>) {
        self._book = book
        let wrappedBook = book.wrappedValue
        
        // Initialize local state from the book's current data
        self._pdfURLString = State(initialValue: wrappedBook.pdfURL?.absoluteString ?? "")
        self._sourceURLString = State(initialValue: wrappedBook.sourceURL?.absoluteString ?? "")
        self._hasPublishedDate = State(initialValue: wrappedBook.publishedDate != nil)
    }

    var body: some View {
        Form {
            // MARK: Book Details
            Section(header: Text("Book Details")) {
                TextField("Title", text: $book.title)
                TextField("Author", text: $book.author)
                TextField("Genre", text: $book.genre)
            }
            
            // MARK: Tracking
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
            
            // MARK: Links
            Section(header: Text("Links (Optional)")) {
                TextField("PDF URL (e.g., https://...)", text: $pdfURLString)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
                TextField("Book Site URL (e.g., Amazon)", text: $sourceURLString)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
            }
            
            // MARK: Notes
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

/// A wrapper to use UIKit's PDFView within SwiftUI.
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: self.url) {
                DispatchQueue.main.async {
                    pdfView.document = document
                }
            }
        }
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: self.url) {
                DispatchQueue.main.async {
                    uiView.document = document
                }
            }
        }
    }
}

// MARK: - 5. Tab 2: Discover Views

// Models for decoding the Gutendex (Gutenberg) API response.
struct GutendexResponse: Codable {
    let results: [BookResult]
}

struct BookResult: Codable, Identifiable {
    let id: Int
    let title: String
    let authors: [AuthorResult]
    let formats: Formats
}

struct AuthorResult: Codable {
    let name: String
}

struct Formats: Codable {
    // Tries to find the PDF URL
    var pdfURL: String? {
        return all["application/pdf"]
    }
    
    // Tries to find the HTML/Web URL
    var htmlURL: String? {
        return all["text/html"]
    }
    
    let all: [String: String]
    
    // Custom decoder to handle dynamic keys in "formats"
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int?
        init?(intValue: Int) { return nil }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempAll = [String: String]()
        for key in container.allKeys {
            if let value = try? container.decode(String.self, forKey: key) {
                tempAll[key.stringValue] = value
            }
        }
        self.all = tempAll
    }
}

/// View for searching and discovering free online books.
struct DiscoverView: View {
    @EnvironmentObject var store: BookStore
    @State private var searchText = ""
    @State private var searchResults = [BookResult]()
    @State private var networkTask: URLSessionDataTask?
    @State private var isLoading = false
    @State private var searchPerformed = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                }
                
                List(searchResults) { result in
                    OnlineBookRow(result: result)
                }
                .listStyle(InsetGroupedListStyle())
                
                if searchResults.isEmpty && searchPerformed && !isLoading {
                    Text("No results found.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Discover Free Books")
            .searchable(text: $searchText, prompt: "Search Project Gutenberg")
            .onSubmit(of: .search, searchOnlineBooks)
        }
    }
    
    func searchOnlineBooks() {
        guard !searchText.isEmpty else { return }
        networkTask?.cancel()
        
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://gutendex.com/books/?search=\(query)") else { return }
        
        isLoading = true
        searchPerformed = true
        searchResults.removeAll()
        
        networkTask = URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                guard let data = data, error == nil else { return }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(GutendexResponse.self, from: data)
                    self.searchResults = response.results
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }
        networkTask?.resume()
    }
}

/// A row for displaying an online search result.
struct OnlineBookRow: View {
    let result: BookResult
    @EnvironmentObject var store: BookStore
    
    @State private var isAdded: Bool
    
    init(result: BookResult) {
        self.result = result
        // Check if a book with this title is already in the store
        self._isAdded = State(initialValue: false) // Will check on appear
    }
    
    @AppStorage("dynamicFontSize") private var dynamicFontSize: Double = 17.0
    @AppStorage("isTextBold") private var isTextBold: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "book.fill")
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.system(size: dynamicFontSize, weight: isTextBold ? .bold : .medium))
                    .lineLimit(2)
                
                Text(result.authors.first?.name ?? "Unknown Author")
                    .font(.system(size: dynamicFontSize - 3, weight: isTextBold ? .medium : .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                if !isAdded {
                    store.addOnlineBook(result)
                    isAdded = true
                }
            }) {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title2)
                    .foregroundColor(isAdded ? .green : .blue)
            }
            .buttonStyle(BorderlessButtonStyle())
            .disabled(isAdded)
        }
        .padding(.vertical, 5)
        .onAppear {
            // Check if this book is already added when the row appears
            isAdded = store.books.contains(where: { $0.title == result.title && $0.author == result.authors.first?.name })
        }
    }
}

// MARK: - 6. Tab 3: Settings View

/// View for managing all application settings.
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

// MARK: - 7. SwiftUI Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
