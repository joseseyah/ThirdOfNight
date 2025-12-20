//
//  AppIntent.swift
//  prayertimes
//
//  Created by Joseph Hanson Villar Hayes on 17/12/2025.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Prayer Times" }
    static var description: IntentDescription { "Shows the next prayer time." }
}
