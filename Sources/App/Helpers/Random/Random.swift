#if os(Linux)
import Glibc
#else
import Foundation
#endif

struct Random {
    
    #if os(Linux)
    static var initialized = false
    #endif
    
    static func roll(max: Int) -> Int {
        #if os(Linux)
        if !Random.initialized {
            srandom(UInt32(time(nil)))
            Random.initialized = true
        }
        
        return Int(random() % max)
        #else
        return Int(arc4random_uniform(UInt32(max)))
        #endif
    }
}
