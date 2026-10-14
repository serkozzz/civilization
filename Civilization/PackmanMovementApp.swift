//
//  PackmanMovementApp.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import SwiftUI

@main
struct PackmanMovementApp: App {

    var aiSupervisor: AISupervisor
    let arenaActor: ArenaActor
    let arenaVM: ArenaViewModel
    let arenaConfiguration = ArenaConfiguration(width: 800, height: 600)
    
    init() {

        let firstSnaphot = PackmanMovementApp.createFirstSnapshot(arenaConf: arenaConfiguration)
        
        arenaActor = ArenaActor(initialSnapshot: firstSnaphot, arenaConfiguration: arenaConfiguration)
        
        arenaVM = ArenaViewModel(arenaActor: arenaActor, arenaConfiguration: arenaConfiguration)
        aiSupervisor = AISupervisor(arenaActor: arenaActor)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(arenaActor: arenaActor, arenaVM: arenaVM, arenaConfiguration: arenaConfiguration)
                .task {
                    let arenaSnapshot = await arenaActor.arenaSnapshot
                    aiSupervisor.startAll(arenaSnapshot: arenaSnapshot)
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
