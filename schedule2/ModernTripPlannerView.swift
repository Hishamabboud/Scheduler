//
//  ModernTripPlannerView.swift
//  schedule2
//
//  Created by AI Assistant on 05/10/2025.
//

import SwiftUI
import MapKit

struct ModernTripPlannerView: View {
    @StateObject private var tripsService = NSTripsService()
    @State private var fromAddress = ""
    @State private var toAddress = ""
    @State private var departureTime = Date()
    @State private var selectedTransportMode: TripTransportMode = .train
    @State private var tripResult: ModernTripResult?
    @State private var liveTripOptions: [LiveTripResult] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingMap = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
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
                        LazyVStack(spacing: 0) {
                            // Modern hero header
                            modernHeroHeader
                                .padding(.bottom, 28)
                            
                            // Quick routes section
                            quickRoutesSection
                                .padding(.horizontal, 20)
                                .padding(.bottom, 24)
                            
                            // Trip planning form
                            tripPlanningForm
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingMap) {
                ModernMapView()
            }
        }
    }
    
    // MARK: - Modern Hero Header
    private var modernHeroHeader: some View {
        VStack(spacing: 20) {
            // Top spacing for status bar
            Rectangle()
                .fill(.clear)
                .frame(height: 20)
            
            // Main title section
            VStack(spacing: 16) {
                // App icon and title
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.green.gradient)
                            .frame(width: 60, height: 60)
                            .glassEffect(.regular.tint(.green), in: .circle)
                        
                        Image(systemName: "map.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text("Journey Planner")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                
                Text("Plan your trip across the Netherlands")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Quick Routes Section
    private var quickRoutesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Popular Routes")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
            }
            
            GlassEffectContainer(spacing: 12) {
                LazyVStack(spacing: 12) {
                    QuickRouteCard(
                        from: "Amsterdam Centraal",
                        to: "Utrecht Centraal",
                        duration: "38 min",
                        price: "€8.90",
                        icon: "train.side.front.car",
                        color: .blue
                    ) {
                        fromAddress = "Amsterdam Centraal"
                        toAddress = "Utrecht Centraal"
                    }
                    
                    QuickRouteCard(
                        from: "Amsterdam Centraal",
                        to: "Rotterdam Centraal",
                        duration: "42 min",
                        price: "€14.60",
                        icon: "train.side.front.car",
                        color: .purple
                    ) {
                        fromAddress = "Amsterdam Centraal"
                        toAddress = "Rotterdam Centraal"
                    }
                    
                    QuickRouteCard(
                        from: "Amsterdam Centraal",
                        to: "Schiphol Airport",
                        duration: "20 min",
                        price: "€5.40",
                        icon: "airplane",
                        color: .orange
                    ) {
                        fromAddress = "Amsterdam Centraal"
                        toAddress = "Schiphol Airport"
                    }
                }
            }
        }
    }
    
    // MARK: - Trip Planning Form
    private var tripPlanningForm: some View {
        VStack(spacing: 20) {
            // Transport mode selector
            transportModeSelector
                .padding(.horizontal, 20)
            
            // Address input section
            addressInputSection
                .padding(.horizontal, 20)
            
            // Time and options
            timeAndOptionsSection
                .padding(.horizontal, 20)
            
            // Plan journey button
            planJourneyButton
                .padding(.horizontal, 20)

            // Live results section
            if !liveTripOptions.isEmpty {
                liveResultsSection
                    .padding(.horizontal, 20)
            }

            if !errorMessage.isEmpty {
                errorSection
                    .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Transport Mode Selector
    private var transportModeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transport Mode")
                .font(.system(size: 18, weight: .semibold))
            
            HStack(spacing: 12) {
                ForEach(TripTransportMode.allCases, id: \.self) { mode in
                    ModernTransportModeButton(
                        mode: mode,
                        isSelected: selectedTransportMode == mode
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTransportMode = mode
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Address Input Section
    private var addressInputSection: some View {
        VStack(spacing: 16) {
            // From address
            ModernAddressField(
                title: "From",
                address: $fromAddress,
                icon: "location.circle",
                iconColor: .green,
                placeholder: "Enter departure location"
            )
            
            // Swap button
            HStack {
                Spacer()
                Button(action: swapAddresses) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(width: 36, height: 36)
                        .background(.blue.opacity(0.1), in: Circle())
                }
                Spacer()
            }
            
            // To address
            ModernAddressField(
                title: "To",
                address: $toAddress,
                icon: "location.circle.fill",
                iconColor: .red,
                placeholder: "Enter destination"
            )
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Time and Options Section
    private var timeAndOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Departure Time")
                .font(.system(size: 18, weight: .semibold))
            
            HStack(spacing: 16) {
                // Current time button
                Button("Now") {
                    departureTime = Date()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.blue.opacity(0.1), in: Capsule())
                
                Spacer()
                
                // Date picker
                DatePicker("", selection: $departureTime, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .scaleEffect(0.9)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Plan Journey Button
    private var planJourneyButton: some View {
        Button(action: planTrip) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                }
                
                Text(isLoading ? "Planning Journey..." : "Plan Journey")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 12))
            .glassEffect(.regular.tint(.blue), in: .rect(cornerRadius: 12))
        }
        .disabled(fromAddress.isEmpty || toAddress.isEmpty || isLoading)
        .opacity(fromAddress.isEmpty || toAddress.isEmpty ? 0.6 : 1.0)
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper Methods
    private func swapAddresses() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let temp = fromAddress
            fromAddress = toAddress
            toAddress = temp
        }
    }
    
    private func planTrip() {
        isLoading = true
        errorMessage = ""
        liveTripOptions = []
        tripResult = nil

        Task {
            // Fetch live trip options from NS API
            await tripsService.fetchTrips(
                from: fromAddress,
                to: toAddress,
                dateTime: departureTime
            )

            await MainActor.run {
                self.liveTripOptions = tripsService.tripOptions

                if let error = tripsService.error {
                    self.errorMessage = error
                }

                self.isLoading = false
            }
        }
    }
    
    // MARK: - Live Results Section
    private var liveResultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: tripsService.isUsingLiveData ? "antenna.radiowaves.left.and.right" : "info.circle")
                            .foregroundColor(tripsService.isUsingLiveData ? .green : .orange)
                            .font(.title3)

                        Text("Journey Options")
                            .font(.system(size: 20, weight: .semibold))
                    }

                    Text(tripsService.isUsingLiveData ? "Live data from NS" : "Demo data")
                        .font(.caption)
                        .foregroundColor(tripsService.isUsingLiveData ? .green : .orange)
                }

                Spacer()

                Button("View on Map") {
                    showingMap = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }

            ForEach(liveTripOptions) { trip in
                ModernLiveTripCard(trip: trip)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    // MARK: - Trip Results Section (Legacy)
    private func tripResultsSection(_ result: ModernTripResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Journey Options")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Button("View on Map") {
                    showingMap = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }

            TripResultCard(result: result)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Error Section
    private var errorSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24))
                .foregroundColor(.orange)
            
            Text("Journey Planning Error")
                .font(.system(size: 16, weight: .semibold))
            
            Text(errorMessage)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Supporting Views

