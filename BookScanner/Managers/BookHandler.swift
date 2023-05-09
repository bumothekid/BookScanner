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
        let oldBooksArray: [String] = UserDefaults.standard.array(forKey: "bookOrder") as? [String] ?? [String]()
        let bookData = try JSONEncoder().encode(book)
        var newBooksDict = oldBooksDict
        var newBooksArray = oldBooksArray
        
        newBooksDict[book.industryIdentifiers[1].identifier] = bookData
        newBooksArray.append(book.industryIdentifiers[1].identifier)
        
        UserDefaults.standard.removeObject(forKey: "books")
        UserDefaults.standard.removeObject(forKey: "bookOrder")
        UserDefaults.standard.set(newBooksDict, forKey: "books")
        UserDefaults.standard.set(newBooksArray, forKey: "bookOrder")
    }
    
    public func removeBookByISBN(_ isbn: String) async throws {
        let oldBooksDict: [String: Any] = UserDefaults.standard.dictionary(forKey: "books") ?? [String: Any]()
        let oldBooksArray: [String] = UserDefaults.standard.array(forKey: "bookOrder") as? [String] ?? [String]()
        
        guard oldBooksDict[isbn] != nil else { return }
        
        var newBooksDict = oldBooksDict
        var newBooksArray = oldBooksArray
        
        newBooksDict.removeValue(forKey: isbn)
        newBooksArray.remove(at: newBooksArray.firstIndex(of: isbn)!)
        
        UserDefaults.standard.removeObject(forKey: "books")
        UserDefaults.standard.removeObject(forKey: "bookOrder")
        UserDefaults.standard.set(newBooksDict, forKey: "books")
        UserDefaults.standard.set(newBooksArray, forKey: "bookOrder")
    }
    
    public func getBookByISBN(_ isbn: String) async throws -> Book? {
        let booksDict: [String: Any] = UserDefaults.standard.dictionary(forKey: "books") ?? [String: Any]()
        guard let bookData = booksDict[isbn] else { return nil }
        let book = try JSONDecoder().decode(Book.self, from: bookData as! Data)
        
        return book
    }
    
    public func getAllBooks() async throws -> [String: Book] {
        let booksDict: [String: Any] = UserDefaults.standard.dictionary(forKey: "books") ?? [String: Any]()
        
        var books = [String: Book]()
        
        booksDict.forEach { (key, value) in
            let book = try? JSONDecoder().decode(Book.self, from: value as! Data)
            books[key] = book
        }
        
        return books
    }
    
    public func getBookOrder() async throws -> [String] {
        let bookOrder: [String] = UserDefaults.standard.array(forKey: "bookOrder") as? [String] ?? [String]()
        
        return bookOrder
    }
}
