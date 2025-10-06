//
//  FavCde.swift
//  MovieAPP
//
//  Created by Anwin Km  on 07/10/25.
//

import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let favoritesKey = "favoriteMovies"
    private var favoriteMovieIds: Set<Int> = []
    
    private init() {
        loadFavorites()
    }
    
    // Load favorites from UserDefaults
    private func loadFavorites() {
        if let savedIds = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] {
            favoriteMovieIds = Set(savedIds)
            print("📌 Loaded \(favoriteMovieIds.count) favorite movies")
        }
    }
    
    // Save favorites to UserDefaults
    private func saveFavorites() {
        let idsArray = Array(favoriteMovieIds)
        UserDefaults.standard.set(idsArray, forKey: favoritesKey)
        UserDefaults.standard.synchronize()
        print("💾 Saved \(favoriteMovieIds.count) favorite movies")
    }
    
    // Check if a movie is favorite
    func isFavorite(movieId: Int) -> Bool {
        return favoriteMovieIds.contains(movieId)
    }
    
    // Toggle favorite status
    func toggleFavorite(movieId: Int) -> Bool {
        if favoriteMovieIds.contains(movieId) {
            favoriteMovieIds.remove(movieId)
            saveFavorites()
            print("💔 Removed movie \(movieId) from favorites")
            return false
        } else {
            favoriteMovieIds.insert(movieId)
            saveFavorites()
            print("❤️ Added movie \(movieId) to favorites")
            return true
        }
    }
    
    // Add to favorites
    func addToFavorites(movieId: Int) {
        favoriteMovieIds.insert(movieId)
        saveFavorites()
    }
    
    // Remove from favorites
    func removeFromFavorites(movieId: Int) {
        favoriteMovieIds.remove(movieId)
        saveFavorites()
    }
    
    // Get all favorite movie IDs
    func getAllFavoriteIds() -> [Int] {
        return Array(favoriteMovieIds)
    }
    
    // Clear all favorites
    func clearAllFavorites() {
        favoriteMovieIds.removeAll()
        saveFavorites()
    }
}
