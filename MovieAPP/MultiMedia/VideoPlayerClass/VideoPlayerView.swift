//
//  Untitled.swift
//  MovieAPP
//
//  Created by Anwin Km - Technology Associate-Mobile Development on 06/10/25.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let controlsContainer = UIView()
    private let playPauseButton = UIButton(type: .system)
    private let progressSlider = UISlider()
    private var isPlaying = false
    private var hideControlsTimer: Timer?
    private var timeObserver: Any?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .black
        
        // Add controls container
        controlsContainer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        controlsContainer.alpha = 1
        addSubview(controlsContainer)
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            controlsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            controlsContainer.topAnchor.constraint(equalTo: topAnchor),
            controlsContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Play / Pause button
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.tintColor = .white
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        controlsContainer.addSubview(playPauseButton)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: controlsContainer.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Progress Slider
        progressSlider.minimumTrackTintColor = .systemRed
        progressSlider.maximumTrackTintColor = .lightGray
        progressSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        controlsContainer.addSubview(progressSlider)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressSlider.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 16),
            progressSlider.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
            progressSlider.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor, constant: -10)
        ])
        
        // Tap gesture to toggle control visibility
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControlsVisibility))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Load Video
    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        layer.insertSublayer(playerLayer!, at: 0)
        
        addPeriodicTimeObserver()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    // MARK: - Player Controls
    @objc private func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            startHideTimer()
        }
        isPlaying.toggle()
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(sender.value) * totalSeconds
        let seekTime = CMTime(seconds: value, preferredTimescale: 600)
        player.seek(to: seekTime)
    }
    
    // MARK: - Progress Tracking
    private func addPeriodicTimeObserver() {
        guard let player = player else { return }
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = player.currentItem?.duration else { return }
            let currentTime = CMTimeGetSeconds(time)
            let totalTime = CMTimeGetSeconds(duration)
            self.progressSlider.value = Float(currentTime / totalTime)
        }
    }
    
    // MARK: - Control Visibility
    @objc private func toggleControlsVisibility() {
        UIView.animate(withDuration: 0.3) {
            self.controlsContainer.alpha = self.controlsContainer.alpha == 0 ? 1 : 0
        }
        if controlsContainer.alpha == 1 {
            startHideTimer()
        } else {
            hideControlsTimer?.invalidate()
        }
    }
    
    private func startHideTimer() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.controlsContainer.alpha = 0
            }
        }
    }
    
    deinit {
        hideControlsTimer?.invalidate()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
}
