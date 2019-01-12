//
//  RegisterViewController.swift
//  TaskManagerApp
//
//  Created by 伊藤凌也 on 2019/01/11.
//  Copyright © 2019 ry-itto. All rights reserved.
//

import UIKit
import RealmSwift

class RegisterViewController: UIViewController {
    
    @IBOutlet var dueDateTextField: UITextField?
    @IBOutlet var taskTitle: UITextField?
    @IBOutlet var taskContent: UITextField?
    @IBOutlet var registerButton: UIButton?
    
    var realm: Realm?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // Realm初期化，Realmファイルへのパスを標準出力
            print(Realm.Configuration.defaultConfiguration.fileURL!)
            realm = try Realm()
        } catch {
            print("Failed : Realm initialize")
        }
        
        // 期日のテキストフィールドの入力方法のビューについて設定
        dueDateTextField?.inputView = createDatePickerView()
        
        // 出てくる期日入力用ビューのツールバー部分を設定
        dueDateTextField?.inputAccessoryView = createToolBarForDatePicker()
        
        // 登録，編集ボタンのUI設定
        registerButton?.backgroundColor = UIColor(hex: "00adb5")
        registerButton?.setTitleColor(UIColor(hex: "222831"), for: .normal)
    }
    
    // 登録，編集ボタンがタップされた時の処理
    @IBAction func didRegisterButtonTapped(_ sender: UIButton) {
        let numberOfTasks: Int? = realm?.objects(Task.self).count
        let task = Task()
        task.id = (numberOfTasks ?? 0) + 1
        task.title = taskTitle?.text ?? ""
        task.content = taskContent?.text ?? ""
        
        do {
            // DBに追加
            try realm?.write {
                realm?.add(task)
            }
        } catch {
            print("RegisterViewController#didRegisterButtonTapped")
            print("Failed : Realm write process")
        }
        (presentingViewController as? ViewController)?.tableView?.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    // 画面下部のボタンのタイトルを設定するメソッド
    func setButtonTitle(buttonTitle: String) {
        registerButton?.setTitle(buttonTitle, for: .normal)
        
        print("Set button title to \(buttonTitle)!!")
    }
    
    // DatePickerのViewを作成するメソッド
    private func createDatePickerView() -> UIDatePicker {
        let dp: UIDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        dp.locale = Locale.current
        dp.datePickerMode = .date
        dp.minimumDate = Date()
        dp.addTarget(self, action: #selector(setText), for: .valueChanged)
        return dp
    }
    
    // DatePickerのツールバーについて設定するメソッド
    private func createToolBarForDatePicker() -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didDoneButtonTapped))
        toolbar.setItems([doneButtonItem], animated: true)
        
        return toolbar
    }
    
    // DatePickerのツールバーにあるdoneボタンがタップされた時の処理
    @objc private func didDoneButtonTapped() {
        
        // キーボード(今回はDatePickerView)を隠す
        dueDateTextField?.resignFirstResponder()
    }
    
    // 期日テキストフィールドに整形したDateを設定
    @objc private func setText(_ sender: UIDatePicker) {
        let df = DateFormatter()
        df.dateStyle = .long
        df.locale = Locale(identifier: "ja")
        dueDateTextField?.text = df.string(from: sender.date)
    }
}
