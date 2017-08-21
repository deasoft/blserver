//
//  User.swift
//  VaporProject
//
//  Created by Anton Sokolov on 20.08.17.
//
//

import Vapor
import FluentProvider
import HTTP

final class User: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The user name
    var name: String
    
    /// The column names for `id` and `name` in the database
    static let idKey = "id"
    static let nameKey = "name"
    
    /// Creates a new User
    init(name: String) {
        self.name = name
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        name = try row.get(User.nameKey)
    }
    
    // Serializes the User to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.nameKey, name)
        return row
    }
}

// MARK: Fluent Preparation

extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Users
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.nameKey)
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
//     - Creating a new User (POST /user)
//     - Fetching a user (GET /user, GET /user/:id)
//
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(User.nameKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id)
        try json.set(User.nameKey, name)
        return json
    }
}

// MARK: HTTP

// This allows User models to be returned
// directly in route closures
extension User: ResponseRepresentable { }

// MARK: Update

// This allows the User model to be updated
// dynamically by the request.
extension User: Updateable {
    // Updateable keys are called when `user.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<User>] {
        return [
            // If the request contains a String at key "name"
            // the setter callback will be called.
            UpdateableKey(User.nameKey, String.self) { user, name in
                user.name = name
            }
        ]
    }
}
