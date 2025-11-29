//
//  APIConfigurationView.swift
//  schedule2
//
//  Created by Hisham Abboud on 28/09/2025.
//

import SwiftUI

struct APIConfigurationView: View {
    @AppStorage("nsAPIKey") private var nsAPIKey: String = ""
    @AppStorage("ndwAPIKey") private var ndwAPIKey: String = ""
    @Environment(\.dismiss) private var dismiss
    
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
                        modernHeaderSection
                            .padding(.top, 20)
                        
                        // Configuration sections
                        VStack(spacing: 20) {
                            modernNSAPISection
                            modernNDWAPISection
                            modernOpenOVSection
                            modernStatusSection
                            modernNoteSection
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
    
    // MARK: - Modern Header Section
    private var modernHeaderSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(.orange.gradient)
                    .frame(width: 60, height: 60)
                    .glassEffect(.regular.tint(.orange), in: .circle)
                
                Image(systemName: "key.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("API Configuration")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Configure your API keys to access real-time traffic data from official Dutch transport services")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Modern NS API Section
    private var modernNSAPISection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "train.side.front.car")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("NS (Train Data)")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Real-time train delays and disruptions")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusIndicator(isConfigured: !nsAPIKey.isEmpty)
            }
            
            // API Key input
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                SecureField("Enter your NS API key", text: $nsAPIKey)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(nsAPIKey.isEmpty ? .clear : .blue.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Instructions
            ModernInstructionCard(
                title: "How to get your NS API key:",
                steps: [
                    "Visit apiportal.ns.nl",
                    "Create an account and sign in",
                    "Subscribe to the Reisinformatie API",
                    "Copy your subscription key"
                ]
            )
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Modern NDW API Section
    private var modernNDWAPISection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.red.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("NDW (Road Traffic)")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Real-time road incidents and traffic data")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusIndicator(isConfigured: !ndwAPIKey.isEmpty)
            }
            
            // API Key input
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                SecureField("Enter your NDW API key", text: $ndwAPIKey)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(ndwAPIKey.isEmpty ? .clear : .red.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Instructions
            ModernInstructionCard(
                title: "How to get your NDW API key:",
                steps: [
                    "Visit ndw.nu",
                    "Register for API access",
                    "Request access to traffic data APIs",
                    "Receive your API credentials"
                ]
            )
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Modern OpenOV Section
    private var modernOpenOVSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.green.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "bus.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("OpenOV (Public Transport)")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Free access to bus, tram, and metro data")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusIndicator(isConfigured: true)
            }
            
            // Free API info
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("No API key required")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                    
                    Text("OpenOV provides free access to real-time public transport data across the Netherlands")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.green.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Modern Status Section
    private var modernStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuration Status")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 12) {
                StatusRow(
                    title: "Train Data (NS)",
                    subtitle: "Real-time train information",
                    isConfigured: !nsAPIKey.isEmpty,
                    color: .blue
                )
                
                StatusRow(
                    title: "Road Traffic (NDW)",
                    subtitle: "Real-time road incidents",
                    isConfigured: !ndwAPIKey.isEmpty,
                    color: .red
                )
                
                StatusRow(
                    title: "Public Transport (OpenOV)",
                    subtitle: "Bus, tram, and metro data",
                    isConfigured: true,
                    color: .green
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Modern Note Section
    private var modernNoteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                Text("Important Note")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            Text("Without API keys, the app displays realistic demo data that simulates real-time conditions. For actual live data, configure your API keys above.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
        .padding(16)
        .background(.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Supporting Views

struct StatusIndicator: View {
    let isConfigured: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isConfigured ? .green.opacity(0.15) : .orange.opacity(0.15))
                .frame(width: 24, height: 24)
            
            Image(systemName: isConfigured ? "checkmark" : "exclamationmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isConfigured ? .green : .orange)
        }
    }
}

struct ModernInstructionCard: View {
    let title: String
    let steps: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 16, alignment: .leading)
                        
                        Text(step)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct StatusRow: View {
    let title: String
    let subtitle: String
    let isConfigured: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: isConfigured ? "checkmark" : "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isConfigured ? color : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(isConfigured ? "Configured" : "Not Set")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isConfigured ? .green : .orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((isConfigured ? Color.green : Color.orange).opacity(0.15), in: Capsule())
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    APIConfigurationView()
}