struct QuickRouteCard: View {
    let from: String
    let to: String
    let duration: String
    let price: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(color)
                }
                
                // Route info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(extractCityName(from))
                            .font(.system(size: 15, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(extractCityName(to))
                            .font(.system(size: 15, weight: .semibold))
                    }
                    
                    HStack(spacing: 8) {
                        Text(duration)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Text(price)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
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
    
    private func extractCityName(_ address: String) -> String {
        if address.contains("Centraal") {
            return address.replacingOccurrences(of: " Centraal", with: "")
        } else if address.contains("Airport") {
            return "Schiphol"
        }
        return address
    }
}

struct ModernTransportModeButton: View {
    let mode: TripTransportMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mode.systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(mode.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue.gradient)
                            .glassEffect(.regular.tint(.blue), in: .rect(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.clear)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

struct ModernAddressField: View {
    let title: String
    @Binding var address: String
    let icon: String
    let iconColor: Color
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                TextField(placeholder, text: $address)
                    .font(.system(size: 16, weight: .medium))
                    .textFieldStyle(.plain)
                
                if !address.isEmpty {
                    Button("Clear") {
                        address = ""
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct TripResultCard: View {
    let result: ModernTripResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.duration)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("\(result.transfers) transfer\(result.transfers == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(result.price)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Total cost")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Steps
            ForEach(result.steps.indices, id: \.self) { index in
                let step = result.steps[index]
                TripStepView(step: step, isLast: index == result.steps.count - 1)
            }
        }
        .padding(20)
        .background(.green.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.green.opacity(0.2), lineWidth: 1)
        )
    }
}

struct TripStepView: View {
    let step: ModernTripStep
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Transport icon and line
            VStack(spacing: 4) {
                Image(systemName: step.mode.systemImage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(step.mode.color)
                    .frame(width: 28, height: 28)
                    .background(step.mode.color.opacity(0.15), in: Circle())
                
                if !isLast {
                    Rectangle()
                        .fill(.secondary)
                        .frame(width: 2, height: 20)
                }
            }
            
            // Step details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(step.line)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Spacer()
                    
                    Text(step.duration)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Text(step.departure, style: .time)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("→")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Text(step.arrival, style: .time)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

struct ModernMapView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Placeholder for map
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        VStack {
                            Image(systemName: "map")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            Text("Interactive Map")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Route visualization coming soon")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            .navigationTitle("Route Map")
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

// MARK: - Simple Models for Modern Trip Planner

struct ModernTripResult {
    let duration: String
    let price: String
    let transfers: Int
    let steps: [ModernTripStep]
}

struct ModernTripStep {
    let mode: TripTransportMode
    let from: String
    let to: String
    let duration: String
    let departure: Date
    let arrival: Date
    let line: String
}

// MARK: - Modern Live Trip Card
struct ModernLiveTripCard: View {
    let trip: LiveTripResult
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main summary row
            Button(action: { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }) {
                HStack(spacing: 12) {
                    // Status indicator
                    Circle()
                        .fill(trip.status.color)
                        .frame(width: 12, height: 12)

                    // Times
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(trip.departureTime, style: .time)
                                .font(.system(size: 16, weight: .bold))

                            Image(systemName: "arrow.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)

                            Text(trip.arrivalTime, style: .time)
                                .font(.system(size: 16, weight: .bold))
                        }

                        HStack(spacing: 6) {
                            Text(trip.formattedDuration)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)

                            Text("•")
                                .foregroundColor(.secondary)

                            if trip.transfers == 0 {
                                Text("Direct")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.green)
                            } else {
                                Text("\(trip.transfers) transfer\(trip.transfers > 1 ? "s" : "")")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    // Price
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(trip.formattedPrice)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)

                        if trip.isOptimal {
                            Text("Best")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1), in: Capsule())
                        }
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            // Warnings
            if !trip.warnings.isEmpty && !trip.warnings.first!.contains("Demo data") {
                ForEach(trip.warnings.filter { !$0.contains("Demo data") }.prefix(1), id: \.self) { warning in
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 12))
                        Text(warning)
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                            .lineLimit(1)
                    }
                }
            }

            // Expanded details
            if isExpanded {
                Divider()
                    .padding(.vertical, 4)

                // Legs
                ForEach(Array(trip.legs.enumerated()), id: \.offset) { index, leg in
                    ModernLegView(leg: leg, isLast: index == trip.legs.count - 1)
                }

                // Crowd info
                if let crowd = trip.crowdForecast {
                    HStack(spacing: 6) {
                        Image(systemName: crowdIcon(for: crowd))
                            .font(.system(size: 12))
                            .foregroundColor(crowdColor(for: crowd))
                        Text("Expected crowd: \(crowd.capitalized)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .background(trip.status.color.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(trip.status.color.opacity(0.2), lineWidth: 1)
        )
    }

    private func crowdIcon(for forecast: String) -> String {
        switch forecast.uppercased() {
        case "LOW": return "person"
        case "MEDIUM": return "person.2"
        case "HIGH": return "person.3"
        default: return "person.2"
        }
    }

    private func crowdColor(for forecast: String) -> Color {
        switch forecast.uppercased() {
        case "LOW": return .green
        case "MEDIUM": return .orange
        case "HIGH": return .red
        default: return .secondary
        }
    }
}

// MARK: - Modern Leg View
struct ModernLegView: View {
    let leg: LiveTripLeg
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Timeline
            VStack(spacing: 2) {
                Circle()
                    .fill(leg.mode.color)
                    .frame(width: 10, height: 10)

                if !isLast {
                    Rectangle()
                        .fill(leg.mode.color.opacity(0.3))
                        .frame(width: 2, height: 35)
                }
            }
            .frame(width: 14)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Transport line info
                HStack(spacing: 6) {
                    Image(systemName: leg.mode.systemImage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(leg.mode.color)

                    Text(leg.lineName)
                        .font(.system(size: 13, weight: .semibold))

                    if let number = leg.lineNumber {
                        Text(number)
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(.blue.opacity(0.1), in: Capsule())
                    }

                    Spacer()

                    if leg.hasDelay {
                        Text("+\(leg.delayMinutes)m")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                }

                // From
                HStack(spacing: 6) {
                    Text(leg.departureTime, style: .time)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(width: 45, alignment: .leading)

                    Text(leg.fromStation)
                        .font(.system(size: 12))
                        .lineLimit(1)

                    if let track = leg.actualDepartureTrack ?? leg.plannedDepartureTrack {
                        Spacer()
                        Text("Pl. \(track)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(leg.trackChanged ? .orange : .secondary)
                    }
                }

                // To
                HStack(spacing: 6) {
                    Text(leg.arrivalTime, style: .time)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(width: 45, alignment: .leading)

                    Text(leg.toStation)
                        .font(.system(size: 12))
                        .lineLimit(1)

                    if let track = leg.actualArrivalTrack ?? leg.plannedArrivalTrack {
                        Spacer()
                        Text("Pl. \(track)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ModernTripPlannerView()
}