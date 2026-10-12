//
//  ArenaActor.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Foundation

actor ArenaActor {

    private(set) var arenaSnapshot: ArenaSnapshot
    private var arenaConfiguration: ArenaConfiguration
    
    private var indexById: [UUID: Int]?
    
    init(initialSnapshot: ArenaSnapshot, arenaConfiguration: ArenaConfiguration) {
        self.arenaSnapshot = initialSnapshot
        self.arenaConfiguration = arenaConfiguration
        if indexById == nil {  createIndex() }
    }
    
    func tryMove(player: Player, direction: Direction) {
        
        let idx = indexById![player.id]!
        var tempPlayer = arenaSnapshot.players[idx]
        switch direction {
        case .up:
            move(player: &tempPlayer, dx: 0, dy: -player.speed)
        case .down:
            move(player: &tempPlayer, dx: 0, dy: player.speed)
        case .left:
            move(player: &tempPlayer, dx: -player.speed, dy: 0)
        case .right:
            move(player: &tempPlayer, dx: player.speed, dy: 0)
        }
        if (isPlayerInsideOfArena(tempPlayer)) {
            arenaSnapshot.players[idx] = tempPlayer
        }
    }
    
    private func move(player: inout Player, dx: CGFloat, dy: CGFloat) {
        player.coord = CGPoint(x: player.coord.x + dx, y: player.coord.y + dy)
    }
    
    private func isPlayerInsideOfArena(_ player: Player) -> Bool {
        player.coord.x >= 0 && player.coord.x <= arenaConfiguration.width
        && player.coord.y >= 0 && player.coord.y <= arenaConfiguration.height
       
    }
    
    private func createIndex() {
        indexById = [:]
        for idx in 0..<arenaSnapshot.players.count {
            let id = arenaSnapshot.players[idx].id
            indexById![id] = idx
        }
    }
}
