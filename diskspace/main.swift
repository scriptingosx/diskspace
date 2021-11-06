#!/usr/bin/swift sh
//
//  main.swift
//  diskspace
//
//  Created by Armin Briegel on 2021-11-02.
//

import Foundation
import ArgumentParser // apple/swift-argument-parser

// Code based on sample from here:
// https://developer.apple.com/documentation/foundation/urlresourcekey/checking_volume_storage_capacity

struct DiskSpace : ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "diskspace",
        abstract: "Returns available disk space",
        discussion: """
With the various APFS features the value for free disk space returned from tools such as `du` or `df` will not be accurate. This tool uses system functions to get various measures of available disk space.

The 'Important' value matches the free disk space value shown in Finder.

You can get the details from Apple's documentation:

https://developer.apple.com/documentation/foundation/urlresourcekey/checking_volume_storage_capacity
""",
        version: "1"
    )
    
    // MARK: Flags and Arguments
    
    @Flag(name: [.customShort("H"), .long],
          help: "Human readable output using unit suffixes")
    var humanReadable = false
    
    @Flag(name: .shortAndLong,
          help: "Print only the value of the Available Capacity")
    var available = false

    @Flag(name: .shortAndLong,
          help: "Print only the value of the Important Capacity")
    var important = false

    @Flag(name: .shortAndLong,
          help: "Print only the value of the Opportunistic Capacity")
    var opportunistic = false

    @Flag(name: .shortAndLong,
          help: "Print only the value of the Total Capacity")
    var total = false
    
    @Argument(help: "path to the volume") var volumePath = "/"
    
    // MARK: Functions
    
    func printValue(value int: Int, label: String? = nil) {
        printValue(value: Int64(int), label: label)
    }
    
    func printValue(value int: Int64, label: String? = nil) {
        var value = ""
        
        if humanReadable {
            value = ByteCountFormatter().string(fromByteCount: int)
        } else {
            value = String(int)
        }
        
        if let label = label {
            let paddedLabel = "\(label):".padding(toLength: 15, withPad: " ", startingAt: 0)
            print("\(paddedLabel) \(value)")
        } else {
            print(value)
        }
    }
    
    // MARK: Run the command
    
    func run() {
        let showAll = !(available || important || opportunistic || total)
        
        let systemVolume = URL(fileURLWithPath: volumePath)
        do {
            let values = try systemVolume.resourceValues(forKeys: [.volumeAvailableCapacityKey,.volumeAvailableCapacityForImportantUsageKey, .volumeAvailableCapacityForOpportunisticUsageKey, .volumeTotalCapacityKey])
            if let availableCapacity = values.volumeAvailableCapacity {
                if available {
                    printValue(value: availableCapacity)
                } else if showAll {
                    printValue(value: availableCapacity, label: "Available")
                }
            }
            if let importantCapacity = values.volumeAvailableCapacityForImportantUsage {
                if important {
                    printValue(value: importantCapacity)
                } else if showAll {
                    printValue(value: importantCapacity, label: "Important")
                }
            }
            if let opportunisticCapacity = values.volumeAvailableCapacityForOpportunisticUsage {
                if opportunistic {
                    printValue(value: opportunisticCapacity)
                } else if showAll {
                    printValue(value: opportunisticCapacity, label: "Opportunistic")
                }
            }
            if let totalCapacity = values.volumeTotalCapacity {
                if total {
                    printValue(value: totalCapacity)
                } else if showAll {
                    printValue(value: totalCapacity, label: "Total")
                }
            }
        } catch {
            print("Error retrieving capacity: \(error.localizedDescription)")
        }
    }
}

// call the struct's main function
DiskSpace.main()
