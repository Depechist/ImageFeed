//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Artem Adiev on 08.06.2023.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // останавливаем тест, если что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        // тест сценария авторизации

        // Нажать кнопку авторизации
        app.buttons["Authenticate"].tap()

        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"] // вовращаем веб вью
        webView.waitForExistence(timeout: 5) // ждем 5 секунд

        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element // находим поле для ввода логина
        loginTextField.waitForExistence(timeout: 5) // ждем 5 секунд
        loginTextField.tap() // выбираем форму
        loginTextField.typeText("depechist@live.com") // вводим логин
        app.toolbars["Toolbar"].buttons["Done"].tap() // жмем ввод
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element // находим поле для ввода пароля
        passwordTextField.waitForExistence(timeout: 5) // ждем 5 секунд
        passwordTextField.tap() // выбираем форму
        passwordTextField.typeText("artem177176") // вводим пароль
        app.toolbars["Toolbar"].buttons["Done"].tap() // жмем ввод
        
        webView.swipeUp() // скрываем клавиатуру после ввода текста (необязательно)

        print(app.debugDescription) // печатаем в консоли дерево UI-элементов (для отладки и выявления проблем)
        sleep(3)

        // Нажать кнопку логина
        webView.buttons["Login"].tap() // жмем на кнопку авторизации

        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables // возвращаем таблицы на экран
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0) // возвращаем ячейку по индексу 0

        XCTAssertTrue(cell.waitForExistence(timeout: 5)) // ждем появление ячейки на экране 5 секунд
    }

    func testFeed() throws {
        // тест сценария ленты картинок
        
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        let likeButton = cell.descendants(matching: .button)["LikeButton"]
        cell.waitForExistence(timeout: 5)
        // Сделать жест «смахивания» вверх по экрану для его скролла
        app.swipeUp()
        
        // Поставить лайк в ячейке верхней картинки
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        likeButton.tap()
        sleep(3)
        
        // Отменить лайк в ячейке верхней картинки
        likeButton.tap()
        sleep(3)
        
        // Нажать на верхнюю ячейку
        cellToLike.tap()
        sleep(3)
        
        // Подождать, пока картинка открывается на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        sleep(3)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуться на экран ленты
        let backButton = app.buttons["BackButton"]
        backButton.tap()
    }
    
    
    func testProfile() throws {
        // тест сценария профиля
        
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        sleep(5)
        
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(3)
        
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["Artem"].exists)
        XCTAssertTrue(app.staticTexts["@depechist"].exists)
        sleep(3)
        
        // Нажать кнопку логаута
        app.buttons["LogoutButton"].tap()
        
        // Проверить, что открылся экран авторизации
        let webView = app.webViews["UnsplashWebView"] // вовращаем веб вью
        webView.waitForExistence(timeout: 5)
    }
}
