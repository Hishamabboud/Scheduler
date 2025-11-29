//
//  AIDelayPredictionComponents.swift
//  schedule2
//
//  Created by AI Assistant on 05/10/2025.
//

import SwiftUI

// MARK: - AI Delay Prediction Card

struct AIDelayPredictionCard: View {
    let prediction: AIDelayPrediction
    let route: String
    let transportType: TransportType
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with AI indicator
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.purple)
                    
                    Text("AI Prediction")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                ConfidenceBadge(confidence: prediction.confidence)
            }
            
            // Main prediction display
            VStack(spacing: 12) {
                // Probability visualization
                DelayProbabilityView(probability: prediction.probability)
                
                // Duration estimate if available
                if let duration = prediction.estimatedDuration {
                    DelayDurationEstimate(duration: duration)
                }
                
                // Primary factors
                if !prediction.primaryFactors.isEmpty {
                    DelayFactorsView(factors: prediction.primaryFactors)
                }
                
                // Recommendation
                RecommendationView(
                    recommendation: prediction.recommendation,
                    probability: prediction.probability
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.purple.opacity(0.3), lineWidth: 1)
        )
        .glassEffect(.regular.tint(.purple), in: .rect(cornerRadius: 16))
    }
}

// MARK: - Delay Probability Visualization

struct DelayProbabilityView: View {
    let probability: Double
    
    private var probabilityText: String {
        return "\(Int(probability * 100))%"
    }
    
    private var riskLevel: RiskLevel {
        switch probability {
        case 0.0..<0.25: return .low
        case 0.25..<0.5: return .moderate
        case 0.5..<0.75: return .high
        default: return .veryHigh
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Circular progress indicator
            ZStack {
                Circle()
                    .stroke(riskLevel.color.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: probability)
                    .stroke(
                        riskLevel.color.gradient,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: probability)
                
                VStack(spacing: 2) {
                    Text(probabilityText)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(riskLevel.color)
                    
                    Text("chance")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // Risk level indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(riskLevel.color)
                    .frame(width: 8, height: 8)
                
                Text(riskLevel.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(riskLevel.color)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(riskLevel.color.opacity(0.1), in: Capsule())
        }
    }
}

enum RiskLevel: String, CaseIterable {
    case low = "Low Risk"
    case moderate = "Moderate Risk"
    case high = "High Risk"
    case veryHigh = "Very High Risk"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        }
    }
}

// MARK: - Confidence Badge

struct ConfidenceBadge: View {
    let confidence: Double
    
    private var confidenceText: String {
        return "\(Int(confidence * 100))%"
    }
    
