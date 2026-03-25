/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: NetworkManager.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/Network/
Назначение: Generic networking singleton handling URLSessions and requests. //              Универсальный синглтон для работы с сетью и запросами URLSession.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    
    // Change this to your local IP if running on device, or localhost if on Simulator
    // iPhone Simulator -> localhost works
    // Real Device -> Need Mac's IP (e.g., http://192.168.1.5:5217)
    // For now using localhost for Simulator
    private let baseURL = "http://localhost:5217/api"
    
    private init() {}
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Auth Token if exists
        if let token = TokenManager.shared.get() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(.requestFailed))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async { completion(.failure(.requestFailed)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(.unknown)) }
                return
            }
            
            // Try to read error message if status is not success
            if !(200...299).contains(httpResponse.statusCode) {
                if let data = data,
                   let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    // Special case for 401: clear token but use server's message if possible
                    if httpResponse.statusCode == 401 {
                        TokenManager.shared.clear()
                        DispatchQueue.main.async { completion(.failure(.serverError(message: errorResponse.message))) }
                    } else {
                        DispatchQueue.main.async { completion(.failure(.serverError(message: errorResponse.message))) }
                    }
                } else if httpResponse.statusCode == 401 {
                    TokenManager.shared.clear()
                    DispatchQueue.main.async { completion(.failure(.unauthorized)) }
                } else {
                    DispatchQueue.main.async { completion(.failure(.serverError(message: "Status Code: \(httpResponse.statusCode)"))) }
                }
                return
            }

            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.unknown)) }
                return
            }
            
            // Debugging log
            if let str = String(data: data, encoding: .utf8) {
                print("Server Response [\(endpoint)]: \(str)")
            }
            
            // Handle Void response success
            if T.self == Void.self && (200...299).contains(httpResponse.statusCode) {
                 DispatchQueue.main.async { completion(.success(() as! T)) }
                 return
            }
            
            do {
                let decoder = JSONDecoder()
                
                // .NET DateTime format strategy
                let df = DateFormatter()
                df.calendar = Calendar(identifier: .iso8601)
                df.locale = Locale(identifier: "en_US_POSIX")
                df.timeZone = TimeZone(secondsFromGMT: 0)
                
                decoder.dateDecodingStrategy = .custom({ decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    // Try standard ISO8601 variants
                    let formats = [
                        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ", // .NET 7+ Long form
                        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",     // Generic milliseconds
                        "yyyy-MM-dd'T'HH:mm:ssZ"          // Standard
                    ]
                    
                    for format in formats {
                        df.dateFormat = format
                        if let date = df.date(from: dateString) {
                            return date
                        }
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
                })

                let decodedResponse = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
                print("Decoding Error [\(endpoint)]: \(error)")
                DispatchQueue.main.async { completion(.failure(.decodingFailed)) }
            }
        }.resume()
    }
    func requestNoResponse(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.get() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(.requestFailed))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async { completion(.failure(.requestFailed)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(.unknown)) }
                return
            }
            
            if let str = String(data: data ?? Data(), encoding: .utf8) {
                 print("Server Response [\(endpoint)]: \(str)")
            }

            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.success(())) }
            } else {
                if let data = data,
                   let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    if httpResponse.statusCode == 401 {
                        TokenManager.shared.clear()
                    }
                    DispatchQueue.main.async { completion(.failure(.serverError(message: errorResponse.message))) }
                } else if httpResponse.statusCode == 401 {
                    TokenManager.shared.clear()
                    DispatchQueue.main.async { completion(.failure(.unauthorized)) }
                } else {
                    DispatchQueue.main.async { completion(.failure(.serverError(message: "Status Code: \(httpResponse.statusCode)"))) }
                }
            }

        }.resume()
    }
}
