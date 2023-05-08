//
//  Book.swift
//  BookScanner
//
//  Created by David Riegel on 08.05.23.
//

import Foundation

struct BookVolume: Codable {
    let volumeInfo: Book
}

struct Book: Codable {
    let authors: [String]
    let categories: [String]?
    let imageLinks: Images?
    let industryIdentifiers: [Identifier]
    let language: String
    let maturityRating: String
    let pageCount: Int
    let publishedDate: String
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
