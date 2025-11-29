//
//  ContentView.swift
//  schedule2
//
//  Created by Hisham Abboud on 28/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var trafficService = RealTimeTrafficService()
    @State private var selectedTransportType = TransportType.road
    @State private var showingAPIConfig = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Traffic Overview
            ModernTrafficOverviewView(
                trafficService: trafficService,
                selectedTransportType: $selectedTransportType,
                showingAPIConfig: $showingAPIConfig
            )
            .tabItem {
                Label("Live Traffic", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(0)
            
            // Trip Planner
            ModernTripPlannerView()
                .tabItem {
                    Label("Journey", systemImage: "location.magnifyingglass")
                }
                .tag(1)
        }
        .tint(.blue)
    }
}

// MARK: - Modern Traffic Overview View

struct ModernTrafficOverviewView: View {
    @ObservedObject var trafficService: RealTimeTrafficService
    @Binding var selectedTransportType: TransportType
    @Binding var showingAPIConfig: Bool
    @State private var showingAISettings = false
    
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
                                .padding(.bottom, 24)
                            
                            // Transport selector with glass effect
                            modernTransportSelector
                                .padding(.horizontal, 20)
                                .padding(.bottom, 28)
                            
                            // Main content
                            mainContent
                        }
                    }
                    .refreshable {
                        await trafficService.fetchTrafficInfo()
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAPIConfig) {
                APIConfigurationView()
            }
            .sheet(isPresented: $showingAISettings) {
                AISettingsView()
            }
        }
        .task {
            if trafficService.trafficInfo == nil {
                await trafficService.fetchTrafficInfo()
            }
        }
    }
    
    // MARK: - Modern Hero Header
    private var modernHeroHeader: some View {
        VStack(spacing: 20) {
            // Top bar with settings
            HStack {
                Spacer()
                
                Button(action: { showingAPIConfig = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                        .glassEffect(.regular, in: .circle)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(action: { showingAPIConfig = true }) {
                        Label("API Settings", systemImage: "key")
                    }
                    
                    Button(action: { showingAISettings = true }) {
                        Label("AI Settings", systemImage: "brain.head.profile")
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            // Main title section
            VStack(spacing: 16) {
                // App icon and title
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 60, height: 60)
                            .glassEffect(.regular.tint(.blue), in: .circle)
                        
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                        
                        // AI indicator
                        Circle()
                            .fill(.purple)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 22, y: -22)
                    }
                    
                    VStack(spacing: 4) {
                        Text("NL Traffic AI")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("Powered by Machine Learning")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.purple)
                    }
                }
                
                // Status and time
                VStack(spacing: 8) {
                    statusIndicator
                    
                    if let lastUpdated = trafficService.trafficInfo?.lastUpdated {
                        Text("Last updated \(timeAgoString(from: lastUpdated))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var statusIndicator: some View {
        HStack(spacing: 8) {
            // Animated status dot
            ZStack {
                Circle()
                    .fill(isLiveData ? .green : .orange)
                    .frame(width: 8, height: 8)
                
                if isLiveData {
                    Circle()
                        .stroke(Color.green, lineWidth: 2)
                        .frame(width: 16, height: 16)
                        .scaleEffect(1.0)
                        .opacity(0.0)
                        .animation(.easeOut(duration: 1.5).repeatForever(), value: UUID())
                }
            }
            
            Text(isLiveData ? "LIVE DATA" : "DEMO MODE")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isLiveData ? .green : .orange)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .glassEffect(.regular, in: .capsule)
    }
    
    private var isLiveData: Bool {
        trafficService.trafficInfo?.trainServices.contains { service in
            service.operatorName.contains("LIVE")
        } ?? false
    }
    
    // MARK: - Modern Transport Selector
    private var modernTransportSelector: some View {
        GlassEffectContainer(spacing: 20) {
            HStack(spacing: 0) {
                ForEach(TransportType.allCases, id: \.self) { type in
                    TransportTypeButton(
                        type: type,
                        isSelected: selectedTransportType == type
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedTransportType = type
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        if trafficService.isLoading {
            modernLoadingContent
        } else if let error = trafficService.error {
            modernErrorContent(error)
        } else if let trafficInfo = trafficService.trafficInfo {
            modernTrafficContent(trafficInfo)
        } else {
            modernEmptyContent
        }
    }
    
    private var modernLoadingContent: some View {
        VStack(spacing: 24) {
            // Animated loading indicator
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .rotationEffect(.degrees(360))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
            }
            
            VStack(spacing: 8) {
                Text("Fetching Live Data")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Connecting to traffic services...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .padding(.horizontal, 20)
    }
    
    private func modernErrorContent(_ error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Connection Issue")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Unable to fetch live data. Demo mode is active.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Button("Retry Connection") {
                Task { 
                    await trafficService.fetchTrafficInfo()
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.blue, in: Capsule())
            .glassEffect(.regular.tint(.blue), in: .capsule)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .padding(.horizontal, 20)
    }
    
    private var modernEmptyContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.magnifyingglass")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("Ready to Go")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Pull down to get the latest traffic information")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .padding(.horizontal, 20)
    }
    
    private func modernTrafficContent(_ trafficInfo: TrafficInfo) -> some View {
        LazyVStack(spacing: 20) {
            switch selectedTransportType {
            case .road:
                ModernRoadSection(incidents: trafficInfo.roadIncidents)
            case .train:
                ModernTrainSection(services: trafficInfo.trainServices)
            case .bus:
                ModernBusSection(services: trafficInfo.busServices)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    // MARK: - Helper Functions
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Glass Effect Container Implementation (Fallback)

struct GlassEffectContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(spacing: CGFloat, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        content
    }
}
#Preview {
    ContentView()
}
