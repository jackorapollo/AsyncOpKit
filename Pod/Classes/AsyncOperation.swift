/// AsyncOperation takes care of the boilerplate you need for writing asynchronous NSOperations and adds a couple of useful features: An optional results handler that includes the operation, and properties to store results of the operation. 

public class AsyncOperation: NSOperation, AsyncOperationObjectProtocol {
    
    /// The resultsHandler is fired once when the operation finishes on the queue specified by `resultsHandlerQueue`. It passes in the finished operation which will indicate whethere the operation was cancelled, had an error, or has a value.
    public var resultsHandler: ((finishedOp: AsyncOperationObjectProtocol) -> Void)?
    
    /// The operation queue on which the results handler will fire. Default is mainQueue.
    public var resultsHandlerQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    
    /// Override main to start potentially asynchronous work. When the operation is complete, you must call finish(). Do not call super.
    /// This method will not be called it the operation was cancelled before it was started.
    override public func main() {
        finish()
    }
    
    // use this property to store the results of your operation. You can also declare new properties in subclasses
    public var value: AnyObject?
    
    // use this property to store any error about your operation
    public var error: NSError?
    
    // MARK: Async Operation boilerplate. For more information, read the Concurrency Programming Guide for iOS or OS X.
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
        
        dispatch_async(qualityOfService.getGlobalDispatchQueue(), {
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