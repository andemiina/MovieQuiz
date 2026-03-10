import UIKit

//MARK: - ViewController
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Properties
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupQuestionFactory()
        setupAlertPresenter()
        setupStatisticService()
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)}
        
    }
    
    
    //MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(false)
    }
    
    //MARK: - Private Methods
    
    private func handleAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion else { return }
        
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    private func setupQuestionFactory() {
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
    }
    
    private func setupAlertPresenter() {
        let alertPresenter = AlertPresenter(delegate: self)
        self.alertPresenter = alertPresenter
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        resetBoarder()
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
        }
        setButtonEnabled(false)
    }
    
    private func showNextQuestionOrResult() {
        setButtonEnabled(true)
        
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let text = correctAnswers == questionsAmount ?
                        """
                        Поздравляем, вы ответили на \(correctAnswers) из \(questionsAmount)!
                        Количество сыгранных квизов: \(String(describing: statisticService.gamesCount))
                        Рекорд: \(String(describing: statisticService.bestGame.correct))/10 (\(String(describing: statisticService.bestGame.date.dateTimeString)))
                        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                        """ :
                        """
                        Ваш результат: \(correctAnswers)/\(questionsAmount)
                        Количество сыгранных квизов: \(String(describing: statisticService.gamesCount))
                        Рекорд: \(String(describing: statisticService.bestGame.correct))/10 (\(String(describing: statisticService.bestGame.date.dateTimeString)))
                        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                        """
            
            let alertModel = AlertModel(
                title: Constants.titleText,
                message: text,
                buttonText: Constants.buttonText,
                completion: { [weak self] in
                    self?.currentQuestionIndex = 0
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                })
            
            self.alertPresenter?.show(quiz: alertModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
            
            resetBoarder()
        }
    }
    
    private func resetBoarder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    private func setButtonEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
        
    }
    
    private func setupStatisticService() {
        let statisticService = StatisticService()
        self.statisticService = statisticService
    }
}
