//
//  IntersectionDetector.swift
//  Civilization
//
//  Created by Sergey Kozlov on 13.10.2026.
//

import Foundation
import CoreGraphics

nonisolated final class IntersectionDetector {
    static func isIntersection(obj1: ArenaObject, obj2: ArenaObject) -> Bool {
        let halfSidesSum = (obj1.side + obj2.side) / 2
        return abs(obj1.coord.x - obj2.coord.x) < halfSidesSum
        && abs(obj1.coord.y - obj2.coord.y) < halfSidesSum
    }
    
    static func scanArea(arenaSnaphot: ArenaSnapshot, scanningRect: CGRect) -> ArenaScanningResult {
        guard !scanningRect.isNull, !scanningRect.isInfinite else {
            return ArenaScanningResult(enemies: [], food: [])
        }
        let area = scanningRect.standardized
        guard !area.isEmpty else {
            return ArenaScanningResult(enemies: [], food: [])
        }
        let center = CGPoint(x: area.midX, y: area.midY)

        func isVisible(_ object: any ArenaObject) -> Bool {
            let side = object.side
            guard side.isFinite, side > 0 else { return false }
            let halfSide = side / 2
            // Strict overlap: touching the scan boundary alone is not visible.
            return object.coord.x + halfSide > area.minX
                && object.coord.x - halfSide < area.maxX
                && object.coord.y + halfSide > area.minY
                && object.coord.y - halfSide < area.maxY
        }

        func vector(to point: CGPoint) -> CGVector {
            CGVector(dx: point.x - center.x, dy: point.y - center.y)
        }

        let enemies = arenaSnaphot.players.filter { isVisible($0) }.map {
            ScannedEnemy(distanceVector: vector(to: $0.coord),
                         sideEstimation: SideEstimation(sizeAccuracy: .exact, estimatedSide: $0.side),
                         id: $0.id)
        }
        let food = arenaSnaphot.food.filter { isVisible($0) }.map {
            vector(to: $0.coord)
        }
        return ArenaScanningResult(enemies: enemies, food: food)
    }
}
