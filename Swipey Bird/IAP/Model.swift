//
//  Model.swift
//  Swipey Bird
//
//  Created by Eric Gustin on 7/31/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import Foundation
import StoreKit

class Model {
    
    struct GameData: Codable, SettingsManageable {
        var extraLives: Int = 0
        
        var superPowers: Int = 0
        
        var didUnlockAllMaps = false
    }
    
    var gameData = GameData()
    
    var products = [SKProduct]()
    
    
    init() {
        _ = gameData.load()
    }
    
    
    func getProduct(containing keyword: String) -> SKProduct? {
        return products.filter { $0.productIdentifier.contains(keyword) }.first
    }
}
