//
//  ArenaActor.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Foundation

actor ArenaActor {
    let snapshotsStream: AsyncStream<ArenaSnapshot>
    private let snapshotsContinuation: AsyncStream<ArenaSnapshot>.Continuation
    private var arenaSnapshot: ArenaSnapshot
    private var arenaConfiguration: ArenaConfiguration
    
    init(arenaSnapshot: ArenaSnapshot, arenaConfiguration: ArenaConfiguration) {
        self.arenaSnapshot = arenaSnapshot
        self.arenaConfiguration = arenaConfiguration
        
        let pair = AsyncStream<ArenaSnapshot>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )

        snapshotsStream = pair.stream
        snapshotsContinuation = pair.continuation
    }
    
    func tryMove(player: Player, direction: Direction) {
        let idx = arenaSnapshot.players.firstIndex(where: { $0.id == player.id} )!
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
            snapshotsContinuation.yield(arenaSnapshot)
        }
    }
    
    private func move(player: inout Player, dx: CGFloat, dy: CGFloat) {
        player.coord = CGPoint(x: player.coord.x + dx, y: player.coord.y + dy)
    }
    
    private func isPlayerInsideOfArena(_ player: Player) -> Bool {
        player.coord.x >= 0 && player.coord.x <= arenaConfiguration.width
        && player.coord.y >= 0 && player.coord.y <= arenaConfiguration.height
       
    }
    
    private func finish() {
        snapshotsContinuation.finish()
    }
    
    deinit {
        snapshotsContinuation.finish()
    }
}
