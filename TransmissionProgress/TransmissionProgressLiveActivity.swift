//
//  TransmissionProgressLiveActivity.swift
//  TransmissionProgress
//
//  Created by Olivier on 25/05/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TransmissionProgressLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TransmissionProgressAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                HStack{
                    Text(context.attributes.name)
                    Spacer()
                    if context.state.eta != -1 {
                        Text(String("\(context.state.eta/60) min."))
                    }
                }
                HStack{
                    Gauge(value: context.state.progression, label: {})
                    Text(String(format: "%.1f", context.state.progression * 100) + " %")
                }
            }
            //.activityBackgroundTint(Color.cyan)
            //.activityBackgroundTint(nil)
            .padding()
            .activityBackgroundTint(Color.white.opacity(0.5))
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName:  "arrow.down.to.line.circle")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.eta != -1 {
                        Text(String("\(context.state.eta/60) min."))
                    } else {
                        Text(String(format: "%.1f", context.state.progression * 100) + " %")
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack{
                        Text(context.attributes.name)
                        ProgressView(value: context.state.progression * 100)
                    }.padding()
                }
            } compactLeading: {
                if context.state.eta != -1 {
                    Text(String("\(context.state.eta/60) min."))
                } else {
                    Image(systemName: "arrow.down.to.line.circle")
                }
            } compactTrailing: {
                Text(String(format: "%.1f", context.state.progression * 100) + " %")
            } minimal: {
                Text("X")
            }
            .keylineTint(Color.red)
        }
    }
}

/*
 extension TransmissionProgressAttributes {
 fileprivate static var preview: TransmissionProgressAttributes {
 TransmissionProgressAttributes(name: "World")
 }
 }
 */

/*
 extension TransmissionProgressAttributes.ContentState {
 fileprivate static var smiley: TransmissionProgressAttributes.ContentState {
 TransmissionProgressAttributes.ContentState(emoji: "😀")
 }
 
 fileprivate static var starEyes: TransmissionProgressAttributes.ContentState {
 TransmissionProgressAttributes.ContentState(emoji: "🤩")
 }
 }
 
 #Preview("Notification", as: .content, using: TransmissionProgressAttributes.preview) {
 TransmissionProgressLiveActivity()
 } contentStates: {
 TransmissionProgressAttributes.ContentState.smiley
 TransmissionProgressAttributes.ContentState.starEyes
 }
 */
