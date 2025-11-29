//
//  TransportKnowledgeBase.swift
//  schedule2
//
//  Created by AI Assistant on 05/10/2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

// MARK: - Transport Knowledge Base¬

class TransportKnowledgeBase: ObservableObject {
    static let shared = TransportKnowledgeBase()
    
    @Published var isLearning = false
    @Published var totalIncidents = 0
    @Published var lastLearningUpdate: Date?
    
    private var historicalIncidents: [HistoricalIncident] = []
    private var patternCache: [String: [HistoricalIncident]] = [:]
    
    private init() {
        loadHistoricalData()
        startContinuousLearning()
    }
    
    // MARK: - Data Management
    
    func addIncident(_ incident: HistoricalIncident) {
        historicalIncidents.append(incident)
        totalIncidents = historicalIncidents.count
        
        // Clear relevant cache entries
        clearCacheForIncident(incident)
        
        // Save to persistent storage
        saveHistoricalData()
        
        // Update learning
        Task {
            await updatePatternLearning()
        }
    }
    
    func getHistoricalData(
        transportType: TransportType,
        route: String,
        location: String,
        context: PredictionContext
    ) async -> [HistoricalIncident] {
        
        let cacheKey = "\(transportType.rawValue)_\(route)_\(location)_\(context.dayOfWeek)_\(context.hourOfDay)"
        
        if let cachedData = patternCache[cacheKey] {
            return cachedData
        }
        
        let filteredData = historicalIncidents.filter { incident in
            matchesContext(incident: incident, transportType: transportType, route: route, location: location, context: context)
        }
        
        // Cache the result
        patternCache[cacheKey] = filteredData
        
        return filteredData
    }
    
    // MARK: - Pattern Learning
    
