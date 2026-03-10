
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    //MARK: - Properties
    weak var delegate: UIViewController?
    
    //MARK: - Initializer
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
    
    //MARK: - Public Methods
    func show(quiz result: AlertModel) {
        
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
