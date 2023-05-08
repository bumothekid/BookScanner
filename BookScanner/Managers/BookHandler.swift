//
//  BookHandler.swift
//  BookScanner
//
//  Created by David Riegel on 08.05.23.
//

import Foundation

class BookHandler {

    public func saveBook(_ book: Book) async throws {
        let oldBooksDict: [String: Any] = UserDefaults.standard.dictionary(forKey: "books") ?? [String: Any]()
        let bookData = try JSONEncoder().encode(book)
        var newBooksDict = oldBooksDict
        
        newBooksDict[book.industryIdentifiers[1].identifier] = bookData
        
        UserDefaults.standard.removeObject(forKey: "books")
        UserDefaults.standard.set(newBooksDict, forKey: "books")
    }
    
    public func getBookByISBN(_ isbn: String) async throws -> Book? {
        let booksDict: [String: Any] = UserDefaults.standard.dictionary(forKey: "books") ?? [String: Any]()
        guard let bookData = booksDict[isbn] else { return nil }
        let book = try JSONDecoder().decode(Book.self, from: bookData as! Data)
        
        return book
    }
    
    private func decodeBook(_ isbn: String) {
        
    }
}
