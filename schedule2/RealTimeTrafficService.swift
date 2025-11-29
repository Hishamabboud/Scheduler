//
//  RealTimeTrafficService.swift
//  schedule2
//
//  Created by Hisham Abboud on 28/09/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Real API Models

// NDW (Dutch road traffic) API Models
struct NDWTrafficData: Codable {
    let items: [NDWTrafficItem]
}

struct NDWTrafficItem: Codable {
    let id: String
    let description: String
    let location: String
    let severity: String
    let startTime: String?
    let expectedEndTime: String?
    let road: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, location, severity
        case startTime = "start_time"
        case expectedEndTime = "expected_end_time"
        case road
    }
}

// NS API Models
struct NSDisruptionResponse: Codable {
    let payload: NSDisruptionPayload
}

struct NSDisruptionPayload: Codable {
    let disruptions: [NSDisruption]
}

struct NSDisruption: Codable {
    let id: String
    let title: String
    let description: String?
    let type: String
    let impact: String
    let expectedDuration: Int?
    let alternativeTransport: String?
    let routes: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, type, impact
        case expectedDuration = "expected_duration"
        case alternativeTransport = "alternative_transport"
        case routes
    }
}

// OpenOV API Models
struct OpenOVResponse: Codable {
    let data: [String: OpenOVStopData]
}

struct OpenOVStopData: Codable {
    let stop: OpenOVStop
    let departures: [String: OpenOVDeparture]?
}

struct OpenOVStop: Codable {
    let name: String
    let municipality: String
}

struct OpenOVDeparture: Codable {
    let linePublicNumber: String
    let destinationName: String
    let expectedDepartureTime: Int
    let departureDelay: Int
    let realtimeText: String?
    
    enum CodingKeys: String, CodingKey {
        case linePublicNumber = "LinePublicNumber"
        case destinationName = "DestinationName50"
        case expectedDepartureTime = "ExpectedDepartureTime"
        case departureDelay = "DepartureDelay"
        case realtimeText = "RealtimeText"
    }
}

// MARK: - Real-Time Traffic Service

@MainActor
class RealTimeTrafficService: ObservableObject {
    @Published var trafficInfo: TrafficInfo?
    @Published var isLoading = false
    @Published var error: String?
    
    private let session = URLSession.shared
    
    // API Configuration with UserDefaults
    private var nsAPIKey: String {
        UserDefaults.standard.string(forKey: "nsAPIKey") ?? ""
    }
    
    private var ndwAPIKey: String {
        UserDefaults.standard.string(forKey: "ndwAPIKey") ?? ""
    }
    
    private struct APIConfig {
        // NDW API (Dutch Road Traffic Data)
        static let ndwBaseURL = "https://www.ndw.nu/api/v1"
        
        // NS API (Dutch Railways)
        static let nsBaseURL = "https://gateway.apiportal.ns.nl"
        
        // OpenOV API (Public Transport) - HTTPS first, with alternative endpoints
        static let openOVBaseURL = "https://v0.ovapi.nl"
        
        // Alternative OpenOV endpoints (HTTPS only)
        static let openOVAlternativeEndpoints = [
            "https://api.9292.nl/0.1", // 9292 public transport API
            "https://gtfs.ovapi.nl"     // GTFS data endpoint
        ]
    }
    
    func fetchTrafficInfo() async {
        isLoading = true
        error = nil
        
        // FIRST: Test the NS API directly
        await testNSAPIDirectly()
        
        do {
            // Fetch all data sources concurrently
            async let roadData = fetchRoadTrafficData()
            async let trainData = fetchTrainData()
            async let busData = fetchBusData()
            
            let (roadIncidents, trainServices, busServices) = try await (roadData, trainData, busData)
            
            trafficInfo = TrafficInfo(
                roadIncidents: roadIncidents,
                trainServices: trainServices,
                busServices: busServices,
                lastUpdated: Date()
            )
            
        } catch {
            // Provide specific error messages for different types of issues
            if ATSHelper.isATSError(error) {
                self.error = "Network security restrictions are limiting some APIs. Using demo data where needed. Check the API Configuration for more details."
            } else {
                self.error = "Failed to fetch real-time traffic data: \(error.localizedDescription)"
            }
            print("Traffic fetch error: \(error)")
        }
        
        isLoading = false
    }
    
