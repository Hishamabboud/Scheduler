//
//  DelayPredictionService.swift
//  schedule2
//
//  Created by AI Assistant on 05/10/2025.
//

import Foundation
import CoreML
import WeatherKit
import CoreLocation
import Combine
import SwiftUI

// MARK: - Delay Prediction Models

struct AIDelayPrediction {
    let probability: Double // 0.0 to 1.0
    let confidence: Double // 0.0 to 1.0
    let primaryFactors: [DelayFactor]
    let estimatedDuration: TimeInterval?
    let recommendation: String
}

struct DelayFactor {
    let type: DelayFactorType
    let impact: Double // 0.0 to 1.0
    let description: String
}

enum DelayFactorType: String, CaseIterable {
    case weather = "Weather"
    case timeOfDay = "Time of Day"
    case dayOfWeek = "Day of Week"
    case seasonalPatterns = "Seasonal Patterns"
    case infrastructure = "Infrastructure"
    case passengerVolume = "Passenger Volume"
    case plannedMaintenance = "Planned Maintenance"
    case historicalTrends = "Historical Trends"
    case externalEvents = "External Events"
    
    var systemImage: String {
        switch self {
        case .weather: return "cloud.rain"
        case .timeOfDay: return "clock"
        case .dayOfWeek: return "calendar"
        case .seasonalPatterns: return "snowflake"
        case .infrastructure: return "wrench.and.screwdriver"
        case .passengerVolume: return "person.3"
        case .plannedMaintenance: return "hammer"
        case .historicalTrends: return "chart.line.uptrend.xyaxis"
        case .externalEvents: return "exclamationmark.triangle"
        }
    }
}

// MARK: - Knowledge Base Models

struct HistoricalIncident: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let transportType: String // Changed to String for Codable
    let route: String
    let location: String
    let duration: TimeInterval
    let reason: String // Changed to String for Codable
    let severity: String // Changed to String for Codable
    let weatherCondition: String // Changed to String for Codable
    let dayOfWeek: Int
    let hourOfDay: Int
    let passengerLoad: String // Changed to String for Codable
    let isHoliday: Bool
    let description: String
    
    init(transportType: TransportType, route: String, location: String, duration: TimeInterval, reason: DelayReason, severity: SeverityLevel) {
        self.id = UUID()
        self.timestamp = Date()
        self.transportType = transportType.rawValue
        self.route = route
        self.location = location
        self.duration = duration
        self.reason = reason.rawValue
        self.severity = severity.rawValue
        
        // Auto-populate context data
        let calendar = Calendar.current
        let now = Date()
        self.dayOfWeek = calendar.component(.weekday, from: now)
        self.hourOfDay = calendar.component(.hour, from: now)
        self.weatherCondition = WeatherCondition.unknown.rawValue // Will be populated by weather service
        self.passengerLoad = PassengerLoad.normal.rawValue // Will be estimated based on time/route
        self.isHoliday = calendar.isDateInWeekend(now) // Simplified
        self.description = "\(reason.rawValue) on \(route)"
    }
}

enum DelayReason: String, CaseIterable, Codable {
    case technicalFailure = "Technical Failure"
    case weatherRelated = "Weather Related"
    case infrastructureIssue = "Infrastructure Issue"
    case accident = "Accident"
    case staffShortage = "Staff Shortage"
    case plannedConstruction = "Planned Construction"
    case passengerVolume = "Passenger Volume"
    case externalFactors = "External Factors"
    case signalProblem = "Signal Problem"
    case trackMaintenance = "Track Maintenance"
    case roadConstruction = "Road Construction"
    case trafficAccident = "Traffic Accident"
}

enum SeverityLevel: String, CaseIterable, Codable {
    case minor = "Minor"      // < 5 minutes
    case moderate = "Moderate" // 5-15 minutes
    case major = "Major"       // 15-30 minutes
    case severe = "Severe"     // > 30 minutes
    
    var color: String {
        switch self {
        case .minor: return "yellow"
        case .moderate: return "orange"
        case .major: return "red"
        case .severe: return "purple"
        }
    }
    
    var maxDuration: TimeInterval {
        switch self {
        case .minor: return 300      // 5 minutes
        case .moderate: return 900   // 15 minutes
        case .major: return 1800     // 30 minutes
        case .severe: return 3600    // 60 minutes
        }
    }
}

