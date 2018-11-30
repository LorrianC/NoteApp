//
//  ListViewController.swift
//  NoteApp
//
//  Created by LorrianC on 2018/11/8.
//  Copyright © 2018 Lorrianc. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,NoteViewControllerDelegate {
    
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    //Model
    var data : [Note] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
       // print("coder")
        self.loadFromCoreData()
        //self.loadFromFile()
       // 產生10筆假資料供測試用
//        for index in 0...10{
//            let note = Note()
//            note.text = "Note \(index)"
//            data.append(note)
//        }
        
//        //對done事件有興趣,通知的名稱為"NoteUpdate"
//        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.updateNote(notification:)), name:Notification.Name("NoteUpdate"), object: nil)
//
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    //通知方法的參數是固定的，要馬沒有參數，要馬就是一個參數Notification物件
//    @objc func updateNote(notification: Notification){
//       if let note = notification.userInfo?["note"] as? Note{
//            if let index =  self.data.firstIndex(of: note){
//            //取得在data中的位置
//            let indexPath = IndexPath(row: index, section: 0)//組成IndexPath
//            //reload特定位置
//            self.tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
//
//        }
//
        }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self//storyboard可以做
        self.tableView.delegate = self
        //self.tableView.rowHeight = UITableView.automaticDimension
//        if #available(iOS 11.0, *){
//        self.navigationController?.navigationBar.prefersLargeTitles = true//storyboard可以做
//        }
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
    }
    
    
    
    @IBAction func addNote(_ sender: Any) {
        let moc = CoreDataHelper.shared.managedObjectContext()
        let note = Note(context: moc)
        
        
        //let note = Note()
     
        note.text = "New Note"
        self.data.insert(note, at: 0)//加到model中
        self.saveToCoreData()
        //self.saveToFile()
        //產生位置物件
        let indexPath = IndexPath(row: 0, section: 0)
        //呼叫insertRows
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    
    }
    
    
    @IBAction func upload(_ sender: Any) {
        let item = sender as! UIBarButtonItem
        
        let activityView = UIActivityIndicatorView(style: .gray)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        item.customView = activityView
        activityView.startAnimating()//開始旋轉
        
        DispatchQueue.global().async { //進入背景執行緒
            Thread.sleep(forTimeInterval: 3)//模擬網路下載
            DispatchQueue.main.async {//與畫面有關，丟回主執行緒
                  item.customView = nil //恢復原本的按鈕
            }
        }
        
        
    }
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)

        
    }
    
    @IBAction func edit(_ sender: Any) {
        
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        
        
    }
    
    //新刪改查
    //MARK:Archiving
    func saveToFile(){
        //把self.data存到檔案
        do {
           let data =  try NSKeyedArchiver.archivedData(withRootObject: self.data, requiringSecureCoding: false)
            //把data寫到檔案
            let home = URL(fileURLWithPath:NSHomeDirectory())
            let documents = home.appendingPathComponent("Documents")
            let fileName  = documents.appendingPathComponent("notes.archive")//檔名notes.archive
            try data.write(to: fileName, options: [.atomicWrite])
        }catch{
            print("error \(error)")
        }
    }
    
    func loadFromFile(){
        
        let home = URL(fileURLWithPath:NSHomeDirectory())
        let documents = home.appendingPathComponent("Documents")
        let fileName  = documents.appendingPathComponent("notes.archive")//檔名notes.archive
        do{
            //從檔案轉成Data
            let data = try Data(contentsOf: fileName)
            //解成[Note]放回self.data
            self.data = try  NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)as! [Note]
            
        }catch{
            print("loadFromFile error \(error)")
        }
       
    }
    
    
    //新增、儲存、刪除
    //MARK: Core Data
    func saveToCoreData(){
        CoreDataHelper.shared.saveContext()
        
    }
    func loadFromCoreData(){
        let moc = CoreDataHelper.shared.managedObjectContext()
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        moc.performAndWait {
            do{
                let result = try moc.fetch(fetchRequest)
                self.data = result
            }catch{
                print("error \(error)")
            }
        }
        
    }
    
    
    
    
    
    //MARK: UITableViewDataSource
    //預設一個section, numberofsection可以return
    
    //  section 0有幾筆
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //reuse機制
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        let note = self.data[indexPath.row]//取得該位置的Note物件
        cell.textLabel?.text = note.text//把note中的文字放在cell的textLabel上
        cell.showsReorderControl = true//storyboard可以做
        cell.imageView?.image = note.thumbnailImage()//縮圖顯示
        return cell

        
//        cell.accessoryType = .checkmark //storyboard也可以做
//        cell.accessoryView = UISwitch() // 客製化用的，UIView****
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! NoteCell
//        let note = self.data[indexPath.row]//取得該位置的Note物件
//        cell.myLabel.text = note.text
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let note = self.data.remove(at: indexPath.row)//根據位置刪除data中的note
            CoreDataHelper.shared.managedObjectContext().delete(note)
            self.saveToCoreData()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //更新model位置,取出原本的資料，塞到新的位置
       
        let note = self.data.remove(at: sourceIndexPath.row)//取出原本的資料
        self.data.insert(note, at: destinationIndexPath.row)//塞到新的位置
        self.saveToCoreData()
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("row=\(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        //只有在這個controll是storyboard產生的，self.storyboard才會有值，才能找到storyboard物件
        //透過storyboard id 產生第二組畫面
//        if let noteVC = self.storyboard?.instantiateViewController(withIdentifier: "noteVC"){
//        self.navigationController?.pushViewController(noteVC, animated: true)
//        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "This is Header"
//    }
//
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return "This is Footer"
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UISwitch()
//    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   
    
    //prepare for segue傳遞資料給NoteVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "noteSegue"{
            //前往NoteViewController
           // print("NoteViewController")
           let noteVC = segue.destination as! NoteViewController
            if let indexPath =  self.tableView.indexPathForSelectedRow{
                //取得相對應的Note物件，放在NoteViewController的CurrentNote屬性上
                noteVC.currentNote = self.data[indexPath.row]
                noteVC.delegate = self
                //=segue.source as! ListViewController
                //noteViewController的listVC去是ListViewController物件（self）
            }
        }
        
    }
    //按下done時被通知的方法
    func didFinishUpdate(note:Note){
        //CoreDataHelper.shared.saveContext()
        self.saveToCoreData()
        //reload indexpath
        if let index =  self.data.firstIndex(of: note){
            //取得在data中的位置
            let indexPath = IndexPath(row: index, section: 0)//組成IndexPath
            //reload特定位置
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
       
    }

}