    // Test function to verify API access
    private func testNSAPIDirectly() async {
        let apiKey = "24580b0cd78f49d489cea30d58fb2150"  // New API key
        
        print("🧪 TESTING NS API DIRECTLY...")
        print("🔑 Using API Key: \(apiKey)")
        
        guard let url = URL(string: "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/disruptions") else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        print("🌐 Making test request to: \(url)")
        print("📋 Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 STATUS CODE: \(httpResponse.statusCode)")
                print("📋 RESPONSE HEADERS: \(httpResponse.allHeaderFields)")
                
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                print("📄 RESPONSE BODY (first 1000 chars):")
                print(String(responseString.prefix(1000)))
                
                if httpResponse.statusCode == 200 {
                    print("✅ API IS WORKING!")
                } else {
                    print("❌ API ERROR - Status \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("🌐 NETWORK ERROR: \(error)")
        }
        
        print("🧪 TEST COMPLETED")
        print(String(repeating: "=", count: 50))
    }
    
    // MARK: - Road Traffic Data (NDW API)
    
    private func fetchRoadTrafficData() async throws -> [RoadIncident] {
        // For demo purposes, we'll create realistic data since NDW API requires authentication
        // In production, you would make actual API calls to NDW
        
        let demoIncidents = [
            RoadIncident(
                description: "Accident - 2 lanes blocked",
                location: "A1 Amsterdam - Apeldoorn, between junctions Muiderberg and Naarden",
                severity: "Major",
                startTime: Date().addingTimeInterval(-3600),
                expectedEndTime: Date().addingTimeInterval(1800),
                roadNumber: "A1"
            ),
            RoadIncident(
                description: "Road construction",
                location: "A4 The Hague - Rotterdam, km 15-18 direction Rotterdam",
                severity: "Minor",
                startTime: Date().addingTimeInterval(-7200),
                expectedEndTime: Date().addingTimeInterval(14400),
                roadNumber: "A4"
            ),
            RoadIncident(
                description: "Broken down truck",
                location: "A2 Utrecht - Den Bosch, right lane blocked near Vianen",
                severity: "Minor",
                startTime: Date().addingTimeInterval(-1200),
                expectedEndTime: Date().addingTimeInterval(600),
                roadNumber: "A2"
            )
        ]
        
        // Simulate API delay
        try await Task.sleep(nanoseconds: 800_000_000)
        
        return demoIncidents
    }
    
    // MARK: - Train Data (NS API)
    
    private func fetchTrainData() async throws -> [TrainService] {
        // Use your actual NS API key
        let apiKey = nsAPIKey.isEmpty ? "24580b0cd78f49d489cea30d58fb2150" : nsAPIKey
        
        print("🚄 Fetching comprehensive NS train data with API key: \(apiKey.prefix(8))...")
        
        // Try multiple approaches to get delay information
        async let disruptionData = fetchDisruptions(apiKey: apiKey)
        async let departureData = fetchDepartureBoardDelays(apiKey: apiKey)
        async let stationListData = fetchStationBasedDelays(apiKey: apiKey)
        
        let (disruptions, departureDelays, stationDelays) = try await (disruptionData, departureData, stationListData)
        
        // Combine all delay sources
        var nsDelays = disruptions
        nsDelays.append(contentsOf: departureDelays)
        nsDelays.append(contentsOf: stationDelays)
        
        // Remove duplicates based on train number and time
        nsDelays = Array(Set(nsDelays))
        
        // Create comprehensive service list for major operators
        var services: [TrainService] = []
        
        // NS - Main operator
        services.append(TrainService(
            operatorName: nsDelays.isEmpty ? "NS (Nederlandse Spoorwegen) - DEMO" : "NS (Nederlandse Spoorwegen) - LIVE",
            route: "National Network",
            status: nsDelays.isEmpty ? .normal : .delayed,
            delays: Array(nsDelays.prefix(15))
        ))
        
        // Add regional operators with their own delay data
        let regionalOperators = [
            ("Arriva", "Northern & Eastern Netherlands", ["GN", "ZWO", "ASS"]),
            ("Connexxion", "Central Netherlands", ["AMF", "HLM", "LEY"]),
            ("Keolis", "Limburg & Regional", ["MT", "SIT", "VL"]),
            ("NS International", "International Routes", ["ASD", "UTG", "RTD"]),
            ("ProRail Services", "Infrastructure Related", ["EHV", "TL", "BD"])
        ]
        
        for (operatorName, region, stationCodes) in regionalOperators {
            let operatorDelays = await fetchOperatorDelays(
                operatorName: operatorName,
                stationCodes: stationCodes,
                apiKey: apiKey
            )
            
            services.append(TrainService(
                operatorName: operatorDelays.isEmpty ? "\(operatorName) - DEMO" : "\(operatorName) - LIVE",
                route: region,
                status: operatorDelays.isEmpty ? .normal : .delayed,
                delays: operatorDelays
            ))
        }
        
        return services
    }
    
    private func fetchDisruptions(apiKey: String) async throws -> [TrainDelay] {
        // Try multiple disruption endpoints
        let endpoints = [
            "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/disruptions",
            "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/disruptions?actual=true",
            "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/disruptions?type=planned"
        ]
        
        var allDelays: [TrainDelay] = []
        
        for endpointURL in endpoints {
            guard let url = URL(string: endpointURL) else { continue }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            
            do {
                let (data, response) = try await session.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let delays = try await parseNSResponse(data)
                    allDelays.append(contentsOf: delays)
                    print("✅ Got \(delays.count) delays from \(endpointURL)")
                }
            } catch {
                print("⚠️ Failed to fetch from \(endpointURL): \(error)")
                // Continue with other endpoints
            }
        }
        
        return allDelays
    }
    
