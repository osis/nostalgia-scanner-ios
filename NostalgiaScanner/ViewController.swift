//
//  ViewController.swift
//  NostalgiaScanner
//
//  Created by Dwayne Forde on 2017-12-23.
//

import UIKit
import SafariServices

class ViewController: UIViewController, NostalgiaCameraDelegate {
    
    @IBOutlet var imgView: UIImageView!
    var camera: NostalgiaCamera!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        camera = NostalgiaCamera(controller: self, andImageView: imgView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        camera.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        camera.stop()
    }
    
    func matchedItem() {
        let safariController = SFSafariViewController(url: URL(string: "https://www.visitdublin.com/")!)
        present(safariController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

