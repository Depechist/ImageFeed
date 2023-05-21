import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func ImagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [ImagesListService.Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func tableView( // Вызываем метод fetchPhotosNextPage перед показом ячейки на экране
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListServiceObserver = NotificationCenter.default // "New API" observer
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        imagesListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier { // проверявем идентификатор сегвея
            let viewController = segue.destination as! SingleImageViewController // Преобразовываем segue.destionation к ожидаемому типу SingleImageViewController, прописанному в Сториборде
            let indexPath = sender as! IndexPath // Преобразовываем сендер к типу IndexPath
            let photo = photos[indexPath.row] // Получаем по индексу картинку и ее название
            guard let imageURL = URL(string: photo.largeImageURL!) else { return }
            viewController.imageURL = imageURL // Передаем картинку в ImageView внутри SingleImageViewController
        } else {
            super.prepare(for: segue, sender: sender) // Если это неизвестный сегвей, есть вероятность, что он был определён суперклассом (то есть родительским классом). В таком случае мы должны передать ему управление.
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let image = photos[indexPath.row]
        guard let thumbnailUrlString = image.thumbImageURL,
              let url = URL(string: thumbnailUrlString) else { return }
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Stub")) { [weak self] _ in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
     
        // указываем форматтеру формат испльзуемый на Unsplash
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        if let createDateString = image.createdAt,
           let date = dateFormatter.date(from: createDateString) {
            
            // указываем форматтеру формат требуемый по дизайну
            dateFormatter.dateFormat = "d MMMM yyyy 'г.'"
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = "date error"
            print(image.createdAt)
        }
        
        if let date = dateFormatter.date(from: image.createdAt!) {
            cell.dateLabel.text = dateFormatter.string(from: date)
        }
        
        cell.setLike(like: photos[indexPath.row].isLiked)
    }
    
    func updateTableViewAnimated() {
        let currentItemsCount = photos.count
        photos = imagesListService.photos
        var paths: [IndexPath] = []
        for i in currentItemsCount ..< photos.count {
            paths.append(IndexPath(row: i, section: 0))
        }
        tableView.performBatchUpdates {
            tableView.insertRows(at: paths, with: .automatic)
        } completion: { _ in }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath) // Прописываем сегвей на контроллер с одной картинокой
        tableView.deselectRow(at: indexPath, animated: true) // Убираем выделение в таблице
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func ImagesListCellDidTapLike(_ cell: ImagesListCell) {
        
        // Ищем адрес ячейки по которой произошло нажатие
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Ищем фото по адресу из массива фото
        let photo = photos[indexPath.row]
        
        // Показываем лоадер
        UIBlockingProgressHUD.show()
        
        // Делаем запрос на изменение статуса "нравится" на противоположный
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            
            // Проверяем результат
            switch result {
            case .success(let photoResult):
                
                // Конвертируем модель PhotoResult в модель Photo
                let updatedPhoto = photoResult.photo.asPhoto()
                
                // Меняем оригинальную модель на обновленную с сервера
                self?.photos[indexPath.row] = updatedPhoto
                
                // Меняем иконку в ячейке на актуальную
                cell.setLike(like: updatedPhoto.isLiked)
                
                // Убираем лоадер
                UIBlockingProgressHUD.dismiss()
            case.failure(let error):
                UIBlockingProgressHUD.dismiss()
                print(photo.id, error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

