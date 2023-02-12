import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet { // Обработчик didSet - если нужно подменить изображение уже после viewDidLoad
            guard isViewLoaded else { return } // Проверяем было ли загружено view чтобы не закрешится
            imageView.image = image // Попадаем сюда если SingleImageViewController был показан, а указатель на него был запомнен извне. Далее  — извне (например, по свайпу) в него проставляется новое изображение.
        }
    }
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
}

