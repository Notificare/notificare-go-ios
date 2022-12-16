//
//  OrderStatusTrackerView.swift
//  WidgetExtension
//
//  Created by Helder Pinhal on 14/12/2022.
//

import SwiftUI
import WidgetKit

struct OrderStatusTrackerView: View {
    let state: OrderActivityAttributes.OrderState

    var body: some View {
        HStack(spacing: 8) {
            TrackerProgressView(
                currentState: state,
                representedState: .preparing
            )

            TrackerProgressBarView(
                currentState: state,
                representedState: .shipped
            )

            TrackerProgressView(
                currentState: state,
                representedState: .shipped
            )

            TrackerProgressBarView(
                currentState: state,
                representedState: .delivered
            )

            TrackerProgressView(
                currentState: state,
                representedState: .delivered
            )
        }
    }
}

private struct TrackerProgressView: View {
    let currentState: OrderActivityAttributes.OrderState
    let representedState: OrderActivityAttributes.OrderState

    var body: some View {
        Image(systemName: icon)
            .resizable()
            .scaledToFit()
            .foregroundColor(foregroundColor)
            .padding(4)
            .frame(width: 24, height: 24)
            .background(backgroundColor)
            .clipShape(Circle())
    }

    private var icon: String {
        switch representedState {
        case .preparing:
            return "shippingbox"

        case .shipped:
            return "bicycle"

        case .delivered:
            return "house"
        }
    }

    private var foregroundColor: Color {
        if representedState.index <= currentState.index {
            return .white
        } else {
            return .black
        }
    }

    private var backgroundColor: Color {
        if representedState.index <= currentState.index {
            return Color("color_primary")
        } else {
            return Color("color_disabled_grey")
        }
    }
}

private struct TrackerProgressBarView: View {
    let currentState: OrderActivityAttributes.OrderState
    let representedState: OrderActivityAttributes.OrderState

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(fillColor)
            .frame(height: 4)
    }

    private var fillColor: Color {
        if representedState.index <= currentState.index {
            return Color("color_primary")
        } else {
            return Color("color_disabled_grey")
        }
    }
}

struct OrderStatusTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        OrderStatusTrackerView(state: .preparing)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
