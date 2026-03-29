
import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func setButtonEnabled(_ isEnabled: Bool)
    func showNetworkError(message: String)
}
