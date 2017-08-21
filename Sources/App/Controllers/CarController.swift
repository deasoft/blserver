//
//  CarController.swift
//  VaporProject
//
//  Created by Anton Sokolov on 20.08.17.
//
//

import Vapor
//Import HTTP for getting all our response types, codes, etc..
import HTTP
//Adopt the ResourceRepresentable protocol in our Controller
final class CarController: ResourceRepresentable {
    
    var cars: [Car] = []
    
    //This will get called if the index in 'makeResource()' below will be called.
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Car.all().makeJSON()
        //return try JSON(node: cars)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        
        //Guard statement to make sure we are validating the data correct (we of course should also later guard for the color etc)
        guard let name = request.data["name"]?.string else {
            //Throw a Abort response, I like using the custom status to make sure the frontends have the correct message and response code
            throw Abort(Status.preconditionFailed, metadata: "Missing name")
        }
        guard let color = request.data["color"]?.string else {
            throw Abort(Status.preconditionFailed, metadata: "Missing color")
        }
        guard let milesDriven = request.data["milesDriven"]?.int else {
            throw Abort(Status.preconditionFailed, metadata: "Missing milesDriven")
        }
        
        //Create a car
        let car = Car(name: name, color: color, milesDriven: milesDriven)
        //Add it to our container object
        cars.append(car)
        //Return the newly created car
        return try car.makeJSON()
        //return try car.converted(to: JSON.self)
    }
    
    
    //This is the function the figure out what method that should be called depending on the HTTP request type. We will here start with the get.
    func makeResource() -> Resource<Car> {
        return Resource(
            index: index,
            store: create
        )
    }
}

