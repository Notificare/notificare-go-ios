//
//  CoffeeBrewerLiveActivity.swift
//  WidgetExtension
//
//  Created by Helder Pinhal on 30/11/2022.
//

import SwiftUI
import WidgetKit
import ActivityKit

@available(iOS 16.1, iOSApplicationExtension 16.1, *)
struct CoffeeBrewerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CoffeeBrewerActivityAttributes.self) { context in
            CoffeeBrewerLockScreenView(
                attributes: context.attributes,
                state: context.state
            )
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    CoffeeBrewerHeadlineView(state: context.state)
                }
            } compactLeading: {
                Image("ic_coffee_cup_filled")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("color_cream"))
            } compactTrailing: {
                Text(context.state.localizedTimeRemaining)
            } minimal: {
                if context.state.state == .served {
                    Image("ic_coffee_cup_filled")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("color_cream"))
                } else {
                    Label {
                        Text(context.state.localizedTimeRemaining)
                    } icon: {
                        Image(systemName: "timer")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color("color_cream"))
                            .frame(width: 16, height: 16)
                    }
                    .font(.footnote)
                }
            }
        }
    }
}
