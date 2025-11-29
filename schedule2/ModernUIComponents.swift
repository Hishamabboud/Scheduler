//
//  ModernUIComponents.swift
//  schedule2
//
//  Created by AI Assistant on 05/10/2025.
//

import SwiftUI
import Combine

// MARK: - Modern Transport Type Button with Liquid Glass

struct TransportTypeButton: View {
    let type: TransportType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: type.systemImage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(type.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue)
                                    .opacity(0.3)
                            )
                            .glassEffect(.regular.tint(.blue), in: .rect(cornerRadius: 8))
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Modern Road Section

struct ModernRoadSection: View {
    let incidents: [RoadIncident]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with summary
            HStack {
                Image(systemName: "car.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Road Network")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(incidents.isEmpty ? "All clear" : "\(incidents.count) incident\(incidents.count == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(
                    status: incidents.isEmpty ? .normal : .disrupted,
                    compact: false
                )
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
            
            // Incidents list or empty state
            if incidents.isEmpty {
                ModernEmptyState(
                    icon: "checkmark.circle.fill",
                    title: "No Incidents",
                    subtitle: "All major roads are running normally",
                    iconColor: .green
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(incidents) { incident in
                        RoadIncidentRow(incident: incident)
                    }
                }
            }
        }
    }
}

// MARK: - Simplified AI Components (Basic Implementation)

// Basic AI Prediction Models
struct DelayPrediction {
    let probability: Double
    let confidence: Double
    let primaryFactors: [String]
    let recommendation: String
    
    static func demo(for transportType: TransportType) -> DelayPrediction {
        let probability = Double.random(in: 0.1...0.8)
        let confidence = Double.random(in: 0.6...0.95)
        
        let factors = ["Weather", "Rush Hour", "Historical Patterns", "Passenger Load"].shuffled().prefix(2)
        
        let recommendation = probability > 0.5 
            ? "High delay risk - consider alternative routes" 
            : "Normal travel conditions expected"
        
        return DelayPrediction(
            probability: probability,
            confidence: confidence,
            primaryFactors: Array(factors),
            recommendation: recommendation
        )
    }
}

class SimpleDelayPredictionService: ObservableObject {
    @Published var isLoading = false
    
    func predictDelayProbability(for transportType: TransportType, route: String, location: String) async -> DelayPrediction {
        isLoading = true
        
        // Simulate AI processing time
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        isLoading = false
        return DelayPrediction.demo(for: transportType)
    }
}

class SimpleKnowledgeBase: ObservableObject {
    @Published var isLearning = false
    @Published var totalIncidents = 247 // Demo data
    
    static let shared = SimpleKnowledgeBase()
    
    private init() {
        // Simulate learning activity
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.isLearning.toggle()
            if self.isLearning {
                self.totalIncidents += Int.random(in: 1...3)
            }
        }
    }
}

// Simple AI Prediction Card
struct SimpleAICard: View {
    let prediction: DelayPrediction
    let route: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.purple)
                
                Text("AI Prediction")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.purple)
                
                Spacer()
                
                Text("\(Int(prediction.confidence * 100))% confidence")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            // Probability
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(Int(prediction.probability * 100))% delay risk")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(riskColor)
                    
                    Text("Factors: \(prediction.primaryFactors.joined(separator: ", "))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(riskColor)
                    .frame(width: 8, height: 8)
            }
            
            // Recommendation
            Text(prediction.recommendation)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(.purple.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.purple.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var riskColor: Color {
        switch prediction.probability {
        case 0.0..<0.25: return .green
        case 0.25..<0.5: return .yellow
        case 0.5..<0.75: return .orange
        default: return .red
        }
    }
}

// Simple AI Status View
struct SimpleAIStatusView: View {
    @ObservedObject var knowledgeBase: SimpleKnowledgeBase
    @ObservedObject var predictionService: SimpleDelayPredictionService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.purple)
                
                Text("AI Status")
                    .font(.system(size: 16, weight: .semibold))
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(knowledgeBase.totalIncidents)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Incidents Learned")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(knowledgeBase.isLearning ? .green : .orange)
                            .frame(width: 6, height: 6)
                        
                        Text(knowledgeBase.isLearning ? "Learning" : "Idle")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(knowledgeBase.isLearning ? .green : .orange)
                    }
                    
                    Text("AI Status")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Modern Train Section with Simplified AI

