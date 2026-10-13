//
//  ArenaActor.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Foundation


nonisolated enum MoveResult: Sendable {
    case moved
    case blocked
    case removed
}


actor ArenaActor {

    private(set) var arenaSnapshot: ArenaSnapshot
    private var arenaConfiguration: ArenaConfiguration
    
    private var indexById: [UUID: Int]?

    init(initialSnapshot: ArenaSnapshot, arenaConfiguration: ArenaConfiguration) {
        self.arenaSnapshot = initialSnapshot
        self.arenaConfiguration = arenaConfiguration
    }
    
    func tryMove(_ playerToMove: Player, direction: Direction) -> MoveResult {
        if indexById == nil {  createIndex() }
        guard let playerToMoveIdx = indexById?[playerToMove.id] else {
            return .removed
        }
        var tempPlayer = arenaSnapshot.players[playerToMoveIdx]
        switch direction {
        case .up:
            move(player: &tempPlayer, dx: 0, dy: -playerToMove.speed)
        case .down:
            move(player: &tempPlayer, dx: 0, dy: playerToMove.speed)
        case .left:
            move(player: &tempPlayer, dx: -playerToMove.speed, dy: 0)
        case .right:
            move(player: &tempPlayer, dx: playerToMove.speed, dy: 0)
        }
        var indexToRemove: Int?
        var indexToGrow: Int?
        for player in arenaSnapshot.players {
            if player.id == tempPlayer.id { continue }
            let isIntersected = IntersectionDetector.isIntersection(obj1: tempPlayer, obj2: player)
            if (isIntersected) {
                if tempPlayer.size >= player.size {
                    indexToRemove = indexById![player.id]
                    indexToGrow = indexById![tempPlayer.id]!
                }
                else {
                    indexToRemove = indexById![tempPlayer.id]
                    indexToGrow = indexById![player.id]!
                }
                break;

            }
        }
        if (isPlayerInsideOfArena(tempPlayer)) {
            arenaSnapshot.players[playerToMoveIdx] = tempPlayer
        }
        else {
            return .blocked
        }
        
        if let indexToRemove, let indexToGrow {
            arenaSnapshot.players[indexToGrow].size += arenaSnapshot.players[indexToRemove].size
            arenaSnapshot.players.remove(at: indexToRemove)
            createIndex()
        }
        if indexToRemove == playerToMoveIdx {
            return .removed
        }
        return .moved
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
