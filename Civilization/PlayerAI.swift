//
//  PlayerAI.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Foundation



class PlayerAI {
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
    
    func start() async throws {

            while true {
                await makeTurn()
                try await Task.sleep(for: .seconds(secondsBetweenMoves))
                try Task.checkCancellation()
            }
  
    }
    
    private func makeTurn() async {
        await arenaActor.tryMove(player: player, direction: Direction.random)
    }
    
}
