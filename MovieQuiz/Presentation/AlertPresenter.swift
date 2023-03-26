
import UIKit

class AlertPresenter {
    
    weak var delegete: UIViewController?
    
    init(delegete: UIViewController? = nil) {
        self.delegete = delegete
    }
    
    func showAlert(alertData: AlertModel) {
        let alert = UIAlertController(
                title: alertData.title,
                message: alertData.message,
                preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertData.buttonText, style: .default) {_ in
            alertData.completion()
            }
            
        alert.addAction(action)
            
        self.delegete?.present(alert, animated: true, completion: nil)
    }
}
