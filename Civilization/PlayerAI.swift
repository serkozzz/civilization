//
//  PlayerAI.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Foundation



nonisolated final class PlayerAI {
    var secondsBetweenMoves: TimeInterval
    var player: Player
    var arenaActor: ArenaActor
    
    init(player: Player,
         arenaActor: ArenaActor,
         secondsBetweenMoves: TimeInterval) {
        self.player = player
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
        let moveResult = await arenaActor.tryMove(player, direction: Direction.random)
        if moveResult == .removed {
            throw CancellationError()
        }
    }
}
