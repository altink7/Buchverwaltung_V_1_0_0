//
//  DiscoverView.swift
//  Buchverwaltung_V_1_0_0
//
//  Created by Altin Kelmendi on 14.11.25.
//

import SwiftUICore
import Foundation
import UIKit
import SwiftUI


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