    private func startContinuousLearning() {
        // Learn from new API data every hour
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            Task {
                await self.learnFromRealtimeData()
            }
        }
    }
    
    private func learnFromRealtimeData() async {
        isLearning = true
        defer { 
            isLearning = false
            lastLearningUpdate = Date()
        }
        
        // This would integrate with your existing RealTimeTrafficService
        // to continuously learn from live delay data
        
        // Example: Learn from current delays
        await learnFromCurrentDelays()
        
        // Analyze patterns
        await updatePatternLearning()
    }
    
    private func learnFromCurrentDelays() async {
        // In a real implementation, this would:
        // 1. Get current delays from RealTimeTrafficService
        // 2. Create HistoricalIncident records
        // 3. Add them to the knowledge base
        
        // For demo purposes, simulate learning some incidents
        let demoIncidents = generateDemoLearningData()
        for incident in demoIncidents {
            addIncident(incident)
        }
    }
    
    private func updatePatternLearning() async {
        // Analyze patterns in the data
        let patterns = await analyzeDelayPatterns()
        
        // Update prediction models based on patterns
        await updatePredictionModels(with: patterns)
    }
    
    // MARK: - Pattern Analysis
    
    private func analyzeDelayPatterns() async -> DelayPatterns {
        let patterns = DelayPatterns()
        
        // Analyze weather patterns
        patterns.weatherPatterns = analyzeWeatherImpact()
        
        // Analyze time-based patterns
        patterns.timePatterns = analyzeTimeBasedPatterns()
        
        // Analyze route-specific patterns
        patterns.routePatterns = analyzeRoutePatterns()
        
        // Analyze seasonal patterns
        patterns.seasonalPatterns = analyzeSeasonalPatterns()
        
        return patterns
    }
    
    private func analyzeWeatherImpact() -> [WeatherCondition: Double] {
        var weatherImpact: [WeatherCondition: Double] = [:]
        
        for condition in WeatherCondition.allCases {
            let incidentsInCondition = historicalIncidents.filter { $0.weatherCondition == condition.rawValue }
            let totalIncidents = historicalIncidents.count
            
            if totalIncidents > 0 {
                let impactRate = Double(incidentsInCondition.count) / Double(totalIncidents)
                weatherImpact[condition] = impactRate
            }
        }
        
        return weatherImpact
    }
    
    private func analyzeTimeBasedPatterns() -> [Int: Double] {
        var hourlyImpact: [Int: Double] = [:]
        
        for hour in 0...23 {
            let incidentsAtHour = historicalIncidents.filter { $0.hourOfDay == hour }
            let totalIncidents = historicalIncidents.count
            
            if totalIncidents > 0 {
                let impactRate = Double(incidentsAtHour.count) / Double(totalIncidents)
                hourlyImpact[hour] = impactRate
            }
        }
        
        return hourlyImpact
    }
    
    private func analyzeRoutePatterns() -> [String: RoutePattern] {
        var routePatterns: [String: RoutePattern] = [:]
        
        let routeGroups = Dictionary(grouping: historicalIncidents, by: { $0.route })
        
        for (route, incidents) in routeGroups {
            let pattern = RoutePattern(
                route: route,
                totalIncidents: incidents.count,
                averageDuration: incidents.map { $0.duration }.reduce(0, +) / Double(incidents.count),
                commonReasons: Dictionary(grouping: incidents, by: { $0.reason })
                    .mapValues { $0.count }
                    .sorted { $0.value > $1.value }
                    .map { $0.key },
                peakHours: Dictionary(grouping: incidents, by: { $0.hourOfDay })
                    .mapValues { $0.count }
                    .sorted { $0.value > $1.value }
                    .prefix(3)
                    .map { $0.key }
            )
            
            routePatterns[route] = pattern
        }
        
        return routePatterns
    }
    
    private func analyzeSeasonalPatterns() -> [Int: Double] {
        var monthlyImpact: [Int: Double] = [:]
        
        for month in 1...12 {
            let calendar = Calendar.current
            let incidentsInMonth = historicalIncidents.filter { 
                calendar.component(.month, from: $0.timestamp) == month 
            }
            let totalIncidents = historicalIncidents.count
            
            if totalIncidents > 0 {
                let impactRate = Double(incidentsInMonth.count) / Double(totalIncidents)
                monthlyImpact[month] = impactRate
            }
        }
        
        return monthlyImpact
    }
    
    // MARK: - Prediction Model Updates
    
    private func updatePredictionModels(with patterns: DelayPatterns) async {
        // In a real implementation, this would update Core ML models
        // or other machine learning components with the learned patterns
        
        print("🧠 Updated prediction models with \(patterns.weatherPatterns.count) weather patterns")
        print("📊 Analyzed \(patterns.routePatterns.count) route patterns")
        print("🕒 Updated time-based patterns for \(patterns.timePatterns.count) hours")
    }
    
    // MARK: - Helper Methods
    
    private func matchesContext(
        incident: HistoricalIncident,
        transportType: TransportType,
        route: String,
        location: String,
        context: PredictionContext
    ) -> Bool {
        
        // Match transport type
        guard incident.transportType == transportType.rawValue else { return false }
        
        // Match route (exact or similar)
        guard incident.route == route || incident.route.contains(route) || route.contains(incident.route) else {
            // Check if location matches as fallback
            return incident.location.lowercased().contains(location.lowercased()) ||
                   location.lowercased().contains(incident.location.lowercased())
        }
        
        // Weight by similarity to current context
        let contextSimilarity = calculateContextSimilarity(incident: incident, context: context)
        
        // Only include incidents with reasonable similarity
        return contextSimilarity > 0.3
    }
    
    private func calculateContextSimilarity(incident: HistoricalIncident, context: PredictionContext) -> Double {
        var similarity = 0.0
        var factors = 0
        
        // Time similarity
        let hourDiff = abs(incident.hourOfDay - context.hourOfDay)
        similarity += max(0, 1.0 - Double(hourDiff) / 12.0) // Max 12 hour difference
        factors += 1
        
        // Day of week similarity
        if incident.dayOfWeek == context.dayOfWeek {
            similarity += 1.0
        } else if abs(incident.dayOfWeek - context.dayOfWeek) <= 1 {
            similarity += 0.5
        }
        factors += 1
        
        // Weather similarity
        if incident.weatherCondition == context.weatherCondition.rawValue {
            similarity += 1.0
        } else if let incidentWeather = WeatherCondition(rawValue: incident.weatherCondition),
                  weatherConditionsAreSimilar(incidentWeather, context.weatherCondition) {
            similarity += 0.6
        }
        factors += 1
        
        // Passenger load similarity
        if incident.passengerLoad == context.passengerLoad.rawValue {
            similarity += 1.0
        }
        factors += 1
        
        return similarity / Double(factors)
    }
    
    private func weatherConditionsAreSimilar(_ condition1: WeatherCondition, _ condition2: WeatherCondition) -> Bool {
        let rainConditions: Set<WeatherCondition> = [.rain, .heavyRain, .storm]
        let clearConditions: Set<WeatherCondition> = [.clear, .cloudy]
        let winterConditions: Set<WeatherCondition> = [.snow, .ice]
        
        return (rainConditions.contains(condition1) && rainConditions.contains(condition2)) ||
               (clearConditions.contains(condition1) && clearConditions.contains(condition2)) ||
               (winterConditions.contains(condition1) && winterConditions.contains(condition2))
    }
    
    private func clearCacheForIncident(_ incident: HistoricalIncident) {
        // Clear cache entries that might be affected by this new incident
        let keysToRemove = patternCache.keys.filter { key in
            key.contains(incident.transportType) || 
            key.contains(String(incident.dayOfWeek)) ||
            key.contains(String(incident.hourOfDay))
        }
        
        for key in keysToRemove {
            patternCache.removeValue(forKey: key)
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveHistoricalData() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(historicalIncidents) {
            UserDefaults.standard.set(encoded, forKey: "historicalIncidents")
        }
    }
    
    private func loadHistoricalData() {
        guard let data = UserDefaults.standard.data(forKey: "historicalIncidents") else {
            // Load demo data if no saved data exists
            loadDemoData()
            return
        }
        
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([HistoricalIncident].self, from: data) {
            historicalIncidents = decoded
            totalIncidents = historicalIncidents.count
        } else {
            loadDemoData()
        }
    }
    
    private func loadDemoData() {
        // Generate demo historical data for training
        historicalIncidents = generateDemoHistoricalData()
        totalIncidents = historicalIncidents.count
        saveHistoricalData()
    }
    
    private func generateDemoHistoricalData() -> [HistoricalIncident] {
        var incidents: [HistoricalIncident] = []
        let calendar = Calendar.current
        
        // Generate incidents over the past 3 months
        for dayOffset in 0..<90 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) ?? Date()
            
            // Generate 0-3 incidents per day
            let incidentsPerDay = Int.random(in: 0...3)
            
            for _ in 0..<incidentsPerDay {
                let randomHour = Int.random(in: 0...23)
                let incidentDate = calendar.date(bySettingHour: randomHour, minute: Int.random(in: 0...59), second: 0, of: date) ?? date
                
                let transportType = TransportType.allCases.randomElement() ?? .train
                let reason = DelayReason.allCases.randomElement() ?? .technicalFailure
                let duration = TimeInterval.random(in: 300...3600) // 5 min to 1 hour
                let severity = generateSeverityForDuration(duration)
                let route = generateRandomRoute()
                let location = generateRandomLocation()
                
                // Create incident with all parameters as enums (the extension will convert to strings)
                let incident = HistoricalIncident(
                    id: UUID(),
                    timestamp: incidentDate,
                    transportType: transportType,
                    route: route,
                    location: location,
                    duration: duration,
                    reason: reason,
                    severity: severity,
                    weatherCondition: generateWeatherForDate(incidentDate),
                    dayOfWeek: calendar.component(.weekday, from: incidentDate),
                    hourOfDay: calendar.component(.hour, from: incidentDate),
                    passengerLoad: generatePassengerLoad(for: incidentDate),
                    isHoliday: calendar.isDateInWeekend(incidentDate),
                    description: "\(reason.rawValue) on \(route)"
                )
                
                incidents.append(incident)
            }
        }
        
        return incidents
    }
    
    private func generateDemoLearningData() -> [HistoricalIncident] {
        // Generate a few new incidents for continuous learning demo
        let now = Date()
        var incidents: [HistoricalIncident] = []
        
        if Int.random(in: 1...10) <= 3 { // 30% chance of new incident
            let incident = HistoricalIncident(
                transportType: TransportType.allCases.randomElement() ?? .train,
                route: generateRandomRoute(),
                location: generateRandomLocation(),
                duration: TimeInterval.random(in: 300...1800),
                reason: DelayReason.allCases.randomElement() ?? .technicalFailure,
                severity: .moderate
            )
            incidents.append(incident)
        }
        
        return incidents
    }
    
    // MARK: - Demo Data Generation Helpers
    
    private func generateRandomRoute() -> String {
        let trainRoutes = [
            "Amsterdam Centraal - Utrecht Centraal",
            "Rotterdam Centraal - Den Haag Centraal",
            "Eindhoven Centraal - Utrecht Centraal",
            "Groningen - Zwolle",
            "Maastricht - Eindhoven"
        ]
        
        let busRoutes = [
            "Line 22: Leidseplein - Muiderpoort",
            "Line 48: Dam - Borneo Eiland", 
            "Line 25: Schiedam - Rotterdam CS",
            "Line 18: Den Haag HS - Scheveningen"
        ]
        
        let roadRoutes = [
            "A1 Amsterdam - Apeldoorn",
            "A4 Den Haag - Rotterdam",
            "A2 Utrecht - Den Bosch",
            "A12 Den Haag - Utrecht",
            "A50 Eindhoven - Apeldoorn"
        ]
        
        let allRoutes = trainRoutes + busRoutes + roadRoutes
        return allRoutes.randomElement() ?? "Unknown Route"
    }
    
    private func generateRandomLocation() -> String {
        let locations = [
            "Amsterdam", "Rotterdam", "Den Haag", "Utrecht", "Eindhoven",
            "Groningen", "Zwolle", "Tilburg", "Breda", "Amersfoort",
            "Haarlem", "Lelystad", "Maastricht", "Venlo", "Assen"
        ]
        
        return locations.randomElement() ?? "Unknown Location"
    }
    
    private func generateSeverityForDuration(_ duration: TimeInterval) -> SeverityLevel {
        switch duration {
        case 0..<300: return .minor
        case 300..<900: return .moderate
        case 900..<1800: return .major
        default: return .severe
        }
    }
    
    private func generateWeatherForDate(_ date: Date) -> WeatherCondition {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        
        // Seasonal weather patterns
        switch month {
        case 12, 1, 2: // Winter
            return [.snow, .ice, .rain, .cloudy].randomElement() ?? .cloudy
        case 6, 7, 8: // Summer
            return [.clear, .cloudy, .rain].randomElement() ?? .clear
        default:
            return WeatherCondition.allCases.randomElement() ?? .clear
        }
    }
    
    private func generatePassengerLoad(for date: Date) -> PassengerLoad {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        // Weekend has lower load
        if dayOfWeek == 1 || dayOfWeek == 7 {
            return [.low, .normal].randomElement() ?? .low
        }
        
        // Rush hours have high load
        if (7...9).contains(hour) || (17...19).contains(hour) {
            return [.high, .extreme].randomElement() ?? .high
        }
        
        return .normal
    }
}

