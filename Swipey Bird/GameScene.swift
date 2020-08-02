//
//  GameScene.swift
//  SideScroller
//
//  Created by Eric Gustin on 7/21/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  let LEADERBOARD_ID = "com.eric.SwipeyBird"
  
  private var background = [SKSpriteNode]()
  private var player: SKSpriteNode!
  private var playerYVelocity: Double = 0
  private var otherObjectsSpeed: Double = 6
  private var bottomObstacles: [SKSpriteNode] = []
  private var topObstacles: [SKSpriteNode] = []
  
  private var isGameBegan = false
  private var isGamePaused = false
  private var isAnimatingDeath = false
  
  private var playerTextureAtlas = SKTextureAtlas()
  private var playerTextureArray = [SKTexture]()
  
  private var topOfGroundY: CGFloat!
  
  private var scoreLabel: UILabel?
  private var score: Int?
  
  private let tapToStartLabel = UILabel()
  private var questionMarkButton: UIButton?
  //private var noAdsButton: UIButton?
  
  private var howToPlayPopup: HowToPlayPopup?
  
  override func didMove(to view: SKView) {
    playerTextureAtlas = SKTextureAtlas(named: "playerFlying")
    for i in 1...playerTextureAtlas.textureNames.count {
      playerTextureArray.append(SKTexture(imageNamed: "frame-\(i).png"))
    }
    topOfGroundY = 6*(self.scene?.size.height)!/14
    physicsWorld.gravity = .zero
    setUpNodes()
    setUpSubviews()
    setUpGestureRecognizers()
  }
  
  override func update(_ currentTime: TimeInterval) {
    if !isGamePaused  {
      if isGameBegan {
        moveObstacles()
        updateScore()
      }
      animateTapToStartLabel()
      moveGround()
      moveBackground()
      movePlayer()
    }
    if game.isOver {
      game.isOver = false
      scoreLabel?.removeFromSuperview()
      let gameScene = GameScene(size: self.size)
      gameScene.scaleMode = self.scaleMode
      gameScene.anchorPoint = self.anchorPoint
      let animation = SKTransition.fade(withDuration: 1.0)
      self.view?.presentScene(gameScene, transition: animation)
    }
  }
  
  deinit {
    
  }
  
  private func setUpNodes() {
    createBackground()
    createGround()
    createPlayer()
    // obstacles created after the first click
  }
  
  private func setUpSubviews() {
    score = 0
    scoreLabel = UILabel()
    scoreLabel?.text = "\(score ?? 0)"
    scoreLabel?.font = UIFont(name: "Cartooncookies", size: 49)
    scoreLabel?.textColor = .black
    scoreLabel?.translatesAutoresizingMaskIntoConstraints = false
    view?.addSubview(scoreLabel!)
    scoreLabel?.centerXAnchor.constraint(equalTo: view!.centerXAnchor).isActive = true
    scoreLabel?.topAnchor.constraint(equalTo: view!.topAnchor, constant: UIScreen.main.bounds.height/8).isActive = true
    
    tapToStartLabel.text = "TAP TO START"
    tapToStartLabel.font = UIFont(name: "Cartooncookies", size: 22)
    tapToStartLabel.textColor = .black
    tapToStartLabel.translatesAutoresizingMaskIntoConstraints = false
    view?.addSubview(tapToStartLabel)
    tapToStartLabel.centerXAnchor.constraint(equalTo: view!.centerXAnchor).isActive = true
    tapToStartLabel.topAnchor.constraint(equalTo: view!.topAnchor, constant: UIScreen.main.bounds.height/4).isActive = true
    
    questionMarkButton = UIButton()
    questionMarkButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(questionMarkButtonClicked)))
    questionMarkButton?.setImage(UIImage(named: "questionmark"), for: .normal)
    questionMarkButton?.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
    questionMarkButton?.translatesAutoresizingMaskIntoConstraints = false
    view!.addSubview(questionMarkButton!)
    questionMarkButton?.trailingAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
    questionMarkButton?.topAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
    