enum WeatherCondition: String, CaseIterable, Codable {
    case clear = "Clear"
    case cloudy = "Cloudy"
    case rain = "Rain"
    case heavyRain = "Heavy Rain"
    case snow = "Snow"
    case ice = "Ice"
    case fog = "Fog"
    case storm = "Storm"
    case unknown = "Unknown"
    
    var delayRiskMultiplier: Double {
        switch self {
        case .clear, .cloudy: return 1.0
        case .rain: return 1.3
        case .heavyRain: return 1.6
        case .snow: return 2.0
        case .ice: return 2.5
        case .fog: return 1.4
        case .storm: return 2.2
        case .unknown: return 1.1
        }
    }
}

enum PassengerLoad: String, CaseIterable, Codable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
    case extreme = "Extreme"
    
    var delayRiskMultiplier: Double {
        switch self {
        case .low: return 0.8
        case .normal: return 1.0
        case .high: return 1.3
        case .extreme: return 1.7
        }
    }
}

// MARK: - AI Delay Prediction Service

@MainActor
class DelayPredictionService: ObservableObject {
    @Published var isLoading = false
    @Published var lastPredictionUpdate: Date?
    
    private let knowledgeBase = TransportKnowledgeBase.shared
    private let weatherService = WeatherService()
    
    // MARK: - Main Prediction Methods
    
    func predictDelayProbability(
        for transportType: TransportType,
        route: String,
        location: String,
        at time: Date = Date()
    ) async -> AIDelayPrediction {
        
        isLoading = true
        defer { 
            isLoading = false
            lastPredictionUpdate = Date()
        }
        
        // Gather context data
        let context = await gatherPredictionContext(location: location, time: time)
        
        // Get historical data for similar conditions
        let historicalData = await knowledgeBase.getHistoricalData(
            transportType: transportType,
            route: route,
            location: location,
            context: context
        )
        
        // Calculate base probability from historical data
        let baseProbability = calculateBaseProbability(from: historicalData)
        
        // Apply contextual modifiers
        let adjustedProbability = applyContextualModifiers(
            baseProbability: baseProbability,
            context: context,
            transportType: transportType
        )
        
        // Determine primary factors
        let factors = identifyDelayFactors(context: context, historicalData: historicalData)
        
        // Calculate confidence based on data quality
        let confidence = calculateConfidence(historicalDataCount: historicalData.count, context: context)
        
        // Estimate duration if delay is likely
        let estimatedDuration = adjustedProbability > 0.3 ? estimateDelayDuration(
            probability: adjustedProbability,
            historicalData: historicalData,
            context: context
        ) : nil
        
        // Generate recommendation
        let recommendation = generateRecommendation(
            probability: adjustedProbability,
            factors: factors,
            transportType: transportType
        )
        
        return AIDelayPrediction(
            probability: min(adjustedProbability, 1.0),
            confidence: confidence,
            primaryFactors: factors,
            estimatedDuration: estimatedDuration,
            recommendation: recommendation
        )
    }
    
    func predictRouteDelays(for service: TrainService) async -> [RouteDelayPrediction] {
        var predictions: [RouteDelayPrediction] = []
        
        // Predict for each major station on the route
        let stations = extractStations(from: service.route)
        
        for station in stations {
            let prediction = await predictDelayProbability(
                for: TransportType.train,
                route: service.route,
                location: station
            )
            
            predictions.append(RouteDelayPrediction(
                station: station,
                prediction: prediction
            ))
        }
        
        return predictions
    }
    
    // MARK: - Context Gathering
    
    private func gatherPredictionContext(location: String, time: Date) async -> PredictionContext {
        let calendar = Calendar.current
        
        // Get weather data
        let weather = await weatherService.getCurrentWeather(for: location)
        
        // Determine passenger load based on time patterns
        let passengerLoad = estimatePassengerLoad(time: time)
        
        // Check for holidays/events
        let isHoliday = calendar.isDateInWeekend(time) // Simplified
        let hasEvents = await checkForLocalEvents(location: location, date: time)
        
        return PredictionContext(
            timestamp: time,
            dayOfWeek: calendar.component(.weekday, from: time),
            hourOfDay: calendar.component(.hour, from: time),
            monthOfYear: calendar.component(.month, from: time),
            weatherCondition: weather,
            passengerLoad: passengerLoad,
            isHoliday: isHoliday,
            hasLocalEvents: hasEvents,
            location: location
        )
    }
    
    // MARK: - Probability Calculations
    
