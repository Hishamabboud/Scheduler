//
//  DetailViews.swift
//  schedule2
//
//  Created by Hisham Abboud on 28/09/2025.
//

import SwiftUI

// MARK: - Modern Road Traffic Detail View

struct RoadTrafficDetailView: View {
    let incidents: [RoadIncident]
    
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
                    LazyVStack(spacing: 16) {
                        if incidents.isEmpty {
                            ModernEmptyState(
                                icon: "checkmark.circle.fill",
                                title: "All Clear",
                                subtitle: "No road incidents are currently reported across the Netherlands",
                                iconColor: .green
                            )
                            .padding(.top, 60)
                        } else {
                            // Statistics header
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(incidents.count)")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.blue)
                                        Text("Active Incidents")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("\(majorIncidentsCount)")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.red)
                                        Text("Major Issues")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(20)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .glassEffect(.regular, in: .rect(cornerRadius: 16))
                                
                                // Incidents list
                                ForEach(incidents) { incident in
                                    RoadIncidentRow(incident: incident)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Road Traffic")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var majorIncidentsCount: Int {
        incidents.filter { $0.severity.lowercased() == "major" }.count
    }
}

// MARK: - Modern Train Services Detail View

struct TrainServicesDetailView: View {
    let services: [TrainService]
    
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
                    LazyVStack(spacing: 20) {
                        // Summary statistics
                        let totalDelays = services.flatMap { $0.delays }.count
                        let avgDelay = totalDelays > 0 ? services.flatMap { $0.delays }.map { $0.delayMinutes }.reduce(0, +) / totalDelays : 0
                        
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("\(totalDelays)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.orange)
                                Text("Total Delays")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack(spacing: 4) {
                                Text("\(avgDelay) min")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.blue)
                                Text("Avg Delay")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .glassEffect(.regular, in: .rect(cornerRadius: 16))
                        
                        // Services breakdown
                        ForEach(services) { service in
                            ModernServiceDetailCard(service: service)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Train Services")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Modern Bus Services Detail View

struct BusServicesDetailView: View {
    let services: [BusService]
    
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
                    LazyVStack(spacing: 20) {
                        // Summary statistics
                        let totalDelays = services.flatMap { $0.delays }.count
                        let activeServices = services.filter { $0.status != .normal }.count
                        
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("\(totalDelays)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.orange)
                                Text("Total Delays")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack(spacing: 4) {
                                Text("\(activeServices)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.green)
                                Text("Affected Routes")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .glassEffect(.regular, in: .rect(cornerRadius: 16))
                        
                        // Services breakdown
                        ForEach(services) { service in
                            ModernBusServiceDetailCard(service: service)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Bus Services")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Modern Service Detail Cards

struct ModernServiceDetailCard: View {
    let service: TrainService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Service header
            HStack {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "train.side.front.car")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(cleanServiceName(service.operatorName))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(service.route)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: service.status, compact: false)
                    
                    if service.delays.count > 0 {
                        Text("\(service.delays.count) delays")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Delays list
            if service.delays.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("No delays reported for this service")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(service.delays) { delay in
                        TrainDelayRow(delay: delay)
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    private func cleanServiceName(_ name: String) -> String {
        return name.replacingOccurrences(of: " - LIVE", with: "")
                  .replacingOccurrences(of: " - DEMO", with: "")
    }
}

struct ModernBusServiceDetailCard: View {
    let service: BusService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Service header
            HStack {
                ZStack {
                    Circle()
                        .fill(.green.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "bus.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(cleanServiceName(service.operatorName))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(service.region)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: service.status, compact: false)
                    
                    if service.delays.count > 0 {
                        Text("\(service.delays.count) delays")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Delays list
            if service.delays.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("No delays reported for this service")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(service.delays) { delay in
                        BusDelayRow(delay: delay)
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    private func cleanServiceName(_ name: String) -> String {
        return name.replacingOccurrences(of: " - LIVE", with: "")
                  .replacingOccurrences(of: " - DEMO", with: "")
    }
}