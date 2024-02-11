//
//  Extensions.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import Foundation
import UIKit

extension UIView
{
    var width: CGFloat
    {
        self.frame.size.width
    }
    
    var height:CGFloat
    {
        frame.size.height
    }
    
    var left:CGFloat
    {
        frame.origin.x
    }
    
    var right: CGFloat
    {
        left + width
    }
    
    var top:CGFloat
    {
        frame.origin.y
    }
    var bottom:CGFloat
    {
        top + height
    }
}

extension UIImage
{
    private var storagePath:URL?
    {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func saveToDocumentDirectory(with nameID:String)
    {
        if getImageFromStorageDirectory(with: nameID) == nil
        {
            let imageToSave = self.jpegData(compressionQuality: 0.9)
            if let path = storagePath
            {
                let imagePath = path.appending(component: nameID)
                do{
                    try imageToSave?.write(to: imagePath, options: .atomic)
                    
                }catch
                {
                    print(error.localizedDescription)
                }
            }else
            {
                print("wrong path")
            }
        }else
        {
            return
        }
       
    }
    
    func getImageFromStorageDirectory(with nameID:String) ->UIImage?
    {
        let imageData = storagePath?.appending(component: nameID).path(percentEncoded: false)
        if let image = UIImage(contentsOfFile: imageData!)
        {
            return image
        }
        else
        {
            
            return nil
        }
    }
    
    func removeImages()
    {
        let fileManger = FileManager.default
        let imagesDirectory = fileManger.urls(for: .documentDirectory, in: .userDomainMask).first
        
        if let content = try? fileManger.contentsOfDirectory(atPath: imagesDirectory!.path(percentEncoded: false))
        {
            for image in content
            {

                do
                {
                    let imagePath = imagesDirectory?.appending(component: image)
                    try fileManger.removeItem(at: imagePath!)
                }catch
                {

                    print(error.localizedDescription)
                    break
                }

            }
        }
    }
}
