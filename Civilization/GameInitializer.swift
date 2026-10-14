//
//  GameInitializer.swift
//  Civilization
//
//  Created by Sergey Kozlov on 14.10.2026.
//

import SwiftUI
import Combine

class GameInitializer: ObservableObject {
    
    @Published var arenaVM: ArenaViewModel?
    var aiSupervisor: AISupervisor?
    
    
    func startIfNeed(geoSize: CGSize) async {
        guard arenaVM == nil else { return }
        
        let arenaConfiguration = ArenaConfiguration(width: geoSize.width, height: geoSize.height)
        
        let firstSnaphot = createFirstSnapshot(arenaConf: arenaConfiguration)
        
        let arenaActor = ArenaActor(initialSnapshot: firstSnaphot, arenaConfiguration: arenaConfiguration)
        
        arenaVM = ArenaViewModel(arenaActor: arenaActor, arenaConfiguration: arenaConfiguration)
        aiSupervisor = AISupervisor(arenaActor: arenaActor)
        let arenaSnapshot = await arenaActor.arenaSnapshot
        aiSupervisor!.startAll(arenaSnapshot: arenaSnapshot)
    }
    
    private func createFirstSnapshot(arenaConf: ArenaConfiguration) -> ArenaSnapshot {
        let foodItemsNumber = 525
        let playersNumber = 1000
        
        var foodItems = [Food]()
        for _ in 0..<foodItemsNumber {
            let x = arenaConf.width * Double.random(in: 0...1)
            let y = arenaConf.height * Double.random(in: 0...1)
            foodItems.append(Food(coord: CGPoint(x: x, y: y), size: 2, nutrition: 2))
        }
        
        var players = [Player]()
        for _ in 0..<playersNumber {
            let x = arenaConf.width * Double.random(in: 0...1)
            let y = arenaConf.height * Double.random(in: 0...1)
            let player = Player(coord: CGPoint(x: x, y: y),
                                speed: Double.random(in: 0.5...2),
                                vision: Double.random(in: 50...100))
            players.append(player)
        }
        
        return .init(players: players, food: foodItems)
    }
}
