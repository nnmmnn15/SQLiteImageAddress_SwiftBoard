//
//  InsertViewController.swift
//  iteImageAddress
//
//  Created by 노민철 on 12/18/24.
//

import UIKit

class InsertViewController: UIViewController {

    @IBOutlet weak var lblName: UITextField!
    @IBOutlet weak var lblPhone: UITextField!
    @IBOutlet weak var lblAddress: UITextField!
    @IBOutlet weak var lblRelation: UITextField!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var btnPhotoState: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnPhotoState.isEnabled = false
        lblName.delegate = self
        lblPhone.delegate = self
        lblAddress.delegate = self
        lblRelation.delegate = self
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary // 사진 라이브러리 사용
    }
    
    @IBAction func btnGetImage(_ sender: UIButton) {
        // 갤러리 접근 권한이 있는지 확인
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnInsert(_ sender: UIButton) {
        let insertAlert = UIAlertController(title: "입력 결과", message: "", preferredStyle: .alert)
        
        if lblName.text?.isEmpty == false && lblPhone.text?.isEmpty == false && lblAddress.text?.isEmpty == false && lblRelation.text?.isEmpty == false && imgProfile.image != nil{
            DatabaseManager.shared.insert(name: lblName.text!, phoneNumber: lblPhone.text!, address: lblAddress.text!, relationship: lblRelation.text!, image: imgProfile.image!)
            // alert
            let actionDefault = UIAlertAction(title: "확인", style: .default, handler: {Action in self.navigationController?.popViewController(animated: true)})
            insertAlert.addAction(actionDefault)
            insertAlert.message = "성공"
            present(insertAlert, animated: true)
        } else{
            // alert
            let actionDefault = UIAlertAction(title: "확인", style: .default)
            insertAlert.addAction(actionDefault)
            insertAlert.message = "실패"
            present(insertAlert, animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InsertViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 이미지 선택 후 호출되는 델리게이트 메서드
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 선택된 이미지를 imageView에 설정
        if let pickedImage = info[.originalImage] as? UIImage {
            imgProfile.image = pickedImage
        }
        
        // 이미지 피커 닫기
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 이미지 선택 취소 시 호출되는 메서드
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print("이미지 선택이 취소되었습니다.")
        picker.dismiss(animated: true, completion: nil)
    }
}

extension InsertViewController : UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if lblName.text?.isEmpty == true || lblPhone.text?.isEmpty == true || lblAddress.text?.isEmpty == true ||
            lblRelation.text?.isEmpty == true {
            btnPhotoState.isEnabled = false
        } else {
            btnPhotoState.isEnabled = true
        }
    }
}
