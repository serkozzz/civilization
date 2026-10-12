//
//  ArenaView.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import SwiftUI

struct ArenaView: View {
    @ObservedObject var viewModel: ArenaViewModel

    var body: some View {
        
        Canvas { context, size in
            guard let snapshot = viewModel.arenaSnapshot else { return }

            let scaleX = size.width / viewModel.arenaConfiguration.width
            let scaleY = size.height / viewModel.arenaConfiguration.height
            var path = Path()

            for player in snapshot.players {
                let side = sqrt(player.size)
                let point = CGPoint(
                    x: player.coord.x * scaleX,
                    y: player.coord.y * scaleY
                )
                let rect = CGRect(
                    x: point.x - side / 2,
                    y: point.y - side / 2,
                    width: side,
                    height: side
                )
                path.addRect(rect)
            }
            context.fill(path, with: .color(.primary))
        }
        .task {
            viewModel.observe()
        }
    }
}
