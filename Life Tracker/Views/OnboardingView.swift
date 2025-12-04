// Created by Celaya Solutions 2025
//
//  OnboardingView.swift
//  Life Tracker
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "sparkles",
            title: "Welcome to AI Companion",
            description: "Your intelligent partner for planning, acting, and strategic thinking. Let's show you how it works.",
            color: .blue
        ),
        OnboardingPage(
            icon: "bubble.left.and.bubble.right",
            title: "Casual Chat",
            description: "Have natural conversations. Get help with everyday questions and tasks.",
            color: .blue,
            example: "\"Help me organize my thoughts about starting a new project\""
        ),
        OnboardingPage(
            icon: "lightbulb.fill",
            title: "Planning Mode",
            description: "Brainstorm ideas, organize thoughts, and prepare for what's ahead.",
            color: .orange,
            example: "\"I want to plan a product launch for next quarter\""
        ),
        OnboardingPage(
            icon: "figure.walk",
            title: "Acting Mode",
            description: "Break down goals into steps and track your progress with coaching.",
            color: .green,
            example: "\"Help me execute my marketing strategy step-by-step\""
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Review Mode",
            description: "Analyze patterns, review decisions, and learn from your experiences.",
            color: .purple,
            example: "\"What patterns do you see in my communication style?\""
        ),
        OnboardingPage(
            icon: "crown.fill",
            title: "Chess Mode - The Power Move",
            description: "Strategic analysis using ALL your data: health metrics, patterns, sentiment, and more for game-theory level insights.",
            color: .yellow,
            example: "\"Should I launch my business now or wait 3 months?\""
        ),
        OnboardingPage(
            icon: "lock.shield",
            title: "Confidence Mode",
            description: "Private conversations with zero memory. Perfect for sensitive topics.",
            color: .gray,
            example: "Nothing is saved. Total privacy."
        ),
        OnboardingPage(
            icon: "heart.text.square.fill",
            title: "Health Integration",
            description: "We can integrate with HealthKit to correlate your physiological state with mood and decision quality.",
            color: .red,
            showHealthPermission: true
        ),
        OnboardingPage(
            icon: "checkmark.circle.fill",
            title: "You're All Set!",
            description: "Choose a mode to get started. Pro tip: Try Chess Mode when making important decisions.",
            color: .green,
            isLastPage: true
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        isPresented = false
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
                    .foregroundColor(.secondary)
                    .padding()
                }
            }

            // Content
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Navigation
            HStack(spacing: 20) {
                if currentPage > 0 {
                    Button(action: {
                        withAnimation {
                            currentPage -= 1
                        }
                    }) {
                        Text("Back")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                    .foregroundColor(.primary)
                }

                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        isPresented = false
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(pages[currentPage].color)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
    var example: String?
    var showHealthPermission: Bool = false
    var isLastPage: Bool = false
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var requestedHealth = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)

            // Title
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Example
            if let example = page.example {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Example:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)

                    Text(example)
                        .font(.subheadline)
                        .italic()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(page.color.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            }

            // Health permission
            if page.showHealthPermission {
                Button(action: {
                    requestHealthPermission()
                }) {
                    Label(requestedHealth ? "Permission Requested" : "Enable HealthKit",
                          systemImage: requestedHealth ? "checkmark.circle.fill" : "heart.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(requestedHealth ? Color.green : Color.red)
                        .cornerRadius(10)
                }
                .disabled(requestedHealth)
            }

            // Last page extras
            if page.isLastPage {
                VStack(spacing: 12) {
                    FeatureBadge(icon: "text.book.closed", text: "Prompt Library")
                    FeatureBadge(icon: "chart.bar", text: "Analytics Dashboard")
                    FeatureBadge(icon: "brain.head.profile", text: "Pattern Recognition")
                }
                .padding(.horizontal, 40)
            }

            Spacer()
            Spacer()
        }
    }

    private func requestHealthPermission() {
        HealthKitManager.shared.requestAuthorization { success, error in
            requestedHealth = true
            if success {
                HealthKitManager.shared.fetchAllHealthData { _ in }
            }
        }
    }
}

struct FeatureBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(text)
                .font(.subheadline)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