    private func calculateBaseProbability(from historicalData: [HistoricalIncident]) -> Double {
        guard !historicalData.isEmpty else { return 0.15 } // Default baseline
        
        let recentData = historicalData.filter { incident in
            let daysAgo = Date().timeIntervalSince(incident.timestamp) / (24 * 3600)
            return daysAgo <= 90 // Focus on last 90 days
        }
        
        guard !recentData.isEmpty else { return 0.12 }
        
        // Calculate incident rate
        let totalDays = 90.0
        let incidents = Double(recentData.count)
        let dailyIncidentRate = incidents / totalDays
        
        // Convert to probability (max 0.8 for base probability)
        return min(dailyIncidentRate * 0.4, 0.8)
    }
    
    private func applyContextualModifiers(
        baseProbability: Double,
        context: PredictionContext,
        transportType: TransportType
    ) -> Double {
        var adjustedProbability = baseProbability
        
        // Weather impact
        adjustedProbability *= context.weatherCondition.delayRiskMultiplier
        
        // Passenger load impact
        adjustedProbability *= context.passengerLoad.delayRiskMultiplier
        
        // Time of day impact
        adjustedProbability *= getTimeOfDayMultiplier(hour: context.hourOfDay, transportType: transportType)
        
        // Day of week impact
        adjustedProbability *= getDayOfWeekMultiplier(dayOfWeek: context.dayOfWeek, transportType: transportType)
        
        // Seasonal impact
        adjustedProbability *= getSeasonalMultiplier(month: context.monthOfYear, transportType: transportType)
        
        // Holiday/event impact
        if context.isHoliday || context.hasLocalEvents {
            adjustedProbability *= 1.2
        }
        
        return adjustedProbability
    }
    
    // MARK: - Factor Analysis
    
    private func identifyDelayFactors(
        context: PredictionContext,
        historicalData: [HistoricalIncident]
    ) -> [DelayFactor] {
        
        var factors: [DelayFactor] = []
        
        // Weather factor
        if context.weatherCondition != .clear && context.weatherCondition != .cloudy {
            let impact = (context.weatherCondition.delayRiskMultiplier - 1.0) * 0.5
            factors.append(DelayFactor(
                type: .weather,
                impact: impact,
                description: "Current weather conditions: \(context.weatherCondition.rawValue)"
            ))
        }
        
        // Rush hour factor
        let rushHourImpact = getRushHourImpact(hour: context.hourOfDay)
        if rushHourImpact > 0.1 {
            factors.append(DelayFactor(
                type: .timeOfDay,
                impact: rushHourImpact,
                description: "Peak travel time increases delay risk"
            ))
        }
        
        // Historical trends
        let historicalImpact = min(Double(historicalData.count) / 50.0, 0.8)
        if historicalImpact > 0.2 {
            factors.append(DelayFactor(
                type: .historicalTrends,
                impact: historicalImpact,
                description: "Route has experienced \(historicalData.count) incidents recently"
            ))
        }
        
        // Passenger volume
        if context.passengerLoad == .high || context.passengerLoad == .extreme {
            let impact = (context.passengerLoad.delayRiskMultiplier - 1.0) * 0.6
            factors.append(DelayFactor(
                type: .passengerVolume,
                impact: impact,
                description: "High passenger volume expected"
            ))
        }
        
        return factors.sorted { $0.impact > $1.impact }
    }
    
    // MARK: - Helper Methods
    
    private func getTimeOfDayMultiplier(hour: Int, transportType: TransportType) -> Double {
        switch transportType {
        case .train:
            // Train rush hours: 7-9 AM, 5-7 PM
            if (7...9).contains(hour) || (17...19).contains(hour) {
                return 1.4
            } else if (22...6).contains(hour) {
                return 0.8 // Less service, fewer delays
            }
            return 1.0
        case .bus:
            // Bus rush hours have higher impact due to traffic
            if (7...9).contains(hour) || (16...18).contains(hour) {
                return 1.6
            }
            return 1.0
        case .road:
            // Road traffic peaks
            if (7...9).contains(hour) || (16...19).contains(hour) {
                return 1.8
            }
            return 1.0
        }
    }
    
    private func getDayOfWeekMultiplier(dayOfWeek: Int, transportType: TransportType) -> Double {
        // 1 = Sunday, 2 = Monday, etc.
        if dayOfWeek == 1 || dayOfWeek == 7 { // Weekend
            return transportType == .road ? 0.7 : 0.8
        } else if dayOfWeek == 2 { // Monday
            return 1.2 // Monday effect
        }
        return 1.0
    }
    
