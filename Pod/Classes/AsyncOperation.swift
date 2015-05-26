public class AsyncOperation: NSOperation, AsyncOperationObjectProtocol {
    
    public var resultsHandler: ((finishedOp: AsyncOperationObjectProtocol) -> Void)?
    public var resultsHandlerQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    
    override public func main() {
        // subclass this and kick off potentially asynchronous work
        // call finished = true when done
        // do not call super as super does nothing but finish the task
        // println("Error: \(self) Must subclass main to do anything useful")
        finish()
    }
    
    public var value: AnyObject? // use this property to store the results of your operation
    public var error: NSError? // use this property to store any error about your operation
    
    override public final var asynchronous: Bool {
        return true
    }
    
    override public final func start() {
        if cancelled {
            finish()
            return
        }
        
        if finished {
            return
        }
        
        willChangeValueForKey("isExecuting")
        
        dispatch_async(qualityOfService.globalDispatchQueue(), {
            if (!self.finished && !self.cancelled) {
                self.main()
            } else {
                self.finish()
            }
        })
        
        _executing = true
        didChangeValueForKey("isExecuting")
    }
    
    override public final var executing: Bool {
        get { return _executing }
    }
    
    override public final var finished: Bool {
        get { return _finished }
    }
    
    public final func finish() {
        
        if finished { return }
        
        if let resultsHandler = resultsHandler {
            
            self.resultsHandler = nil
            
            resultsHandlerQueue.addOperationWithBlock {
                resultsHandler(finishedOp: self)
            }
        }
        
        willChangeValueForKey("isFinished")
        willChangeValueForKey("isExecuting")
        _executing = false
        _finished = true
        didChangeValueForKey("isExecuting")
        didChangeValueForKey("isFinished")
        
    }
    
    private var _executing = false
    private var _finished = false
        
}