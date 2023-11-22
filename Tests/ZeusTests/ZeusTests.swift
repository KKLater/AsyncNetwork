import XCTest
@testable import Zeus
@testable import AsyncZeus

#if canImport(Async)
import Async
#endif

final class ZeusTests: XCTestCase {
#if canImport(Async)
    
    func testTask() -> AsyncTask<Any, any Error> {
        return AsyncTask<Any, any Error> { resultClosure in
            resultClosure(.failure(AsyncError.resultError))
        }
        
        // swift async 使用
    }

    func testSequentialRequestsOptions1() throws {
        Async.Task { operation in
            let result = operation.await { resultClosure in
                resultClosure(.failure(AsyncError.resultError))
            }
            
            switch result {
            case .success(let success):
                print(success)
            case .failure(let error):
                print(error)
            }
            
            let task = AsyncTask<Any, AsyncError> { resultClosure in
                resultClosure(.failure(AsyncError.resultError))
            }
            /// 
            /// func testTask() -> AsyncTask<Any, any Error> {
            ///     return AsyncTask<Any, any Error> { resultClosure in
            ///         resultClosure(.failure(AsyncError.resultError))
            ///     }
            /// }
            ///
            /// let task = testTask()
            let taskResult = operation.await(task)
            switch taskResult {
            case .success(let success):
                print(success)
            case .failure(let error):
                print(error)
            case .none:
                print("nill")
            }
            
            if let value = task.value {
                print(value)
            }
            
            if let error = task.error {
                print(error)
            }
        }
     
        expectation(timeout: 20, description: "testSequentialRequestsOptions") { expectation in
            Async.Task { operation in
            
                let id = "100"
                let token = "KNSkjdnjjasdasjkwklasdan"
                
                let getRequest = GetRequest(id: id, token: token).responseDecodeableTask()
                let getResult = operation.await(getRequest)
                switch getResult {
                case .success(let success):
                    print(success)
                case .failure(let error):
                    print(error)
                case .none:
                    print("nil")
                }
                guard case let .success(getRespond) = getResult else {
                    XCTAssert(false, "Get Request Failed")
                    return
                }
                
                let getRespondResult = getRespond
                print("Get Result: \(getRespondResult)")
                XCTAssertNotNil(getRespondResult, "Get Request Failed")
                let getArgs = getRespondResult.args
                XCTAssertNotNil(getArgs, "Get Request Failed")
                let getId = getArgs.id
                let getToken = getArgs.token
                
                XCTAssertNotNil(getId, "Get Request Failed, get id is nil")
                XCTAssertNotNil(getToken, "Get Request Failed, get token is nil")
                
                let postRequest = PostRequest(id: getId, token: getToken).responseDecodeableTask()
                let postResult = operation.await(postRequest)
                guard case let .success(postRespond) = postResult else {
                    XCTAssert(false, "Post Request Failed")
                    return
                }
                let postRespondResult = postRespond
                XCTAssertNotNil(postRespondResult, "Post Request Failed")
                let postArgs = postRespondResult.form

                let postId = postArgs.id
                let postToken = postArgs.token
                
                XCTAssertNotNil(postId, "Post Request Failed, get id is nil")
                XCTAssertNotNil(postToken, "Post Request Failed, get token is nil")
                print("id: \(postId), token: \(postToken)")
                operation.main {
                    // reload view
                    
                    expectation.fulfill()
                }
            }
        }
    }
    
    func testSequentialRequestsOptions() throws {
        expectation(timeout: 20, description: "testSequentialRequestsOptions") { expectation in
            Async.Task { operation in
            
                let id = "100"
                let token = "KNSkjdnjjasdasjkwklasdan"
                
                let getTask = GetRequest(id: id, token: token).responseDecodeableTask()
                
                let getResult = operation.await(getTask)
                guard case let .success(getRespond) = getResult else {
                    XCTAssert(false, "Get Request Failed")
                    return
                }
                let getRespondResult = getRespond
                print("Get Result: \(getRespondResult)")
                XCTAssertNotNil(getRespondResult, "Get Request Failed")
                let getArgs = getRespondResult.args
                XCTAssertNotNil(getArgs, "Get Request Failed")
                let getId = getArgs.id
                let getToken = getArgs.token
                
                XCTAssertNotNil(getId, "Get Request Failed, get id is nil")
                XCTAssertNotNil(getToken, "Get Request Failed, get token is nil")

                let postTask = PostRequest(id: getId, token: getToken).responseDecodeableTask()
                let postResult = operation.await(postTask)
                guard case let .success(postRespond) = postResult else {
                    XCTAssert(false, "Post Request Failed")
                    return
                }
                let postRespondResult = postRespond
                XCTAssertNotNil(postRespondResult, "Post Request Failed")
                let postArgs = postRespondResult.form

                let postId = postArgs.id
                let postToken = postArgs.token
                
                XCTAssertNotNil(postId, "Post Request Failed, get id is nil")
                XCTAssertNotNil(postToken, "Post Request Failed, get token is nil")
                print("id: \(postId), token: \(postToken)")
                operation.main {
                    // reload view
                    expectation.fulfill()
                }
            }
        }
    }
    
