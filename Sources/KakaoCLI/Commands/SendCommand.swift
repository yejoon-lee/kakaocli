import ArgumentParser
import Foundation
import KakaoCore

struct SendCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "send",
        abstract: "Send a message via UI automation"
    )

    @Argument(help: "Chat name to send to (substring match), or any value with --self")
    var chat: String

    @Argument(help: "Message text to send. Several messages are sent in order in one chat-window session.")
    var messages: [String]

    @Option(name: .long, help: "With several messages: minimum random pause between them (seconds)")
    var minGap: Double = 1.0

    @Option(name: .long, help: "With several messages: maximum random pause between them (seconds)")
    var maxGap: Double = 3.0

    @Flag(name: [.customLong("me")], help: "Send to self-chat (나와의 채팅) regardless of chat argument")
    var selfChat = false

    @Flag(name: .long, help: "Show what would happen without actually sending")
    var dryRun = false

    func run() throws {
        let automator = KakaoAutomator()
        let target = selfChat ? "self-chat" : chat
        if dryRun {
            for m in messages { print("DRY RUN: Would send to '\(target)': \(m)") }
            print("Steps: activate KakaoTalk → find chat '\(target)' → open once → type each message + Enter (random \(minGap)-\(maxGap)s gaps)")
            return
        }
        guard !messages.isEmpty else { throw ValidationError("at least one message is required") }
        try automator.sendMessages(to: chat, messages: messages, selfChat: selfChat,
                                   minGap: minGap, maxGap: maxGap) { i in
            let ts = ISO8601DateFormatter().string(from: Date())
            print("[\(ts)] sent \(i + 1)/\(messages.count)")
            fflush(stdout)
        }
        print(messages.count == 1 ? "Message sent to '\(target)'." : "\(messages.count) messages sent to '\(target)'.")
    }
}