    private var confidenceLevel: String {
        switch confidence {
        case 0.0..<0.5: return "Low"
        case 0.5..<0.75: return "Medium"
        case 0.75..<0.9: return "High"
        default: return "Very High"
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(confidenceText)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.blue)
            
            Text("confidence")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Delay Duration Estimate

struct DelayDurationEstimate: View {
    let duration: TimeInterval
    
    private var durationText: String {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.orange)
            
            Text("Estimated delay: \(durationText)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Delay Factors View

struct DelayFactorsView: View {
    let factors: [DelayFactor]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("Contributing Factors")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 6) {
                ForEach(Array(factors.prefix(3).enumerated()), id: \.offset) { index, factor in
                    DelayFactorRow(factor: factor, rank: index + 1)
                }
            }
        }
    }
}

struct DelayFactorRow: View {
    let factor: DelayFactor
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank indicator
            Text("\(rank)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
                .background(impactColor, in: Circle())
            
            // Factor icon
            Image(systemName: factor.type.systemImage)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(impactColor)
                .frame(width: 16)
            
            // Factor description
            VStack(alignment: .leading, spacing: 2) {
                Text(factor.type.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(factor.description)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Impact percentage
            Text("\(Int(factor.impact * 100))%")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(impactColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(impactColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 6))
    }
    
    private var impactColor: Color {
        switch factor.impact {
        case 0.0..<0.3: return .green
        case 0.3..<0.6: return .orange
        default: return .red
        }
    }
}

// MARK: - Recommendation View

struct RecommendationView: View {
    let recommendation: String
    let probability: Double
    
    private var recommendationIcon: String {
        switch probability {
        case 0.0..<0.3: return "checkmark.circle"
        case 0.3..<0.6: return "exclamationmark.triangle"
        default: return "xmark.circle"
        }
    }
    
    private var recommendationColor: Color {
        switch probability {
        case 0.0..<0.3: return .green
        case 0.3..<0.6: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: recommendationIcon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(recommendationColor)
                .frame(width: 20, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Recommendation")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Text(recommendation)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(12)
        .background(.secondary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Route Prediction Summary

struct RoutePredictionSummary: View {
    let predictions: [RouteDelayPrediction]
    let route: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "map")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                
                Text("Route Analysis: \(route)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(predictions.indices, id: \.self) { index in
                    RouteStopPredictionRow(
                        station: predictions[index].station,
                        prediction: predictions[index].prediction,
                        isLast: index == predictions.count - 1
                    )
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}

struct RouteStopPredictionRow: View {
    let station: String
    let prediction: AIDelayPrediction
    let isLast: Bool
    
    private var riskColor: Color {
        switch prediction.probability {
        case 0.0..<0.25: return .green
        case 0.25..<0.5: return .yellow
        case 0.5..<0.75: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Station indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(riskColor)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(.secondary)
                        .frame(width: 2, height: 24)
                }
            }
            
            // Station info
            VStack(alignment: .leading, spacing: 4) {
                Text(station)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Text("\(Int(prediction.probability * 100))% delay risk")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(riskColor)
                    
                    if let duration = prediction.estimatedDuration {
                        Text("~\(Int(duration / 60))min")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Quick factors indicator
            if let topFactor = prediction.primaryFactors.first {
                Image(systemName: topFactor.type.systemImage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Knowledge Base Status View

struct KnowledgeBaseStatusView: View {
    @ObservedObject var knowledgeBase: TransportKnowledgeBase
    @ObservedObject var predictionService: DelayPredictionService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.purple)
                
                Text("AI Knowledge Base")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            // Status indicators
            LazyVStack(spacing: 12) {
                StatusIndicatorRow(
                    title: "Historical Incidents",
                    value: "\(knowledgeBase.totalIncidents)",
                    icon: "doc.text",
                    color: .blue
                )
                
                StatusIndicatorRow(
                    title: "Learning Status",
                    value: knowledgeBase.isLearning ? "Active" : "Idle",
                    icon: knowledgeBase.isLearning ? "brain.head.profile" : "pause.circle",
                    color: knowledgeBase.isLearning ? .green : .secondary
                )
                
                if let lastUpdate = knowledgeBase.lastLearningUpdate {
                    StatusIndicatorRow(
                        title: "Last Updated",
                        value: timeAgoString(from: lastUpdate),
                        icon: "clock",
                        color: .secondary
                    )
                }
                
                if let lastPrediction = predictionService.lastPredictionUpdate {
                    StatusIndicatorRow(
                        title: "Predictions Updated",
                        value: timeAgoString(from: lastPrediction),
                        icon: "chart.line.uptrend.xyaxis",
                        color: .secondary
                    )
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.purple.opacity(0.2), lineWidth: 1)
        )
        .glassEffect(.regular.tint(.purple), in: .rect(cornerRadius: 16))
    }
    
    private func timeAgoString(from date: Date) -> String {
        let timeInterval = Date().timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "Just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d ago"
        }
    }
}

struct StatusIndicatorRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

// MARK: - AI Insights Panel

struct AIInsightsPanel: View {
    let transportType: TransportType
    let currentDelays: [TrainDelay]
    @ObservedObject var predictionService: DelayPredictionService
    
    @State private var insights: [AIInsight] = []
    @State private var isLoadingInsights = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.yellow)
                
                Text("AI Insights")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isLoadingInsights {
                    ProgressView()
                        .controlSize(.mini)
                }
            }
            
            if insights.isEmpty && !isLoadingInsights {
                Text("Analyzing patterns to generate insights...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(insights) { insight in
                        AIInsightCard(insight: insight)
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.yellow.opacity(0.2), lineWidth: 1)
        )
        .glassEffect(.regular.tint(.yellow), in: .rect(cornerRadius: 16))
        .task {
            await generateInsights()
        }
    }
    
    private func generateInsights() async {
        isLoadingInsights = true
        defer { isLoadingInsights = false }
        
        // Simulate AI analysis delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Generate insights based on current data
        var generatedInsights: [AIInsight] = []
        
        // Analyze current delays
        if !currentDelays.isEmpty {
            let avgDelay = currentDelays.map { $0.delayMinutes }.reduce(0, +) / currentDelays.count
            generatedInsights.append(AIInsight(
                type: .pattern,
                title: "Current Delay Pattern",
                description: "Average delay is \(avgDelay) minutes. This is \(avgDelay > 5 ? "higher" : "lower") than typical for this time.",
                confidence: 0.85,
                actionable: avgDelay > 5
            ))
        }
        
        // Weather impact insight
        generatedInsights.append(AIInsight(
            type: .weather,
            title: "Weather Impact Analysis",
            description: "Current weather conditions increase delay probability by 20% compared to clear conditions.",
            confidence: 0.78,
            actionable: true
        ))
        
        // Time-based insight
        let hour = Calendar.current.component(.hour, from: Date())
        if (7...9).contains(hour) || (17...19).contains(hour) {
            generatedInsights.append(AIInsight(
                type: .timing,
                title: "Rush Hour Effect",
                description: "Delay risk is 40% higher during rush hour. Consider traveling 1 hour earlier or later.",
                confidence: 0.92,
                actionable: true
            ))
        }
        
        insights = generatedInsights
    }
}

struct AIInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let description: String
    let confidence: Double
    let actionable: Bool
}

enum InsightType: String, CaseIterable {
    case pattern = "Pattern"
    case weather = "Weather" 
    case timing = "Timing"
    case route = "Route"
    
    var icon: String {
        switch self {
        case .pattern: return "chart.bar"
        case .weather: return "cloud.rain"
        case .timing: return "clock"
        case .route: return "map"
        }
    }
    
    var color: Color {
        switch self {
        case .pattern: return .blue
        case .weather: return .cyan
        case .timing: return .orange
        case .route: return .purple
        }
    }
}

struct AIInsightCard: View {
    let insight: AIInsight
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.type.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(insight.type.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(insight.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(insight.confidence * 100))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(insight.type.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(insight.type.color.opacity(0.1), in: Capsule())
                }
                
                Text(insight.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineSpacing(1)
                
                if insight.actionable {
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb.min")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        
                        Text("Actionable")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(12)
        .background(insight.type.color.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}