import UIKit

final class AlertPresenter: AlertPresenterProtoсol {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController? = nil ) {
        self.viewController = viewController
    }
    
    func showAlert(in model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.buttonAction()
        }
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
    

}
