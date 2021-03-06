//
//  DetailViewController.swift
//  Homepwner
//
//  Created by James Roland on 9/15/15.
//  Copyright (c) 2015 LinkedIn. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBAction func backgroundTapped(sender: AnyObject) {
        view.endEditing(true)
    }
    

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var serialField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var cancelClosure: ( () -> Void)?
    var saveClosure: ( () -> Void)?
    var isNew: Bool = false {
        didSet {
            if isNew {
                let cancelItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
                navigationItem.leftBarButtonItem = cancelItem
                let doneItem = UIBarButtonItem(barButtonSystemItem: .Done,
                    target: self,
                    action: "save:")
                navigationItem.rightBarButtonItem = doneItem
            }
            else {
                navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
                navigationItem.rightBarButtonItem = nil
            }
        }
    }

    
    let item: Item
    let imageStore: ImageStore
    
    init(item: Item, imageStore: ImageStore) {
        self.item = item
        self.imageStore = imageStore
        super.init(nibName: "DetailViewController", bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        nameField.text = item.name
        if let sn = item.serialNumber {
            serialField.text = sn
        }
        valueField.text = "\(item.valueInDollars)"
        
        let date = item.dateCreated
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        dateLabel.text = dateFormatter.stringFromDate(date)
        
        let key = item.itemKey
        if let imageToDisplay = imageStore.imageForKey(key) {
            imageView.image = imageToDisplay
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
        
        updateItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func save(sender: AnyObject) {
        updateItem()
        saveClosure?()
    }
    
    func cancel(sender: AnyObject) {
        cancelClosure?()
    }
    
    func updateItem() {
        item.name = nameField.text
        item.serialNumber = serialField.text
        item.valueInDollars = valueField.text.toInt() ?? 0
    }
    
    @IBAction func takePicture(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
        }
        else {
            imagePicker.sourceType = .PhotoLibrary
        }
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.Popover
        imagePicker.popoverPresentationController?.barButtonItem =
        sender as! UIBarButtonItem
    
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        imageView.image = image
        imageStore.setImage(image, forKey: item.itemKey)
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
