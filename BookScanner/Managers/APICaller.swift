//
//  APICaller.swift
//  BookScanner
//
//  Created by David Riegel on 08.05.23.
//

import Foundation

class APICaller {
    static let shared = APICaller()
    
    var baseRequest: URLRequest?
    
    struct Constants {
        static let baseApiURL: String = "https://www.googleapis.com/books/v1/volumes?q=isbn:"
        static let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as! String
    }
    
    enum APIError: Error {
        case failedToBuildURL
        case noItemsInRequest
    }
    
    public func getBookByISBN(_ isbn: String) async throws -> Book {
        guard let apiURL = URL(string: Constants.baseApiURL + isbn + "&key=" + Constants.apiKey) else { throw APIError.failedToBuildURL }
        let request = await createGETRequest(apiURL)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customStringToDate
        let jsonData = try decoder.decode(APIBooks.self, from: data)
        guard let apiBook = jsonData.items.first?.volumeInfo else { throw APIError.noItemsInRequest }
        
        return Book(title: apiBook.title, isbn: apiBook.industryIdentifiers[1].identifier.hasPrefix("978") ? apiBook.industryIdentifiers[1].identifier : "978" + apiBook.industryIdentifiers[1].identifier, publisher: apiBook.publisher, pageCount: apiBook.pageCount, authors: apiBook.authors, categories: apiBook.categories, coverURL: apiBook.imageLinks?.thumbnail, language: apiBook.language, publishedDate: apiBook.publishedDate)
    }
    
    private func createGETRequest(_ apiURL: URL) async -> URLRequest {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        return request
    }
}
