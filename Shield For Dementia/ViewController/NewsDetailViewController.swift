//
//  NewsDetailViewController.swift
//  Shield For Dementia Carer
//
//  Created by 彭孝诚 on 2019/5/10.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class NewsDetailViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var newsDetailWeb: WKWebView!
    @IBOutlet weak var addToFavButton: UIBarButtonItem!
    @IBOutlet weak var addToFavToolBar: UIToolbar!
    
    
    var news:News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfNewsIsFavorite()

        CBToast.showToastAction()
        newsDetailWeb.navigationDelegate = self
        let request = URLRequest(url: URL(string: news!.link)!)
        newsDetailWeb.load(request)
        newsDetailWeb.allowsBackForwardNavigationGestures = false
        newsDetailWeb.allowsLinkPreview = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        CBToast.hiddenToastAction()

    }
    

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        CBToast.hiddenToastAction()
    }
        /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func addToFavorite(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "NewsCoreData", in: context)
        let newsToAdd = NSManagedObject(entity: entity!, insertInto: context)
        newsToAdd.setValue(news!.title, forKey: "newsTitle")
        newsToAdd.setValue(news!.description, forKey: "newsDesc")
        newsToAdd.setValue(news!.link, forKey: "newsLink")
        newsToAdd.setValue(news!.pubDate, forKey: "newsPubDate")
        do {
            try context.save()
            CBToast.showToast(message:"Saved to favorite.", aLocationStr: "center", aShowTime: 2.0)
        } catch {
            print("Failed saving")
        }
    }
    
    func checkIfNewsIsFavorite(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsCoreData")
        request.predicate = NSPredicate(format: "newsLink = %@", news!.link)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            let newsList = result as! [NSManagedObject]
            if newsList.count != 0{
                addToFavToolBar.isHidden = true
            }
        } catch {
            print("Failed")
        }
    }
}

