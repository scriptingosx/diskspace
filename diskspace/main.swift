//
//  main.swift
//  diskspace
//
//  Created by Armin Briegel on 2021-11-02.
//

import Foundation

let fileURL = URL(fileURLWithPath:"/")
do {
    let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey,.volumeAvailableCapacityForImportantUsageKey, .volumeAvailableCapacityForOpportunisticUsageKey, .volumeTotalCapacityKey])
    if let importantCapacity = values.volumeAvailableCapacity {
        print("Available:     \(importantCapacity)")
    }
    if let importantCapacity = values.volumeAvailableCapacityForImportantUsage {
        print("Important:     \(importantCapacity)")
    }
    if let opportunisticCapacity = values.volumeAvailableCapacityForOpportunisticUsage {
        print("Opportunistic: \(opportunisticCapacity)")
    }
    if let totalCapacity = values.volumeTotalCapacity {
        print("Total:         \(totalCapacity)")
    }
} catch {
    print("Error retrieving capacity: \(error.localizedDescription)")
}
