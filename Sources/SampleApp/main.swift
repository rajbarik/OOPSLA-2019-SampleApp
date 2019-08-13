
import Foundation
import RxSwift
    

/// @mockable
protocol LocationProtocol {
    var locationName: String { get set }
    var longitude: Int { get set}
    var lattitude: Int { get set}
    func toLocationString() -> String
    func equals(_ loc:LocationProtocol) -> Bool
    func near(_ loc:LocationProtocol) -> Bool 
}

class Location : LocationProtocol {
    var locationName: String = "Unknown"
    var longitude: Int = 0
    var lattitude: Int = 0
    init(arg: String, long: Int, lat: Int) {
        self.locationName = arg
        self.longitude = long
        self.lattitude = lat
    }
    func toLocationString() -> String {
        return locationName
    }
    func equals(_ loc:LocationProtocol) -> Bool {
      return self.locationName == loc.locationName
    }
    func near(_ loc:LocationProtocol) -> Bool {
      return ((self.longitude - loc.longitude) < 5) && ((self.lattitude - loc.lattitude) < 5)
    }
}
 
/// @mockable
protocol RequestProtocol {
    var requestId: Int { get set }
    func toRequestString() -> String
    func equals(_ req:RequestProtocol) -> Bool
}

class Request : RequestProtocol {
    var requestId: Int = 0
    init(arg: Int) {
        self.requestId = arg
    }
    func toRequestString() -> String {
        return "\(requestId)"
    }
    func equals(_ req:RequestProtocol) -> Bool {
      return self.requestId == req.requestId
    }
}


protocol StateTransitionEventStreaming {
    var eventStream: Observable<[RequestProtocol]> { get }
    func update(events: [RequestProtocol])
}

class StateEventStream: StateTransitionEventStreaming {
    let eventSubject = PublishSubject<[RequestProtocol]>()
    var eventStream: Observable<[RequestProtocol]> {
        return eventSubject.asObservable()
    }
    
    init() {}
    func update(events: [RequestProtocol]) {
        eventSubject.onNext(events)
    }
}

protocol LocationSearchResultStreaming {
    var locationSearchStream: Observable<[LocationProtocol]> { get }
    func update(Ids: [LocationProtocol])
}

class LocationSearchResultStream: LocationSearchResultStreaming {
    let locationSearchSubject = PublishSubject<[LocationProtocol]>()
    var locationSearchStream: Observable<[LocationProtocol]> {
        return locationSearchSubject.asObservable()
    }
    
    init() {}
    func update(Ids: [LocationProtocol]) {
        locationSearchSubject.onNext(Ids)
    }
}


class SampleApp {

    let db = DisposeBag()
    let locationSearchStream: LocationSearchResultStreaming
    let stateEventStream: StateTransitionEventStreaming
    var result: String = ""
    //var start: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    //var end: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()

    init(_ locationSearchStream : LocationSearchResultStreaming, _ stateEventStream :StateTransitionEventStreaming) {
        self.locationSearchStream = locationSearchStream
        self.stateEventStream = stateEventStream
    }
 
    func activate(resultIndex:Int) {
        Observable.combineLatest(locationSearchStream.locationSearchStream, stateEventStream.eventStream)
            .map  { (a, b) -> ([String], [String]) in
                let updatedLocations = a.map { el in
                    return el.toLocationString() + " \(el.equals(a[resultIndex]))" + "\(el.near(a[resultIndex]))"
                }
                let updatedRequests: [String] = b.map { el in
                    return el.toRequestString() + " \(el.equals(b[resultIndex]))"
                }
                return (updatedLocations, updatedRequests)
            }
            .subscribe(
            onNext: { (locs, reqs)  in
                self.result = "\(locs[resultIndex]),\(reqs[resultIndex])"
            },onError: { (error) in
                print("Error is \(error)")
            },onCompleted: {
                //self.end = CFAbsoluteTimeGetCurrent()
                //print("Time=",self.end  - self.start)
            }, onDisposed: {
            })
            .addDisposableTo(db)
        
    }
    
    func update(numEvents: Int, numLocationSearchresults: Int, numRequests: Int) {
        //start=CFAbsoluteTimeGetCurrent()
        for i in 0..<numEvents {
            var a = [LocationProtocol]()
            for j in 0..<numLocationSearchresults {
                a.append(Location(arg: "str \(i),\(j)", long: i, lat: j))
            }
            locationSearchStream.update(Ids: a)
            var b = [RequestProtocol]()
            for j in 0..<numRequests {
                b.append(Request(arg: i+j))
            }
            stateEventStream.update(events: b)
            
        }
    }
}

let s = SampleApp(LocationSearchResultStream(), StateEventStream())
let NUMEVENTS = 10000
let NUMLOCATIONSEARCHRESULTS=1000
let NUMREQUESTS=1000
let resultIndex = Int.random(in: 0..<NUMLOCATIONSEARCHRESULTS)
let start = CFAbsoluteTimeGetCurrent()
s.activate(resultIndex: resultIndex)
s.update(numEvents: NUMEVENTS, numLocationSearchresults: NUMLOCATIONSEARCHRESULTS , numRequests: NUMREQUESTS)
let end = CFAbsoluteTimeGetCurrent()
print("Time=", end - start)
print(s.result)

