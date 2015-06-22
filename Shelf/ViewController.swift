//
//  ViewController.swift
//  shelf
//
//  Created by Ner on 6/18/15.
//
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var showAnswer: UILabel!
    @IBOutlet weak var textField: UITextField!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    //wrap the question into a json request
    func wrapQuestion(questionText : String) -> String{
        var jasonRequest : String
        jasonRequest = "{\"question\":{\"questionText\":\"" + questionText + "\"}}"
        
        return jasonRequest
    }
    
    
    
    //wrap the json request into a http post
    func postRequest(jsonRequest: String){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://watson-wdc01.ihost.com/instance/542/deepqa/v1/question")!)
        request.HTTPMethod = "POST"
        let postString = wrapQuestion(jsonRequest)
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("30", forHTTPHeaderField:"X-SyncTimeOut")
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let userPasswordString = "coop_student2:QrMsG1Sr"
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions(nil)
        let authString = "Basic \(base64EncodedCredential)"
        config.HTTPAdditionalHeaders = ["Authorization" : authString]
        let session = NSURLSession(configuration: config)
        
        request.setValue(authString, forHTTPHeaderField: "Authorization")
        //request.setValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        
        
        //let task = session.dataTaskWithRequest(request) {
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            //println("response = \(response)")
            
            self.showAnswer.text = self.parseJSON(data)
        }
        
        task.resume()
    }
    
    
    //Parse the JSON response
    func parseJSON(data:NSData)->String{
        var texts = [String]()
        var jsonError: NSError?
        
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? [String: AnyObject],
        question = json["question"] as? [String:AnyObject],
        answers = question["answers"] as? [[String:AnyObject]]
        
        {
            for answer in answers{
                
                if let words = answer["text"] as? String{
                    texts.append(words)
                }
                
            }
            println(texts[0])
            // this code is executed if the json is a dictionary AND
            // the "feed" is a dictionary AND
            // the "entry" is an array of dictionaries
        } else {
            println("I don't think so")
            // otherwise, this code is executed
        }
        return texts[0]
    }
    
    @IBAction func search(sender: AnyObject) {
        
        
        postRequest(textField.text)
        
    }

    
    
    
    
    
    /**   //
    func parseAnswer(){
    
    }
    */
    
}