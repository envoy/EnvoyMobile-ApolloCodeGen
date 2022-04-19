//
//  AuthenticationService.swift
//  
//
//  Created by Brent Mifsud on 2022-04-18.
//

import Foundation

class AuthenticationService {
    enum Error: Swift.Error {
        case invalidUrl
        case networkError
        case credentialsNotFound
    }
    
    private let session = URLSession.shared
    private let fileManager = FileManager.default
    
    func getJWT(for environment: Environment, username: String, password: String) async throws -> String {
        // Construct the url for the authentication request
        let url = environment.url
            .appendingPathComponent("auth")
            .appendingPathComponent("v0")
            .appendingPathComponent("token")
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw Self.Error.invalidUrl
        }
        
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "password"),
            URLQueryItem(name: "scope", value: "first_party token.refresh public iphone")
        ]
        
        guard let finalUrl = components.url else {
            throw Self.Error.invalidUrl
        }
        
        // Add HTTP properties
        var request = URLRequest(url: finalUrl)
        request.httpMethod = "POST"
        request.addValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(environment.token)", forHTTPHeaderField: "Authorization")
        
        let credentials = Credentials(username: username, password: password)
        
        request.httpBody = try JSONEncoder().encode(credentials)
        
        // Submit Request
        let (data, urlResponse) = try await session.data(for: request)
        
        guard let httpResponse = urlResponse as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw Self.Error.networkError
        }
        
        let response = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        return response.accessToken
    }
}

struct Credentials: Encodable {
    let username: String
    let password: String
}

struct AuthResponse: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