    private func getSeasonalMultiplier(month: Int, transportType: TransportType) -> Double {
        switch month {
        case 12, 1, 2: // Winter months
            return 1.3 // Weather delays more common
        case 7, 8: // Summer months
            return transportType == .road ? 1.1 : 0.9 // More road trips, fewer train issues
        default:
            return 1.0
        }
    }
    
    private func getRushHourImpact(hour: Int) -> Double {
        if (7...9).contains(hour) || (17...19).contains(hour) {
            return 0.4
        } else if (10...16).contains(hour) {
            return 0.1
        }
        return 0.0
    }
    
    private func estimatePassengerLoad(time: Date) -> PassengerLoad {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let dayOfWeek = calendar.component(.weekday, from: time)
        
        // Weekend has lower load
        if dayOfWeek == 1 || dayOfWeek == 7 {
            return .low
        }
        
        // Rush hours have high load
        if (7...9).contains(hour) || (17...19).contains(hour) {
            return .high
        }
        
        return .normal
    }
    
    private func checkForLocalEvents(location: String, date: Date) async -> Bool {
        // In a real implementation, this would check event calendars
        // For now, simulate random events
        return Int.random(in: 1...10) == 1 // 10% chance of local event
    }
    
    private func extractStations(from route: String) -> [String] {
        // Simple extraction - in reality, you'd have a proper route database
        let components = route.components(separatedBy: " - ")
        return components.count >= 2 ? [components.first!, components.last!] : [route]
    }
    
    private func calculateConfidence(historicalDataCount: Int, context: PredictionContext) -> Double {
        var confidence = 0.5 // Base confidence
        
        // More historical data = higher confidence
        confidence += min(Double(historicalDataCount) / 100.0, 0.3)
        
        // Known weather conditions increase confidence
        if context.weatherCondition != .unknown {
            confidence += 0.1
        }
        
        // Recent time increases confidence
        confidence += 0.1
        
        return min(confidence, 0.95)
    }
    
    private func estimateDelayDuration(
        probability: Double,
        historicalData: [HistoricalIncident],
        context: PredictionContext
    ) -> TimeInterval? {
        
        guard !historicalData.isEmpty else { return nil }
        
        let relevantIncidents = historicalData.filter { incident in
            // Filter for similar conditions
            return incident.weatherCondition == context.weatherCondition.rawValue ||
                   incident.hourOfDay == context.hourOfDay
        }
        
        guard !relevantIncidents.isEmpty else {
            // Fallback to all historical data
            let avgDuration = historicalData.map { $0.duration }.reduce(0, +) / Double(historicalData.count)
            return avgDuration * probability
        }
        
        let avgDuration = relevantIncidents.map { $0.duration }.reduce(0, +) / Double(relevantIncidents.count)
        return avgDuration * probability
    }
    
    private func generateRecommendation(
        probability: Double,
        factors: [DelayFactor],
        transportType: TransportType
    ) -> String {
        
        if probability < 0.2 {
            return "Low delay risk. Normal travel conditions expected."
        } else if probability < 0.4 {
            return "Moderate delay risk. Consider checking live updates before traveling."
        } else if probability < 0.7 {
            let primaryFactor = factors.first?.type.rawValue ?? "various factors"
            return "High delay risk due to \(primaryFactor.lowercased()). Consider alternative routes or times."
        } else {
            return "Very high delay risk. Strong recommendation to delay travel or use alternative transport."
        }
    }
}

// MARK: - Supporting Structures

struct PredictionContext {
    let timestamp: Date
    let dayOfWeek: Int
    let hourOfDay: Int
    let monthOfYear: Int
    let weatherCondition: WeatherCondition
    let passengerLoad: PassengerLoad
    let isHoliday: Bool
    let hasLocalEvents: Bool
    let location: String
}

struct RouteDelayPrediction: Identifiable {
    let id = UUID()
    let station: String
    let prediction: AIDelayPrediction
}

// MARK: - Weather Service

class WeatherService {
    func getCurrentWeather(for location: String) async -> WeatherCondition {
        // In a real implementation, this would use WeatherKit or another service
        // For now, simulate weather conditions
        let conditions: [WeatherCondition] = [.clear, .cloudy, .rain, .heavyRain, .snow, .fog]
        return conditions.randomElement() ?? .clear
    }
}