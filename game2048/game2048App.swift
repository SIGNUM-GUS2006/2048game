//
//  game2048App.swift
//  game2048
//
//  Created by Диана on 12.01.2025.
//

import SwiftUI

@main
struct game2048App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Record.self])
        }
    }
}
