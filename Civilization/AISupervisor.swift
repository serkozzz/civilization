//
//  AISuperwiser.swift
//  Civilization
//
//  Created by Sergey Kozlov on 14.10.2026.
//

import Foundation

nonisolated
class AISupervisor {
    var arenaActor: ArenaActor
    
    private var tasksMap = [UUID: Task<Void, Error>]()
    private var removalListenerTask: Task<Void, Error>?
    
    init(arenaActor: ArenaActor) {
        self.arenaActor = arenaActor

    }
    
    func startAll(arenaSnapshot: ArenaSnapshot) {
        assert(tasksMap.isEmpty)
        arenaSnapshot.players.forEach { player in
            let task = Task {
                let ai = PlayerAI(playerID: player.id,
                                   arenaActor: arenaActor,
                                   secondsBetweenMoves: Double.random(in: 0.03...0.1))
                try await ai.start()
            }
        }
        
        removalListenerTask = Task {
            for await removedId in self.arenaActor.playersRemovalStream {
                tasksMap[removedId]?.cancel()
                tasksMap[removedId] = nil
            }
        }
    }
    
    
}