    func testSequentialRequests() throws {
        expectation(timeout: 20, description: "testSequentialRequests") { expectation in
            Async.Task { operation in
            
                let id = "100"
                let token = "KNSkjdnjjasdasjkwklasdan"
                
                let getRequest = GetRequest(id: id, token: token).responseDecodeableTask()
                                
                let getResult = operation.await(getRequest)
                guard case let .success(getObject) = getResult else {
                    XCTAssert(false, "Get Request Failed")
                    return
                }

                let getArgs = getObject.args
                XCTAssertNotNil(getArgs, "Get Request Failed")
                let getId = getArgs.id
                let getToken = getArgs.token
                
                XCTAssertNotNil(getId, "Get Request Failed, get id is nil")
                XCTAssertNotNil(getToken, "Get Request Failed, get token is nil")
                print("Get: id: \(getId), token: \(getToken)")

                let postRequest = PostRequest(id: getId, token: getToken).responseDecodeableTask()
                let postResult = operation.await(postRequest)
                guard case let .success(postObject) = postResult else {
                    XCTAssert(false, "Post Request Failed")
                    return
                }
                let postForm = postObject.form
                XCTAssertNotNil(postForm, "Post Request Failed")

                let postId = postForm.id
                let postToken = postForm.token
                
                XCTAssertNotNil(postId, "Post Request Failed, get id is nil")
                XCTAssertNotNil(postToken, "Post Request Failed, get token is nil")
                print("Post id: \(postId), token: \(postToken)")
                operation.main {
                    // reload view
                    expectation.fulfill()
                }
            }
        }
        
    }
    
    func testConcurrentRequestsOptions() throws {
        expectation(timeout: 20, description: "testConcurrentRequestsOptions") { expectation in
            
            Async.Task { operation in
                let id = "100"
                let token = "KNSkjdnjjasdasjkwklasdan"
                let getTask = GetRequest(id: id, token: token).responseDecodeableTask()
                let postTask = PostRequest(id: id, token: token).responseDecodeableTask()
                let results = operation.await([getTask, postTask])
                XCTAssertNotNil(results, "Concurrent Requests Failed")
                XCTAssertNotNil(getTask.value, "Concurrent Request Get Failed")
                XCTAssertNotNil(postTask.value, "Concurrent Request Get Failed")

                if let getResult = getTask.value {
                    print(getResult)
                }
                
                if let postResult = postTask.value {
                    print(postResult)
                }
                operation.main {
                    // reload view
                    expectation.fulfill()
                }
            }
        }
    }
    
    func testConcurrentRequests() throws {
        expectation(timeout: 20, description: "testConcurrentRequests") { expectation in
            
            Async.Task { operation in
                let id = "100"
                let token = "KNSkjdnjjasdasjkwklasdan"
                let getTask = GetRequest(id: id, token: token).responseDecodeableTask()
                let postTask = PostRequest(id: id, token: token).responseDecodeableTask()
                
                let results = operation.await([getTask, postTask])
                XCTAssertNotNil(results, "Concurrent Requests Failed")
                XCTAssertNotNil(getTask.value, "Concurrent Request Get Failed")
                XCTAssertNotNil(postTask.value, "Concurrent Request Get Failed")

                if let getResult = getTask.value {
                    print(getResult)
                }
                
                if let postResult = postTask.value {
                    print(postResult)
                }
                operation.main {
                    // reload view
                    expectation.fulfill()
                }
            }
        }
    }
    
    func testAwaitResponseable() {
        expectation(timeout: 20, description: "testConcurrentRequestsOptions") { expectation in
            
            Async.Task { operation in
                let id = "100"
                let token = "KNSkjdnjjasdasjkwklasdan"
                let getTask = GetRequest(id: id, token: token).responseDecodeableTask()
                let postTask = PostRequest(id: id, token: token).responseDecodeableTask()
                let results = operation.await([getTask, postTask])
                XCTAssertNotNil(results, "Concurrent Requests Failed")
                XCTAssertNotNil(getTask.value, "Concurrent Request Get Failed")
                XCTAssertNotNil(postTask.value, "Concurrent Request Get Failed")

                if let getResult = getTask.value {
                    print(getResult)
                }
                
                if let postResult = postTask.value {
                    print(postResult)
                }
                operation.main {
                    // reload view
                    expectation.fulfill()
                }
            }
        }
    }
    
    func testJsonMapping() throws {
        let dictionary: [String: Any] = [
            "respCode": 200,
            "respData": [
                "id": 1,
                "name": "KK",
                "info": [
                    "card": [
                        "carId": 112,
                        "carDesc":"序号"
                    ]
                ]
            ]
        ]
        
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        let mappingData = try data.zeus.mapping(by: "respData")
        XCTAssertNotNil(mappingData)
        do {
            let info = try data.zeus.mapping(by: "respData.info")
            XCTAssertNotNil(info)
        } catch {
            print(error)
        }
    }
    
    #endif
}

class GetRequest: Requestable, ResponseDecodable {
    typealias ResponseType = GetResponseObject
    
    func baseUrl() -> String {
        "https://httpbin.org"
    }
    
    func path() -> String {
        "/get"
    }
    
    func method() -> Zeus.Method {
        return .get
    }
    
    var id: String
    var token: String
    
    init(id: String, token: String) {
        self.id = id
        self.token = token
    }
    
    deinit {
        print("Get Request Deinit")
    }
}

class PostRequest: Requestable, ResponseDecodable {
    typealias ResponseType = PostResponseObject
    
    func baseUrl() -> String {
        "https://httpbin.org"
    }
    
    func path() -> String {
        "/post"
    }
    
    func method() -> Zeus.Method {
        return .post
    }
    
    var id: String
    var token: String
    
    init(id: String, token: String) {
        self.id = id
        self.token = token
    }
    deinit {
        print("Post Request Deinit")
    }
}


struct GetResponseObject: Responseable {
    var args: GetResponseObject.Args
    
    struct Args: Responseable {
        var id: String
        var token: String
    }
}


struct PostResponseObject: Responseable {
    var form: PostResponseObject.Form
    
    struct Form: Responseable {
        var id: String
        var token: String
    }
}



