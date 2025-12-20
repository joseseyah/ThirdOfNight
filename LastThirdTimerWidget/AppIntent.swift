//
//  AppIntent.swift
//  LastThirdTimerWidget
//
//  Created by Joseph Hanson Villar Hayes on 17/12/2025.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Last Third Timer" }
    static var description: IntentDescription { "Shows the time until the last third of the night." }
}