struct ModernTrainSection: View {
    let services: [TrainService]
    @StateObject private var predictionService = SimpleDelayPredictionService()
    @StateObject private var knowledgeBase = SimpleKnowledgeBase.shared
    @State private var predictions: [String: DelayPrediction] = [:]
    @State private var showingAIInsights = false
    
    var body: some View {
        VStack(spacing: 16) {
            // AI Status Header
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.purple)
                
                Text("AI-Enhanced Train Analysis")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button(action: { showingAIInsights.toggle() }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            
            // AI Status Panel (collapsible)
            if showingAIInsights {
                SimpleAIStatusView(
                    knowledgeBase: knowledgeBase,
                    predictionService: predictionService
                )
                .padding(.horizontal, 20)
            }
            
            // Services overview with AI predictions
            LazyVStack(spacing: 12) {
                ForEach(services) { service in
                    ModernServiceCardWithSimpleAI(
                        service: service,
                        prediction: predictions[service.operatorName],
                        predictionService: predictionService,
                        onPredictionUpdate: { prediction in
                            predictions[service.operatorName] = prediction
                        }
                    )
                }
            }
            
            // Recent delays preview with AI analysis
            let allDelays = services.flatMap { $0.delays }
            if !allDelays.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Current Delays + AI Analysis")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        NavigationLink("View All") {
                            TrainServicesDetailView(services: services)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    }
                    
                    LazyVStack(spacing: 8) {
                        ForEach(Array(allDelays.prefix(3))) { delay in
                            VStack(spacing: 8) {
                                TrainDelayRow(delay: delay)
                                
                                // Simple AI prediction for this delay
                                SimpleAIDelayPrediction(delay: delay, service: predictionService)
                            }
                        }
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .glassEffect(.regular, in: .rect(cornerRadius: 16))
            }
            
            // Knowledge Base Status (if learning is active)
            if knowledgeBase.isLearning {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.purple)
                    
                    Text("AI is learning from current traffic patterns...")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    ProgressView()
                        .controlSize(.mini)
                }
                .padding(12)
                .background(.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func cleanServiceName(_ name: String) -> String {
        return name.replacingOccurrences(of: " - LIVE", with: "")
                  .replacingOccurrences(of: " - DEMO", with: "")
    }
}

// MARK: - Modern Bus Section

struct ModernBusSection: View {
    let services: [BusService]
    
    var body: some View {
        VStack(spacing: 16) {
            // Services overview
            LazyVStack(spacing: 12) {
                ForEach(services) { service in
                    ModernServiceCard(
                        icon: "bus.fill",
                        title: cleanServiceName(service.operatorName),
                        subtitle: service.region,
                        status: service.status,
                        delayCount: service.delays.count,
                        iconColor: .green,
                        destination: AnyView(BusServicesDetailView(services: [service]))
                    )
                }
            }
            
            // Recent delays preview
            let allDelays = services.flatMap { $0.delays }
            if !allDelays.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Delays")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        NavigationLink("View All") {
                            BusServicesDetailView(services: services)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    }
                    
                    LazyVStack(spacing: 8) {
                        ForEach(Array(allDelays.prefix(3))) { delay in
                            BusDelayRow(delay: delay)
                        }
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .glassEffect(.regular, in: .rect(cornerRadius: 16))
            }
        }
    }
    
    private func cleanServiceName(_ name: String) -> String {
        return name.replacingOccurrences(of: " - LIVE", with: "")
                  .replacingOccurrences(of: " - DEMO", with: "")
    }
}

// MARK: - Modern Service Card

struct ModernServiceCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let status: ServiceStatus
    let delayCount: Int
    let iconColor: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                // Icon container
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                // Service info
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Status and delay count
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: status, compact: true)
                    
                    if delayCount > 0 {
                        Text("\(delayCount) delay\(delayCount == 1 ? "" : "s")")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .glassEffect(.regular, in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: ServiceStatus
    let compact: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: compact ? 6 : 8, height: compact ? 6 : 8)
            
            if !compact {
                Text(status.rawValue.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(statusColor)
            }
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .background(statusColor.opacity(0.15), in: Capsule())
    }
    
    private var statusColor: Color {
        switch status {
        case .normal:
            return .green
        case .delayed:
            return .orange
        case .disrupted, .cancelled:
            return .red
        }
    }
}

// MARK: - Modern Empty State

struct ModernEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(iconColor)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}

// MARK: - Glass Effect Extensions