// MARK: - Pattern Analysis Models

class DelayPatterns {
    var weatherPatterns: [WeatherCondition: Double] = [:]
    var timePatterns: [Int: Double] = [:]
    var routePatterns: [String: RoutePattern] = [:]
    var seasonalPatterns: [Int: Double] = [:]
}

struct RoutePattern {
    let route: String
    let totalIncidents: Int
    let averageDuration: TimeInterval
    let commonReasons: [String]
    let peakHours: [Int]
}

// MARK: - Extensions for Incident Creation

extension HistoricalIncident {
    init(id: UUID, timestamp: Date, transportType: TransportType, route: String, location: String, duration: TimeInterval, reason: DelayReason, severity: SeverityLevel, weatherCondition: WeatherCondition, dayOfWeek: Int, hourOfDay: Int, passengerLoad: PassengerLoad, isHoliday: Bool, description: String) {
        self.id = id
        self.timestamp = timestamp
        self.transportType = transportType.rawValue
        self.route = route
        self.location = location
        self.duration = duration
        self.reason = reason.rawValue
        self.severity = severity.rawValue
        self.weatherCondition = weatherCondition.rawValue
        self.dayOfWeek = dayOfWeek
        self.hourOfDay = hourOfDay
        self.passengerLoad = passengerLoad.rawValue
        self.isHoliday = isHoliday
        self.description = description
    }
}
