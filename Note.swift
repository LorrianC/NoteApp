
import Foundation
import UIKit
import CoreData

//class Note: NSObject,Equatable,NSCoding{
//class Note: NSObject,NSCoding{
class Note: NSManagedObject{
   /*
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.text, forKey: "text")
        aCoder.encode(self.imageName, forKey: "imageName")
        aCoder.encode(self.noteID, forKey: "noteID")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.noteID = aDecoder.decodeObject(forKey: "noteID") as! String
        self.text = aDecoder.decodeObject(forKey: "text") as? String
        self.imageName = aDecoder.decodeObject(forKey: "imageName") as?String
    }*/
 
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.noteID == rhs.noteID // 1.用noteID做比較
        //return lhs == rhs //2.比較記憶體位置
    }
    
    @NSManaged var noteID : String //資料庫使用mysql, primary key
    @NSManaged var text : String?
    @NSManaged var imageName : String?
    //var image : UIImage?
    //新增至資料庫前會呼叫的程式
    override func awakeFromInsert() {
        noteID = UUID().uuidString
    }
    
//   override init() {
//        noteID = UUID().uuidString //產生亂碼ID，轉成String
//    }
    
    func image()->UIImage?{//來取代 var image(屬性)，透過方法來取得照片，不隨時存放在屬性中
        
        if let name = imageName{
            let home = URL(fileURLWithPath: NSHomeDirectory())
            let documents = home.appendingPathComponent("Documents")
            //再往下串檔名,noteID xxx-xxx-xxx-xxx.jpg
            let fileName = name
            let fileURL = documents.appendingPathComponent(fileName)
            if let image = UIImage(contentsOfFile: fileURL.path){
                return image
            }
            
        }
        
        return nil
    }
    func thumbnailImage() -> UIImage? {
        if let image =  self.image() {
            
            let thumbnailSize = CGSize(width:50, height: 50); //設定縮圖大小
            let scale = UIScreen.main.scale //找出目前螢幕的scale，視網膜技術為2.0
            
            //產生畫布，第一個參數指定大小,第二個參數true:不透明（黑色底）,false表示透明背景,scale為螢幕scale
            UIGraphicsBeginImageContextWithOptions(thumbnailSize,false,scale)
            
            //計算長寬要縮圖比例，取最大值MAX會變成UIViewContentModeScaleAspectFill
            //最小值MIN會變成UIViewContentModeScaleAspectFit
            let widthRatio = thumbnailSize.width / image.size.width;
            let heightRadio = thumbnailSize.height / image.size.height;
            
            let ratio = max(widthRatio,heightRadio);
            
            let imageSize = CGSize(width:image.size.width*ratio,height: image.size.height*ratio);
            
            image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y: -(imageSize.height-thumbnailSize.height)/2.0,
                                 width: imageSize.width,height: imageSize.height))
            //取得畫布上的縮圖
            let smallImage = UIGraphicsGetImageFromCurrentImageContext();
            //關掉畫布
            UIGraphicsEndImageContext();
            return smallImage
        }else{
            return nil;
        }
        
    }


}
