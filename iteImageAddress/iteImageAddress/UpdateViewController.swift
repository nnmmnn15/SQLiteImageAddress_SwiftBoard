//
//  UpdateViewController.swift
//  iteImageAddress
//
//  Created by 노민철 on 12/18/24.
//

import UIKit

class UpdateViewController: UIViewController {
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfRelation: UITextField!
    
    @IBOutlet weak var imgView: UIImageView!
    
    var receiveId = 0
    var receiveName = ""
    var receivePhone = ""
    var receiveAddress = ""
    var receiveRelation = ""
    var receiveImage: UIImage?
    
    // shared: 앱 전체에서 하나의 데이터베이스 인스턴스만 유지(여러 번 생성 방지)
    let dbManager = DatabaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    // 내부에서만 사용
    private func setupUI(){
        // 받아온 데이터로 UI 초기화
        tfName.text = receiveName
        tfPhone.text = receivePhone
        tfAddress.text = receiveAddress
        tfRelation.text = receiveRelation
        if let image = receiveImage {
            imgView.image = image
        }
    }
    
    @IBAction func updatePhoto(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @IBAction func updateProfile(_ sender: UIButton) {
        guard let name = tfName.text,
              let phone = tfPhone.text,
              let address = tfAddress.text,
              let relation = tfRelation.text else { return }
        
        // 데이터베이스 업데이트
        dbManager.update(
            id: receiveId,
            name: name,
            phoneNumber: phone,
            address: address,
            relationship: relation,
            image: imgView.image
        )
        // 업데이트 후 이전 화면으로 돌아가기
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteProfile(_ sender: UIButton) {
        // 데이터 삭제
        dbManager.delete(id: receiveId)
        navigationController?.popViewController(animated: true)
    }
}

extension UpdateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imgView.image = selectedImage
        }
        dismiss(animated: true)
    }
}
