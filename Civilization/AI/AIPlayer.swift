//
//  AIPlayer.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Foundation


nonisolated final class AIPlayer {
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
        guard let scanningResult = await arenaActor.scanArea(for: playerID) else {  return }
        let nearestEnemy = nearestEnemy(from: scanningResult.enemies)
        let nearestFood = nearestFood(from: scanningResult.food)
        
        guard let player = await arenaActor.player(by: playerID) else { return }
        if let nearestEnemy  {
            let estimatedSide = nearestEnemy.sideEstimation.estimatedSide
            let vectorToMove = (estimatedSide > player.side) ? -nearestEnemy.distanceVector : nearestEnemy.distanceVector
            let direction = direction(from: vectorToMove )
            let _ = await arenaActor.tryMove(playerID, direction: direction)
        }
        else {
            let _ = await arenaActor.tryMove(playerID, direction: Direction.random)
        }
    }
    
    /// Converts a vector to a cardinal direction. Ties prefer the horizontal axis.
    /// Arena coordinates increase downward along the Y axis.
    func direction(from vector: CGVector) -> Direction {
        guard vector.dx.isFinite, vector.dy.isFinite,
              vector.dx != 0 || vector.dy != 0 else {
            return .right
        }

        if abs(vector.dx) >= abs(vector.dy) {
            return vector.dx > 0 ? .right : .left
        }
        return vector.dy > 0 ? .down : .up
    }

    private func nearestEnemy(from enemies: [ScannedEnemy]) -> ScannedEnemy? {
        var nearestEnemy: ScannedEnemy?
        var minDistance = CGFloat.infinity
        for enemy in enemies {
            if enemy.id == playerID {
                continue
            }
            let distance = enemy.distanceVector.magnitude
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
            if distance < minDistance {
                nearestFood = foodVector
                minDistance = distance
            }
        }
        return nearestFood
    }
}
