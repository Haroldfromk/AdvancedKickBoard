//
//  MapManager.swift
//  Bean-scooter-app
//
//  Created by Dongik Song on 4/24/24.
//

import Foundation
import Alamofire

protocol SendData: AnyObject {
    func sendData (data: MapModel?)
}

class MapManager {
    // Alamofire 사용.
    
    weak var delegate: SendData?
    
    func fetchRequest(textString: String, completion: @escaping (Result<MapModel, Error>) -> Void) {
        let url = "https://dapi.kakao.com/v2/local/search/address.json"
        let header: HTTPHeaders = ["Authorization" : "KakaoAK API_Key"]
        let parameter = ["query" : textString]
        
        AF.request(url, method: .get, parameters: parameter, headers: header).responseDecodable(of: MapModel.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    // MARK: - 데이터전달 두가지 방식 사용, 1. Escaping Closure 2. Delegate
    
    // Escaping Closure로 전달 + Component(x)
    func fetchRequestWithSession(completion: @escaping (Result<MapModel, Error>) -> Void) {
            
            let urlString = "https://dapi.kakao.com/v2/local/search/address.json"
            if let url = URL(string: urlString) {
                
                //var urlComponent = URLComponents(string: urlString)
                //urlComponent?.queryItems = [URLQueryItem(name: "query", value: "전북 삼성동 100")]
                
                //let urlforrequest = urlComponent?.url
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.url?.append(queryItems: [URLQueryItem(name: "query", value: "전북 삼성동 100")])
                request.setValue("KakaoAK API_Key", forHTTPHeaderField: "Authorization")
               
                
                let urlSession = URLSession(configuration: .default)
                
                let task = urlSession.dataTask(with: request) { (data, response, error) in
                    if let e = error {
                        completion(.failure(e))
                    }
                    
                    if let safeData = data {
                        if let decodedData = self.decodingJson(data: safeData) {
                            completion(.success(decodedData))
                            
                        } else {
                            print("decoding fail")
                        }

                    }
                }
                task.resume()
            }
            
        }
     
    // Delegate로 전달. + component (일반적으로 구글링 했을때의 방식)
    func fetchRequestWithDelegate (textString: String) {
        let urlString = "https://dapi.kakao.com/v2/local/search/address.json"
        if let url = URL(string: urlString) {
            
            var urlComponent = URLComponents(string: urlString)
            urlComponent?.queryItems = [URLQueryItem(name: "query", value: textString)]
            
            let urlforrequest = urlComponent?.url
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("KakaoAK API_Key", forHTTPHeaderField: "Authorization")
                       
            let urlSession = URLSession(configuration: .default)
            
            let task = urlSession.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    self.delegate?.sendData(data: nil)
                }
                
                if let safeData = data {
                    if let decodedData = self.decodingJson(data: safeData) {
                        self.delegate?.sendData(data: decodedData)

                        
                    } else {
                        print("decoding fail")
                    }

                }
            }
            task.resume()
        }
        
    }
    
    
        func decodingJson (data: Data) -> MapModel? {
            
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(MapModel.self, from: data)
                let documents = decodedData.documents
                let address = documents[0].addressName
                let x = documents[0].x
                let y = documents[0].y
                
                let list: MapModel = MapModel(documents: [Document(addressName: address, x: x, y: y)])
                
                return list
                
            } catch {
                print(error)
                
                return nil
            }
            
        }
}



