//
//  SetSchedule.swift
//  BCP Schedule
//
//  Created by Kevin Vincent on 10/21/14.
//  Copyright (c) 2014 bcp. All rights reserved.
//

import UIKit

class SetSchedule: UIViewController {
    @IBOutlet var c1: UITextField!
    @IBOutlet var c2: UITextField!
    @IBOutlet var c3: UITextField!
    @IBOutlet var c4: UITextField!
    @IBOutlet var c5: UITextField!
    @IBOutlet var c6: UITextField!
    @IBOutlet var c7: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        var error: NSError?
        var data: String = String(NSUserDefaults.standardUserDefaults().objectForKey("classlist")! as String)
        var AsArray = JSONParseArray(data)
        c1.text = AsArray[0] as String;
        c2.text = AsArray[1] as String;
        c3.text = AsArray[2] as String;
        c4.text = AsArray[3] as String;
        c5.text = AsArray[4] as String;
        c6.text = AsArray[5] as String;
        c7.text = AsArray[6] as String;
    }
    
    @IBAction func DoneAction(sender: AnyObject) {
        //Action before switch
        var cArray = [c1.text, c2.text, c3.text, c4.text, c5.text, c6.text, c7.text]
        var toStore:String = JSONStringify(cArray, prettyPrinted: false)
        NSUserDefaults.standardUserDefaults().setObject(toStore, forKey: "classlist")
        NSUserDefaults.standardUserDefaults().synchronize();
        
        //Switch
        let vc: AnyObject? = self.storyboard?.instantiateViewControllerWithIdentifier("Main")
        self.showViewController(vc as ViewController, sender: vc)
    }
    
    func JSONParseArray(jsonString: String) -> [AnyObject] {
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
                return array
            }
        }
        return [AnyObject]()
    }
    
    
    func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string
                }
            }
        }
        return ""
    }
}
