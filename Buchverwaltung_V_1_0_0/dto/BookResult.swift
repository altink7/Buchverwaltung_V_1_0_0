//
//  BookResult.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//


struct BookResult: Codable, Identifiable {
    let id: Int
    let title: String
    let authors: [AuthorResult]
    let formats: Formats
}