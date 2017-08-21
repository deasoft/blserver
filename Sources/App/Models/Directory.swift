//
//  Directory.swift
//  VaporProject
//
//  Created by Anton Sokolov on 21.08.17.
//
//

import Vapor
import FluentProvider
import HTTP

final class Directory: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The label of the phone
    var label: String
    var phoneNumber: Int
    
    /// The column names for `id` and `label` in the database

    static let idKey = "id"
    static let phoneNumberKey = "phoneNumber"
    static let labelKey = "label"
    
    /// Creates a new Directory
    init(label: String, phoneNumber: Int) {
        self.label = label
        self.phoneNumber = phoneNumber
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Directory from the
    /// database row
    init(row: Row) throws {
        label = try row.get(Directory.labelKey)
        phoneNumber = try row.get(Directory.phoneNumberKey)
    }
    
    // Serializes the Directory to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Directory.labelKey, label)
        try row.set(Directory.phoneNumberKey, phoneNumber)
        return row
    }
}

// MARK: Fluent Preparation

extension Directory: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Phones
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Directory.labelKey)
            builder.string(Directory.phoneNumberKey)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Directory (POST /phones)
//     - Fetching a phone (GET /phones, GET /phones/:id)
//
extension Directory: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            label: json.get(Directory.labelKey),
            phoneNumber: json.get(Directory.phoneNumberKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Directory.idKey, id)
        try json.set(Directory.labelKey, label)
        try json.set(Directory.phoneNumberKey, phoneNumber)
        return json
    }
}

// MARK: HTTP

// This allows Directory models to be returned
// directly in route closures
extension Directory: ResponseRepresentable { }

// MARK: Update

// This allows the Directory model to be updated
// dynamically by the request.
extension Directory: Updateable {
    // Updateable keys are called when `phone.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Directory>] {
        return [
            // If the request contains a String at key "label"
            // the setter callback will be called.
            UpdateableKey(Directory.labelKey, String.self) { phone, label in
                phone.label = label
            }
        ]
    }
}

