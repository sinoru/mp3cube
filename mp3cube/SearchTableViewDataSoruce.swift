//
//  SearchTableViewDataSoruce.swift
//  mp3cube
//
//  Created by 강재홍 on 2017. 7. 22..
//  Copyright © 2017년 kokonoe. All rights reserved.
//

import UIKit
import Alamofire

private let cellReuseIdentifier = "cell"

private let pattern = "</i>&nbsp;(.*)</td>"
private let pattern_artist = "rel=\"nofollow\">(.*)</a>"

class SearchTableViewDataSoruce: NSObject {

    var tblData: [String] = []
    var tblDataArtist: [String] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewController: SearchViewController!

    func search(name: String) {
        self.tblData.removeAll()
        self.tblDataArtist.removeAll()
        self.tableView.reloadData()

        var url = "http://mp3cube.net/search/"
        let encodeQuery = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        url = url + encodeQuery! + ".html"

        Alamofire.request(url)
            .responseString { response in
                switch response.result {
                case .success(let value):
                    var music_name = value.matchingStrings(regex: pattern)
                    var music_artist = value.matchingStrings(regex: pattern_artist)
                    if music_name.count == 0 {
                        let alertError = UIAlertController(title: "Error",
                                                           message: "해당되는 음악이 없습니다.",
                                                           preferredStyle: UIAlertControllerStyle.alert)
                        alertError.addAction(UIAlertAction(title: "확인",
                                                           style: UIAlertActionStyle.default,
                                                           handler: nil))
                       self.viewController.present(alertError, animated: true, completion: nil)
                    } else {
                        self.tableView.beginUpdates()
                        for i in 0..<music_name.count {
                            self.tblData.append(music_name[i][1])
                            self.tblDataArtist.append(music_artist[i][1])
                            self.tableView.insertRows(at: [IndexPath(row: self.tblData.count - 1,
                                                                     section: 0)], with: .automatic)
                        }
                        self.tableView.endUpdates()
                    }
                case .failure(_):
                    self.viewController.errorNetwork()
                }
        }
    }
}

extension SearchTableViewDataSoruce: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tblData.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! SearchTableViewCell

        cell.myTitle?.text = self.tblData[indexPath.row]
        cell.myArtist?.text = self.tblDataArtist[indexPath.row]

        return cell
    }
}
