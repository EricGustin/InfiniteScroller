//
//  GameViewController.swift
//  SideScroller
//
//  Created by Eric Gustin on 7/21/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController {
  
  //  Gamecenter variables
  var gcEnabled = Bool()
  var gcDefaultLeaderBoard = String()
  let LEADERBOARD_ID = "com.eric.SwipeyBird"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    authenticateLocalPlayer()
    
    if let view = self.view as! SKView? {
      // Load the SKScene from 'GameScene.sks'
      if let scene = SKScene(fileNamed: "GameScene") {
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // Present the scene
        view.presentScene(scene)
      }
      
      view.ignoresSiblingOrder = true
      view.showsPhysics = true
      view.showsFPS = true
    }
  }
  
  func authenticateLocalPlayer() {
    let localPlayer: GKLocalPlayer = GKLocalPlayer.local
    localPlayer.authenticateHandler = {(GameViewController, error) -> Void in
      if((GameViewController) != nil) {
        // 1. Show login if player is not logged in
        self.present(GameViewController!, animated: true, completion: nil)
      } else if (localPlayer.isAuthenticated) {
        // 2. Player is already authenticated & logged in, load game center
        self.gcEnabled = true
        
        // Get the default leaderboard ID
        localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
          if error != nil { print(error as Any)
          } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
        })
      } else {
        // 3. Game center is not enabled on the users device
        self.gcEnabled = false
        print("Local player could not be authenticated!")
        print(error as Any)
      }
    }
  }
    
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}
