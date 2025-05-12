// Created by Celaya Solutions 2025
//
//  MainTabView.swift
//  Life Tracker
//

import SwiftUI

// Import the view model
import Foundation

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            
            FinancialView()
                .tabItem {
                    Label("Financial", systemImage: "dollarsign.circle.fill")
                }
                .tag(2)
            
            QuickToolsView()
                .tabItem {
                    Label("Tools", systemImage: "hammer.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
} 