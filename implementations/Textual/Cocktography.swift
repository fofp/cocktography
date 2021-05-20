import Foundation

@objc
class Plugin: NSObject, THOPluginProtocol {
	@objc
	let subscribedServerInputCommands = ["privmsg"]
    
    @objc
    let subscribedUserInputCommands = ["enchode", "enchodes"]

	@objc
	func didReceiveServerInput(_ inputObject: THOPluginDidReceiveServerInputConcreteObject, on client: IRCClient) {
		handleIncomingPrivateMessageCommand(inputObject, on: client)
	}

    @objc
    func userInputCommandInvoked(on client: IRCClient, command commandString: String, messageString: String) {
        var theString = messageString
        let currentChannel = client.lastSelectedChannel
        var stroke = 2
        
        if (commandString.lowercased() == "enchodes") {
            let split = theString.split(separator: " ")
            
            if (split.count > 0) {
                if ("\(split.first!)".isNumber) {
                    stroke = Int("\(split.first!)")!

                    theString = split.dropFirst().joined(separator: " ")
                }
            }
        }

        let enchodedMessages = enchode(message: theString, stroke: stroke)

        performBlock(onMainThread: {
            for enchodedMessage in enchodedMessages {
                client.sendPrivmsg(enchodedMessage, to: currentChannel!)
            }
            
            let newMessage = "\(client.userNickname) (Dechoded): \(theString)"
            client.printDebugInformation(newMessage, in: currentChannel!)
        })
    }
    
	func handleIncomingPrivateMessageCommand(_ inputObject: THOPluginDidReceiveServerInputConcreteObject, on client: IRCClient) {
		let messageReceived = inputObject.messageSequence
		let messageParamaters = inputObject.messageParamaters
		let messageSender = inputObject.senderNickname

        var senderChannel = client.findChannel(messageParamaters[0])
        if (senderChannel?.isChannel != true) {
            if (messageReceived.prefix(1) != "\u{01}") {
                performBlock(onMainThread: {
                    senderChannel = client.findChannelOrCreate(messageSender, isPrivateMessage: true)
                })
            }
        }
        
        if (isEnchoded(message: messageReceived)) {
            if (isFirstMessage(message: messageReceived)) {
                Cocktography.dechodes[messageSender] = ""
            }
            if (dechode(nick: messageSender, message: messageReceived, client: client)) {
                let newMessage = "\(messageSender) (Dechoded): \(Cocktography.dechodes[messageSender]!)"
                
                performBlock(onMainThread: {
                    client.printDebugInformation(newMessage, in: senderChannel!)
                })
                
                Cocktography.dechodes[messageSender] = ""
            }
        }
	}
    
    func isFirstMessage(message: String) -> Bool {
        let split = message.split(separator: " ")
        
        if (split.count > 0) {
            if ("\(split.first!)" == "\((Cocktography.dechoder as NSDictionary).allKeys(for: "start").first!)") {
                return true
            }
        }
        return false
    }
  
    func isEnchoded(message: String) -> Bool {
        let split = message.split(separator: " ")
        
        if (split.count > 0) {
            if ("\(split.first!)" == "\((Cocktography.dechoder as NSDictionary).allKeys(for: "start").first!)" || "\(split.first!)" == "\((Cocktography.dechoder as NSDictionary).allKeys(for: "mark").first!)") {
                if ("\(split.last!)" == "\((Cocktography.dechoder as NSDictionary).allKeys(for: "stop").first!)" || "\(split.last!)" == "\((Cocktography.dechoder as NSDictionary).allKeys(for: "cont").first!)") {
                    return true
                }
            }
        }
        return false
    }
    
