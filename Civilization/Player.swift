//
//  Player.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import Foundation
import Combine



struct Player: Equatable, Identifiable {
    var coord: CGPoint
    private(set) var speed: Double
    var size: Double = 9
    
    init(coord: CGPoint, speed: Double) {
        self.coord = coord
        self.speed = speed
    }
    
    var id = UUID()

}
