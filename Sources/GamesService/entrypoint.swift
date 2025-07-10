import Vapor
import Logging
import NIOCore
import NIOPosix

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = try await Application.make(env)
        
        do {
            print("----0----")
            try await configure(app)
            print("----1----")
            try await app.execute()
            print("----2----")
        } catch {
            print("----3----")
            app.logger.report(error: error)
            print("----4----")
            try? await app.asyncShutdown()
            print("----5----")
            throw error
        }
        print("----6----")
        try await app.asyncShutdown()
        print("----7----")
    }
}
