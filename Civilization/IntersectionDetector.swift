//
//  IntersectionDetector.swift
//  Civilization
//
//  Created by Sergey Kozlov on 13.10.2026.
//

import Foundation

nonisolated final class IntersectionDetector {
    static func isIntersection(obj1: ArenaObject, obj2: ArenaObject) -> Bool {
        let halfSidesSum = (obj1.side + obj2.side) / 2
        return abs(obj1.coord.x - obj2.coord.x) < halfSidesSum
        && abs(obj1.coord.y - obj2.coord.y) < halfSidesSum
    }
}
