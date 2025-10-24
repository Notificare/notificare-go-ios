//
//  OrderStatusLiveActivity.swift
//  Actito Go
//
//  Created by Helder Pinhal on 30/09/2022.
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, iOSApplicationExtension 16.1, *)
struct OrderStatusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderActivityAttributes.self) { context in
            OrderStatusLockScreenView(
                attributes: context.attributes,
                state: context.state
            )
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        Image("artwork_logo_badge")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)

                        Spacer()

                        OrderStatusHeadlineView(state: context.state.state)

                        Spacer()

                        Image(systemName: icon(for: context.state.state))
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .padding(4)
                            .frame(width: 24, height: 24)
                            .background(Color("color_primary"))
                            .clipShape(Circle())
                    }
                }
            } compactLeading: {
                Image("artwork_logo_badge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } compactTrailing: {
                Image(systemName: icon(for: context.state.state))
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .padding(4)
                    .frame(width: 24, height: 24)
                    .background(Color("color_primary"))
                    .clipShape(Circle())
            } minimal: {
                Image(systemName: icon(for: context.state.state))
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .padding(4)
                    .frame(width: 24, height: 24)
                    .background(Color("color_primary"))
                    .clipShape(Circle())
            }
        }
    }

    private func icon(for state: OrderActivityAttributes.OrderState) -> String {
        switch state {
        case .preparing:
            return "shippingbox"

        case .shipped:
            return "bicycle"

        case .delivered:
            return "house"
        }
    }
}
