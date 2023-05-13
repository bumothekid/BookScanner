//
//  Book.swift
//  BookScanner
//
//  Created by David Riegel on 11.05.23.
//

import Foundation

struct Book: Codable {
    let title: String
    let isbn: String
    let publisher: String?
    let pageCount: Int?
    let authors: [String]?
    let categories: [String]?
    let coverURL: String?
    let language: String
    let publishedDate: Date
    
    func toDict() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let bookDict = ["title": title, "isbn": isbn, "publisher": publisher as Any, "pageCount": pageCount as Any, "authors": authors as Any, "categories": categories as Any, "coverURL": coverURL as Any, "language": language, "publishedDate": dateFormatter.string(from: publishedDate)] as [String : Any]
        
        return bookDict
    }
}
