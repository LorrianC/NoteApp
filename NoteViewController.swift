//
//  NoteViewController.swift
//  NoteApp
//
//  Created by LorrianC on 2018/11/22.
//  Copyright © 2018 Lorrianc. All rights reserved.
//

import UIKit

protocol NoteViewControllerDelegate:class{
     func didFinishUpdate(note:Note)
}

class NoteViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    var currentNote:Note! //ListVC一定要傳給NoteVC,所以用!
    weak var delegate:NoteViewControllerDelegate?//只能放class的物件，不能放struct(x)的物件
    var imageRatioConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.navigationItem.largeTitleDisplayMode = .never //storyboard可設定
        self.textView.text = self.currentNote.text //初始化畫面上的文字
        self.imageView.image = self.currentNote.image() //初始化畫面上的圖片
        
        self.imageView.layer.borderWidth = 5
        self.imageView.layer.borderColor = UIColor.blue.cgColor
        self.imageView.layer.cornerRadius = 10
        //self.imageView.layer.masksToBounds = true
        self.imageView.layer.shadowColor = UIColor.darkGray.cgColor
        self.imageView.layer.shadowOpacity = 0.8
        self.imageView.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        
        print("toolbar intrinsic size \(self.toolbar.intrinsicContentSize)")
        print("imageView intrinsic size \(self.imageView.intrinsicContentSize)")
        
        //補4:3條件
        self.imageRatioConstraint = self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 0.75)
        if self.traitCollection.verticalSizeClass == .regular{
            self.imageRatioConstraint.isActive = true
        }
        
        

    }
    
    //轉向會呼叫
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super .willTransition(to: newCollection, with: coordinator)
        
        if newCollection.verticalSizeClass == .compact {
            //轉成橫向，不要4:3
            self.imageRatioConstraint.isActive = false
        }else{
            self.imageRatioConstraint.isActive = true
        }
        self.toolbar.invalidateIntrinsicContentSize()
    }
    

    @IBAction func camera(_ sender: Any) {
        
        
        let controller = UIImagePickerController()
        controller.sourceType = .savedPhotosAlbum
        controller.delegate = self
        self.present(controller,animated: true,completion: nil)//由下往上
        
        
        
        
    }
    @IBAction func done(_ sender: Any) {
        //到ListVC prepare準備
        
        
        //更新Note中的資料
        self.currentNote.text = self.textView.text
       // self.currentNote.image = self.imageView.image
        
        
        //如果使用者有選新的照片，
        if self.isNewPhoto{
            //才把照片存下來，XXX.jpg
            
            if let imageData = self.imageView.image?.jpegData(compressionQuality: 1){
                do{
                    let home = URL(fileURLWithPath: NSHomeDirectory())
                    let documents = home.appendingPathComponent("Documents")
                    //再往下串檔名,noteID xxx-xxx-xxx-xxx.jpg
                    let fileName = "\(self.currentNote.noteID).jpg"
                    let fileURL = documents.appendingPathComponent(fileName)
                    //把檔名存回currentName
                    self.currentNote.imageName = fileName
                
                   try imageData.write(to: fileURL, options: [.atomicWrite])
                    
                }catch {
                    print("寫入圖檔有錯\(error)")
                }
        }
        }
        //NotificationCenter.default.post(name: Notification.Name("NoteUpdate"), object: nil, userInfo: ["note":self.currentNote])
        
        
        
            //通知ListViewController
           //NoteViewController的listVC = ListViewController物件
           //Any不一定有didFinishUpdate方法
          //目的：Any增加限制，限制一定要有didFinishUpdate方法
        self.delegate?.didFinishUpdate(note:self.currentNote)
        
        //Push往下切，pop往上
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    var isNewPhoto = false
    
    //Mark:UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
           
            self.imageView.image = image //把使用者選的照片放在imageView上
            self.isNewPhoto = true
       
        }
        picker.dismiss(animated: true, completion: nil)//關閉選擇照片的畫面,與present一組用，self.dismiss也ok
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
