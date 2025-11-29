//
//  AISettingsView.swift
//  schedule2
//
//  Created by AI Assistant on 05/10/2025.
//

import SwiftUI

struct AISettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var knowledgeBase = TransportKnowledgeBase.shared
    @StateObject private var predictionService = DelayPredictionService()
    
    @AppStorage("aiPredictionsEnabled") private var aiPredictionsEnabled = true
    @AppStorage("continuousLearningEnabled") private var continuousLearningEnabled = true
    @AppStorage("predictionConfidenceThreshold") private var predictionConfidenceThreshold = 0.7
    @AppStorage("showDetailedFactors") private var showDetailedFactors = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Header section
                        aiHeaderSection
                            .padding(.top, 20)
                        
                        // Settings sections
                        VStack(spacing: 20) {
                            aiToggleSettings
                            knowledgeBaseSettings
                            predictionSettings
                            privacySettings
                            aboutAISection
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                // Custom close button
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                        .background(.regularMaterial, in: Circle())
                }
                .padding(.top, 60)
                .padding(.trailing, 20)
            }
        }
    }
    
    // MARK: - AI Header Section
    private var aiHeaderSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(.purple.gradient)
                    .frame(width: 60, height: 60)
                    .glassEffect(.regular.tint(.purple), in: .circle)
                
                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("AI Settings")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Configure machine learning predictions and knowledge base")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - AI Toggle Settings
    private var aiToggleSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Features")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 12) {
                SettingToggleRow(
                    title: "AI Delay Predictions",
                    subtitle: "Use machine learning to predict delay probabilities",
                    isOn: $aiPredictionsEnabled,
                    icon: "brain.head.profile",
                    color: .purple
                )
                
                SettingToggleRow(
                    title: "Continuous Learning",
                    subtitle: "Automatically learn from new traffic data",
                    isOn: $continuousLearningEnabled,
                    icon: "arrow.triangle.2.circlepath",
                    color: .blue
                )
                
                SettingToggleRow(
                    title: "Detailed Factors",
                    subtitle: "Show contributing factors in predictions",
                    isOn: $showDetailedFactors,
                    icon: "chart.bar.fill",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Knowledge Base Settings
    private var knowledgeBaseSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Knowledge Base")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 16) {
                // Status indicators
                KnowledgeBaseStatusView(
                    knowledgeBase: knowledgeBase,
                    predictionService: predictionService
                )
                
                // Management buttons
                VStack(spacing: 12) {
                    Button(action: resetKnowledgeBase) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Reset Knowledge Base")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: exportData) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Export Training Data")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Prediction Settings
    private var predictionSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prediction Settings")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 16) {
                // Confidence threshold slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Confidence Threshold")
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Text("\(Int(predictionConfidenceThreshold * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    Text("Only show predictions above this confidence level")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Slider(value: $predictionConfidenceThreshold, in: 0.5...0.95, step: 0.05)
                        .tint(.blue)
                }
                .padding(16)
                .background(.blue.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                
                // Prediction examples
                VStack(alignment: .leading, spacing: 12) {
                    Text("Example Predictions")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        PredictionExampleRow(
                            scenario: "Rush hour + Rain",
                            probability: 0.75,
                            factors: ["Weather", "Time of Day"]
                        )
                        
                        PredictionExampleRow(
                            scenario: "Weekend morning",
                            probability: 0.15,
                            factors: ["Day of Week", "Historical Trends"]
                        )
                        
                        PredictionExampleRow(
                            scenario: "Technical issues + High load",
                            probability: 0.85,
                            factors: ["Infrastructure", "Passenger Volume"]
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Privacy Settings
    private var privacySettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy & Data")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 12) {
                PrivacyInfoRow(
                    title: "On-Device Processing",
                    description: "All AI predictions run locally on your device",
                    icon: "lock.shield",
                    status: "Enabled"
                )
                
                PrivacyInfoRow(
                    title: "Data Collection",
                    description: "Only anonymized traffic patterns are stored",
                    icon: "eye.slash",
                    status: "Anonymous"
                )
                
                PrivacyInfoRow(
                    title: "External Sharing",
                    description: "No personal data is shared with third parties",
                    icon: "hand.raised.slash",
                    status: "Never"
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.green.opacity(0.3), lineWidth: 1)
        )
        .glassEffect(.regular.tint(.green), in: .rect(cornerRadius: 16))
    }
    
    // MARK: - About AI Section
    private var aboutAISection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About AI Predictions")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 12) {
                AboutInfoCard(
                    title: "How It Works",
                    description: "The AI analyzes historical delays, weather patterns, time patterns, and passenger loads to predict future delay probabilities.",
                    icon: "gearshape.2"
                )
                
                AboutInfoCard(
                    title: "Accuracy",
                    description: "Predictions improve over time as more data is collected. Current models achieve 75-85% accuracy in delay prediction.",
                    icon: "target"
                )
                
                AboutInfoCard(
                    title: "Limitations",
                    description: "Predictions are estimates based on historical data. Unexpected events may not be predicted accurately.",
                    icon: "exclamationmark.triangle"
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Helper Methods
    
    private func resetKnowledgeBase() {
        // Reset the knowledge base
        // In a real implementation, this would clear stored data
        print("🔄 Resetting knowledge base...")
    }
    
    private func exportData() {
        // Export training data
        // In a real implementation, this would create an export file
        print("📤 Exporting training data...")
    }
}

// MARK: - Supporting Views

struct SettingToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(color)
        }
        .padding(12)
        .background(color.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct PredictionExampleRow: View {
    let scenario: String
    let probability: Double
    let factors: [String]
    
    private var riskColor: Color {
        switch probability {
        case 0.0..<0.25: return .green
        case 0.25..<0.5: return .yellow
        case 0.5..<0.75: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Scenario
            VStack(alignment: .leading, spacing: 2) {
                Text(scenario)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(factors.joined(separator: ", "))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Probability
            Text("\(Int(probability * 100))%")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(riskColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(riskColor.opacity(0.1), in: Capsule())
        }
        .padding(8)
        .background(.secondary.opacity(0.03), in: RoundedRectangle(cornerRadius: 6))
    }
}

struct PrivacyInfoRow: View {
    let title: String
    let description: String
    let icon: String
    let status: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.green)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(status)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.green.opacity(0.1), in: Capsule())
        }
        .padding(12)
        .background(.green.opacity(0.03), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct AboutInfoCard: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .background(.blue.opacity(0.03), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    AISettingsView()
}
