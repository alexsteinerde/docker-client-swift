import Foundation
import NIO

struct DockerStream {
    /// Extracts a log entry/line for a container not having a TTY
    static func getEntryNoTty(buffer: inout ByteBuffer, timestamps: Bool) throws -> DockerLogEntry {
        let timestampLen = timestamps ? 31 : 0
        
        guard let sourceRaw: UInt8 = buffer.readInteger(endianness: .big, as: UInt8.self) else {
            throw DockerLogDecodingError.dataCorrupted("Unable to read log entry source stream header")
        }
        let msgSource = DockerLogEntry.Source.init(rawValue: sourceRaw) ?? .stdout
        let _ = buffer.readBytes(length: 3) // 3 unused bytes
        
        guard let msgSize: UInt32 = buffer.readInteger(endianness: .big, as: UInt32.self) else {
            throw DockerLogDecodingError.dataCorrupted("Unable to read log size header")
        }
        
        guard msgSize > 0 else {
            throw DockerLogDecodingError.noMessageFound
        }
        if buffer.readableBytes < msgSize {
            // TODO: does this happen during normal logs streaming behavior?
            throw DockerLogDecodingError.dataCorrupted("Readable bytes (\(buffer.readableBytes)) is less than msgSize (\(msgSize))")
        }
        
        var timestamp: Date? = nil
        var msgBuffer = ByteBuffer.init(bytes: buffer.readBytes(length: Int(msgSize))!)
        if timestamps {
            guard let timestampRaw = msgBuffer.readString(length: timestampLen, encoding: .utf8) else {
                throw DockerLogDecodingError.noTimestampFound
            }
            guard let timestampTry = GetContainerLogsEndpoint.formatter.date(from: String(timestampRaw)) else {
                throw DockerLogDecodingError.timestampCorrupted
            }
            timestamp = timestampTry
        }
        guard let message = msgBuffer.readString(length: msgBuffer.readableBytes - 1, encoding: .utf8) else {
            throw  DockerLogDecodingError.dataCorrupted("Unable to parse log message as String")
        }
        
        return DockerLogEntry(source: msgSource, timestamp: timestamp, message: message)
    }
    
    /// Extracts a log entry/line for a container having a TTY
    static func getEntryTty(buffer: inout ByteBuffer, timestamps: Bool) throws -> [DockerLogEntry] {
        let timestampLen = timestamps ? 31 : 0
        var logEntries: [DockerLogEntry] = []
        
        let data = buffer.readData(length: buffer.readableBytes)!
        let lines = data.split(separator: 10 /* ascii code for \n */)
        for line in lines {
            var timestamp: Date? = nil
            var msgBuffer = ByteBuffer(data: line)
            if timestamps {
                guard let timestampRaw = msgBuffer.readString(length: timestampLen, encoding: .utf8) else {
                    throw DockerLogDecodingError.noTimestampFound
                }
                guard let timestampTry = GetContainerLogsEndpoint.formatter.date(from: String(timestampRaw)) else {
                    throw DockerLogDecodingError.timestampCorrupted
                }
                timestamp = timestampTry
            }
            guard let message = msgBuffer.readString(length: msgBuffer.readableBytes - 1, encoding: .utf8) else {
                throw  DockerLogDecodingError.dataCorrupted("Unable to parse log message as String")
            }
            
            logEntries.append(
                DockerLogEntry(source: .stdout, timestamp: timestamp, message: message)
            )
        }
        return logEntries
    }
}
