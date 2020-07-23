//
//  GameOverPopup.swift
//  SideScroller
//
//  Created by Eric Gustin on 7/22/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class GameOverPopup : UIView {
  
  private let container: UIView = {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor = .white
    container.layer.cornerRadius = 12
    return container
  }()
  
  private let scoreLabel: UILabel = {
    let label = UILabel()
    label.text = "Score: "
    label.font = UIFont(name: "Cartooncookies", size: 25)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let bestScoreLabel: UILabel = {
    let label = UILabel()
    label.text = "Best Score: "
    label.font = UIFont(name: "Cartooncookies", size: 25)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private var score: Int?
  private lazy var bestScore = UserDefaults.standard.integer(forKey: "bestScore")
  
  private var containerInitialHeight: NSLayoutConstraint = NSLayoutConstraint()
  
  required init(score: Int?) {
    super.init(frame: .zero)
    self.score = score
    postInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    postInit()
  }
  
  private func postInit() {
    self.frame = UIScreen.main.bounds
    self.backgroundColor = UIColor.white.withAlphaComponent(0.0)
    checkIfNewBestScore()
    setUpSubviews()
    animateIn()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func checkIfNewBestScore() {
    if UserDefaults.standard.integer(forKey: "bestScore") < self.score ?? 0 {
      UserDefaults.standard.set(score, forKey: "bestScore")
    }
  }
  
  private func setUpSubviews() {
    self.addSubview(container)
    container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7).isActive = true
    containerInitialHeight = container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25)
    containerInitialHeight.isActive = true
    
    scoreLabel.text?.append("\(score ?? 0)")
    container.addSubview(scoreLabel)
    scoreLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    scoreLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 0.7*self.frame.width/8).isActive = true
    
    bestScoreLabel.text?.append("\(bestScore)")
    container.addSubview(bestScoreLabel)
    bestScoreLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    bestScoreLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 10).isActive = true
    
    
  }
  
  private func animateIn() {
    container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height/12)
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.container.transform = .identity
    }, completion: nil)
  }
}
