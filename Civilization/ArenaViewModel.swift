//
//  ArenaViewModel.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Combine
import Foundation

class ArenaViewModel: ObservableObject {
    @Published var arenaSnapshot: ArenaSnapshot?
    let arenaActor: ArenaActor
    let arenaConfiguration: ArenaConfiguration
    
    init(arenaActor: ArenaActor, arenaConfiguration: ArenaConfiguration) {
        self.arenaActor = arenaActor
        self.arenaConfiguration = arenaConfiguration
    }
    
    func observe() async {
        for await snapshot in arenaActor.snapshotsStream {
            arenaSnapshot = snapshot
        }
    }
    
    func toScreenSpace(coord: CGPoint, geoSize: CGSize) -> CGPoint {
        let scaleX = geoSize.width / arenaConfiguration.width
        let scaleY = geoSize.height / arenaConfiguration.height
        
        return CGPoint(x: coord.x * scaleX, y: coord.y * scaleY)
    }
}
