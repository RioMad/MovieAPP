//
//  Home+Extesnion.swift
//  MovieAPP
//
//  Created by Anwin Km  on 06/10/25.
//

import UIKit

extension HomeVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell else {
            return UICollectionViewCell()
        }
        cell.imgMovie.image = UIImage(named:  items[indexPath.row])
        cell.layer.cornerRadius = 12
        
        return cell
    }
}
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TBLCell", for: indexPath) as? TBLCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.indexPath = indexPath
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = movies[indexPath.row]
        print("Selected movie: \(movie.title) (ID: \(movie.id))")
        let detailVC = MovieDetailsVC(movieId: movie.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