//    noAdsButton = UIButton()
//    noAdsButton?.setImage(UIImage(named: "noads"), for: .normal)
//    noAdsButton?.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
//    noAdsButton?.translatesAutoresizingMaskIntoConstraints = false
//    view!.addSubview(noAdsButton!)
//    noAdsButton?.leadingAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.leadingAnchor, constant: -10).isActive = true
//    noAdsButton?.centerYAnchor.constraint(equalTo: questionMarkButton!.centerYAnchor).isActive = true
  }
  
  
  private func createBackground() {
    //  Set up background
    for i in 0..<2 {
      background.append(SKSpriteNode(imageNamed: "background@4x"))
      background[i].name = "Background"
      let scale = (self.scene?.size.height)! / background[i].frame.height
      background[i].setScale(scale)
      background[i].anchorPoint = CGPoint(x: 0.5, y: 0.5)
      background[i].zPosition = -3
      background[i].position = CGPoint(x: CGFloat(i)*background[i].frame.width, y: 0)
      self.addChild(background[i])
    }
  }
  
  private func createGround() {
    //  Set up ground
    for i in 0..<2 {
      let groundImage = SKSpriteNode(imageNamed: "ground@4x")
      groundImage.name = "Ground"
      groundImage.size = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!/7)
      groundImage.anchorPoint = CGPoint(x: 0.5, y: 0.5)
      groundImage.zPosition = -1
      groundImage.position = CGPoint(x: CGFloat(i)*groundImage.size.width, y: -self.frame.size.height/2 + self.scene!.size.height/28)
      groundImage.physicsBody = SKPhysicsBody(rectangleOf: groundImage.size)
      groundImage.physicsBody?.isDynamic = false
      self.addChild(groundImage)
    }
  }
  
  private func createPlayer() {
    player = SKSpriteNode(imageNamed: playerTextureAtlas.textureNames[0])
    player.name = "Player"
    player.zPosition = 1
    player.setScale(CGFloat(0.2))
    player.position = CGPoint(x: -(scene?.frame.width)!/8, y: 0)
    
    let offsetX = player.size.width * player.anchorPoint.x
    let offsetY = player.size.height * player.anchorPoint.y
    player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: offsetX*1.08, height: offsetY*1.25), center: CGPoint(x: player.frame.maxY - player.frame.width*0.38, y: player.frame.midY))
    player.physicsBody?.affectedByGravity = true
    player.physicsBody?.restitution = 0.0
    player.physicsBody?.contactTestBitMask = player.physicsBody?.collisionBitMask ?? 0
    player.run(SKAction.repeatForever(SKAction.animate(with: playerTextureArray, timePerFrame: 0.15)))
    

    scene?.addChild(player)
  }
  
  private func createObstacles() {
    for i in 0...3 {
      let randomYScale = CGFloat.random(in: -1/8...3/8)
      
      topObstacles.append(SKSpriteNode(imageNamed: "upsideDownTube@4x"))
      topObstacles[i].xScale = 1.75
      topObstacles[i].size = CGSize(width: topObstacles[i].frame.width, height: (self.scene?.frame.height)!)
      topObstacles[i].yScale = 0.75
      topObstacles[i].physicsBody?.isDynamic = false
      topObstacles[i].zPosition = -2
      topObstacles[i].name = "TopObstacle"
      if i == 0 {
        topObstacles[i].position = CGPoint(x: CGFloat(i+1)*(self.scene?.size.width)!/2, y: self.scene!.frame.maxY - self.scene!.frame.height*0.125 + self.scene!.frame.height/12)
      } else {
        topObstacles[i].position = CGPoint(x: CGFloat(i+1)*(self.scene?.size.width)!/2, y: self.scene!.frame.maxY - self.scene!.frame.height*randomYScale + self.scene!.frame.height/12 + self.scene!.frame.height/14)
      }
      topObstacles[i].physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: topObstacles[i].frame.width/6, height: topObstacles[i].frame.height))
      topObstacles[i].physicsBody?.affectedByGravity = false
      topObstacles[i].physicsBody?.isDynamic = false
      scene?.addChild(topObstacles[i])
      
      bottomObstacles.append(SKSpriteNode(imageNamed: "skyscraper@4x"))
      bottomObstacles[i].xScale = 0.4
     bottomObstacles[i].size = CGSize(width: bottomObstacles[i].frame.width, height: (self.scene?.size.height)!)
      bottomObstacles[i].yScale = 0.75
      bottomObstacles[i].zPosition = -2
      bottomObstacles[i].name = "BottomObstacle"
      if i == 0 {
        bottomObstacles[i].position = CGPoint(x: CGFloat(i+1)*(self.scene?.size.width)!/2, y: self.scene!.frame.minY + self.scene!.frame.height*0.125 - self.scene!.frame.height/12)
      } else {
        bottomObstacles[i].position = CGPoint(x: CGFloat(i+1)*(self.scene?.size.width)!/2, y: self.scene!.frame.minY + self.scene!.frame.height*(0.25-randomYScale) - self.scene!.frame.height/12 + self.scene!.frame.height/14)
      }
      bottomObstacles[i].physicsBody = SKPhysicsBody(texture: bottomObstacles[i].texture!, size: CGSize(width: bottomObstacles[i].texture!.size().width*0.4, height: self.scene!.size.height*0.75))
      bottomObstacles[i].physicsBody?.affectedByGravity = false
      bottomObstacles[i].physicsBody?.isDynamic = false
      scene?.addChild(bottomObstacles[i])
    }

  }
  
  private func moveGround() {
    self.enumerateChildNodes(withName: "Ground") { (node, error) in
      node.position.x -= CGFloat(self.otherObjectsSpeed)
      if node.position.x < -(self.scene?.size.width)! {
        node.position.x += ((self.scene?.size.width)!)*2
      }
    }
  }
  
  private func moveBackground() {
    self.enumerateChildNodes(withName: "Background") { (node, error) in
      node.position.x -= 0.1
      if node.position.x < -node.frame.width {
        node.position.x += (node.frame.width*2)
      }
    }
  }
  
  private func moveObstacles() {
    let randomYScale = CGFloat.random(in: -1/8...3/8)
    self.enumerateChildNodes(withName: "BottomObstacle") { (node, error) in
      node.position.x -= CGFloat(self.otherObjectsSpeed)
      if node.position.x < -((self.scene?.size.width)!/2) - node.frame.width/2 {
        node.position.x = (self.scene?.size.width)!
        node.position.y = self.scene!.frame.minY + self.scene!.frame.height*(0.25-randomYScale) - self.scene!.frame.height/12 + self.scene!.frame.height/14
      }
      if self.player.position.y > (self.scene?.frame.maxY)! && abs(node.position.x - self.player.position.x) <= 2  {
        self.collision(between: self.player, object: node)
      }
    }
    self.enumerateChildNodes(withName: "TopObstacle") { (node, error) in
      node.position.x -= CGFloat(self.otherObjectsSpeed)
      if node.position.x < -((self.scene?.size.width)!/2) - node.frame.width/2 {
        node.position.x = (self.scene?.size.width)!
        node.position.y = self.scene!.frame.maxY - self.scene!.frame.height*randomYScale + self.scene!.frame.height/12 + self.scene!.frame.height/14
        
      }
    }
  }
  
  private func movePlayer() {
    player.position.y += CGFloat(playerYVelocity)
  }
  
  private func updateScore() {
    self.enumerateChildNodes(withName: "BottomObstacle") { (node, error) in
      if abs(node.position.x - self.player.position.x) <= CGFloat(self.otherObjectsSpeed/2) {
        self.score! += 1
        self.scoreLabel?.text = "\(self.score ?? 0)"
        self.otherObjectsSpeed += 0.04
      }
    }
  }
  
  private func animateTapToStartLabel() {
    if self.tapToStartLabel.layer.animationKeys()?.count == nil {
      UIView.animate(withDuration: 1, animations: {
        self.tapToStartLabel.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
      }) { _ in
        UIView.animate(withDuration: 1) {
          self.tapToStartLabel.transform = .identity
        }
      }
    }
    
  }
    
  private func setUpGestureRecognizers() {
    physicsWorld.contactDelegate = self
    let slideUp = UISwipeGestureRecognizer(target: self, action: #selector(changeGravity))
    slideUp.direction = .up
    view?.addGestureRecognizer(slideUp)
    let slideDown = UISwipeGestureRecognizer(target: self, action: #selector(changeGravity))
    slideDown.direction = .down
    view?.addGestureRecognizer(slideDown)
  }
  
  private func collision(between player: SKNode, object: SKNode) {
    if !isGamePaused {
      scoreLabel?.isHidden = true
      showPlayAgainPopup()
    }
    isGamePaused = true
    if object.name == "Ground" {
      player.physicsBody?.isResting = true  // Ensures that the player will only make contact with the ground once
      endGame()
    }
    if object.name == "BottomObstacle" || object.name == "TopObstacle" {
      physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
      player.run(SKAction.rotate(byAngle: -CGFloat.pi/2, duration: 0.7))
      for i in 0..<bottomObstacles.count {
        bottomObstacles[i].physicsBody = nil
        topObstacles[i].physicsBody = nil
      }
    }
  }
  
  private func endGame() {
    player.removeAllActions()
  }
  
  private func showPlayAgainPopup() {
    let playAgainPopup = GameOverPopup(score: score)
    self.view?.addSubview(playAgainPopup)
    let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
    bestScoreInt.value = Int64(score!)
    GKScore.report([bestScoreInt]) { (error) in
      if error != nil {
        print(error!.localizedDescription)
      }
    }
  }
  
  
  func didBegin(_ contact: SKPhysicsContact) {
    guard let nodeA = contact.bodyA.node else { return }
    guard let nodeB = contact.bodyB.node else { return }
    if nodeA.name == "Player" {
      collision(between: nodeA, object: nodeB)
    } else if nodeB.name == "Player" {
      collision(between: nodeB, object: nodeA)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !isGameBegan {
      isGameBegan = true
      tapToStartLabel.removeFromSuperview()
      questionMarkButton?.removeFromSuperview()
     // noAdsButton?.removeFromSuperview()
      howToPlayPopup?.animateOut()
      createObstacles()
    }
    if !isGamePaused {
      physicsWorld.gravity = CGVector(dx: 0, dy: 0)
      playerYVelocity = 0
    }
  }
  
  @objc func changeGravity(_ sender: UISwipeGestureRecognizer) {
    if !isGamePaused {
      guard sender.view != nil else { return }
      if sender.direction == .up {
        playerYVelocity = 19.5 + Double(score!)*0.13
      }
      if sender.direction == .down {
        playerYVelocity = -19.5 - Double(score!)*0.13
      }
    }
  }
  
  @objc func questionMarkButtonClicked() {
    questionMarkButton?.removeFromSuperview()
    howToPlayPopup = HowToPlayPopup()
    self.view?.addSubview(howToPlayPopup!)
  }
  
}
