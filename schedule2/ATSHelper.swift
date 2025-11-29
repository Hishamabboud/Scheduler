//
//  ATSHelper.swift
//  schedule2
//
//  Created by Hisham Abboud on 05/10/2025.
//

import Foundation
import SwiftUI

/// Helper utility for handling App Transport Security (ATS) issues
struct ATSHelper {
    
    /// Check if an error is related to App Transport Security
    static func isATSError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            return urlError.code == .appTransportSecurityRequiresSecureConnection
        }
        return false
    }
    
    /// Get a user-friendly error message for ATS issues
    static func atsErrorMessage() -> String {
        return """
        Some transit APIs require HTTP connections, but iOS requires secure HTTPS connections by default.
        
        To fix this:
        1. The app attempts to use HTTPS where possible
        2. For development, HTTP exceptions are configured in Info.plist
        3. Some real-time data may be limited until APIs support HTTPS
        """
    }
    
    /// Get developer-friendly ATS configuration instructions
    static func atsConfigurationInstructions() -> String {
        return """
        App Transport Security Configuration:
        
        Add the following to your Info.plist to allow HTTP connections for specific domains:
        
        <key>NSAppTransportSecurity</key>
        <dict>
            <key>NSExceptionDomains</key>
            <dict>
                <key>v0.ovapi.nl</key>
                <dict>
                    <key>NSExceptionAllowsInsecureHTTPLoads</key>
                    <true/>
                    <key>NSIncludesSubdomains</key>
                    <true/>
                </dict>
            </dict>
        </dict>
        
        Note: Only add exceptions for trusted APIs, and prefer HTTPS when available.
        """
    }
}

/// SwiftUI view component for displaying ATS-related information
struct ATSInfoView: View {
    let showDetails: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundColor(.orange)
                Text("Network Security Notice")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text("Some public transport APIs use HTTP connections, which are restricted by iOS security policies.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if showDetails {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What this means:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label("HTTPS APIs work normally (NS, NDW)", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Label("Some HTTP APIs may be limited", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Label("Demo data is used as fallback", systemImage: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                .padding(.leading, 8)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack(spacing: 16) {
        ATSInfoView(showDetails: false)
        ATSInfoView(showDetails: true)
    }
    .padding()
}