//
//  ArenaActor.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Foundation
import CoreGraphics


nonisolated enum MoveResult: Sendable {
    case moved
    case blocked
    case removed
    case dragging
}


actor ArenaActor {

    private(set) var arenaSnapshot: ArenaSnapshot
    let playersRemovalStream: AsyncStream<UUID>
    private let playersRemovalContinuation: AsyncStream<UUID>.Continuation
    
    private var arenaConfiguration: ArenaConfiguration
    
    private var indexById: [UUID: Int]?
    
    
    init(initialSnapshot: ArenaSnapshot, arenaConfiguration: ArenaConfiguration) {
        self.arenaSnapshot = initialSnapshot
        self.arenaConfiguration = arenaConfiguration
        
        (playersRemovalStream, playersRemovalContinuation) = AsyncStream<UUID>.makeStream()
    }
    
    func player(by:UUID) -> Player? {
        guard let idx = indexById![by] else { return nil }
        return arenaSnapshot.players[idx]
    }
    
    func setPlayerPosition(playerID: UUID, to: CGPoint) {
        guard let idx = indexById![playerID] else { return }
        arenaSnapshot.players[idx].coord = to
    }
    
    func setDragging(playerID: UUID, dragging: Bool) {
        guard let idx = indexById![playerID] else { return }
        arenaSnapshot.players[idx].playerMode = dragging ? .dragging : .simulated
    }
    
    func scanArea(for playerID: UUID) -> ArenaScanningResult? {
        if indexById == nil {  createIndex() }
        guard let playerIdx = indexById![playerID] else { return nil}
        let player = arenaSnapshot.players[playerIdx]
        if player.playerMode == .dragging { return nil }
        
       
        let scanningAreaSide = player.side + player.vision
        let halfSide = scanningAreaSide / 2
        let scanningRect = CGRect(
            x: player.coord.x - halfSide,
            y: player.coord.y - halfSide,
            width: scanningAreaSide,
            height: scanningAreaSide
        )
        return IntersectionDetector.scanArea(
            arenaSnaphot: arenaSnapshot,
            scanningRect: scanningRect
        )
    }
    
    func tryMove(_ playerToMoveID: UUID, direction: Direction) -> MoveResult {
        if indexById == nil {  createIndex() }

        guard let playerToMoveIdx = indexById![playerToMoveID] else { return .removed}
        let playerToMove = arenaSnapshot.players[playerToMoveIdx]
        if playerToMove.playerMode == .dragging { return .dragging }
        
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
        
        if (isPlayerInsideOfArena(tempPlayer)) {
            arenaSnapshot.players[playerToMoveIdx] = tempPlayer
        }
        else {
            return .blocked
        }
        
       
        let (indexToRemove, indexToGrow) = checkPlayersIntesection(movingPlayer: tempPlayer)
        
        if let indexToRemove, let indexToGrow {
            //fight
            let playerToRemove = arenaSnapshot.players[indexToRemove]
            arenaSnapshot.players[indexToGrow].size += playerToRemove.size
            arenaSnapshot.players.remove(at: indexToRemove)
            createIndex()
            playersRemovalContinuation.yield(playerToRemove.id)
            if indexToRemove == playerToMoveIdx {
                return .removed
            }
        }
        else {
            //eat
            let foodIdxToEat = getIntersectedFoodItemIdx(movingPlayer: tempPlayer)
            if let foodIdxToEat {
                tempPlayer.size = arenaSnapshot.food[foodIdxToEat].nutrition
                arenaSnapshot.food.remove(at: foodIdxToEat)
            }
        }
        return .moved
    }
    
    private func checkPlayersIntesection(movingPlayer: Player) ->  (indexToRemove: Int?, indexToGrow: Int?) {
        var indexToRemove: Int?, indexToGrow: Int?
        for player in arenaSnapshot.players {
            if player.id == movingPlayer.id { continue }
            if player.playerMode == .dragging { continue }
            let isIntersected = IntersectionDetector.isIntersection(obj1: movingPlayer, obj2: player)
            if (isIntersected) {
                if movingPlayer.size >= player.size {
                    indexToRemove = indexById![player.id]
                    indexToGrow = indexById![movingPlayer.id]!
                }
                else {
                    indexToRemove = indexById![movingPlayer.id]
                    indexToGrow = indexById![player.id]!
                }
                break;
            }
        }
        return (indexToRemove, indexToGrow)
    }
    
    private func getIntersectedFoodItemIdx(movingPlayer: Player) -> Int? {
        for i in 0..<arenaSnapshot.food.count {
            let foodItem = arenaSnapshot.food[i]
            let isIntersected = IntersectionDetector.isIntersection(obj1: movingPlayer, obj2: foodItem)
            if (isIntersected) {
                return i
            }
        }
        return nil
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
    
    deinit {
        playersRemovalContinuation.finish()
    }
}
