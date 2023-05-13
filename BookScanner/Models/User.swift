//
//  User.swift
//  BookScanner
//
//  Created by David Riegel on 11.05.23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct User: Codable {
    let uid: String
    let email: String
    let displayName: String
    let username: String
    let avatarURL: URL?
    let createdAt: Double
    let followingPath: [String]
    let booksPath: [String]
    
    var booksReference: [DocumentReference] {
        var references = [DocumentReference]()
        
        for ref in booksPath {
            references.append(Firestore.firestore().document(ref))
        }
        
        return references
    }
    
    var followingReference: [DocumentReference] {
        var references = [DocumentReference]()
        
        for ref in followingPath {
            references.append(Firestore.firestore().document(ref))
        }
        
        return references
    }
    
    
    var searchQueries: [String] {
        [username.generateStringSequence()].flatMap { $0 } // Add display name | Split also spaces
    }
}
