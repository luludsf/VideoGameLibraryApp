//
//  AppConfig.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import Foundation

struct AppConfig {
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Info.plist file not found.")
        }
        return dict
    }()
    
    static let accessToken: String = {
        guard let accessTokenString = AppConfig.infoDictionary["ACCESS_TOKEN"] as? String else {
            fatalError("ACCESS_TOKEN not set in Info.plist for this configuration.")
        }
        return accessTokenString
    }()
    
    static let clientId: String = {
        guard let clientIdString = AppConfig.infoDictionary["CLIENT_ID"] as? String else {
            fatalError("CLIENT_ID not set in Info.plist for this configuration.")
        }
        return clientIdString
    }()
}
