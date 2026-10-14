//
//  PlayerAI.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Foundation



nonisolated final class PlayerAI {
    var secondsBetweenMoves: TimeInterval
    var playerID: UUID
    var arenaActor: ArenaActor
    
    init(playerID: UUID,
         arenaActor: ArenaActor,
         secondsBetweenMoves: TimeInterval) {
        self.playerID = playerID
        self.arenaActor = arenaActor
        self.secondsBetweenMoves = secondsBetweenMoves
    }
    
    @concurrent
    func start() async throws {

            while true {
                try await makeTurn()
                try await Task.sleep(for: .seconds(secondsBetweenMoves))
                try Task.checkCancellation()
            }
  
    }
    
    private func makeTurn() async throws {
        let player = await arenaActor.arenaSnapshot.players[playerID]
        let scanningResult = await arenaActor.scanArea(for: player)
        let nearestEnemy = nearestEnemy(from: scanningResult.enemies)
        let nearestFood = nearestFood(from: scanningResult.food)
        
        let moveResult = await arenaActor.tryMove(player, direction: Direction.random)
        if moveResult == .removed {
            throw CancellationError()
        }
    }
    
    private func nearestEnemy(from enemies: [ScannedEnemy]) -> ScannedEnemy? {
        var nearestEnemy: ScannedEnemy?
        var minDistance = CGFloat.infinity
        for enemy in enemies {
            let distance = enemy.distanceVector.magnitude
            if distance <= player.side  {
                continue
            }
            if distance < minDistance {
                nearestEnemy = enemy
                minDistance = distance
            }
        }
        return nearestEnemy
    }
    
    private func nearestFood(from foodVectors: [CGVector]) -> CGVector? {
        var nearestFood: CGVector?
        var minDistance = CGFloat.infinity
        for foodVector in foodVectors {
            let distance = foodVector.magnitude
            if distance <= player.side  {
                continue
            }
            if distance < minDistance {
                nearestFood = foodVector
                minDistance = distance
            }
        }
        return nearestFood
    }
}
