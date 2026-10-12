//
//  Direction.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

enum Direction: Int {
    case up
    case down
    case left
    case right
    
    static var random: Direction {
        let rndInt = Int.random(in: 0...3)
        return Direction(rawValue: rndInt)!
    }
}
