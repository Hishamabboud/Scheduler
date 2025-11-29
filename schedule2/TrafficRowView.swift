//
//  TrafficRowView.swift
//  schedule2
//
//  Created by Hisham Abboud on 28/09/2025.
//

import SwiftUI

// MARK: - Road Incident Row (Modern Design)
struct RoadIncidentRow: View {
    let incident: RoadIncident
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(incident.roadNumber)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.15), in: Capsule())
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(incident.severity.uppercased())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(severityColor)
            }
            
            Text(incident.description)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            
            Text(incident.location)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            
            if let expectedEnd = incident.expectedEndTime {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("Expected to clear by \(expectedEnd, style: .time)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
        )
    }
    
    private var severityColor: Color {
        switch incident.severity.lowercased() {
        case "minor":
            return .orange
        case "major":
            return .red
        default:
            return .secondary
        }
    }
}

// MARK: - Train Delay Row (Modern Design)
struct TrainDelayRow: View {
    let delay: TrainDelay
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(delay.trainNumber)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(delay.route)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(delay.delayMinutes) min")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.orange)
                
                Text(delay.station)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.orange.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Bus Delay Row (Modern Design)
struct BusDelayRow: View {
    let delay: BusDelay
    
    var body: some View {
        HStack(spacing: 12) {
            // Line number badge
            Text(delay.lineNumber)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.green, in: Capsule())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(delay.route)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(delay.stop)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("+\(delay.delayMinutes) min")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.orange)
        }
        .padding(12)
        .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.green.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Service Status Row (Modern Design)
struct ServiceStatusRow: View {
    let serviceName: String
    let status: ServiceStatus
    let delayCount: Int
    let transportType: TransportType
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: transportType.systemImage)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            // Service info
            VStack(alignment: .leading, spacing: 2) {
                Text(serviceName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(delayCount > 0 ? "\(delayCount) delay\(delayCount == 1 ? "" : "s")" : "No delays")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status badge
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(status.rawValue.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.15), in: Capsule())
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .normal: return .green
        case .delayed: return .orange
        case .disrupted, .cancelled: return .red
        }
    }
    
    private var iconColor: Color {
        switch transportType {
        case .road: return .red
        case .train: return .blue
        case .bus: return .green
        }
    }
}

// MARK: - Formatter
private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()