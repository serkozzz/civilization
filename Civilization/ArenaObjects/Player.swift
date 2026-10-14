//
//  Player.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Foundation
import Combine


nonisolated
struct Player: ArenaObject, Equatable, Identifiable {
    
    var coord: CGPoint
    var size: CGFloat = 9
    
    private(set) var speed: Double
    private(set) var vision: Double

    init(coord: CGPoint, speed: Double, vision: Double) {
        self.coord = coord
        self.speed = speed
        self.vision = vision
    }
    
    var id = UUID()

}
