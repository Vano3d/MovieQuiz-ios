import UIKit

class AlertPresenter: AlertPresenterProtoсol {
    
    private weak var viewController:UIViewController?
    
    func showAlert(in model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion!()
        }
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
    
    init(viewController: UIViewController? ) {
        self.viewController = viewController
    }
}
