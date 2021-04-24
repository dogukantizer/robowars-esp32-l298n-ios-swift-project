import UIKit
import CoreBluetooth

var myPeripheal:CBPeripheral?
var myCharacteristic:CBCharacteristic?
var manager:CBCentralManager?

let serviceUUID = CBUUID(string: "ab0828b1-198e-4351-b779-901fa0e0371e")
//let periphealUUID = CBUUID(string: "528E6FB1-C3A5-3F66-620B-71C21BE727AB")

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    
    @IBOutlet weak var up1: UIButton!
    @IBOutlet weak var down1: UIButton!
    @IBOutlet weak var left1: UIButton!
    @IBOutlet weak var right1: UIButton!
    
    var up1flag = false
    var down1flag = false
    var left1flag = false
    var right1flag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        addLongPressGesture()
    }
    
    func addLongPressGesture(){
        
        let longPress1 = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress1.minimumPressDuration = 0
        self.up1.tag = 1
        self.up1.addGestureRecognizer(longPress1)
        
        let longPress2 = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress2.minimumPressDuration = 0
        self.down1.tag = -1
        self.down1.addGestureRecognizer(longPress2)
        
        let longPress3 = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress3.minimumPressDuration = 0
        self.left1.tag = -2
        self.left1.addGestureRecognizer(longPress3)
        
        let longPress4 = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress4.minimumPressDuration = 0
        self.right1.tag = 2
        self.right1.addGestureRecognizer(longPress4)
        
    }
    

    @IBAction func scanButtonTouched(_ sender: Any) {
        manager?.stopScan()
        manager?.scanForPeripherals(withServices:[serviceUUID], options: nil)
    }
    
    
    @IBAction func disconnectTouched(_ sender: Any) {
        manager?.cancelPeripheralConnection(myPeripheal!)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.identifier.uuidString == "528E6FB1-C3A5-3F66-620B-71C21BE727AB" {
            myPeripheal = peripheral
            myPeripheal?.delegate = self
            manager?.connect(myPeripheal!, options: nil)
            manager?.stopScan()
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Bluetooth is switched off")
        case .poweredOn:
            print("Bluetooth is switched on")
        case .unsupported:
            print("Bluetooth is not supported")
        default:
            print("Unknown state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([serviceUUID])
        print("Connected to " +  peripheral.name!)
        
        connectButton.isEnabled = false
        disconnectButton.isEnabled = true
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from " +  peripheral.name!)
        
        myPeripheal = nil
        myCharacteristic = nil
        
        connectButton.isEnabled = true
        disconnectButton.isEnabled = false
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        myCharacteristic = characteristics[0]
    }
    
   
    
    
    
    
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        
        guard let sender = gesture.view as? UIButton else {
            print("Sender is not a button")
            return
        }
    
        if gesture.state == UIGestureRecognizer.State.began {
            print("Long Press began")
            
            if(gesture.view?.tag == 1){
                
                self.up1.isEnabled = true
                self.down1.isEnabled = false
                
                up1flag = true
                down1flag = false
                
            } else if(gesture.view?.tag == -1){
                
                self.up1.isEnabled = false
                self.down1.isEnabled = true
                
                up1flag = false
                down1flag = true
                
            }
            
            if(gesture.view?.tag == -2){
                
                self.left1.isEnabled = true
                self.right1.isEnabled = false
                
                left1flag = true
                right1flag = false
                
            } else if(gesture.view?.tag == 2){
                
                self.left1.isEnabled = false
                self.right1.isEnabled = true
                
                left1flag = false
                right1flag = true
                
            }
            
            run()
            
        } else if gesture.state ==
                    UIGestureRecognizer.State.ended {
            print("Long Press end")
            
            if(gesture.view?.tag == 1 || gesture.view?.tag == -1 ){
                self.up1.isEnabled = true
                self.down1.isEnabled = true
                
                up1flag = false
                down1flag = false
            }
            
            if(gesture.view?.tag == 2 || gesture.view?.tag == -2){
                self.left1.isEnabled = true
                self.right1.isEnabled = true
                
                left1flag = false
                right1flag = false
            }
            
            run()
            
        }
    }
    
    
    func run(){
        
        var sol_motor_ileri = 0
        var sol_motor_geri = 0
        var sag_motor_ileri = 0
        var sag_motor_geri = 0
        
        if(up1flag){
            
            if(left1flag){
                
                sol_motor_ileri = 150
                sol_motor_geri = 0
                sag_motor_ileri = 250
                sag_motor_geri = 0
                
            } else if(right1flag){
                
                sol_motor_ileri = 250
                sol_motor_geri = 0
                sag_motor_ileri = 150
                sag_motor_geri = 0
                
            }  else {
                
                sol_motor_ileri = 250
                sol_motor_geri = 0
                sag_motor_ileri = 250
                sag_motor_geri = 0
            }
            
        } else if(down1flag){
            
            if(left1flag){
                
                sol_motor_ileri = 0
                sol_motor_geri = 150
                sag_motor_ileri = 0
                sag_motor_geri = 250
                
            } else if(right1flag){
                
                sol_motor_ileri = 0
                sol_motor_geri = 250
                sag_motor_ileri = 0
                sag_motor_geri = 150
                
            } else {
                
                sol_motor_ileri = 0
                sol_motor_geri = 250
                sag_motor_ileri = 0
                sag_motor_geri = 250
            }
            
        } else {
            
            if(left1flag){
                
                sol_motor_ileri = 0
                sol_motor_geri = 250
                sag_motor_ileri = 250
                sag_motor_geri = 0
                
            } else if(right1flag){
                
                sol_motor_ileri = 250
                sol_motor_geri = 0
                sag_motor_ileri = 0
                sag_motor_geri = 250
                
            }
        }
        
        
        let text = sag_motor_ileri.description + ";" + sag_motor_geri.description + ";" + sol_motor_ileri.description + ";" + sol_motor_geri.description + ";";
        if (myPeripheal != nil && myCharacteristic != nil) {
            let data = text.data(using: .utf8)
            myPeripheal!.writeValue(data!,  for: myCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        }
        print("sol_motor_ileri:" + sol_motor_ileri.description)
        print("sol_motor_geri:" + sol_motor_geri.description)
        print("sag_motor_ileri:" + sag_motor_ileri.description)
        print("sag_motor_geri:" + sag_motor_geri.description)
              
        print("*******")
    }
    
    
}


