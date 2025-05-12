// Created by Celaya Solutions 2025
//
//  Life_TrackerApp.swift
//  Life Tracker
//
//  Created by Christopher Celaya on 5/11/25.
//

import SwiftUI

@main
struct Life_TrackerApp: App {
    @State private var hasRequestedNotificationPermission = false
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
                .onAppear {
                    if !hasRequestedNotificationPermission {
                        requestNotificationPermission()
                    }
                }
        }
    }
    
    private func requestNotificationPermission() {
        NotificationManager.shared.requestPermission { granted in
            hasRequestedNotificationPermission = true
            print("Notification permission granted: \(granted)")
        }
    }
}
