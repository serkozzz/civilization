//
//  ArenaObject.swift
//  Civilization
//
//  Created by Sergey Kozlov on 13.10.2026.
//

import Foundation

nonisolated
protocol ArenaObject {
    var coord: CGPoint { get }
    var size: CGFloat { get }
}

nonisolated
extension ArenaObject {
    var side: CGFloat {
        sqrt(size)
    }
}