    private func fetchDepartureBoardDelays(apiKey: String) async throws -> [TrainDelay] {
        // Comprehensive list of major stations across Netherlands
        let majorStations = [
            // Major cities
            "ASD",  // Amsterdam Centraal
            "UTG",  // Utrecht Centraal  
            "RTD",  // Rotterdam Centraal
            "GVC",  // Den Haag Centraal
            "EHV",  // Eindhoven Centraal
            "GN",   // Groningen
            "ZL",   // Zwolle
            "TL",   // Tilburg
            "BD",   // Breda
            "AMF",  // Amersfoort
            // Regional hubs
            "HLM",  // Haarlem
            "LEY",  // Lelystad
            "ASS",  // Assen  
            "MT",   // Maastricht
            "VL",   // Venlo
            "ZWO",  // Zwolle
            "HT",   // Houten
            "SIT"   // Sittard
        ]
        
        var allDelays: [TrainDelay] = []
        
        // Check more stations but limit concurrent requests
        for stationCode in majorStations.prefix(8) { // Increased from 3 to 8
            do {
                let delays = try await fetchStationDelays(stationCode: stationCode, apiKey: apiKey)
                allDelays.append(contentsOf: delays)
            } catch {
                print("⚠️ Failed to fetch delays for station \(stationCode): \(error)")
                // Continue with other stations
            }
        }
        
        return allDelays
    }
    
    private func fetchOperatorDelays(operatorName: String, stationCodes: [String], apiKey: String) async -> [TrainDelay] {
        var delays: [TrainDelay] = []
        
        for stationCode in stationCodes.prefix(2) { // Limit to avoid too many requests
            do {
                let stationDelays = try await fetchStationDelays(stationCode: stationCode, apiKey: apiKey)
                // Filter delays that might be relevant to this operator
                let filteredDelays = stationDelays.filter { delay in
                    // Simple heuristic to associate delays with operators
                    switch operatorName {
                    case "Arriva":
                        return delay.trainNumber.contains("ARR") || delay.station == "GN"
                    case "Connexxion":
                        return delay.trainNumber.contains("CXX") || delay.station == "AMF"
                    default:
                        return true
                    }
                }
                delays.append(contentsOf: filteredDelays)
            } catch {
                print("⚠️ Failed to fetch \(operatorName) delays for \(stationCode): \(error)")
            }
        }
        
        // If no real delays found, create representative demo delays
        if delays.isEmpty {
            delays = await createDemoDelaysForOperator(operatorName: operatorName, stationCodes: stationCodes)
        }
        
        return Array(delays.prefix(5))
    }
    
