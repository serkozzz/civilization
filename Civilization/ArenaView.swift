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
        
        GeometryReader { geo in
            if let snapshot = viewModel.arenaSnapshot {
                ForEach(snapshot.players) { player in
                    let side = sqrt(player.size)
                    Rectangle().frame(width: side, height: side)
                        .position(viewModel.toScreenSpace(coord: player.coord, geoSize: geo.size))
                }
            }
        }
        .task {
           await viewModel.observe()
        }
    }
}
