//
//  UserController.swift
//  VaporProject
//
//  Created by Anton Sokolov on 20.08.17.
//
//

//
//  User.swift
//  VaporProject
//
//  Created by Anton Sokolov on 20.08.17.
//
//

import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// RESTful interactions with our User table
final class UserController: ResourceRepresentable {
    /// 'GET' on '/user'
    /// Return an index of all available users
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    /// 'POST' on '/user' with valid JSON
    /// Creates new user
    func create(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        try user.save()
        return user
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/user/userID' we should show that specific user
    func show(_ req: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'user/userID' we should remove that resource from the database
    func delete(_ req: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/user' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try User.makeQuery().delete()
        return Response(status: .ok)
    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, user: User) throws -> ResponseRepresentable {
        // See `extension Post: Updateable`
        try user.update(for: req)
        
        // Save an return the updated post.
        try user.save()
        return user
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new User with the same ID.
    func replace(_ req: Request, user: User) throws -> ResponseRepresentable {
        // First attempt to create a new User from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.user()
        
        // Update the post with all of the properties from
        // the new post
        user.name = new.name
        try user.save()
        
        // Return the updated post
        return user
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    /// Create a user from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
}

/// Since PostController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension UserController: EmptyInitializable { }


