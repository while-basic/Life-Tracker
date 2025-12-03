# AI Companion App - Setup Instructions

## Overview
The AI Companion feature has been successfully integrated into the Life Tracker app. This document outlines the required Xcode configuration and next steps.

## What's Been Built

### ✅ Core Architecture
- **6 AI Modes**: Casual Chat, Planning, Acting, Review, Chess Mode, Confidence Mode
- **Data Models**: Complete data structures for conversations, health data, psychoanalysis, prompts
- **HealthKit Integration**: Manager for fetching heart rate, steps, sleep, HRV, and activity data
- **Psychoanalysis Engine**: Sentiment tracking, word frequency analysis, communication patterns
- **Prompt Library**: Full CRUD system for user-created and built-in prompts
- **Analytics Dashboard**: Comprehensive analytics with charts and insights

### ✅ Views Created
1. `AICompanionView.swift` - Main view with mode switching
2. `PlanningModeView.swift` - Brainstorming and idea organization
3. `ActingModeView.swift` - Step-by-step execution coaching
4. `ReviewModeView.swift` - Pattern analysis and retrospectives
5. `ChessModeView.swift` - Strategic analysis using all available data
6. `ConversationView` - Chat interface (used by Casual Chat & Confidence modes)
7. `PromptLibraryView.swift` - Prompt management system
8. `AnalyticsView.swift` - Detailed analytics dashboard

### ✅ Services
- `HealthKitManager.swift` - Centralized HealthKit data fetching
- `AICompanionViewModel.swift` - State management and conversation handling

### ✅ Navigation
- AI Companion tab added to MainTabView with brain icon

## Required Xcode Configuration

### 1. Add HealthKit Capability
In Xcode:
1. Select your project in the navigator
2. Select the "Life Tracker" target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "HealthKit"

### 2. Add Privacy Descriptions to Info.plist
Add these keys to your Info.plist (or Target -> Info):

```xml
<key>NSHealthShareUsageDescription</key>
<string>We need access to your health data to provide personalized insights and correlate your physiological state with communication patterns for better strategic analysis.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>We may update your health data based on your activities and workouts tracked in the app.</string>
```

### 3. Enable HealthKit in Target Settings
1. In your target's "Signing & Capabilities" tab
2. Ensure HealthKit capability is enabled
3. Check the required health data types:
   - Heart Rate
   - Step Count
   - Active Energy Burned
   - Heart Rate Variability
   - Sleep Analysis

### 4. Build Settings
Ensure your deployment target is iOS 16.0 or later (required for Swift Charts and some HealthKit features).

## Next Steps - AI Integration

### Apple Intelligence Integration
The app currently uses placeholder AI responses. To integrate Apple Intelligence:

1. **Add Apple Intelligence Framework** (when available)
   - The infrastructure is ready in `AICompanionViewModel.swift`
   - Replace the `generateAIResponse()` method with actual Apple Intelligence API calls

2. **Alternative: OpenAI/Anthropic Integration**
   - Add API key management
   - Implement API calls in `AICompanionViewModel.swift`
   - Update `sendMessage()` to call external APIs

### Speech Recognition (Optional)
For voice-to-text transcription:
1. Add Speech framework
2. Add privacy description: `NSSpeechRecognitionUsageDescription`
3. Implement transcription service

## File Structure

```
Life Tracker/
├── Models/
│   ├── AppModels.swift (existing)
│   └── AICompanionModels.swift (NEW)
├── ViewModels/
│   ├── AppViewModel.swift (existing)
│   └── AICompanionViewModel.swift (NEW)
├── Views/
│   ├── AICompanionView.swift (NEW)
│   ├── AnalyticsView.swift (NEW)
│   ├── PromptLibraryView.swift (NEW)
│   └── Modes/
│       ├── PlanningModeView.swift (NEW)
│       ├── ActingModeView.swift (NEW)
│       ├── ReviewModeView.swift (NEW)
│       └── ChessModeView.swift (NEW)
├── Services/
│   └── HealthKitManager.swift (NEW)
└── MainTabView.swift (MODIFIED)
```

## Key Features

### 1. Mode System
Each mode has a unique purpose:
- **Casual Chat**: General conversation and assistance
- **Planning**: Brainstorming with idea categorization
- **Acting**: Goal breakdown with step tracking and progress monitoring
- **Review**: Analytics dashboard with sentiment trends and patterns
- **Chess Mode**: Strategic SWOT analysis using all available user data
- **Confidence Mode**: Privacy-first, no data retention

### 2. Health Data Integration
- Real-time heart rate monitoring
- Steps tracking
- Sleep analysis
- Stress levels (derived from HRV)
- All correlated with mood and sentiment

### 3. Psychoanalysis Engine
Tracks:
- Sentiment over time
- Word frequency
- Communication formality
- Conversation patterns
- Mood correlations with health metrics

### 4. Chess Mode (The Killer Feature)
Strategic analysis combining:
- Current physiological state
- Communication patterns
- Sentiment trends
- Behavioral data
- SWOT framework
- Actionable recommendations

## Testing Checklist

- [ ] Build project without errors
- [ ] HealthKit permission prompt appears on first launch
- [ ] Can switch between all 6 modes
- [ ] Can create and use custom prompts
- [ ] Analytics dashboard displays correctly
- [ ] Chess Mode generates SWOT analysis
- [ ] Health data fetches successfully
- [ ] Conversations persist between sessions

## Known Limitations

1. **AI Responses**: Currently using placeholder responses. Needs real AI API integration.
2. **Transcription**: Voice-to-text not yet implemented. Framework is ready.
3. **Apple Intelligence**: Waiting for official API release. Infrastructure in place.
4. **CloudKit Sync**: Not implemented. Using UserDefaults for persistence.

## Future Enhancements

1. **Shortcuts Integration**: Create iOS shortcuts for quick mode access
2. **Action Button Support**: Map to quick AI access
3. **Share Sheet**: Export conversations and analyses
4. **Widget**: Quick stats and insights
5. **Apple Watch**: Health data visualization
6. **Multi-language**: Internationalization support
7. **Export**: Markdown/PDF conversation export

## Demo Preparation

For demo with real data (Chris as test subject):
1. Enable HealthKit and sync real health data
2. Have several conversations across different modes
3. Use Chess Mode for actual business scenario analysis
4. Show sentiment correlation with health metrics
5. Demonstrate prompt library with custom business prompts

## Support

For issues or questions about the AI Companion implementation:
- Check HealthKit permissions in Settings
- Verify Xcode capabilities are enabled
- Review console logs for HealthKit errors
- Ensure iOS 16.0+ deployment target

---

**Status**: ✅ Core implementation complete, ready for AI API integration and testing.
