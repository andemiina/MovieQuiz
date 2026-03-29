
import UIKit

// MARK: - Protocol
protocol MoviesLoaderProtocol {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

//MARK: - MoviesLoader
struct MoviesLoader: MoviesLoaderProtocol {
    
    //MARK: - NetworkClient
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    //MARK: - UR:
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    enum MoviesLoaderError: Error {
        case apiError(String)
        case noData
        case decodingError(Error)
    }
    //MARK: - Public Methods
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data) // десериализация фильма
                    
                    // проверка ошибки от API
                    if !mostPopularMovies.errorMessage.isEmpty {
                        print("Ошибка API: \(mostPopularMovies.errorMessage)")
                        handler(.failure(MoviesLoaderError.apiError(mostPopularMovies.errorMessage)))
                        return
                    }
                    
                    // проверка пустого массива
                    if mostPopularMovies.items.isEmpty {
                        print("Отсутствуют данные для отображения: \(mostPopularMovies.items.count)")
                        handler(.failure(MoviesLoaderError.noData))
                        return
                    }
                    
                    print(" loadMovies вызван, загружено \(mostPopularMovies.items.count) фильмов")
                    handler(.success(mostPopularMovies))
                } catch {
                    print("Ошибка парсинга данных: \(error)")
                    handler(.failure(MoviesLoaderError.decodingError(error)))
                }
            case .failure(let error): // данные не пришли
                print("Ошибка сети: \(error)")
                handler(.failure(error))
            }
        }
    }
}
