//
//  PackmanMovementApp.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import SwiftUI

@main
struct PackmanMovementApp: App {

    @StateObject var gameInitializer = GameInitializer()
    
    var body: some Scene {
        WindowGroup {
            GeometryReader () { geo in
                ZStack {
                    if let arenaVM = gameInitializer.arenaVM {
                        ArenaView(viewModel: arenaVM)
                    }
                }
                .task {
                    await gameInitializer.startIfNeed(geoSize: geo.size)
                }
            }
            
        }
    }
}
