//
//  main.swift
//  diskspace
//
//  Created by Armin Briegel on 2021-11-02.
//

import Foundation
import ArgumentParser

// Code based on sample from here:
// https://developer.apple.com/documentation/foundation/urlresourcekey/checking_volume_storage_capacity

struct DiskSpace : ParsableCommand {
    @Flag var humanReadable: Bool = false
    
    
    func format(_ int: Int) -> String {
        return format(Int64(int))
    }
    
    func format(_ int: Int64) -> String {
        if humanReadable {
            return ByteCountFormatter().string(fromByteCount: Int64(int))
        } else {
            return String(int)
        }
    }
    
    func run() {
        let systemVolume = URL(fileURLWithPath:"/")
        do {
            let values = try systemVolume.resourceValues(forKeys: [.volumeAvailableCapacityKey,.volumeAvailableCapacityForImportantUsageKey, .volumeAvailableCapacityForOpportunisticUsageKey, .volumeTotalCapacityKey])
            if let totalCapacity = values.volumeAvailableCapacity {
                print("Available:     \(format(totalCapacity))")
            }
            if let importantCapacity = values.volumeAvailableCapacityForImportantUsage {
                print("Important:     \(format(importantCapacity))")
            }
            if let opportunisticCapacity = values.volumeAvailableCapacityForOpportunisticUsage {
                print("Opportunistic: \(format(opportunisticCapacity))")
            }
            if let totalCapacity = values.volumeTotalCapacity {
                print("Total:         \(format(totalCapacity))")
            }
        } catch {
            print("Error retrieving capacity: \(error.localizedDescription)")
        }
    }
}

DiskSpace.main()
