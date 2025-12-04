// Created by Celaya Solutions 2025
//
//  TipsView.swift
//  Life Tracker
//

import SwiftUI

struct TipsView: View {
    let mode: AIMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Mode info
                    VStack(spacing: 12) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 60))
                            .foregroundColor(mode.color)

                        Text(mode.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(mode.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    Divider()

                    // Tips
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tips & Best Practices")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(TipsManager.shared.getTipsForMode(mode)) { tip in
                            TipCard(tip: tip)
                        }
                    }

                    Divider()

                    // Quick start prompts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Start Prompts")
                            .font(.headline)
                            .padding(.horizontal)

                        Text("Try these prompts to get started:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        ForEach(TipsManager.shared.getQuickStartPrompts(mode: mode), id: \.self) { prompt in
                            QuickPromptCard(prompt: prompt, color: mode.color)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Tips for \(mode.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TipCard: View {
    let tip: Tip

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: tip.icon)
                .font(.title3)
                .foregroundColor(tip.color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(tip.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct QuickPromptCard: View {
    let prompt: String
    let color: Color

    var body: some View {
        HStack {
            Text(prompt)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(color)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

#Preview {
    TipsView(mode: .chess)
}
