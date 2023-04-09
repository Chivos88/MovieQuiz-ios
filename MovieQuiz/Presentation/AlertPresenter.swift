
import UIKit

class AlertPresenter {
    
    weak var delegete: UIViewController?
    
    init(delegete: UIViewController? = nil) {
        self.delegete = delegete
    }
    
    func showAlert(alertModel: AlertModel) {
        let alert = UIAlertController(
                title: alertModel.title,
                message: alertModel.message,
                preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) {_ in
            alertModel.completion()
            }
            
        alert.addAction(action)
            
        delegete?.present(alert, animated: true, completion: nil)
    }
}
