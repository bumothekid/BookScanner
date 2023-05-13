//
//  APIBook.swift
//  BookScanner
//
//  Created by David Riegel on 08.05.23.
//

import Foundation

struct APIBookVolume: Codable {
    let volumeInfo: APIBook
}

struct APIBook: Codable {
    let authors: [String]?
    let publisher: String?
    let categories: [String]?
    let imageLinks: Images?
    let industryIdentifiers: [Identifier]
    let language: String
    let maturityRating: String
    let pageCount: Int?
    let publishedDate: Date
    let title: String
}

struct Images: Codable {
    let smallThumbnail: String?
    let thumbnail: String?
}

struct Identifier: Codable {
    let identifier: String
    let type: String
}
