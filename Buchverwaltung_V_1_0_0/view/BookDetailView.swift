//
//  BookDetailView.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUICore
import UIKit
import SwiftUI


struct BookDetailView: View {
    @Binding var book: Book
    @State private var showingPDF = false
    
    var body: some View {
        Form {
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
            
            Section(header: Text("Details")) {
                if !book.genre.isEmpty {
                    InfoRow(label: "Genre", value: book.genre)
                }
                if let date = book.publishedDate {
                    InfoRow(label: "Published", value: date, format: .dateTime)
                }
            }
     
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
