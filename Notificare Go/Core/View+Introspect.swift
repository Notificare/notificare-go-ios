//
//  View+Introspect.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 06/04/2022.
//

import Foundation
import Introspect
import SwiftUI

extension View {
    
    /// Finds the horizontal `UIScrollView` from a `SwiftUI.TabBarView` with tab style `SwiftUI.PageTabViewStyle`.
    ///
    /// Customize is called with a `UICollectionView` wrapper, and the horizontal `UIScrollView`.
    public func introspectPagedTabView(customize: @escaping (UICollectionView, UIScrollView) -> ()) -> some View {
        return introspect(selector: TargetViewSelector.ancestorOrSiblingContaining, customize: { (collectionView: UICollectionView) in
            for subview in collectionView.subviews {
                if NSStringFromClass(type(of: subview)).contains("EmbeddedScrollView"), let scrollView = subview as? UIScrollView {
                    customize(collectionView, scrollView)
                    break
                }
            }
        })
    }
}
