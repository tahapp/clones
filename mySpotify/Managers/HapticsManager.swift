//
//  HapticsManager.swift
//  mySpotify
//
//  Created by ben hussain on 12/6/23.
//

import UIKit

final class HapticsManager
{
    static let shared = HapticsManager()
    private init(){}
    
    func vibrateForSelection()
    {
        
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }

    }
    func vibrate(of type: UINotificationFeedbackGenerator.FeedbackType)
    {
        DispatchQueue.main.async {
            let genertor = UINotificationFeedbackGenerator()
            genertor.prepare()
            genertor.notificationOccurred(type)
        }

    }
}


