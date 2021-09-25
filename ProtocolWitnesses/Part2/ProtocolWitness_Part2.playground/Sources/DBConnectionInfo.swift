import Foundation

public struct DBConnectionInfo {
    public let database: String
    public let hostname: String
    public let password: String
    public let port: Int
    public let user: String
    
    public init(
      database: String,
      hostname: String,
      password: String,
      port: Int,
      user: String
    ) {
        self.database = database
        self.hostname = hostname
        self.password = password
        self.port = port
        self.user = user
    }
}
