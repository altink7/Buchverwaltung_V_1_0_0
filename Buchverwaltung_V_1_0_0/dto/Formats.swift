//
//  Formats.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//


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