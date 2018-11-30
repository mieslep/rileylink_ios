//
//  OmnipodPumpManagerState.swift
//  OmniKit
//
//  Created by Pete Schwamb on 8/4/18.
//  Copyright © 2018 Pete Schwamb. All rights reserved.
//

import RileyLinkKit
import RileyLinkBLEKit
import LoopKit

public struct OmnipodPumpManagerState: RawRepresentable, Equatable {
    public typealias RawValue = PumpManager.RawStateValue
    
    public static let version = 1
    
    public var podState: PodState?
    
    public var timeZone: TimeZone
    
    public var rileyLinkConnectionManagerState: RileyLinkConnectionManagerState?

    public init(podState: PodState?, timeZone: TimeZone, rileyLinkConnectionManagerState: RileyLinkConnectionManagerState?) {
        self.podState = podState
        self.rileyLinkConnectionManagerState = rileyLinkConnectionManagerState
        self.timeZone = timeZone
    }
    
    public init?(rawValue: RawValue) {
        guard
            let podStateRaw = rawValue["podState"] as? PodState.RawValue,
            let podState = PodState(rawValue: podStateRaw)
            else
        {
            return nil
        }
        
        
        let timeZone: TimeZone
        if let timeZoneSeconds = rawValue["timeZone"] as? Int,
            let tz = TimeZone(secondsFromGMT: timeZoneSeconds) {
            timeZone = tz
        } else {
            timeZone = TimeZone.currentFixed
        }
        
        let rileyLinkConnectionManagerState: RileyLinkConnectionManagerState?
        if let rileyLinkConnectionManagerStateRaw = rawValue["rileyLinkConnectionManagerState"] as? RileyLinkConnectionManagerState.RawValue {
            rileyLinkConnectionManagerState = RileyLinkConnectionManagerState(rawValue: rileyLinkConnectionManagerStateRaw)
        } else {
            rileyLinkConnectionManagerState = nil
        }

        self.init(
            podState: podState,
            timeZone: timeZone,
            rileyLinkConnectionManagerState: rileyLinkConnectionManagerState
        )
    }
    
    public var rawValue: RawValue {
        var value: [String : Any] = [
            "version": OmnipodPumpManagerState.version,
            "timeZone": timeZone.secondsFromGMT(),
        ]
        
        if let podState = podState {
            value["podState"] = podState.rawValue
        }
        
        if let rileyLinkConnectionManagerState = rileyLinkConnectionManagerState {
            value["rileyLinkConnectionManagerState"] = rileyLinkConnectionManagerState.rawValue
        }
        
        return value
    }
}


extension OmnipodPumpManagerState {
    static let idleListeningEnabledDefaults: RileyLinkDevice.IdleListeningState = .enabled(timeout: .minutes(4), channel: 0)
}


extension OmnipodPumpManagerState: CustomDebugStringConvertible {
    public var debugDescription: String {
        return [
            "* timeZone: \(timeZone)",
            String(reflecting: podState),
            String(reflecting: rileyLinkConnectionManagerState),
            ].joined(separator: "\n")
    }
}
