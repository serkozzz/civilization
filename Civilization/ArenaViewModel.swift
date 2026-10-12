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
    var observationTask: Task<Void, Error>?
    

    
    init(arenaActor: ArenaActor, arenaConfiguration: ArenaConfiguration) {
        self.arenaActor = arenaActor
        self.arenaConfiguration = arenaConfiguration
    }
    
    func observe()  {
        observationTask?.cancel()
        observationTask = Task {
            
            while true {
                try Task.checkCancellation()
                arenaSnapshot = await arenaActor.arenaSnapshot
                try await Task.sleep(for: .seconds(1/60))
            }
        }
    }
    
    func toScreenSpace(coord: CGPoint, geoSize: CGSize) -> CGPoint {
        let scaleX = geoSize.width / arenaConfiguration.width
        let scaleY = geoSize.height / arenaConfiguration.height
        
        return CGPoint(x: coord.x * scaleX, y: coord.y * scaleY)
    }
}
