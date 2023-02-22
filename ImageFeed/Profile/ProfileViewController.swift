import UIKit

class ProfileViewController: UIViewController {
    
    // РЕВЬЮЕРУ:
    // В учебнике есть рекомендация разбить код ниже на функции и уже их вызвать в viewDidLoad()
    // Буду рад фидбеку и примеру функций, на которые лучше разбить данный код для дальнейшего рефакторинга.
    // Спасибо
    
    override func viewDidLoad() {
        
        let profileImage = UIImage(named: "Photo")
        let avatar = UIImageView(image: profileImage)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatar)
        
        avatar.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 70).isActive = true
        avatar.topAnchor.constraint(equalTo: view.topAnchor, constant: 76).isActive = true
        avatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nameLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.textColor = UIColor(named: "YP Gray")
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "LogoutButton")!,
            target: self,
            action: nil)
        logoutButton.tintColor = UIColor(named: "YP Red")

        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)

        logoutButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: avatar.centerYAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        
    }
    
}
