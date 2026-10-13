//
//  PackmanMovementApp.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import SwiftUI

@main
struct PackmanMovementApp: App {
    
    var playerAIs: [PlayerAI]

    let arenaActor: ArenaActor
    let arenaVM: ArenaViewModel
    let arenaConfiguration = ArenaConfiguration(width: 800, height: 600)
    
    init() {

        let firstSnaphot = PackmanMovementApp.createFirstSnapshot(arenaConf: arenaConfiguration)
        
        arenaActor = ArenaActor(initialSnapshot: firstSnaphot, arenaConfiguration: arenaConfiguration)
        
        playerAIs = []
        for i in 0..<firstSnaphot.players.count {
            let playerAI = PlayerAI(player: firstSnaphot.players[i],
                                arenaActor: arenaActor,
                                secondsBetweenMoves: Double.random(in: 0.03...0.1))
            playerAIs.append(playerAI)
        }
        arenaVM = ArenaViewModel(arenaActor: arenaActor, arenaConfiguration: arenaConfiguration)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(arenaActor: arenaActor, arenaVM: arenaVM, arenaConfiguration: arenaConfiguration)
                .task {
                    await withTaskGroup() { group in
                        for playerAI in playerAIs {
                            group.addTask {
                                try? await playerAI.start()
                            }
                        }
                    }
                }
        }
    }
    
    private static func createFirstSnapshot(arenaConf: ArenaConfiguration) -> ArenaSnapshot {
        let foodItemsNumber = 525
        let playersNumber = 1000
        
        var foodItems = [Food]()
        for _ in 0..<foodItemsNumber {
            let x = arenaConf.width * Double.random(in: 0...1)
            let y = arenaConf.height * Double.random(in: 0...1)
            foodItems.append(Food(coord: CGPoint(x: x, y: y), size: 2))
        }
        
        var players = [Player]()
        for _ in 0..<playersNumber {
            let x = arenaConf.width * Double.random(in: 0...1)
            let y = arenaConf.height * Double.random(in: 0...1)
            let player = Player(coord: CGPoint(x: x, y: y), speed:Double.random(in: 0.5...2))
            players.append(player)
        }
        
        return .init(players: players, food: foodItems)
    }
    
}
