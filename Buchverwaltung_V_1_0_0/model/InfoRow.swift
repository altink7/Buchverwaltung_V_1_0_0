//
//  InfoRow.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUICore


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

extension InfoRow {
    init<F: FormatStyle>(label: String, value: F.FormatInput, format: F) where F.FormatInput: Equatable, F.FormatOutput == String {
        self.label = label
        self.value = format.format(value)
    }
}
