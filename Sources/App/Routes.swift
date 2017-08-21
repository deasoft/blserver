import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        group("api") { api in
            //Adding a sub slug to our URL and redirecting all requests to the CarController we just built.
            api.resource("cars", CarController())
        }
        
        try resource("posts", PostController.self)
        
        try resource("user", UserController.self)
        
        try resource("dir", DirectoryController.self)

    }
}
