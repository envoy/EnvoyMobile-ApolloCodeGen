//
//  Environment.swift
//  
//
//  Created by Brent Mifsud on 2022-04-18.
//

import Foundation
import ArgumentParser

enum Environment: String, Decodable, ExpressibleByArgument {
    case prod = "https://app.envoy.com/a/"
    case staging = "https://app.envoy.christmas/a/"
    
    var url: URL {
        URL(string: rawValue)!
    }
    
    var token: String {
        switch self {
        case .prod:
            return "NWMyYzk0NDEtZGIyNS00N2FlLWE1NWYtNzdmMjY0NGY1YzczOjcwNmQ5ZGM5NjllM2JkM2Q3MjhhNTY5OGRmZGQ4N2I1MGQyNWIzNmYxNDlhMDExMDJhNDFiZTQ4ZmY3YjIxYzNjYjc2NzQ4MDRlMmM1ZTkyYmI1ZGU5OWRiYzllZmUxNzAyMDZkZWYxMmE2YTQzMmU3MDU3MDFlNDExMGM4YzBj"
        case .staging:
            return "ZGViNmZlNTItYWQ2Ny0xMWU5LTkxY2YtOGJjNTQxMjgyZmZlOjg4MjU5OWI5ZDM5MTVlMWYxZWMyZTU1NzEzOGIxMjM2MDY5YTdhNjIxZmJmYWM1MDBiNzVhMDVhYjdhNWFjZDA1ZjQ1YmJlMzVkNGNlZmQwNTQ2NzA4NTJlYTgxMDQ3MzQ2OTAwNWFiZWEwMTA3YzRmMjZhYjE3NTA1YWJiZTg0"
        }
    }
    
    init?(argument: String) {
        switch argument {
        case "prod", "production", "p":
            self = .prod
        case "stg", "staging", "s":
            self = .staging
        default:
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        print("INIT FROM DECODER")
        
        switch value {
        case "prod", "production", "p":
            self = .prod
        case "stg", "staging", "s":
            self = .staging
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid Environment Value: \(value)")
            )
        }
    }
}