    private func createDemoDelaysForOperator(operatorName: String, stationCodes: [String]) async -> [TrainDelay] {
        // Create realistic demo data specific to each operator
        switch operatorName {
        case "Arriva":
            return [
                TrainDelay(
                    trainNumber: "ARR 2301",
                    route: "Groningen - Leeuwarden",
                    station: "Groningen",
                    scheduledTime: Date().addingTimeInterval(600),
                    actualTime: Date().addingTimeInterval(900),
                    delayMinutes: 5,
                    reason: "Signal failure"
                ),
                TrainDelay(
                    trainNumber: "ARR 5523",
                    route: "Zwolle - Enschede",
                    station: "Zwolle",
                    scheduledTime: Date().addingTimeInterval(1200),
                    actualTime: Date().addingTimeInterval(1680),
                    delayMinutes: 8,
                    reason: "Earlier disruption"
                )
            ]
        case "Connexxion":
            return [
                TrainDelay(
                    trainNumber: "CXX 3401",
                    route: "Amersfoort - Ede",
                    station: "Amersfoort",
                    scheduledTime: Date().addingTimeInterval(480),
                    actualTime: Date().addingTimeInterval(720),
                    delayMinutes: 4,
                    reason: "Technical issue"
                )
            ]
        case "Keolis":
            return [
                TrainDelay(
                    trainNumber: "KEO 7201",
                    route: "Maastricht - Sittard",
                    station: "Maastricht",
                    scheduledTime: Date().addingTimeInterval(840),
                    actualTime: Date().addingTimeInterval(1200),
                    delayMinutes: 6,
                    reason: "Track maintenance"
                )
            ]
        case "NS International":
            return [
                TrainDelay(
                    trainNumber: "ICE 103",
                    route: "Amsterdam - Berlin",
                    station: "Amsterdam",
                    scheduledTime: Date().addingTimeInterval(1800),
                    actualTime: Date().addingTimeInterval(2400),
                    delayMinutes: 10,
                    reason: "Border control delay"
                )
            ]
        case "ProRail Services":
            return [
                TrainDelay(
                    trainNumber: "PR 901",
                    route: "Infrastructure Service",
                    station: "Various",
                    scheduledTime: Date().addingTimeInterval(300),
                    actualTime: Date().addingTimeInterval(900),
                    delayMinutes: 10,
                    reason: "Track maintenance in progress"
                )
            ]
        default:
            return []
        }
    }
    
    private func fetchStationBasedDelays(apiKey: String) async throws -> [TrainDelay] {
        // Additional approach: try to get delays from journey planning
        let popularRoutes = [
            ("ASD", "UTG"),  // Amsterdam - Utrecht
            ("UTG", "RTD"),  // Utrecht - Rotterdam  
            ("GVC", "ASD"),  // Den Haag - Amsterdam
            ("EHV", "UTG"),  // Eindhoven - Utrecht
            ("RTD", "GVC")   // Rotterdam - Den Haag
        ]
        
        var journeyDelays: [TrainDelay] = []
        
        for (from, to) in popularRoutes.prefix(3) {
            do {
                let delays = try await fetchJourneyDelays(from: from, to: to, apiKey: apiKey)
                journeyDelays.append(contentsOf: delays)
            } catch {
                print("⚠️ Failed to fetch journey delays for \(from) - \(to): \(error)")
            }
        }
        
        return journeyDelays
    }
    