    func dechode(nick: String, message: String, client: IRCClient) -> Bool {
        if (Cocktography.wideDechoder.count < 1) {
            for bundle in Bundle.allBundles {
                if ((bundle.bundlePath.range(of: "Cocktography.bundle")) != nil) {
                    if let path = bundle.path(forResource: "wideDechoder", ofType: "txt") {
                        do {
                            let data = try String(contentsOfFile: path, encoding: .utf8)
                            let myStrings = data.components(separatedBy: .newlines)
                            for chode in myStrings {
                                if (chode.count > 0) {
                                    Cocktography.wideDechoder.append(chode)
                                }
                            }
                        }
                        catch {}
                    }
                }
            }
        }
        
        let split = message.split(separator: " ")
        
        if (!(Cocktography.dechodes.index(forKey: nick) != nil)) {
            Cocktography.dechodes[nick] = ""
        }
        
        for chode in split {
            if let theIndex = Cocktography.dechoder.index(forKey: String(chode)) {
                let dechoded = Cocktography.dechoder[theIndex].value
                
                if (dechoded.count == 1) {
                    Cocktography.dechodes[nick] = Cocktography.dechodes[nick]! + dechoded
                }
            }
            else if let theIndex = Cocktography.wideDechoder.index(of: String(chode)) {
                let first = UInt8(theIndex >> 8)
                let second = UInt8(theIndex & 0xFF)
                
                if let string = String(bytes: [first, second], encoding: .utf8) {
                    if (string.count > 0) {
                        Cocktography.dechodes[nick] = Cocktography.dechodes[nick]! + string
                    }
                }
            }
        }
        
        if (isTheEnd(message: message)) {
            let theMessage = Cocktography.dechodes[nick]!
            var finishedString = theMessage
            
            var stroke = 0
            if let decoded = theMessage.base64Decoded() {
                finishedString = decoded
                stroke += 1
                
                if (finishedString.prefix(1) != "\u{0F}") {
                    while (finishedString.prefix(1) != "\u{0F}") {
                        if (stroke >= 20) {
                            Cocktography.dechodes[nick] = ""
                            return false
                        }
                        
                        if (finishedString.count % 4 != 0) {
                            Cocktography.dechodes[nick] = ""
                            return false
                        }
                        
                        let regex = try! NSRegularExpression(pattern: "^[-A-Za-z0-9\\+\\/\\=]+|=[^=]|={3,}$")
                        let results = regex.matches(in: finishedString, options: [], range: NSRange(finishedString.startIndex..., in: finishedString))
                        if (results.count == 0) {
                            Cocktography.dechodes[nick] = ""
                            return false
                        }
                        
                        if let decoded = finishedString.base64Decoded() {
                            finishedString = decoded
                        }
                        stroke += 1
                    }
                }
            }
            Cocktography.dechodes[nick] = finishedString
            return true
        }
        return false
    }
    
    func isTheEnd(message: String) -> Bool {
        let split = message.split(separator: " ")
        
        if ("\(split.last!)" == "\((Cocktography.dechoder as NSDictionary).allKeys(for: "stop").first!)") {
            return true
        }
        return false
    }
    
    func enchode(message: String, stroke: Int) -> [String] {
        let START = (Cocktography.dechoder as NSDictionary).allKeys(for: "start").first!
        let STOP = (Cocktography.dechoder as NSDictionary).allKeys(for: "stop").first!
        let MARK = (Cocktography.dechoder as NSDictionary).allKeys(for: "mark").first!
        let CONT = (Cocktography.dechoder as NSDictionary).allKeys(for: "cont").first!
        
        let splitAt = 340
        
        var enchoded:[String] = []
        
        let original = "\u{0F}\(message)"
        var stroked = original

        if (stroke > 0) {
            for i in 1...stroke {
                stroked = stroked.base64Encoded()!
            }
        }
        
        var choded = ""
        for char in stroked {
            if ((Cocktography.dechoder as NSDictionary).allKeys(for: "\(char)").count > 0) {
                choded += "\((Cocktography.dechoder as NSDictionary).allKeys(for: "\(char)").first!) "
            }
        }
        
        if (choded.count < splitAt) {
            return ["\(START) \(choded.trimmingCharacters(in: .whitespacesAndNewlines)) \(STOP)"]
        }
        else {
            let split = splitString(string: choded, by: splitAt)
            
            var c = 0
            for line in split {
                var thisLine = ""
                if (c == 0) {
                    thisLine += "\(START) "
                }
                else {
                    thisLine += "\(MARK) "
                }
                
                thisLine += "\(line.trimmingCharacters(in: .whitespacesAndNewlines))"
                
                if (c == (split.count - 1)) {
                    thisLine += " \(STOP)"
                }
                else {
                    thisLine += " \(CONT)"
                }
                
                enchoded.append(thisLine)
                c += 1
            }
        }
        
        return enchoded
    }
    
