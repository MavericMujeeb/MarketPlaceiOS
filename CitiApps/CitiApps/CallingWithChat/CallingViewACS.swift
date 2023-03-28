import SwiftUI
import UIKit

struct CallViewACS: UIViewControllerRepresentable {

    var hostedViewController: UIViewController

    func makeUIViewController(context: Context) -> some UIViewController {
        return hostedViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}
