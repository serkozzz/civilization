//
//  ArenaScanningResult.swift
//  Civilization
//
//  Created by Sergey Kozlov on 13.10.2026.
//

import Foundation

nonisolated struct SideEstimation: Sendable {
    enum SizeAccuracy: Sendable {
        case exact
        case biggerThan
    }
    let sizeAccuracy: SizeAccuracy
    let estimatedSide: CGFloat
}

nonisolated struct ScannedEnemy: Sendable {
    let distanceVector: CGVector
    let sideEstimation: SideEstimation
    let id: UUID
}

nonisolated struct ArenaScanningResult: Sendable {
    var enemies: [ScannedEnemy]
    var food: [CGVector]
}
