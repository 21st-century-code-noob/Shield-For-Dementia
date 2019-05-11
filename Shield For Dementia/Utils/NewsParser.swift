//
//  XMLParser.swift
//  Shield For Dementia Carer
//
//  Created by 彭孝诚 on 2019/5/10.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import Foundation

struct News{
    var title: String
    var description: String
    var pubDate: String
    var imageLink: String
    var link: String
    
}

class NewsParser: NSObject, XMLParserDelegate{
    private var Newses:[News] = []
    private var currentElement = ""
    private var currentTitle: String = ""{
        didSet{
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentDesc: String = ""{
        didSet{
            currentDesc = currentDesc.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubDate: String = ""{
        didSet{
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentImageUrl: String = ""
    {
        didSet{
            currentImageUrl = currentImageUrl.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentLink: String = ""
    {
        didSet{
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var parserCompleteHandler: (([News]) -> Void)?
    
    func parseFeed(url: String, completionHandler:(([News]) -> Void)?){
        CBToast.showToastAction()
        self.parserCompleteHandler = completionHandler
        completionHandler!(Newses)
        
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else{
                if let error = error{
                    print(error)
                }
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            DispatchQueue.main.sync {
                CBToast.hiddenToastAction()
            }
        }
        task.resume()
    }
    
    //XML parser delegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item"{
            currentTitle = ""
            currentDesc = ""
            currentPubDate = ""
            currentLink = ""
            currentImageUrl = ""
        }
        if currentElement == "media:thumbnail"{
            if let imageUrl = attributeDict["url"]{
                currentImageUrl = imageUrl
                print(imageUrl)
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement{
        case "title": currentTitle += string
        case "description": currentDesc += string
        case "pubDate": currentPubDate += string
        case "link": currentLink += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item"{
            let newsItem = News(title: currentTitle, description: currentDesc, pubDate: currentPubDate, imageLink: currentImageUrl, link: currentLink)
            self.Newses.append(newsItem)
            currentImageUrl = ""
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompleteHandler?(Newses)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
    
    
    
}
