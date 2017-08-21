//
//  DirectoryController.swift
//  VaporProject
//
//  Created by Anton Sokolov on 21.08.17.
//
//

import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Directory table
final class DirectoryController: ResourceRepresentable {
    /// When users call 'GET' on '/directory'
    /// it should return an index of all available phones
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Directory.all().makeJSON()
    }
    
    /// When consumers call 'POST' on '/directory' with valid JSON
    /// create and save new phone
    func create(_ req: Request) throws -> ResponseRepresentable {
        let phone = try req.phone()
        try phone.save()
        return phone
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/directory/1333288' we should show that specific phone
    func show(_ req: Request, phone: Directory) throws -> ResponseRepresentable {
        return phone
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'phones/l245349' we should remove that resource from the database
    func delete(_ req: Request, phone: Directory) throws -> ResponseRepresentable {
        try phone.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/phones' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Directory.makeQuery().delete()
        return Response(status: .ok)
    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, phone: Directory) throws -> ResponseRepresentable {
        // See `extension DIrectory: Updateable`
        try phone.update(for: req)
        
        // Save an return the updated phone.
        try phone.save()
        return phone
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Phone with the same ID.
    func replace(_ req: Request, phone: Directory) throws -> ResponseRepresentable {
        // First attempt to create a new Phone from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.phone()
        
        // Update the phone with all of the properties from
        // the new phone
        phone.label = new.label
        try phone.save()
        
        // Return the updated phone
        return phone
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Directory> {
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
    /// Create a phone from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func phone() throws -> Directory {
        guard let json = json else { throw Abort.badRequest }
        return try Directory(json: json)
    }
}

/// Since DirectoryController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension DirectoryController: EmptyInitializable { }

