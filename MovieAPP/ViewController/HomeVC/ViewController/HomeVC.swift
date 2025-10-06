//
//  HomeVC.swift
//  MovieAPP
//
//  Created by Anwin Km  on 06/10/25.
//

import UIKit

class HomeVC: UIViewController, UITextFieldDelegate {
    var favorites: [Bool] = []
    var movies: [Movie] = []
    var shouldNavigateToDetail = true
    var isSearching = false
    @IBOutlet weak var tableView: UITableView!
    var timer: Timer?
    var currentIndex = 0
    @IBOutlet weak var collectionView: UICollectionView!
    let items: [String] = ["1", "2", "3","4","5"]
    @IBOutlet weak var searchView: UIView!{
        didSet{
            searchView.layer.cornerRadius = 14
        }
    }
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    @IBOutlet weak var tfSerach: UITextField!{
        didSet{
            
            tfSerach.attributedPlaceholder = NSAttributedString(
                string: "Search Movies",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#BABABA", alpha: 1.0) ?? .gray]
            )
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tfSerach.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "CollectionCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CollectionCell")
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 16
            layout.itemSize = CGSize(width: collectionView.frame.width * 0.6, height: collectionView.frame.height * 0.8)
        }
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
        startAutoScroll()
        let tbnib = UINib(nibName: "TBLCell", bundle: nil)
        tableView.register(tbnib, forCellReuseIdentifier: "TBLCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        fetchMovies()
        favorites = Array(repeating: false, count: movies.count)
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfSerach.resignFirstResponder()
        searchButtonTapped()
        return true
    }
    func setupActions() {
        tfSerach.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    @objc  func searchButtonTapped() {
        guard let query = tfSerach.text, !query.isEmpty else {
            showAlert(title: "Empty Search", message: "Please enter a movie name to search")
            fetchMovies()
            return
        }
        
        tfSerach.resignFirstResponder()
        searchMovies(query: query)
    }
    func startAutoScroll() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(moveToNextCell), userInfo: nil, repeats: true)
    }
    func showNoResultsAlert(query: String) {
        let alert = UIAlertController(
            title: "No Results",
            message: "No movies found for '\(query)'",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    @objc  func moveToNextCell() {
        guard items.count > 0 else { return }
        
        currentIndex = (currentIndex + 1) % items.count
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    func fetchMovies() {
        activityIndicator.startAnimating()
        
        MovieService.shared.fetchPopularMovies { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let movieResponse):
                    print("✅ Successfully fetched \(movieResponse.results.count) movies")
                    self?.movies = movieResponse.results
                    self?.tableView.reloadData()
                    
                case .failure(let error):
                    print("❌ Error fetching movies: \(error.localizedDescription)")
                    self?.showError(error)
                }
            }
        }
    }
    func searchMovies(query: String) {
        guard !query.isEmpty else {
            isSearching = false
            fetchMovies()
            return
        }
        
        isSearching = true
        activityIndicator.startAnimating()
        
        MovieService.shared.searchMovies(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let movieResponse):
                    print("🔍 Found \(movieResponse.results.count) movies for query: \(query)")
                    self?.movies = movieResponse.results
                    self?.tableView.reloadData()
                    
                    if movieResponse.results.isEmpty {
                        self?.showNoResultsAlert(query: query)
                    }
                    
                case .failure(let error):
                    print("❌ Error searching movies: \(error.localizedDescription)")
                    self?.showError(error)
                }
            }
        }
    }
    func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to fetch movies: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchMovies()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    deinit {
        timer?.invalidate()
    }
}

