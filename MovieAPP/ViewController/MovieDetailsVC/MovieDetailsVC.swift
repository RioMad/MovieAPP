//
//  MovieDetailsVC.swift
//  MovieAPP
//
//  Created by Anwin Km  on 06/10/25.
//

import UIKit

class MovieDetailsVC: UIViewController {
    private let movieId: Int
    private var movieDetail: MovieDetail?
    private var videos: [Video] = []
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backdropImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let runtimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Overview"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trailersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Trailers & Videos"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trailersStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(movieId: Int) {
        self.movieId = movieId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        fetchMovieData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        if let navigationBar = self.navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.tintColor = .white
            navigationItem.backButtonDisplayMode = .minimal
        }
    }
    
    private func setupNavigationBar() {
        // Add favorite button to navigation bar
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        favoriteButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = favoriteButton
        
        updateFavoriteButton()
    }
    
    @objc private func favoriteButtonTapped() {
        let isFavorite = FavoritesManager.shared.toggleFavorite(movieId: movieId)
        updateFavoriteButton()
        
        // Post notification to update table view
        NotificationCenter.default.post(name: NSNotification.Name("FavoriteDidChange"), object: nil)
        
        let message = isFavorite ? "Added to favorites ❤️" : "Removed from favorites 💔"
        showToast(message: message)
    }
    
    private func updateFavoriteButton() {
        let isFavorite = FavoritesManager.shared.isFavorite(movieId: movieId)
        let imageName = isFavorite ? "heart.fill" : "heart"
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName, withConfiguration: config)
    }
    
    private func showToast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backdropImageView)
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(taglineLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(genresLabel)
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(runtimeLabel)
        contentView.addSubview(overviewTitleLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(trailersTitleLabel)
        contentView.addSubview(trailersStackView)
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: 220),
            
            posterImageView.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: -60),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            posterImageView.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            taglineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            taglineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            taglineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            ratingLabel.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 12),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            genresLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 8),
            genresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genresLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            releaseDateLabel.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 4),
            releaseDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            runtimeLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 4),
            runtimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            overviewTitleLabel.topAnchor.constraint(equalTo: runtimeLabel.bottomAnchor, constant: 24),
            overviewTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            overviewLabel.topAnchor.constraint(equalTo: overviewTitleLabel.bottomAnchor, constant: 8),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            trailersTitleLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            trailersTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trailersTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            trailersStackView.topAnchor.constraint(equalTo: trailersTitleLabel.bottomAnchor, constant: 12),
            trailersStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trailersStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trailersStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchMovieData() {
        activityIndicator.startAnimating()
        
        let group = DispatchGroup()
        
        // Fetch movie details
        group.enter()
        MovieService.shared.fetchMovieDetail(movieId: movieId) { [weak self] result in
            switch result {
            case .success(let detail):
                self?.movieDetail = detail
                DispatchQueue.main.async {
                    self?.updateUI(with: detail)
                }
            case .failure(let error):
                print("Failed to fetch movie details: \(error)")
            }
            group.leave()
        }
        
        // Fetch movie videos
        group.enter()
        MovieService.shared.fetchMovieVideos(movieId: movieId) { [weak self] result in
            switch result {
            case .success(let videosResponse):
                self?.videos = videosResponse.results
                DispatchQueue.main.async {
                    self?.updateTrailers()
                }
            case .failure(let error):
                print("Failed to fetch videos: \(error)")
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    private func updateUI(with detail: MovieDetail) {
        title = detail.title
        titleLabel.text = detail.title
        taglineLabel.text = detail.tagline
        overviewLabel.text = detail.overview
        
        if let rating = detail.voteAverage {
            ratingLabel.text = "⭐️ \(String(format: "%.1f", rating))/10"
        }
        
        if let genres = detail.genres, !genres.isEmpty {
            let genreNames = genres.map { $0.name }.joined(separator: ", ")
            genresLabel.text = "Genres: \(genreNames)"
        }
        
        if let releaseDate = detail.releaseDate {
            releaseDateLabel.text = "Release Date: \(releaseDate)"
        }
        
        if let runtime = detail.runtime {
            let hours = runtime / 60
            let minutes = runtime % 60
            runtimeLabel.text = "Runtime: \(hours)h \(minutes)m"
        }
        
        // Load backdrop image
        if let backdropPath = detail.backdropPath,
           let url = URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath)") {
            loadImage(from: url, into: backdropImageView)
        }
        
        // Load poster image
        if let posterPath = detail.posterPath,
           let url = URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)") {
            loadImage(from: url, into: posterImageView)
        }
    }
    
    private func updateTrailers() {
        trailersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if videos.isEmpty {
            let noTrailersLabel = UILabel()
            noTrailersLabel.text = "No trailers available"
            noTrailersLabel.textColor = .secondaryLabel
            noTrailersLabel.font = .systemFont(ofSize: 14)
            trailersStackView.addArrangedSubview(noTrailersLabel)
            return
        }
        
        for video in videos {
            let button = createTrailerButton(for: video)
            trailersStackView.addArrangedSubview(button)
        }
    }
    
    private func createTrailerButton(for video: Video) -> UIButton {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.numberOfLines = 0
        
        let title = "\(video.type): \(video.name)"
        button.setTitle("▶️ \(title)", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        button.addTarget(self, action: #selector(trailerTapped), for: .touchUpInside)
        button.tag = videos.firstIndex(where: { $0.id == video.id }) ?? 0
        
        return button
    }
    
    @objc private func trailerTapped(_ sender: UIButton) {
        let video = videos[sender.tag]
        
        if video.site == "YouTube" {
            if let url = URL(string: "https://www.youtube.com/watch?v=\(video.key)") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}
