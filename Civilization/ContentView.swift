//
//  ContentView.swift
//  PackmanMovement
//
//  Created by Sergey Kozlov on 12.10.2026.
//

import SwiftUI

struct ContentView: View {
        
    var arenaActor: ArenaActor
    var arenaVM: ArenaViewModel
    var arenaConfiguration: ArenaConfiguration
    
    var body: some View {
        GeometryReader () { geo in
            ArenaView(viewModel: arenaVM)
        }
    }
    
   
}

