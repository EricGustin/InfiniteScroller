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

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  private var background = [SKSpriteNode]()
  private var player: SKSpriteNode!
  private var playerYVelocity: Double = 0
  private var bottomObstacles: [SKSpriteNode] = []
  private var topObstacles: [SKSpriteNode] = []
  
  private var isGamePaused = false
  
  private var playerTextureAtlas = SKTextureAtlas()
  private var playerTextureArray = [SKTexture]()
  
  private var topOfGroundY: CGFloat!
  
  private var scoreLabel: UILabel?
  private var score: Int?
  
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
    if !isGamePaused {
      moveGround()
      moveBackground()
      moveObstacles()
      movePlayer()
      updateScore()
    }
  }
  
  private func setUpNodes() {
    createBackground()
    createGround()
    createPlayer()
    createObstacles()
  }
  
  private func setUpSubviews() {
    score = 0
    scoreLabel = UILabel()
    scoreLabel?.text = "\(score ?? 0)"
    scoreLabel?.font = UIFont(name: "Cartooncookies", size: 49)
    scoreLabel?.translatesAutoresizingMaskIntoConstraints = false
    view?.addSubview(scoreLabel!)
    scoreLabel?.centerXAnchor.constraint(equalTo: view!.centerXAnchor).isActive = true
    scoreLabel?.topAnchor.constraint(equalTo: view!.topAnchor, constant: UIScreen.main.bounds.height/8).isActive = true
  }
  
  private func createBackground() {
    //  Set up background
    for i in 0..<2 {
      background.append(SKSpriteNode(imageNamed: "background@4x"))
      background[i].name = "Background"
      let scale = (self.scene?.size.height)! / background[i].frame.height
      background[i].setScale(scale)
      background[i].anchorPoint = CGPoint(x: 0.5, y: 0.5)
      background[i].zPosition = -2
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
      groundImage.position = CGPoint(x: CGFloat(i)*groundImage.size.width, y: -self.frame.size.height/2)
      groundImage.physicsBody = SKPhysicsBody(rectangleOf: groundImage.size)
      groundImage.physicsBody?.isDynamic = false
      self.addChild(groundImage)
    }
  }
  
  private func createPlayer() {
    player = SKSpriteNode(imageNamed: playerTextureAtlas.textureNames[0])
    player.name = "Player"
    player.zPosition = 0
    player.setScale(CGFloat(0.2))
    player.position = CGPoint(x: -(scene?.frame.width)!/12, y: 0)
    
    let offsetX = player.size.width * player.anchorPoint.x
    let offsetY = player.size.height * player.anchorPoint.y
    player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: offsetX*1.1, height: offsetY*1.25), center: CGPoint(x: player.frame.maxY - player.frame.width*0.4, y: player.frame.midY))
    player.physicsBody?.affectedByGravity = true
    player.physicsBody?.contactTestBitMask = player.physicsBody?.collisionBitMask ?? 0
    player.run(SKAction.repeatForever(SKAction.animate(with: playerTextureArray, timePerFrame: 0.15)))
    

    scene?.addChild(player)
  }
  
  private func createObstacles() {
    for i in 0...3 {
      let randomYScale = CGFloat.random(in: 0.25...0.75)
      
      topObstacles.append(SKSpriteNode(imageNamed: "upsideDownTube@4x"))
      topObstacles[i].xScale = 1.75
      topObstacles[i].size = CGSize(width: topObstacles[i].frame.width, height: (self.scene?.size.height)!)
      topObstacles[i].yScale = 0.75 - randomYScale
      topObstacles[i].physicsBody?.isDynamic = false
      topObstacles[i].zPosition = 0
      topObstacles[i].name = "TopObstacle"
      topObstacles[i].position = CGPoint(x: CGFloat(i+1)*(self.scene?.size.width)!/2, y: (self.scene?.size.height)!/2 - topObstacles[i].frame.height/2)
      topObstacles[i].physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: topObstacles[i].frame.width/6, height: topObstacles[i].frame.height))
      topObstacles[i].physicsBody?.affectedByGravity = false
      topObstacles[i].physicsBody?.isDynamic = false
      scene?.addChild(topObstacles[i])
      
      bottomObstacles.append(SKSpriteNode(imageNamed: "tube@4x"))
      bottomObstacles[i].xScale = 1.75
      bottomObstacles[i].size = CGSize(width: bottomObstacles[i].frame.width, height: (self.scene?.size.height)!)
      bottomObstacles[i].yScale = randomYScale
      bottomObstacles[i].zPosition = 0
      bottomObstacles[i].name = "BottomObstacle"
      bottomObstacles[i].position = CGPoint(x: CGFloat(i+1)*(self.scene?.size.width)!/2, y: bottomObstacles[i].size.height/2-6*(self.scene?.size.height)!/14)
      bottomObstacles[i].physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bottomObstacles[i].frame.width/6, height: bottomObstacles[i].frame.height))
      bottomObstacles[i].physicsBody?.affectedByGravity = false
      bottomObstacles[i].physicsBody?.isDynamic = false
      scene?.addChild(bottomObstacles[i])
    }

  }
  
  private func moveGround() {
    self.enumerateChildNodes(withName: "Ground") { (node, error) in
      node.position.x -= 3
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
    let random = CGFloat.random(in: 0.25...0.75)
    self.enumerateChildNodes(withName: "BottomObstacle") { (node, error) in
      node.position.x -= 3
      if node.position.x < -((self.scene?.size.width)!/2) - node.frame.width/2 {
        node.position.x = (self.scene?.size.width)!
        node.yScale = random
        node.position.y = node.frame.height/2-self.topOfGroundY
      }
    }
    self.enumerateChildNodes(withName: "TopObstacle") { (node, error) in
      node.position.x -= 3
      if node.position.x < -((self.scene?.size.width)!/2) - node.frame.width/2 {
        node.position.x = (self.scene?.size.width)!
        node.yScale = 0.75 - random
        node.position.y = (self.scene?.size.height)!/2 - node.frame.height/2
      }
    }
  }
  
  private func movePlayer() {
    player.position.y += CGFloat(playerYVelocity)
  }
  
  private func updateScore() {
    self.enumerateChildNodes(withName: "BottomObstacle") { (node, error) in
      if abs(node.position.x - self.player.position.x) <= 1 {
        self.score! += 1
        self.scoreLabel?.text = "\(self.score ?? 0)"
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
    isGamePaused = true
    endGame()
  }
  
  private func endGame() {
    player.removeAllActions()
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
    if !isGamePaused {
      physicsWorld.gravity = CGVector(dx: 0, dy: 0)
      playerYVelocity = 0
    }
  }
  
  @objc func changeGravity(_ sender: UISwipeGestureRecognizer) {
    if !isGamePaused {
      guard sender.view != nil else { return }
      if sender.direction == .up {
        print("up")
        playerYVelocity = 8.0
      }
      if sender.direction == .down {
        print("down")
        playerYVelocity = -8.0
      }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
  }

  
}
