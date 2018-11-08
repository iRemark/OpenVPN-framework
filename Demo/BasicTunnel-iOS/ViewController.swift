//
//  ViewController.swift
//  BasicTunnel-iOS
//
//  Created by Davide De Rosa on 2/11/17.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
//
//  This file is part of TunnelKit.
//
//  TunnelKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  TunnelKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with TunnelKit.  If not, see <http://www.gnu.org/licenses/>.
//
//  This file incorporates work covered by the following copyright and
//  permission notice:
//
//      Copyright (c) 2018-Present Private Internet Access
//
//      Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//      The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//

import UIKit
import NetworkExtension
import TunnelKit

private let ca = CryptoContainer(pem: """
-----BEGIN CERTIFICATE-----
MIIDKzCCAhOgAwIBAgIJANPD95WqQaAKMA0GCSqGSIb3DQEBCwUAMBMxETAPBgNV
BAMMCFNvZnRwbGV4MB4XDTE4MDkzMDAzNDE1N1oXDTI4MDkyNzAzNDE1N1owEzER
MA8GA1UEAwwIU29mdHBsZXgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQCjBT4cdeOfz4qjO0TFiS59JCrKHJOsrZKj2+si8XMsxeKZAB5HZhD9cRDNd/xp
7O6BzykUsIkq4GNy01amAzibcdz6W2fMWjWuASh99UfMkQ6WJjWciaJbA82Qknpm
LNCg7lJ79JsuHzO9DybeZZ1LbGS3xgtYbB5EwOUarNAHLNSYsYr0YsJHjNr6ceGs
M600wxMxaFx+zgtCtLA5iTNXEiLa9SvUOLF6a4B+VteMs+j+7Qh5ODYPKgvrIx0P
HJ7mwUkPip+t6IQZdd9lLfgZ6xiQEu+1EirwBJ8vpapky+GbEzpnXkcouCrxyUhk
Uzant9RfIaiw5p6gnAYtAC5/AgMBAAGjgYEwfzAdBgNVHQ4EFgQUx0DvjYO+xs1w
sGy38XCRUexO9sMwQwYDVR0jBDwwOoAUx0DvjYO+xs1wsGy38XCRUexO9sOhF6QV
MBMxETAPBgNVBAMMCFNvZnRwbGV4ggkA08P3lapBoAowDAYDVR0TBAUwAwEB/zAL
BgNVHQ8EBAMCAQYwDQYJKoZIhvcNAQELBQADggEBAH0zWl6pu143v5vI7qJD41OE
VIpjGc7GKBmICmecyprcDngNqnOeP5HoK8wlSjTiTDANWFc/1PyhZxNax5zQKiqZ
nFVD5SXJduavfXtU4cd0pi+CEOYpOHOQel4GCVYjxcUQyug8vX29UcxH1IJLdaaT
Eml1faI0qSsASaX5UCmhr4GBYffUrbLzIQok5yLZU56tu2xYlDoHaiJY+m0B9tZn
/Mjq+ExamBwbonTVGLI2NAJXJVETcKFdjF+ybyYrGKg/tuu6yEI7+b15zDHW9oGd
Sr/c/4ybj9QZrH25HqRQ/oxziYWTwABwMFqv8YXJ/hIRu1rjDEmscu1ShP00f4U=
-----END CERTIFICATE-----
""")

extension ViewController {
    private static let appGroup = "group.com.shoplex.vpn.pandavpn"
    
    private static let bundleIdentifier = "com.shoplex.pandavpn.newtunnel"
    
    private func url(withName name: String) -> URL {
        return Bundle(for: ViewController.self).url(forResource: name, withExtension: "ovpn")!
    }
    
    
    /**
        I want to configure this code with external files. How can I modify this place before I can connect?
     **/
    private func makeProtocol_2() -> NETunnelProviderProtocol {
        let server = textServer.text!
        let domain = textDomain.text!

        let hostname = ((domain == "") ? server : [server, domain].joined(separator: "."))
        let port = UInt16(textPort.text!)!
        let credentials = SessionProxy.Credentials(textUsername.text!, textPassword.text!)
 
        var sessionBuilder = SessionProxy.ConfigurationBuilder(ca: ca)
        sessionBuilder.cipher = .aes256cbc
        sessionBuilder.digest = .sha256
        sessionBuilder.compressionFraming = .compLZO
        sessionBuilder.renegotiatesAfter = nil
        sessionBuilder.usesPIAPatches = true
        var builder = TunnelKitProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
        let socketType: TunnelKitProvider.SocketType = .tcp
        
        
  
        builder.endpointProtocols = [TunnelKitProvider.EndpointProtocol(socketType, port)]
        builder.mtu = 1350
        builder.shouldDebug = true
        builder.debugLogKey = "Log"

        let configuration = builder.build()

        return try! configuration.generatedTunnelProtocol(
            withBundleIdentifier: ViewController.bundleIdentifier,
            appGroup: ViewController.appGroup,
            hostname: hostname,
            credentials: credentials
        )
    }
    
    
    
    
    private func makeProtocol() -> NETunnelProviderProtocol {
        
        let credentials = SessionProxy.Credentials("qisike", "qisike123456");
        let parsedFile = try? TunnelKitProvider.Configuration.parsed(fromURL: url(withName: "client-vps1"))
        let sessionConfig = parsedFile?.configuration.sessionConfiguration;
        var builder = TunnelKitProvider.ConfigurationBuilder(sessionConfiguration: sessionConfig!)
        builder.endpointProtocols = [TunnelKitProvider.EndpointProtocol(.tcp, UInt16("685")!)];
        builder.shouldDebug = true
        builder.debugLogKey = "Log"
        
        let configuration = builder.build()
        //222.128.104.134 683
        let hostname = "222.128.104.134";
        
        return try! configuration.generatedTunnelProtocol(
            withBundleIdentifier: ViewController.bundleIdentifier,
            appGroup: ViewController.appGroup,
            hostname: hostname,
            credentials: credentials
        )
    }
    
    
}




