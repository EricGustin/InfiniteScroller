//
//  HowToPlayPopup.swift
//  Swipey Bird
//
//  Created by Eric Gustin on 7/29/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class HowToPlayPopup: UIView {
  
  let container: UIView = {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor = UIColor(red: 253/255, green: 217/255, blue: 181/255, alpha: 1.0)
    container.layer.cornerRadius = 12
    container.layer.borderColor = UIColor.black.cgColor
    container.layer.borderWidth = 1.0
    return container
  }()
  
  let howToPlayLabel: UILabel = {
    let label = UILabel()
    label.text = "HOW TO PLAY"
    label.font = UIFont(name: "Cartooncookies", size: 25)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  let instructions: [UILabel] = {
    let instructions = [UILabel(), UILabel(), UILabel()]
    instructions[0].text = "SWIPE UP TO MOVE UP"
    instructions[1].text = "SWIPE DOWN TO MOVE DOWN"
    instructions[2].text = "TAP TO STAY STILL"
    for instruction in instructions {
      instruction.font = UIFont(name: "Cartooncookies", size: 16)
      instruction.textColor = .black
      instruction.translatesAutoresizingMaskIntoConstraints = false
    }
    return instructions
  }()
  
  let stack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 10
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = UIScreen.main.bounds
    self.backgroundColor = UIColor.white.withAlphaComponent(0)
    setUpSubviews()
    animateIn()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUpSubviews() {
    
    self.addSubview(container)
    
    container.addSubview(stack)
    stack.addArrangedSubview(howToPlayLabel)
    for instruction in instructions {
      stack.addArrangedSubview(instruction)
    }
    
    stack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    stack.topAnchor.constraint(equalTo: self.topAnchor, constant: UIScreen.main.bounds.height/4).isActive = true
    
    container.centerXAnchor.constraint(equalTo: stack.centerXAnchor).isActive = true
    container.topAnchor.constraint(equalTo: stack.topAnchor, constant: -10).isActive = true
    container.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 10).isActive = true
    container.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: -10).isActive = true
    container.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: 10).isActive = true
  }
  
  private func animateIn() {
    container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height/12)
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.container.transform = .identity
    }, completion: nil)
  }
  
  func animateOut() {
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height/12)
      self.alpha = 0
    }) { (complete) in
      if complete {
        self.removeFromSuperview()
      }
    }
  }
}