extension View {
    @ViewBuilder
    func glassEffect(
        _ glass: Glass = .regular,
        in shape: some InsettableShape = .rect(cornerRadius: 8),
        isEnabled: Bool = true
    ) -> some View {
        if isEnabled {
            self.background(
                shape
                    .fill(.ultraThinMaterial)
                    .overlay(
                        shape
                            .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                    )
            )
        } else {
            self
        }
    }
}

// MARK: - Glass Struct for Configuration

struct Glass {
    static let regular = Glass()
    
    func tint(_ color: Color) -> Glass {
        // Configuration for tint (implementation would depend on the specific requirements)
        return self
    }
    
    func interactive(_ enabled: Bool = true) -> Glass {
        // Configuration for interactivity
        return self
    }
}

// MARK: - Simplified AI-Enhanced Service Card

struct ModernServiceCardWithSimpleAI: View {
    let service: TrainService
    let prediction: DelayPrediction?
    let predictionService: SimpleDelayPredictionService
    let onPredictionUpdate: (DelayPrediction) -> Void
    
    @State private var isLoadingPrediction = false
    @State private var showingFullPrediction = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Main service card
            NavigationLink(destination: TrainServicesDetailView(services: [service])) {
                HStack(spacing: 16) {
                    // Icon container with AI indicator
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "train.side.front.car")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.blue)
                        
                        // AI prediction indicator
                        if prediction != nil {
                            Circle()
                                .fill(.purple)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 6, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 16, y: -16)
                        }
                    }
                    
                    // Service info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cleanServiceName(service.operatorName))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(service.route)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Status and delay count with prediction
                    VStack(alignment: .trailing, spacing: 4) {
                        StatusBadge(status: service.status, compact: true)
                        
                        if service.delays.count > 0 {
                            Text("\(service.delays.count) delay\(service.delays.count == 1 ? "" : "s")")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        // AI prediction summary
                        if let prediction = prediction {
                            Text("\(Int(prediction.probability * 100))% risk")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(predictionColor(prediction.probability))
                        } else if isLoadingPrediction {
                            HStack(spacing: 4) {
                                ProgressView()
                                    .controlSize(.mini)
                                Text("AI")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                    
                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .glassEffect(.regular, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            
            // AI Prediction Card (expandable)
            if let prediction = prediction {
                Button(action: { showingFullPrediction.toggle() }) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.purple)
                        
                        Text("AI Prediction: \(Int(prediction.probability * 100))% delay risk")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.purple)
                        
                        Spacer()
                        
                        Image(systemName: showingFullPrediction ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.purple)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                
                if showingFullPrediction {
                    SimpleAICard(prediction: prediction, route: service.route)
                }
            }
        }
        .task {
            await loadPrediction()
        }
    }
    
    private func loadPrediction() async {
        guard prediction == nil else { return }
        
        isLoadingPrediction = true
        
        let newPrediction = await predictionService.predictDelayProbability(
            for: .train,
            route: service.route,
            location: extractPrimaryStation(from: service.route)
        )
        
        isLoadingPrediction = false
        onPredictionUpdate(newPrediction)
    }
    
    private func extractPrimaryStation(from route: String) -> String {
        let components = route.components(separatedBy: " - ")
        return components.first ?? route
    }
    
    private func predictionColor(_ probability: Double) -> Color {
        switch probability {
        case 0.0..<0.25: return .green
        case 0.25..<0.5: return .yellow
        case 0.5..<0.75: return .orange
        default: return .red
        }
    }
    
    private func cleanServiceName(_ name: String) -> String {
        return name.replacingOccurrences(of: " - LIVE", with: "")
                  .replacingOccurrences(of: " - DEMO", with: "")
    }
}

// Simple AI delay prediction for individual delays
struct SimpleAIDelayPrediction: View {
    let delay: TrainDelay
    let service: SimpleDelayPredictionService
    @State private var prediction: DelayPrediction?
    
    var body: some View {
        if let prediction = prediction {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.purple)
                
                Text("Future risk: \(Int(prediction.probability * 100))%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.purple)
                
                Spacer()
                
                Text(prediction.primaryFactors.first ?? "Analysis")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.purple.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
            .task {
                if prediction == nil {
                    self.prediction = await service.predictDelayProbability(
                        for: .train,
                        route: delay.route,
                        location: delay.station
                    )
                }
            }
        }
    }
}

// MARK: - ATSHelper Removed (already exists in ATSHelper.swift)