class ViewController: UIViewController, URLSessionDataDelegate {
    @IBOutlet var textUsername: UITextField!
    
    @IBOutlet var textPassword: UITextField!
    
    @IBOutlet var textServer: UITextField!
    
    @IBOutlet var textDomain: UITextField!
    
    @IBOutlet var textPort: UITextField!
    
    @IBOutlet var switchTCP: UISwitch!
    
    @IBOutlet var buttonConnection: UIButton!
    
    @IBOutlet var textLog: UITextView!
    
    //
    
    var currentManager: NETunnelProviderManager?
    
    var status = NEVPNStatus.invalid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textServer.text = "germany"
        textDomain.text = "privateinternetaccess.com"
        textPort.text = "1198"
        switchTCP.isOn = false
        textUsername.text = "myusername"
        textPassword.text = "mypassword"
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
        
        reloadCurrentManager(nil)
        
        //
        
        testFetchRef()
    }
    
    @IBAction func connectionClicked(_ sender: Any) {
        let block = {
            switch (self.status) {
            case .invalid, .disconnected:
                self.connect()
                
            case .connected, .connecting:
                self.disconnect()
                
            default:
                break
            }
        }
        
        if (status == .invalid) {
            reloadCurrentManager({ (error) in
                block()
            })
        }
        else {
            block()
        }
    }
    
    @IBAction func tcpClicked(_ sender: Any) {
        if switchTCP.isOn {
            textPort.text = "502"
        } else {
            textPort.text = "1198"
        }
    }
    
    func connect() {
        configureVPN({ (manager) in
            return self.makeProtocol()
        }, completionHandler: { (error) in
            if let error = error {
                print("configure error: \(error)")
                return
            }
            let session = self.currentManager?.connection as! NETunnelProviderSession
            do {
                try session.startTunnel()
            } catch let e {
                print("error starting tunnel: \(e)")
            }
        })
    }
    
    func disconnect() {
        configureVPN({ (manager) in
            return nil
        }, completionHandler: { (error) in
            self.currentManager?.connection.stopVPNTunnel()
        })
    }
    
    @IBAction func displayLog() {
        guard let vpn = currentManager?.connection as? NETunnelProviderSession else {
            return
        }
        try? vpn.sendProviderMessage(TunnelKitProvider.Message.requestLog.data) { (data) in
            guard let log = String(data: data!, encoding: .utf8) else {
                return
            }
            self.textLog.text = log
            
            print("💖 \(log)");
        }
    }
    
    func configureVPN(_ configure: @escaping (NETunnelProviderManager) -> NETunnelProviderProtocol?, completionHandler: @escaping (Error?) -> Void) {
        reloadCurrentManager { (error) in
            if let error = error {
                print("error reloading preferences: \(error)")
                completionHandler(error)
                return
            }
            
            let manager = self.currentManager!
            if let protocolConfiguration = configure(manager) {
                manager.protocolConfiguration = protocolConfiguration
            }
            manager.isEnabled = true
            
            manager.saveToPreferences { (error) in
                if let error = error {
                    print("error saving preferences: \(error)")
                    completionHandler(error)
                    return
                }
                print("saved preferences")
                self.reloadCurrentManager(completionHandler)
            }
        }
    }
    
    func reloadCurrentManager(_ completionHandler: ((Error?) -> Void)?) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let error = error {
                completionHandler?(error)
                return
            }
            
            var manager: NETunnelProviderManager?
            
            for m in managers! {
                if let p = m.protocolConfiguration as? NETunnelProviderProtocol {
                    if (p.providerBundleIdentifier == ViewController.bundleIdentifier) {
                        manager = m
                        break
                    }
                }
            }
            
            if (manager == nil) {
                manager = NETunnelProviderManager()
            }
            
            self.currentManager = manager
            self.status = manager!.connection.status
            self.updateButton()
            completionHandler?(nil)
        }
    }
    
    func updateButton() {
        switch status {
        case .connected :
            buttonConnection.setTitle("connected", for: .normal)
            
        case .connecting:
            buttonConnection.setTitle("connecting", for: .normal)
            
        case .disconnected:
            buttonConnection.setTitle("disconnected", for: .normal)
            
        case .disconnecting:
            buttonConnection.setTitle("disconnecting", for: .normal)
            
        default:
            break
        }
    }
    
    @objc private func VPNStatusDidChange(notification: NSNotification) {
        guard let status = currentManager?.connection.status else {
            print("VPNStatusDidChange")
            return
        }
        print("VPNStatusDidChange: \(status.rawValue)")
        self.status = status
        updateButton()
    }
    
    private func testFetchRef() {
        //        let keychain = Keychain(group: ViewController.APP_GROUP)
        //        let username = "foo"
        //        let password = "bar"
        //
        //        guard let _ = try? keychain.set(password: password, for: username) else {
        //            print("Couldn't set password")
        //            return
        //        }
        //        guard let passwordReference = try? keychain.passwordReference(for: username) else {
        //            print("Couldn't get password reference")
        //            return
        //        }
        //        guard let fetchedPassword = try? Keychain.password(for: username, reference: passwordReference) else {
        //            print("Couldn't fetch password")
        //            return
        //        }
        //
        //        print("\(username) -> \(password)")
        //        print("\(username) -> \(fetchedPassword)")
    }
}
