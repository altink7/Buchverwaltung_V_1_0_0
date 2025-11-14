//
//  StarRatingView.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUICore


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