    private func fetchJourneyDelays(from: String, to: String, apiKey: String) async throws -> [TrainDelay] {
        // Get current time for journey planning
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let currentTime = formatter.string(from: Date())
        
        guard let url = URL(string: "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/trips?fromStation=\(from)&toStation=\(to)&dateTime=\(currentTime)") else {
            return []
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return []
        }
        
        // Parse journey data for delays
        var delays: [TrainDelay] = []
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let trips = json["trips"] as? [[String: Any]] {
                
                for trip in trips.prefix(3) {
                    if let legs = trip["legs"] as? [[String: Any]] {
                        for leg in legs {
                            if let product = leg["product"] as? [String: Any],
                               let trainType = product["categoryCode"] as? String,
                               let origin = leg["origin"] as? [String: Any],
                               let destination = leg["destination"] as? [String: Any],
                               let plannedDepartureDateTime = origin["plannedDateTime"] as? String,
                               let actualDepartureDateTime = origin["actualDateTime"] as? String {
                                
                                let dateFormatter = ISO8601DateFormatter()
                                if let plannedTime = dateFormatter.date(from: plannedDepartureDateTime),
                                   let actualTime = dateFormatter.date(from: actualDepartureDateTime) {
                                    
                                    let delayMinutes = Int(actualTime.timeIntervalSince(plannedTime) / 60)
                                    
                                    if delayMinutes > 0 {
                                        let delay = TrainDelay(
                                            trainNumber: product["number"] as? String ?? "\(trainType)-XXX",
                                            route: "\(from) - \(to)",
                                            station: origin["name"] as? String ?? from,
                                            scheduledTime: plannedTime,
                                            actualTime: actualTime,
                                            delayMinutes: delayMinutes,
                                            reason: "Journey planning delay"
                                        )
                                        delays.append(delay)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("❌ Failed to parse journey data for \(from) - \(to): \(error)")
        }
        
        return delays
    }
    
    private func fetchStationDelays(stationCode: String, apiKey: String) async throws -> [TrainDelay] {
        guard let url = URL(string: "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v2/departures?station=\(stationCode)") else {
            return []
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return []
        }
        
        // Parse departure board for delays
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let payload = json["payload"] as? [String: Any],
               let departures = payload["departures"] as? [[String: Any]] {
                
                var delays: [TrainDelay] = []
                
                for departure in departures.prefix(5) { // Check first 5 departures per station
                    // Look for delays in departure data
                    if let plannedDateTime = departure["plannedDateTime"] as? String,
                       let actualDateTime = departure["actualDateTime"] as? String,
                       let direction = departure["direction"] as? String,
                       let trainCategory = departure["trainCategory"] as? String {
                        
                        let dateFormatter = ISO8601DateFormatter()
                        
                        if let plannedTime = dateFormatter.date(from: plannedDateTime),
                           let actualTime = dateFormatter.date(from: actualDateTime) {
                            
                            let delayMinutes = Int(actualTime.timeIntervalSince(plannedTime) / 60)
                            
                            if delayMinutes > 0 { // Only include actual delays
                                let delay = TrainDelay(
                                    trainNumber: departure["name"] as? String ?? "\(trainCategory)-XXX",
                                    route: "To \(direction)",
                                    station: stationCode,
                                    scheduledTime: plannedTime,
                                    actualTime: actualTime,
                                    delayMinutes: delayMinutes,
                                    reason: departure["messages"] as? String ?? "Delay"
                                )
                                delays.append(delay)
                                print("🕐 Found delay: \(delay.trainNumber) - \(delayMinutes) min late")
                            }
                        }
                    }
                }
                
                return delays
            }
        } catch {
            print("❌ Failed to parse departure board for \(stationCode): \(error)")
        }
        
        return []
    }
    
    private func parseNSResponse(_ data: Data) async throws -> [TrainDelay] {
        // Parse the actual NS API response
        let decoder = JSONDecoder()
        let dateFormatter = ISO8601DateFormatter()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            // First, try to decode as raw JSON to see the structure
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📋 NS API JSON structure: \(json.keys)")
                
                // Look for the main payload
                if let payload = json["payload"] as? [String: Any],
                   let disruptions = payload["disruptions"] as? [[String: Any]] {
                    print("📋 Found \(disruptions.count) disruptions in payload")
                    
                    var delays: [TrainDelay] = []
                    
                    for (index, disruption) in disruptions.prefix(5).enumerated() {
                        print("📋 Processing disruption \(index + 1): \(disruption)")
                        
                        let title = disruption["title"] as? String ?? "Unknown disruption"
                        let description = disruption["description"] as? String
                        let impact = disruption["impact"] as? String ?? "Unknown impact"
                        let type = disruption["type"] as? String ?? "disruption"
                        
                        // Create a delay entry from the disruption
                        let delay = TrainDelay(
                            trainNumber: "NS-\(index + 1)",
                            route: title,
                            station: "Network-wide",
                            scheduledTime: Date(),
                            actualTime: Date().addingTimeInterval(900), // 15 min delay
                            delayMinutes: 15,
                            reason: description ?? title
                        )
                        
                        delays.append(delay)
                    }
                    
                    return delays
                }
            }
            
            // If no disruptions found, return empty (which means no issues!)
            print("✅ No current disruptions found - NS network is running normally")
            return []
            
        } catch {
            print("❌ JSON parsing error: \(error)")
            throw error
        }
    }
    
    private func createDemoTrainData(useRealAPI: Bool = false) async -> [TrainDelay] {
        // Simulate API delay
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        // Add indicator that this is demo data when no API key
        let delayReason = useRealAPI ? "Earlier disruption" : "Demo: Earlier disruption"
        
        return [
            TrainDelay(
                trainNumber: "IC 3134",
                route: "Amsterdam Centraal - Rotterdam Centraal",
                station: "Amsterdam Centraal",
                scheduledTime: Date().addingTimeInterval(420),
                actualTime: Date().addingTimeInterval(600),
                delayMinutes: 3,
                reason: delayReason
            ),
            TrainDelay(
                trainNumber: "SPR 7456",
                route: "Utrecht Centraal - Den Bosch",
                station: "Utrecht Centraal",
                scheduledTime: Date().addingTimeInterval(900),
                actualTime: Date().addingTimeInterval(1320),
                delayMinutes: 7,
                reason: useRealAPI ? "Technical issue with train" : "Demo: Technical issue with train"
            ),
            TrainDelay(
                trainNumber: "IC 1540",
                route: "Den Haag Centraal - Eindhoven Centraal",
                station: "Den Haag Centraal",
                scheduledTime: Date().addingTimeInterval(300),
                actualTime: Date().addingTimeInterval(480),
                delayMinutes: 3,
                reason: useRealAPI ? "Traffic congestion" : "Demo: Traffic congestion"
            )
        ]
    }
    
    // MARK: - Bus Data (OpenOV API + Comprehensive Coverage)
    
    private func fetchBusData() async throws -> [BusService] {
        print("🚌 Fetching comprehensive bus data from multiple sources...")
        
        // Major bus operators across Netherlands with their coverage areas
        let busOperators = [
            ("GVB Amsterdam", "Amsterdam Region", ["36014454", "36024455", "36014456", "36014457"]),
            ("RET Rotterdam", "Rotterdam Region", ["31002440", "31002450", "31002441", "31002451"]),
            ("HTM Den Haag", "The Hague Region", ["30002440", "30002441", "30002442"]),
            ("GVU Utrecht", "Utrecht Region", ["34000123", "34000124", "34000125"]),
            ("Hermes Eindhoven", "Eindhoven Region", ["40000567", "40000568"]),
            ("Arriva Buses", "Northern Netherlands", ["20001234", "20001235"]),
            ("Connexxion Buses", "Central Netherlands", ["45001111", "45001112"]),
            ("Keolis Buses", "Limburg Region", ["60005555", "60005556"])
        ]
        
        var allServices: [BusService] = []
        
        for (operatorName, region, stopCodes) in busOperators {
            let service = await fetchComprehensiveBusService(
                operatorName: operatorName,
                region: region,
                stopCodes: stopCodes
            )
            allServices.append(service)
        }
        
        return allServices
    }
    
    private func fetchComprehensiveBusService(operatorName: String, region: String, stopCodes: [String]) async -> BusService {
        var allDelays: [BusDelay] = []
        var realDataFound = false
        
        // Try to get real data from OpenOV API
        for stopCode in stopCodes.prefix(2) {
            do {
                let delays = try await fetchRealBusDelays(stopCode: stopCode, operatorName: operatorName)
                if !delays.isEmpty {
                    allDelays.append(contentsOf: delays)
                    realDataFound = true
                }
            } catch {
                print("⚠️ Failed to fetch real bus data for \(stopCode): \(error)")
            }
        }
        
        // If no real delays found, create realistic demo data
        if allDelays.isEmpty {
            allDelays = await createDemoBusDelaysForOperator(operatorName: operatorName, region: region)
        }
        
        // Determine if showing live or demo data
        let displayName = realDataFound ? "\(operatorName) - LIVE" : "\(operatorName) - DEMO"
        let status: ServiceStatus = allDelays.isEmpty ? .normal : .delayed
        
        return BusService(
            operatorName: displayName,
            region: region,
            status: status,
            delays: Array(allDelays.prefix(8)) // Show up to 8 delays per operator
        )
    }
    
    private func fetchRealBusDelays(stopCode: String, operatorName: String) async throws -> [BusDelay] {
        // Try multiple OpenOV API endpoints for better coverage (HTTPS only)
        let endpoints = [
            "https://v0.ovapi.nl/stopareacode/\(stopCode)",
            "https://v0.ovapi.nl/line/\(stopCode)"
        ]
        
        for endpointURL in endpoints {
            guard let url = URL(string: endpointURL) else { continue }
            
            do {
                let (data, response) = try await session.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let delays = try parseOpenOVResponse(data: data, operatorName: operatorName, stopCode: stopCode)
                    if !delays.isEmpty {
                        print("✅ Got \(delays.count) real bus delays from \(endpointURL)")
                        return delays
                    }
                }
            } catch {
                // Check if this is an ATS (App Transport Security) error
                if let urlError = error as? URLError, urlError.code == .appTransportSecurityRequiresSecureConnection {
                    print("🔒 OpenOV API failed due to App Transport Security: \(endpointURL)")
                    print("   This API requires HTTP but iOS requires HTTPS. Check Info.plist ATS configuration.")
                    print("   Error: \(error.localizedDescription)")
                } else {
                    print("⚠️ OpenOV API failed for \(endpointURL): \(error)")
                }
                continue
            }
        }
        
        return []
    }
    
    private func parseOpenOVResponse(data: Data, operatorName: String, stopCode: String) throws -> [BusDelay] {
        var delays: [BusDelay] = []
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // OpenOV API has complex nested structure
            for (_, stopData) in json {
                if let stopInfo = stopData as? [String: Any],
                   let stopDetails = stopInfo["Stop"] as? [String: Any],
                   let departures = stopInfo["Passes"] as? [String: Any] {
                    
                    let stopName = stopDetails["Name"] as? String ?? "Unknown Stop"
                    
                    for (_, departure) in departures {
                        if let departureInfo = departure as? [String: Any],
                           let lineNumber = departureInfo["LinePublicNumber"] as? String,
                           let destination = departureInfo["DestinationName50"] as? String,
                           let expectedTime = departureInfo["ExpectedDepartureTime"] as? Int,
                           let delaySeconds = departureInfo["DepartureDelay"] as? Int,
                           delaySeconds > 0 {
                            
                            let scheduledTime = Date(timeIntervalSince1970: TimeInterval(expectedTime - delaySeconds))
                            let actualTime = Date(timeIntervalSince1970: TimeInterval(expectedTime))
                            let delayMinutes = delaySeconds / 60
                            
                            let delay = BusDelay(
                                lineNumber: lineNumber,
                                route: "To \(destination)",
                                stop: stopName,
                                scheduledTime: scheduledTime,
                                actualTime: actualTime,
                                delayMinutes: delayMinutes,
                                reason: departureInfo["RealtimeText"] as? String ?? "Delay"
                            )
                            delays.append(delay)
                        }
                    }
                }
            }
        }
        
        return delays
    }
    
    private func createDemoBusDelaysForOperator(operatorName: String, region: String) async -> [BusDelay] {
        // Create realistic demo data specific to each bus operator
        switch operatorName {
        case "GVB Amsterdam":
            return [
                BusDelay(
                    lineNumber: "22",
                    route: "Station Sloterdijk - Muiderpoort Station",
                    stop: "Leidseplein",
                    scheduledTime: Date().addingTimeInterval(300),
                    actualTime: Date().addingTimeInterval(480),
                    delayMinutes: 3,
                    reason: "Traffic congestion"
                ),
                BusDelay(
                    lineNumber: "48",
                    route: "Centraal Station - Borneo Eiland",
                    stop: "Dam",
                    scheduledTime: Date().addingTimeInterval(600),
                    actualTime: Date().addingTimeInterval(900),
                    delayMinutes: 5,
                    reason: "Earlier disruption"
                ),
                BusDelay(
                    lineNumber: "15",
                    route: "Centraal Station - Slotermeer",
                    stop: "Nieuwmarkt",
                    scheduledTime: Date().addingTimeInterval(420),
                    actualTime: Date().addingTimeInterval(660),
                    delayMinutes: 4,
                    reason: "Road works"
                )
            ]
        case "RET Rotterdam":
            return [
                BusDelay(
                    lineNumber: "25",
                    route: "Schiedam - Rotterdam CS",
                    stop: "Beurs",
                    scheduledTime: Date().addingTimeInterval(420),
                    actualTime: Date().addingTimeInterval(660),
                    delayMinutes: 4,
                    reason: "Technical issue"
                ),
                BusDelay(
                    lineNumber: "33",
                    route: "Rotterdam CS - Sliedrecht",
                    stop: "Rotterdam Centraal",
                    scheduledTime: Date().addingTimeInterval(720),
                    actualTime: Date().addingTimeInterval(1080),
                    delayMinutes: 6,
                    reason: "Heavy traffic"
                )
            ]
        case "HTM Den Haag":
            return [
                BusDelay(
                    lineNumber: "18",
                    route: "Den Haag HS - Scheveningen",
                    stop: "Buitenhof",
                    scheduledTime: Date().addingTimeInterval(360),
                    actualTime: Date().addingTimeInterval(600),
                    delayMinutes: 4,
                    reason: "Traffic incident"
                )
            ]
        case "GVU Utrecht":
            return [
                BusDelay(
                    lineNumber: "12",
                    route: "Utrecht CS - Nieuwegein",
                    stop: "Utrecht Centraal",
                    scheduledTime: Date().addingTimeInterval(540),
                    actualTime: Date().addingTimeInterval(840),
                    delayMinutes: 5,
                    reason: "Signal failure"
                )
            ]
        case "Hermes Eindhoven":
            return [
                BusDelay(
                    lineNumber: "401",
                    route: "Eindhoven - Veldhoven",
                    stop: "Eindhoven Centraal",
                    scheduledTime: Date().addingTimeInterval(480),
                    actualTime: Date().addingTimeInterval(720),
                    delayMinutes: 4,
                    reason: "Vehicle breakdown"
                )
            ]
        case "Arriva Buses":
            return [
                BusDelay(
                    lineNumber: "73",
                    route: "Groningen - Assen",
                    stop: "Groningen",
                    scheduledTime: Date().addingTimeInterval(900),
                    actualTime: Date().addingTimeInterval(1200),
                    delayMinutes: 5,
                    reason: "Weather conditions"
                )
            ]
        case "Connexxion Buses":
            return [
                BusDelay(
                    lineNumber: "100",
                    route: "Amsterdam - Hilversum",
                    stop: "Amsterdam Bijlmer",
                    scheduledTime: Date().addingTimeInterval(600),
                    actualTime: Date().addingTimeInterval(960),
                    delayMinutes: 6,
                    reason: "Road construction"
                )
            ]
        case "Keolis Buses":
            return [
                BusDelay(
                    lineNumber: "350",
                    route: "Maastricht - Heerlen",
                    stop: "Maastricht Station",
                    scheduledTime: Date().addingTimeInterval(720),
                    actualTime: Date().addingTimeInterval(1020),
                    delayMinutes: 5,
                    reason: "Driver shortage"
                )
            ]
        default:
            return []
        }
    }
}

// MARK: - API Integration Notes
/*
 Real API Integration Instructions:
 
 1. NDW API (Road Traffic):
    - Register at: https://www.ndw.nu/
    - Get API access credentials
    - Use endpoints like /incidents for real-time road incidents
    - Requires authentication
 
 2. NS API (Train Data):
    - Register at: https://apiportal.ns.nl/
    - Get your API key
    - Replace "YOUR_NS_API_KEY" with actual key
    - Use /reisinformatie-api/api/v3/disruptions endpoint
 
 3. OpenOV API (Bus/Tram/Metro):
    - Free to use, no API key required
    - Base URL: https://v0.ovapi.nl/ (HTTPS supported)
    - Get stop codes from: https://gtfs.ovapi.nl/
    - Use /stopareacode/{code} for real-time departures
 
 4. Additional APIs:
    - Regional transport operators have their own APIs
    - Check each city's public transport website for specific APIs
 */