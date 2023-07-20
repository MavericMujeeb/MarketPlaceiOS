//
//  ContainerHostingController.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 20/07/23.
//

import Foundation
import SwiftUI
import PIPKit

class ContainerUIHostingController: UIHostingController<ContainerUIHostingController.Root>, PIPUsable {
//    private let cancelBag = CancelBag()

    init(rootView: IncomingCallView) {
        super.init(rootView: Root(containerView: rootView))
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    struct Root: View {
        let containerView: IncomingCallView

        var body: some View {
            containerView
        }
    }

    // MARK: Prefers Home Indicator Auto Hidden
}

 extension ContainerUIHostingController: UIViewControllerTransitioningDelegate {}
