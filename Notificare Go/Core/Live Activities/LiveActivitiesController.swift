//
//  LiveActivitiesController.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 15/12/2022.
//

import Foundation
import ActivityKit
import NotificareKit
import OSLog
import UIKit

@available(iOS 16.1, *)
class LiveActivitiesController {
    static let shared = LiveActivitiesController()

    private init() {}


    var hasLiveActivityCapabilities: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func startMonitoring() {
        monitorLiveActivities()
    }


    // MARK: Coffee Brewer

    func createCoffeeBrewerLiveActivity() {
        do {
            let activity = try Activity.request(
                attributes: CoffeeBrewerActivityAttributes(),
                contentState: CoffeeBrewerActivityAttributes.ContentState(
                    state: .grinding,
                    remaining: 5
                ),
                pushType: .token
            )

            Task {
                do {
                    try await Notificare.shared.events().logCustom(
                        "live_activity_started",
                        data: [
                            "activity": getActivityIdentifier(activity)!,
                            "activityId": activity.id,
                        ]
                    )
                } catch {
                    Logger.main.error("Failed to track live activity custom event: \(error)")
                }
            }

            Logger.main.debug("Requested a Live Activity '\(activity.id)'.")
        } catch {
            Logger.main.error("Error requesting Live Activity \(error).")
        }
    }

    func continueCoffeeBrewerLiveActivity() {
        Task {
            for activity in Activity<CoffeeBrewerActivityAttributes>.activities {
                switch activity.contentState.state {
                case .grinding:
                    await activity.update(
                        using: CoffeeBrewerActivityAttributes.ContentState(
                            state: .brewing,
                            remaining: 4
                        )
                    )

                case .brewing:
                    await activity.end(
                        using: CoffeeBrewerActivityAttributes.ContentState(
                            state: .served,
                            remaining: 0
                        ),
                        dismissalPolicy: .default
                    )

                case .served:
                    break
                }
            }
        }
    }

    func cancelCoffeeBrewerLiveActivity() {
        Task {
            for activity in Activity<CoffeeBrewerActivityAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }


    // MARK: Order Status

    func createOrderStatusLiveActivity(products: [Product]) {
        Task {
            for product in products {
                do {
                    try await LiveActivitiesImageDownloader.shared.downloadImage(for: product)
                } catch {
                    Logger.main.warning("Unable to download image for product '\(product.name)': \(error)")
                }
            }

            do {
                let activity = try Activity.request(
                    attributes: OrderActivityAttributes(products: products),
                    contentState: OrderActivityAttributes.ContentState(state: .preparing),
                    pushType: .token
                )

                do {
                    try await Notificare.shared.events().logCustom(
                        "live_activity_started",
                        data: [
                            "activity": getActivityIdentifier(activity)!,
                            "activityId": activity.id,
                        ]
                    )
                } catch {
                    Logger.main.error("Failed to track live activity custom event: \(error)")
                }

                Logger.main.debug("Requested Live Activity '\(activity.id)'.")
            } catch {
                Logger.main.error("Error requesting Live Activity \(error).")
            }
        }
    }


    // MARK: Private API

    private func getActivityIdentifier<T : ActivityAttributes>(_ activity: Activity<T>) -> String? {
        if activity.attributes is CoffeeBrewerActivityAttributes {
            return "coffee-brewer"
        }

        if activity.attributes is OrderActivityAttributes {
            return "order-status"
        }

        return nil
    }

    private func monitorLiveActivities() {
        // Listen to on-going and new Live Activities.
        // Monitor each kind in its own Task since the AsyncSequece will keep waiting
        // thus preventing the second monitor to trigger.

        Task {
            for await activity in Activity<CoffeeBrewerActivityAttributes>.activityUpdates {
                monitorLiveActivity(activity)
            }
        }

        Task {
            for await activity in Activity<OrderActivityAttributes>.activityUpdates {
                monitorLiveActivity(activity)
            }
        }
    }

    private func monitorLiveActivity<T : ActivityAttributes>(_ activity: Activity<T>) {
        Task {
            // Listen to state changes of each activity.
            for await state in activity.activityStateUpdates {
                switch activity.activityState {
                case .active:
                    monitorLiveActivityTokenChanges(activity)

                case .dismissed, .ended:
                    await endLiveActivity(activity)

                @unknown default:
                    Logger.main.warning("Live activity '\(activity.id)' unknown state '\(String(describing: state))'.")
                }
            }
        }
    }

    private func monitorLiveActivityTokenChanges<T : ActivityAttributes>(_ activity: Activity<T>) {
        Task {
            // Listen to push token updates of each active activity.
            for await token in activity.pushTokenUpdates {
                await registerLiveActivity(activity, token: token)
            }
        }
    }

    private func registerLiveActivity<T : ActivityAttributes>(_ activity: Activity<T>, token: Data) async {
        guard let activityIdentifier = getActivityIdentifier(activity) else {
            Logger.main.warning("Unable to get the activity identifier for type '\(String(describing: activity.attributes.self))'.")
            return
        }

        do {
            try await Notificare.shared.push().registerLiveActivity(
                activityIdentifier,
                token: token,
                topics: [activity.id]
            )

            Logger.main.debug("Live activity '\(activityIdentifier)' (\(activity.id)) registered.")
        } catch {
            Logger.main.error("Failed to register live activity '\(activityIdentifier)' (\(activity.id)): \(error)")
        }
    }

    private func endLiveActivity<T : ActivityAttributes>(_ activity: Activity<T>) async {
        guard let activityIdentifier = getActivityIdentifier(activity) else {
            Logger.main.warning("Unable to get the activity identifier for type '\(String(describing: activity.attributes.self))'.")
            return
        }

        do {
            try await Notificare.shared.push().endLiveActivity(activityIdentifier)
            Logger.main.debug("Live activity '\(activityIdentifier)' (\(activity.id)) ended.")
        } catch {
            Logger.main.error("Failed to end live activity '\(activityIdentifier)' (\(activity.id)): \(error)")
        }
    }
}