    func splitString(string: String, by: Int) -> [String] {
        var split:[String] = []
        
        let regex = try! NSRegularExpression(pattern: "\\G\\s*(.{1,\(by)})(?=\\s|$)")
        let results = regex.matches(in: string, options: [], range: NSRange(string.startIndex..., in: string))
        
        if (results.count > 0) {
            for result in results {
                let match = String(string[Range(result.range, in: string)!])
                
                split.append(match)
            }
        }
        
        return split
    }
}

struct Cocktography {
    static var dechodes:[String:String] = [:]
    static var dechoder:[String:String] = [
        "8=D": "e", "8==D": "o", "8===D": "d", "8====D": "D", "8=D~": "E", "8==D~": "i", "8===D~": "l", "8====D~": "L", "8=D~~": "w", "8==D~~": "W", "8===D~~": "g", "8====D~~": "G", "8=D~~~": "c", "8==D~~~": "C", "8===D~~~": "f", "8====D~~~": "F", "8=D~~~~": "u", "8==D~~~~": "U", "8===D~~~~": "m", "8====D~~~~": "M", "8wD": "t", "8w=D": "a", "8w==D": "H", "8w===D": "y", "8wD~": "T", "8w=D~": "n", "8w==D~": "Y", "8w===D~": "p", "8wD~~": "P", "8w=D~~": "b", "8w==D~~": "B", "8w===D~~": "�", "8wD~~~": "h", "8w=D~~~": "1", "8w==D~~~": "!", "8w===D~~~": "2", "8wD~~~~": "@", "8w=D~~~~": "3", "8w==D~~~~": "#", "8w===D~~~~": "4", "8=wD": "A", "8=w=D": "$", "8=w==D": "5", "8=wD~": "%", "8=w=D~": "6", "8=w==D~": "^", "8=wD~~": "7", "8=w=D~~": "&", "8=w==D~~": "8", "8=wD~~~": "*", "8=w=D~~~": "9", "8=w==D~~~": "(", "8=wD~~~~": "0", "8=w=D~~~~": ")", "8=w==D~~~~": "-", "8==wD": "R", "8==w=D": "_", "8==wD~": "+", "8==w=D~": "=", "8==wD~~": ", ", "8==w=D~~": "<", "8==wD~~~": ".", "8==w=D~~~": ">", "8==wD~~~~": "/", "8==w=D~~~~": "?", "8===wD": ";", "8===wD~": ":", "8===wD~~": "\"", "8===wD~~~": "\'", "8===wD~~~~": "[", "8mD": " ", "8m=D": "O", "8m==D": "{", "8m===D": "]", "8mD~": "I", "8m=D~": "N", "8m==D~": "r", "8m===D~": "v", "8mD~~": "V", "8m=D~~": "k", "8m==D~~": "K", "8m===D~~": "j", "8mD~~~": "J", "8m=D~~~": "x", "8m==D~~~": "X", "8m===D~~~": "q", "8mD~~~~": "Q", "8m=D~~~~": "z", "8m==D~~~~": "Z", "8m===D~~~~": "`", "8=mD": "s", "8=m=D": "S", "8=m==D": "}", "8=mD~": "\\", "8=m=D~": "|", "8=m==D~": "~", "8wm===D": "\u{0F}", "8=wm=D": "start", "8=mw=D": "stop", "8=ww=D": "cont", "8wmD": "mark"
    ]
    static var wideDechoder:[String] = []
}
