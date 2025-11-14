//
//  BookRow.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUI


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
            
                    Text(book.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(book.status.color.opacity(0.15))
                        .foregroundColor(book.status.color)
                        .cornerRadius(5)
                    
                
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
