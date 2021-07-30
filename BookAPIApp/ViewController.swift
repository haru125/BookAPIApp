//
//  ViewController.swift
//  BookAPIApp
//
//  Created by Satoshi Ota on 2021/07/24.
//

import UIKit

struct  ImageLinkJson: Codable {
       let smallThumbnail: URL?
   }
   // JSONのItem内のデータ構造
   struct VolumeInfoJson: Codable {
       // 本の名称
       let title: String?
       // 著者
       let authors: [String]?
       // 本の画像
       let imageLinks: ImageLinkJson?
   }
   // Jsonのitem内のデータ構造
   struct ItemJson: Codable {
       let volumeInfo: VolumeInfoJson?
   }

   // JSONのデータ構造
   struct ResultJson: Codable {
       // 複数要素
       let kind: String?
       let totalItems: Int?
       let items: [ItemJson]?
   }


class ViewController: UIViewController {
    
    private let cellId = "cellId"
    private var ItemJsons = [ItemJson]()
    
    let tableView: UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame.size = view.frame.size
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: cellId)
        navigationItem.title = "Book"
        searchBook(keyword: "")
    }
    
    func searchBook(keyword : String) {
            // 本のISBN情報をURLエンコードする
            guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
            }

            // リクエストURLの組み立て
            guard let req_url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(keyword)") else {
                return
            }
            print(req_url)

            // リクエストに必要な情報を生成
            let req = URLRequest(url: req_url)
            // データ転送を管理するためのセッションを生成
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            // リクエストをタスクとして登録
            let task = session.dataTask(with: req, completionHandler: {
                (data , response , error) in
                // セッションを終了
                session.finishTasksAndInvalidate()
                // do try catch エラーハンドリング
                do {
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    // 受け取ったJSONデータをパース(解析)して格納
                    let json = try decoder.decode(ResultJson.self, from: data!)
                    print(json)

                } catch {
                    // エラー処理
                    print("エラー？")
                    print(error)
                }
            })
            // ダウンロード開始
            task.resume()
        }

    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemJsons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BookTableViewCell
//        cell.qiita = VolumeInfoJson[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

class BookTableViewCell: UITableViewCell {
    
    var books: VolumeInfoJson? {
        didSet {
            bodyTextLabel.text = books?.title
            let url = URL(string: books?.title ?? "")
            do {
                let data = try Data(contentsOf: url!)
                let image = UIImage(data: data)
                userImageView.image = image
            }catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
    }
    
    let userImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        return iv
    }()
    
    let bodyTextLabel: UILabel = {
        let label = UILabel()
        label.text = "something in here"
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(userImageView)
        addSubview(bodyTextLabel)
        [
            userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            userImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.heightAnchor.constraint(equalToConstant: 50),
            
            bodyTextLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 20),
            bodyTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ].forEach{ $0.isActive = true }
        
        userImageView.layer.cornerRadius = 50 / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

