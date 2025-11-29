//
//  ContentView.swift
//  schedule2
//
//  Created by Hisham Abboud on 28/09/2025.
//

import SwiftUI

struct ContentViewBackup: View {
    @StateObject private var trafficService = RealTimeTrafficService()
    @State private var selectedTransportType = TransportType.road
    @State private var showingDetail = false
    @State private var showingAPIConfig = false
    @State private var apiTestResult = ""
    @State private var showingAPITest = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Traffic Overview
            mainTrafficView
                .tabItem {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("Overview")
                }
                .tag(0)
            
            // Trip Planner
            TripPlannerView()
                .tabItem {
                    Image(systemName: "map")
                    Text("My Trip")
                }
                .tag(1)
        }
    }
    
    // MARK: - Main Traffic View
    private var mainTrafficView: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with status
                headerView
                
                // API Test Button (temporary for debugging)
                Button("🧪 Test NS API") {
                    Task {
                        await testNSAPI()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
                
                if !apiTestResult.isEmpty {
                    ScrollView {
                        Text(apiTestResult)
                            .font(.caption)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                }
                
                // Transport type picker
                transportPicker
                
                // Content based on loading state
                if trafficService.isLoading {
                    loadingView
                } else if let error = trafficService.error {
                    errorView(error)
                } else if let trafficInfo = trafficService.trafficInfo {
                    contentView(trafficInfo)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("NL Traffic Info")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingAPIConfig = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await trafficService.fetchTrafficInfo()
                        }
                    }
                    .disabled(trafficService.isLoading)
                }
            }
            .sheet(isPresented: $showingAPIConfig) {
                APIConfigurationView()
            }
        }
        .task {
            await trafficService.fetchTrafficInfo()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text("Netherlands Traffic")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                // Data source indicator
                dataSourceIndicator
            }
            
            if let lastUpdated = trafficService.trafficInfo?.lastUpdated {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Last updated: \(lastUpdated, formatter: timeFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var dataSourceIndicator: some View {
        // Check if we have successfully loaded live data
        let hasLiveData = trafficService.trafficInfo?.trainServices.contains { service in
            service.operatorName.contains("LIVE")
        } ?? false
        
        return HStack(spacing: 4) {
            Circle()
                .fill(hasLiveData ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Text(hasLiveData ? "LIVE" : "DEMO")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(hasLiveData ? .green : .orange)
        }
    }
    
    // MARK: - Transport Picker
    private var transportPicker: some View {
        Picker("Transport Type", selection: $selectedTransportType) {
            ForEach(TransportType.allCases, id: \.self) { type in
                Label(type.rawValue, systemImage: type.systemImage)
                    .tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    // MARK: - Content View
    private func contentView(_ trafficInfo: TrafficInfo) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                switch selectedTransportType {
                case .road:
                    roadTrafficSection(trafficInfo.roadIncidents)
                case .train:
                    trainServicesSection(trafficInfo.trainServices)
                case .bus:
                    busServicesSection(trafficInfo.busServices)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Road Traffic Section
    private func roadTrafficSection(_ incidents: [RoadIncident]) -> some View {
        VStack(spacing: 12) {
            // Summary card
            NavigationLink(destination: RoadTrafficDetailView(incidents: incidents)) {
                ServiceStatusRow(
                    serviceName: "Road Network",
                    status: incidents.isEmpty ? .normal : .disrupted,
                    delayCount: incidents.count,
                    transportType: .road
                )
            }
            .buttonStyle(.plain)
            
            // Recent incidents preview
            if !incidents.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Current Incidents")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        if incidents.count > 2 {
                            NavigationLink("View All", destination: RoadTrafficDetailView(incidents: incidents))
                                .font(.caption)
                        }
                    }
                    
                    ForEach(incidents.prefix(2)) { incident in
                        RoadIncidentRow(incident: incident)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("No road incidents reported")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
    }
    
    // MARK: - Train Services Section
    private func trainServicesSection(_ services: [TrainService]) -> some View {
        VStack(spacing: 12) {
            let totalDelays = services.flatMap { $0.delays }.count
            
            // Summary cards
            ForEach(services) { service in
                NavigationLink(destination: TrainServicesDetailView(services: [service])) {
                    ServiceStatusRow(
                        serviceName: service.operatorName,
                        status: service.status,
                        delayCount: service.delays.count,
                        transportType: .train
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Recent delays preview
            let recentDelays = services.flatMap { $0.delays }.prefix(3)
            if !recentDelays.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Current Delays")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        if totalDelays > 3 {
                            NavigationLink("View All", destination: TrainServicesDetailView(services: services))
                                .font(.caption)
                        }
                    }
                    
                    ForEach(Array(recentDelays)) { delay in
                        TrainDelayRow(delay: delay)
                    }
                }
            }
        }
    }
    
    // MARK: - Bus Services Section
    private func busServicesSection(_ services: [BusService]) -> some View {
        VStack(spacing: 12) {
            let totalDelays = services.flatMap { $0.delays }.count
            
            // Summary cards
            ForEach(services) { service in
                NavigationLink(destination: BusServicesDetailView(services: [service])) {
                    ServiceStatusRow(
                        serviceName: service.operatorName,
                        status: service.status,
                        delayCount: service.delays.count,
                        transportType: .bus
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Recent delays preview
            let recentDelays = services.flatMap { $0.delays }.prefix(3)
            if !recentDelays.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Current Delays")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        if totalDelays > 3 {
                            NavigationLink("View All", destination: BusServicesDetailView(services: services))
                                .font(.caption)
                        }
                    }
                    
                    ForEach(Array(recentDelays)) { delay in
                        BusDelayRow(delay: delay)
                    }
                }
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            VStack(spacing: 8) {
                Text("Loading traffic information...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Testing NS API with your key...")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text("Check Xcode console for detailed logs")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            Text("Error")
                .font(.headline)
                .fontWeight(.semibold)
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task {
                    await trafficService.fetchTrafficInfo()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            Text("Welcome to NL Traffic")
                .font(.headline)
                .fontWeight(.semibold)
            Text("Tap refresh to get the latest traffic information for the Netherlands")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - API Test Function
    func testNSAPI() async {
        apiTestResult = "Testing NS API...\n"
        
        let apiKey = "24580b0cd78f49d489cea30d58fb2150"
        
        // Test multiple NS API endpoints to find all delay/disruption data
        let endpoints = [
            ("Disruptions (Default)", "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/disruptions"),
            ("Disruptions (Actual)", "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/disruptions?actual=true"),
            ("Disruptions (Planned)", "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/disruptions?type=planned"),
            ("Disruptions (All Types)", "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/disruptions?actual=true&type=werkzaamheid"),
            ("Disruptions (Maintenance)", "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/disruptions?type=maintenance"),
            ("Stations", "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v2/stations"),
            ("Journey Info", "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/trips?fromStation=ASD&toStation=UTG&dateTime=2024-09-28T10:00:00")
        ]
        
        for (name, urlString) in endpoints {
            apiTestResult += "\n🔍 Testing \(name):\n"
            
            guard let url = URL(string: urlString) else {
                apiTestResult += "❌ Invalid URL\n"
                continue
            }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    apiTestResult += "📊 Status: \(httpResponse.statusCode)\n"
                    
                    if httpResponse.statusCode == 200 {
                        let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                        apiTestResult += "✅ SUCCESS!\n"
                        apiTestResult += "📄 Raw response (first 500 chars):\n\(String(responseString.prefix(500)))\n"
                        
                        // Try to parse JSON and show structure
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            
                            if let jsonDict = json as? [String: Any] {
                                apiTestResult += "📋 JSON Dictionary keys: \(jsonDict.keys.sorted())\n"
                                
                                // Look for different data structures
                                if let payload = jsonDict["payload"] as? [String: Any] {
                                    apiTestResult += "📦 Payload keys: \(payload.keys.sorted())\n"
                                    
                                    if let disruptions = payload["disruptions"] as? [Any] {
                                        apiTestResult += "🚄 Found \(disruptions.count) items\n"
                                        
                                        // Show details of first few items
                                        for (index, item) in disruptions.prefix(2).enumerated() {
                                            if let disruption = item as? [String: Any] {
                                                let title = disruption["title"] as? String ?? "No title"
                                                let type = disruption["type"] as? String ?? "No type"
                                                let impact = disruption["impact"] as? String ?? "No impact"
                                                apiTestResult += "  \(index + 1). \(title) (\(type), impact: \(impact))\n"
                                            }
                                        }
                                    }
                                } else if let items = jsonDict["items"] as? [Any] {
                                    apiTestResult += "📋 Found \(items.count) items in root\n"
                                } else {
                                    apiTestResult += "🔍 No expected structure found, showing all keys and values:\n"
                                    for (key, value) in jsonDict {
                                        let valueStr = String(describing: value).prefix(100)
                                        apiTestResult += "  \(key): \(valueStr)\n"
                                    }
                                }
                            } else if let jsonArray = json as? [Any] {
                                apiTestResult += "📋 JSON Array with \(jsonArray.count) items\n"
                                // Show first item structure
                                if let firstItem = jsonArray.first as? [String: Any] {
                                    apiTestResult += "First item keys: \(firstItem.keys.sorted())\n"
                                }
                            } else {
                                apiTestResult += "🤔 JSON is neither dictionary nor array\n"
                                apiTestResult += "Type: \(type(of: json))\n"
                            }
                            
                        } catch {
                            apiTestResult += "❌ JSON parsing error: \(error.localizedDescription)\n"
                            apiTestResult += "📄 Attempting to show raw response:\n\(String(responseString.prefix(800)))\n"
                        }
                    } else {
                        let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                        apiTestResult += "❌ ERROR - Status \(httpResponse.statusCode)\n"
                        apiTestResult += "📄 Error: \(String(responseString.prefix(200)))\n"
                    }
                }
            } catch {
                apiTestResult += "🌐 Network Error: \(error.localizedDescription)\n"
            }
            
            apiTestResult += "---\n"
        }
    }
}

// MARK: - Formatters
private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ContentView()
}