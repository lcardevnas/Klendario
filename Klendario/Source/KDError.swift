//
//  KDError.swift
//  Klendario
//
//  Created by Luis Cardenas on 21/11/2018.
//  Copyright © 2018 ThXou. All rights reserved.
//

import Foundation

public enum KDError: Error {
    case authorizationFailed(reason: AuthorizationFailureReason)
    
    public enum AuthorizationFailureReason {
        case authorizationDenied
        case authorizationRestricted
    }
}


// MARK: - Error Descriptions
extension KDError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .authorizationFailed(let reason):
            return reason.localizedDescription
        }
    }
}

extension KDError.AuthorizationFailureReason {
    var localizedDescription: String {
        switch self {
        case .authorizationDenied:
            return NSLocalizedString("authorization_denied", comment: "Calendar access authorization was denied")
        case .authorizationRestricted:
            return NSLocalizedString("authorization_restricted", comment: "Calendar access authorization is restricted")
        }
    }
}
