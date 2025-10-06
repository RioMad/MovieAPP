//
//  TBLCell.swift
//  MovieAPP
//
//  Created by Anwin Km  on 06/10/25.
//

import UIKit
protocol MyTableCellDelegate: AnyObject {
    func didTapFavorite(at indexPath: IndexPath)
}
class TBLCell: UITableViewCell {
    let identifier = "TBLCell"
    
    var movieId: Int?
    var onFavoriteToggle: ((Int, Bool) -> Void)?
    @IBOutlet weak var imgPoster: UIImageView!{
        didSet{
            imgPoster.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblData: UILabel!
    @IBOutlet weak var favButton: UIButton!{
        didSet{
            let imageName =  "heart"
            favButton.setImage(UIImage(systemName: imageName), for: .normal)
            favButton.tintColor = .lightGray
        }
    }
    var indexPath: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func favButtonTapped(_ sender: UIButton) {
    }
    
    func configure(with movie: Movie) {
        self.movieId = movie.id
        lblTitle.text = movie.title
        lblData.text = movie.overview
        lblRating.text = "⭐️ \(String(format: "%.1f", movie.voteAverage))"
        if let posterPath = movie.posterPath,
           let url = URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)") {
            loadImage(from: url)
        } else {
            imgPoster.image = nil
            imgPoster.backgroundColor = .systemGray5
        }
    }
    
    func updateFavoriteButtonState() {
        guard let movieId = movieId else { return }
        let isFavorite = FavoritesManager.shared.isFavorite(movieId: movieId)
        updateFavoriteButton(isFavorite: isFavorite)
    }
    
    private func updateFavoriteButton(isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        favButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    private func loadImage(from url: URL) {
        imgPoster.image = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.imgPoster.image = image
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgPoster.image = nil
        lblTitle.text = nil
        lblData.text = nil
        lblRating.text = nil
        movieId = nil
    }
}


