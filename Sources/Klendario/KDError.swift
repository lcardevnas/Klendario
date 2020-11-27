//
//  KDError.swift
//
//  Copyright © 2018 Luis Cardenas. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
