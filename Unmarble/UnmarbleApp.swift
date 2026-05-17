//
//  UnmarbleApp.swift
//  Unmarble
//
//  Created by Rahman Şahinler on 16.05.2026.
//

import SwiftUI

@main
struct UnmarbleApp: App {
    @State private var userStore: UserStore

    init() {
        let store = UserStore()
        store.seedMockGallery()
        _userStore = State(initialValue: store)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(userStore)
        }
    }
}
