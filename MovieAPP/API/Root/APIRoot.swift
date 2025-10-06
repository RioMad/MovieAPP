//
//  APIRoot.swift
//  MovieAPP
//
//  Created by Anwin Km  on 06/10/25.
//
import Foundation

// MARK: - MovieService
class MovieService {
    static let shared = MovieService()
    private let apiKey = "01509ae4423029ed25043d9a386b4083"
    private let baseURL = "https://api.themoviedb.org/3"
    
    private init() {}
    
    // Fetch Popular Movies
    func fetchPopularMovies(completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/movie/popular?api_key=\(apiKey)"
        print("Fetching popular movies from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        performRequest(url: url, completion: completion)
    }
    
    
    
    // Fetch Movie Details
    func fetchMovieDetail(movieId: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        let urlString = "\(baseURL)/movie/\(movieId)?api_key=\(apiKey)"
        print("Fetching movie details for ID \(movieId): \(urlString)")
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieDetail = try decoder.decode(MovieDetail.self, from: data)
                print("Successfully fetched movie details: \(movieDetail.title)")
                completion(.success(movieDetail))
            } catch {
                print("Decoding Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Fetch Movie Videos/Trailers
    func fetchMovieVideos(movieId: Int, completion: @escaping (Result<VideosResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/movie/\(movieId)/videos?api_key=\(apiKey)"
        print("Fetching videos for movie ID \(movieId): \(urlString)")
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let videosResponse = try decoder.decode(VideosResponse.self, from: data)
                print("Successfully fetched \(videosResponse.results.count) videos")
                completion(.success(videosResponse))
            } catch {
                print("Decoding Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Search Movies
    func searchMovies(query: String, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        guard !query.isEmpty else {
            completion(.failure(NSError(domain: "Empty search query", code: -1, userInfo: nil)))
            return
        }
        
        // Encode the query string for URL
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "Invalid search query", code: -1, userInfo: nil)))
            return
        }
        
        let urlString = "\(baseURL)/search/movie?api_key=\(apiKey)&query=\(encodedQuery)"
        print("Searching movies with query '\(query)': \(urlString)")
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        performRequest(url: url, completion: completion)
    }
    
    // Private method to perform actual network request
    private func performRequest(url: URL, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw Response: \(jsonString.prefix(500))...")
            }
            
            do {
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                print("Successfully decoded \(movieResponse.results.count) movies")
                completion(.success(movieResponse))
            } catch let decodingError {
                print("Decoding Error: \(decodingError)")
                if let decodingError = decodingError as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Missing key: \(key.stringValue) - \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for type: \(type) - \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value not found for type: \(type) - \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                completion(.failure(decodingError))
            }
        }.resume()
    }
}

