//
//  DatabaseHandler.swift
//  BookScanner
//
//  Created by David Riegel on 10.05.23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import CryptoKit
import UIKit
import FirebaseStorage

class DatabaseHandler {
    static let shared = DatabaseHandler()
    private var database = Firestore.firestore()
    private var storage = Storage.storage()
    
    enum DatabaseError: Error {
        case userDoesNotExist
    }
    
    // MARK: -- Authentication
    
    public func registerUser(email: String, displayname: String, username: String, password: String) async throws {
        let hashedPassword = SHA256.hash(data: password.data(using: .utf8)!).compactMap { String(format: "%02x", $0) }.joined()
        
        let authResult = try await Auth.auth().createUser(withEmail: email, password: hashedPassword)
        try await database.collection("usernames").document(username).setData(["uid": authResult.user.uid])
        try await database.collection("users").document(authResult.user.uid).setData(["displayname": displayname, "username": username, "email": email, "createdAt": Date().timeIntervalSince1970, "avatarURL": "", "books": [DocumentReference](), "following": [DocumentReference]()])
    }
    
    public func loginUser(email: String, password: String) async throws {
        let hashedPassword = SHA256.hash(data: password.data(using: .utf8)!).compactMap { String(format: "%02x", $0) }.joined()
        
        try await Auth.auth().signIn(withEmail: email, password: hashedPassword)
    }
    
    public func checkUsernameAvailability(_ username: String) async throws -> Bool {
        let usernameReference = database.collection("usernames").document(username)
        let usernameDocument = try await usernameReference.getDocument()
        
        return !usernameDocument.exists
    }
    
    // MARK: -- User Related
    
    public func getCurrentUID() async throws -> String {
        Auth.auth().currentUser!.uid
    }
    
    public func getUserByUsername(_ username: String) async throws -> User? {
        let uid = try await getUserIdByUsername(username)
        
        return try await getUserByUserID(uid)
    }
    
    public func getUserByUserID(_ uid: String) async throws -> User? {
        guard let userData = try await database.collection("users").document(uid).getDocument().data() else { return nil }
        
        var bookReference = [String]()
        for ref in userData["books"] as? [DocumentReference] ?? [DocumentReference]() {
            bookReference.append(ref.path)
        }
        
        var followingReference = [String]()
        for ref in userData["following"] as? [DocumentReference] ?? [DocumentReference]()  {
            followingReference.append(ref.path)
        }
        
        return User(uid: uid, email: userData["email"] as! String, displayName: userData["displayname"] as! String, username: userData["username"] as! String, avatarURL: URL(string: userData["avatarURL"] as? String ?? ""), createdAt: userData["createdAt"] as! Double, followingPath: followingReference, booksPath: bookReference)
    }
    
    public func searchUser(_ search: String) async throws -> [User] {
        let endSearch = search + "~"
        let userReference = database.collection("users").whereField("username", isGreaterThanOrEqualTo: search).whereField("username", isLessThanOrEqualTo: endSearch)
        let userDocuments = try await userReference.getDocuments()
        
        var users = [User]()
        for doc in userDocuments.documents {
            let userData = doc.data()
            
            var bookReference = [String]()
            for ref in userData["books"] as? [DocumentReference] ?? [DocumentReference]() {
                bookReference.append(ref.path)
            }
            
            var followingReference = [String]()
            for ref in userData["following"] as? [DocumentReference] ?? [DocumentReference]()  {
                followingReference.append(ref.path)
            }
            
            let user = User(uid: doc.documentID, email: userData["email"] as! String, displayName: userData["displayname"] as! String, username: userData["username"] as! String, avatarURL: URL(string: userData["avatarURL"] as? String ?? ""), createdAt: userData["createdAt"] as! Double, followingPath: followingReference, booksPath: bookReference)
            users.append(user)
        }
        
        return users
    }

    public func uploadProfilePicture(_ picture: UIImage, _ uid: String) async throws {
        guard let imageData = picture.jpegData(compressionQuality: 0.2) else { return }
        let storageReference = storage.reference().child("avatars").child(uid)
        _ = try await storageReference.putDataAsync(imageData)
        
        
        try await database.collection("users").document(uid).updateData(["avatarURL": storageReference.downloadURL().absoluteString])
    }
    
    public func resetProfilePicture(_ uid: String) async {
        let storageRefernce = storage.reference().child("avatars").child(uid)
        
        do {
            try await storageRefernce.delete()
        } catch {
            print("couldn't delete profile picture from storage")
        }
        
        do {
            try await database.collection("users").document(uid).updateData(["avatarURL": ""])
        } catch {
            print("an error occured while removing the avatarURL from database user")
        }
    }
    
    // MARK: -- Book Related
    
    public func getBookOfTheWeek() async -> Book {
        return Book(title: "", isbn: "", publisher: "", pageCount: 0, authors: nil, categories: nil, coverURL: "", language: "", publishedDate: Date())
    }
    
    public func addBookToUser(book: Book, user: User) async throws {
        let booksArrayReference = database.collection("users").document(user.uid)
        try await booksArrayReference.updateData(["books": FieldValue.arrayUnion([database.collection("books").document(book.isbn)])])
    }
    
    public func addBookToDatabase(_ book: Book) async throws {
        guard try await getBookFromDatabaseByISBN(book.isbn) == nil else {
            return
        }
        
        try await database.collection("books").document(book.isbn).setData(book.toDict())
    }
    
    public func getBookFromDatabaseByISBN(_ isbn: String) async throws -> Book? {
        let bookReference = database.collection("books").document(isbn)
        let bookDocument = try await bookReference.getDocument()
        guard let bookData = bookDocument.data() else { return nil }
        
        return Book(title: bookData["title"] as! String, isbn: bookData["isbn"] as! String, publisher: bookData["publisher"] as? String, pageCount: bookData["pageCount"] as? Int, authors: bookData["authors"] as? [String], categories: bookData["categories"] as? [String], coverURL: bookData["coverURL"] as? String, language: bookData["language"] as! String, publishedDate: DateFormatter().customStringToDate(string: bookData["publishedDate"] as! String)!)
    }
    
    public func getBooksFromDatabaseByISBN(_ isbns: [String]) async throws -> [Book]? {
        let bookReference = database.collection("books").whereField(FieldPath.documentID(), in: isbns)
        let bookDocuments = try await bookReference.getDocuments()
        
        var books = [Book]()
        for doc in bookDocuments.documents {
            let bookData = doc.data()
            let book = Book(title: bookData["title"] as! String, isbn: bookData["isbn"] as! String, publisher: bookData["publisher"] as? String, pageCount: bookData["pageCount"] as? Int, authors: bookData["authors"] as? [String], categories: bookData["categories"] as? [String], coverURL: bookData["coverURL"] as? String, language: bookData["language"] as! String, publishedDate: DateFormatter().customStringToDate(string: bookData["publishedDate"] as! String)!)
            
            books.append(book)
        }
        
        return !books.isEmpty ? books : nil
    }
    
    // MARK: -- Helper Functions
    
    private func getUserIdByUsername(_ username: String) async throws -> String {
        return try await database.collection("usernames").document(username).getDocument().data()?["uid"] as? String ?? ""
    }
}
