//
//  AttachmentViewController.swift
//  Followal Task
//
//  Created by iMac on 03/08/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import KSPhotoBrowser
class AttachmentViewController: UIViewController {

    @IBOutlet weak var viewPhotos: UIView!
    @IBOutlet weak var cvCollection: UICollectionView!
    var task:Task!
    var arrPhotos : [String]!
    
    //MARK:- UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cvCollection.register(UINib.init(resource: nibs.itemsCollectionViewCell), forCellWithReuseIdentifier: "Cell")
        arrPhotos = task.Files.toArray()
        self.title = task.TaskTitle + "'s " + "Attachment"
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
extension AttachmentViewController: UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    
    //MARK:- Collection Life Cycle

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPhotos.count
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ItemsCollectionViewCell
        let attachmentURL = arrPhotos[indexPath.row]
        let url = (webUrls.hostURL() + attachmentURL).toURL()
        cell.imgPhoto!.sd_setImage(with: url, placeholderImage: images.placeholder_personal_profile_details(), options: .progressiveLoad, context: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.frame.size.height)
    }
    
    
}
