//
//  PDFKitView.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUI
import PDFKit


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
