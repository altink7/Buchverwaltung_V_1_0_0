//
//  OnlineBookRow.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUICore
import SwiftUI


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
