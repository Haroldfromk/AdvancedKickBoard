//
//  MapController.swift
//  Bean-scooter-app
//
//  Created by 박중권 on 4/22/24.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView! // 필수.
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var rentButton: UIButton!
    
    @IBOutlet weak var returnButton: UIButton!
    
    let mapManager = MapManager()
    let coordGenerater = CoordGenerator()
    let dateFormatter = DateFormatter()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request: NSFetchRequest<PinData> = PinData.fetchRequest() // Coredata 전체 값을 가져오기 위한 Request
    
    var selectedAnnotation: MKPointAnnotation? // 선택된 Pin
    var isUsed: Bool = false // 유져가 킥보드를 이용하는지?
    var serialNumber: String = ""
    
    var locations: [CLLocationCoordinate2D] = [] // 거리 계산용 배열
    var modalViewController = ModalViewController() // 새로 보여줄 VC
    var dimmingView: UIView? // 어둡게 할 배경
    
    lazy var locationManager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.distanceFilter = 10
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        rentButton.isHidden = false
        
        
        rentButton.isHidden = true
        returnButton.isHidden = true
        
        mapView.delegate = self
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(refreshUI))
        self.mapView.addGestureRecognizer(gesture)
        
        addDimmingView()
        
        getDummy() // Coredata(Local) -> Array
        
        if SavedPinSingleton.shared.array.count == 0 {
            coordGenerater.makingDummyArray()
            getDummy()
            makingDummy() // Array -> Pin
        } else {
            makingDummy()
        }
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if SavedPinSingleton.shared.array.count == 0 {
            coordGenerater.makingDummyArray()
            getDummy()
            makingDummy()
        } else {
            refreshPinData()
        }
    }
    
    // MARK: - Making Dummy pins
    func makingDummy() {
        for i in SavedPinSingleton.shared.array.indices {
            let coordinate = CLLocationCoordinate2D(latitude: SavedPinSingleton.shared.array[i].y, longitude: SavedPinSingleton.shared.array[i].x)
            let serial = SavedPinSingleton.shared.array[i].id ?? "1A2B3C4D5E"
            addMark(coordinate: coordinate, serial: serial)
        }
    }
    
    func getDummy() {
        do {
            SavedPinSingleton.shared.array = try context.fetch(request)
        } catch {
            let alert = UIAlertController(title: "에러 발생", message: "데이터를 로드 하던 중 오류가 발생했습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Refresh Dummy Data
    func refreshPinData () {
        mapView.removeAnnotations(mapView.annotations)
        makingDummy()
    }
    
    
    // MARK: - Method for showing or hiding buttons
    // 대여의 상태를 보고 버튼을 숨기거나 보여줌
    func setbuttonHidden(isStatus: Bool) {
        
        if !isStatus {  // false 대여를 하지 않은 상태
            rentButton.isHidden = true
            returnButton.isHidden = true
        } else { // 대여를 한 상태라면
            rentButton.isHidden = true
            returnButton.isHidden = false
        }
    }
    
    // MARK: - Methods for Locations (MapView)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.startUpdatingLocation()
            updateLocationMap(to: location, with: "Current Location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "통신오류", message: "위치를 가져오는 중 \(error.localizedDescription) 가 발생했습니다", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateLocationMap(to location: CLLocation, with title: String?) {
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        // 값이 낮을 수록 고배율
        self.mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    
    // MARK: - Methods for Features (Rent, Return)
    
    //현재 위치로 이동 버튼
    @IBAction func moveCurrentLocationBtn(_ sender: UIButton) {
        updateLocationMap(to: locationManager.location ?? CLLocation(), with: "현재 위치")    }
    
    //대여 하기 버튼을 눌렀을 때의 동작 정의
    //대여 확인 얼럿 진행, 대여 최종 완료시 대여 종료 동작인 completedRent 함수 호출
    @IBAction func didTapRentButton(_ sender: Any) {
        let rentProcessAlert = UIAlertController(title: "대여 진행", message: "해당 킥보드를 이용하시겠습니까?", preferredStyle: .alert)
        
        let rent = UIAlertAction(title: "대여하기", style: .default) { _ in
            self.completedRent(didSelect: self.selectedAnnotation!)
            
            if let coordinate = self.selectedAnnotation?.coordinate {
                self.locations.append(coordinate) // 핀의 좌표를 배열에 저장.
                // 배열에 저장하는 이유는 거리를 계산하기 위해서.
            }
            
            DispatchQueue.main.async {
                
                self.isUsed = true
                self.setbuttonHidden(isStatus: self.isUsed)
                //self.mapView.removeAnnotations(self.mapView.annotations)
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        rentProcessAlert.addAction(cancel)
        rentProcessAlert.addAction(rent)
        present(rentProcessAlert, animated: true, completion: nil)
        
        
        
    }
    
    
    //대여 완료시의 동작 정의
    func completedRent(didSelect annotation: any MKAnnotation) {
        let pin = annotation
        mapView.removeAnnotation(pin)
    }
    
    // pin 추가.
    func addMark(coordinate: CLLocationCoordinate2D, serial: String) {
        
        let pin = MKPointAnnotation()
        let address = CLGeocoder.init() // 좌표를 기반으로 제공되는 Method를 사용하여 위치정보(주소를 가져옴)
        address.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (placemarks, error) in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            guard let address = placeMark else { return }
            
            pin.title = "기기번호: \(serial)" // 핀의 title
            pin.subtitle = "현재위치: \(address.thoroughfare ?? "Apple Store")" // 핀의 subtitle
            
            pin.coordinate = coordinate // 핀이 꽂힐 좌표. (좌표를 직접 설정해 주지않으면 안됨.)
            self.mapView.addAnnotation(pin) // 지도에 좌표를 추가.
        }
        
    }
    
    // 반납 버튼
    @IBAction func returnScooterBtn(_ sender: UIButton) {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() { // 유져의 위치서비스가 활성화 되어있을때
                self.locationManager.requestWhenInUseAuthorization() // 유져의 동의를 얻는 메서드.
                let currentLocation = self.locationManager.location // 현재 유져의 위치 좌표를 currentLocation에 저장.
                
                let serial = self.serialNumber // 제일 밑에 있는 메서드를 통해 저장을 해두었다가 사용.
                let slicedSerial = String(serial.suffix(10)) // "기기번호: 1A2B3C4D5E" -> 뒤에있는 10자리만 쓰겠다. -> 시리얼번호만 추출.
                self.addMark(coordinate: CLLocationCoordinate2D(latitude: currentLocation?.coordinate.latitude ?? 37.503702192, longitude: currentLocation?.coordinate.longitude ?? 127.025313873406), serial: slicedSerial)
                // 반납할때 유져의 위치를 사용하여 핀에 사용.
                //self.makingDummy()
                self.locations.append(currentLocation!.coordinate) // 반납할때 다시 배열에 저장 -> 거리계산하기위해서.
                //location 배열에는 처음에 유져가 대여할때의 좌표와, 반납할때의 좌표값 두개만 저장.
                
                
                // Coredata Section
                do {
                    let requestForPredicate: NSFetchRequest<PinData> = PinData.fetchRequest() // Request를 새로 만들어준다. filter 처리된 값
                    let predicate = NSPredicate(format: "id == %@", slicedSerial) // 해당 조건에 맞는 값만 가져오기 위해서(filter)
                    
                    requestForPredicate.predicate = predicate // 해당 쿼리문을 리퀘스트에 입력해준다.
                    SavedPinSingleton.shared.array.removeAll() // 미리 배열을 초기화를 해줌,
                    SavedPinSingleton.shared.array = try self.context.fetch(requestForPredicate) // 필터링된 값만 가져옴,
                    
                    if SavedPinSingleton.shared.array.count != 0 { // 존재한다면, 필터를 한 값이 있다면
                        
                        let filteredObject = SavedPinSingleton.shared.array[0] // first 쓸수있지만 옵셔널바인딩
                        
                        // 일종의 덮어쓰기로 보시면 됩니다. 값을 새로 입력해줍니다. 유져가 반납한 그당시 좌표 값을 Coredata에 전달.
                        filteredObject.setValue((currentLocation?.coordinate.longitude ?? 127.025313873406), forKey: "x")
                        filteredObject.setValue((currentLocation?.coordinate.latitude ?? 37.503702192), forKey: "y")
                        
                        do { // 변경사항이 생겼으니 저장.
                            try self.context.save()
                        } catch {
                            let alert = UIAlertController(title: "에러 발생", message: "데이터 저장 중 오류가 발생했습니다.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                    
                    
                } catch {
                    let alert = UIAlertController(title: "에러 발생", message: "데이터 저장 중 오류가 발생했습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                }
                self.getDummy() // 다시 배열에 값을 불러와주고 왜냐? 위에서 초기화를 했기에.
                self.makingDummy() // 배열에 있는 값을 가지고 다시 핀을 생성.
            }
            
        }
        isUsed = false // 유져가 사용이 끝났으니 true -> false로 바꿔줍니다.
        setbuttonHidden(isStatus: isUsed) // 버튼을 다시 안보이게합니다.
        
        let alert = UIAlertController(title: "반납완료", message: "킥보드 반납이 완료되었습니다.\n안녕히 가세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
        let distance = calculateTripDistance()
        let finTime = dateFormatter.string(from: Date())
        RecordSingleton.shared.array.append(RecordModel(distance: distance, time: finTime)) // 주행기록용 배열에 거리와, 날짜를 저장
        locations.removeAll() // 거리 계산후 배열 초기화.
        
    }
    
    // 거리계산 함수.
    func calculateTripDistance() -> Int{
        
        var total: Double = 0.0
        for i in 0..<locations.count - 1 { // 배열에 2개 대여할때의 좌표, 반납할때의 좌표
            let start = locations[i]
            let end = locations[i + 1]
            let distance = getDistance(from: start, to: end)
            total += distance
        }
        
        return Int(total)
    }
    
    // 거리계산은 애플에서 메서드를 제공합니다. distance
    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
    // MARK: - Methods for Gestures
    @objc func showbtn() {
        rentButton.isHidden = false
    }
    
    @objc func refreshUI(){
        setbuttonHidden(isStatus: isUsed)
    }
    
    @objc func showView() {
        
        let modalVC = self.modalViewController
        if let serialText = selectedAnnotation?.title, let addressText = selectedAnnotation?.subtitle {
            modalVC.addressText = addressText
            modalVC.serialText = serialText
            
        }
        
        
        
        // 사이드 메뉴 뷰 컨트롤러를 자식으로 추가하고 뷰 계층 구조에 추가.
        self.addChild(modalVC)
        self.view.addSubview(modalVC.view)
        
        let menuWidth = self.view.frame.width // 가로는 현재 화면과 동일하게
        let menuHeight = self.view.frame.height * 0.3 // 높이만 30%로 설정
        
        // 사이드 메뉴의 시작 위치를 화면 아래로 설정.
        modalVC.view.frame = CGRect(x: 0, y: view.frame.height, width: menuWidth, height: menuHeight)
        
        // 어두운 배경 뷰를 보이게 한다.
        self.dimmingView?.isHidden = false
        self.dimmingView?.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            // 사이드 메뉴를 화면에 표시.
            modalVC.view.frame = CGRect(x: 0, y: self.view.frame.height - menuHeight, width: menuWidth, height: menuHeight)
            // 어두운 배경 뷰의 투명도를 조절.
            self.dimmingView?.alpha = 0.5
        })
    }
    
    // MARK: - ModalView
    private func addDimmingView() {
        
        dimmingView = UIView(frame: self.view.bounds)
        dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView?.isHidden = true
        view.addSubview(dimmingView!)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap))
        dimmingView?.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func handleDimmingViewTap() {
        let modalVC = self.modalViewController
        
        UIView.animate(withDuration: 0.3, animations: {
            modalVC.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            self.dimmingView?.alpha = 0
        }) { (finished) in
            modalVC.view.removeFromSuperview()
            modalVC.removeFromParent()
            self.dimmingView?.isHidden = true
        }
    }
}


// MARK: - SearchBar
extension MapViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    // api를 호출. 파라미터는 서치바에 입력한 텍스트값을 파라미터로 받는다.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            mapManager.fetchRequest(textString: text) { result in
                switch result {
                case .success(let data): // 통신에 성공했을 때, 즉 값을 가져올때
                    if let lat = Double(data.documents[0].y), let lon = Double(data.documents[0].x) {
                        DispatchQueue.main.async {
                            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                            self.mapView.setRegion(region, animated: true) // 받은 좌표값으로 이동.
                        }
                        
                    }
                case .failure(let error): // 통신에 실패했을 때, 즉 뭔가 에러가 발생.
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "에러발생", message: "데이터 통신 중 \(error.localizedDescription) 이 발생했습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
            
        }
    }
}

// MARK: - AnnotationView
extension MapViewController: MKMapViewDelegate {
    
    // AnnotaionView 생성
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin")
        
        if annotationView == nil {
            // view 생성
            
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customPin")
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .infoLight)
            annotationView?.rightCalloutAccessoryView = btn
            let click = UITapGestureRecognizer(target: self, action: #selector(showbtn))
            annotationView?.addGestureRecognizer(click)
            let btnClick = UITapGestureRecognizer(target: self, action: #selector(showView))
            btn.addGestureRecognizer(btnClick)
            
            
        } else {
            annotationView?.annotation = annotation
        }
        
        // pin image 조절 및 등록
        let pinImage = UIImage(named: "scooterPin")
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        annotationView?.image = resizedImage
        
        return annotationView
    }
    
    // 100m 벗어나면 alert 표시
    func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
        
        let pin = annotation
        let currentLocation = mapView.userLocation.location
        
        guard let distance = currentLocation?.distance(from: CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)) else {
            fatalError("Can't get distance from Pin")
        }
        
        if distance > 150.0 {
            rentButton.isHidden = true
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "구역 외 킥보드 접근", message: "150m 를 넘어선 킥보드는 이용이 불가합니다.\n선택한 킥보드와의 거리는 \(Int(distance))m 입니다", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
        }
        
        if isUsed {
            rentButton.isHidden = true
        }
        
    }
    
    // 유져가 터치한 Annotation Pin 감지.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? MKPointAnnotation
        self.serialNumber = (view.annotation?.title!)! // 반납할때 시리얼 번호가 다시 입력이 되어야하기에 사용.
    }
    
}


extension MapViewController: SendData {
    func sendData(data: MapModel?) {
        DispatchQueue.main.async {
            if let lat = Double((data?.documents[0].y)!), let lon = Double((data?.documents[0].x)!) {
                DispatchQueue.main.async {
                    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    self.mapView.setRegion(region, animated: true) // 받은 좌표값으로 이동.
                }
                
            }
        }
    }
  
}
