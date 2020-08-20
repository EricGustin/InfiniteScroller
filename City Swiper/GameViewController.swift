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
import GoogleMobileAds

class GameViewController: UIViewController, GADBannerViewDelegate {

  private var bannerView: GADBannerView!
  
  //  Gamecenter variables
  var gcEnabled = Bool()
  var gcDefaultLeaderBoard = String()
  let LEADERBOARD_ID = "com.eric.CitySwiper"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpAds()
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
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
  }
  
  private func setUpAds() {
    bannerView = GADBannerView(adSize: kGADAdSizeBanner)
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view?.addSubview(bannerView)
    bannerView.centerXAnchor.constraint(equalTo: view!.centerXAnchor).isActive = true
    bannerView.bottomAnchor.constraint(equalTo: view!.bottomAnchor).isActive = true
    //bannerView.adUnitID = "ca-app-pub-2778876616385267/7296308658"
    bannerView.rootViewController = self
    bannerView.load(GADRequest())
    bannerView.delegate = self
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
  
  internal func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    bannerView.alpha = 0
    UIView.animate(withDuration: 1, animations: {
      bannerView.alpha = 1
    })
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
