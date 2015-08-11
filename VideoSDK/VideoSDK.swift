//
//  VideoSDK.swift
//  SDKDemo
//
//  Created by kinghai on 15/6/4.
//  Copyright (c) 2015年 ftguang. All rights reserved.
//

import Foundation
import SwiftHTTP
import CryptoSwift
import MobileCoreServices

/**
VideoSDK is a class to query services.
*/
public class VideoSDK: AbstractService{
    
    public func getCatalogService() -> CatalogService {
        return CatalogService(host: host, accessKey: accessKey, accessSecret: accessSecret)
    }
    
    public func getVideoService() -> VideoService {
        return VideoService(host: host, accessKey: accessKey, accessSecret: accessSecret)
    }
    
    public func getUsageService() -> UsageService {
        return UsageService(host: host, accessKey: accessKey, accessSecret: accessSecret)
    }
    
    public func getMultipartService() -> MultipartService {
        return MultipartService(host: host, accessKey: accessKey, accessSecret: accessSecret)
    }
}

public class Catalog: PropertyChangeTrait {
    public var id: String! {
        didSet {
            propertyChange("id", newValue: id, oldValue: oldValue)
        }
    }
    
    public var name: String! {
        didSet {
            propertyChange("name", newValue: name, oldValue: oldValue)
        }
    }
    
    public var videoNumber:UInt? {
        didSet {
            propertyChange("videoNumber", newValue: videoNumber, oldValue: oldValue)
        }
    }
    
    convenience init(id: String, name: String) {
        self.init(id: id, name: name, videoNumber: nil)
    }
    
    init(id _id:String, name _name:String, videoNumber _vn :UInt?) {
        self.id = _id
        self.name = _name
        self.videoNumber = _vn
    }
}

/*
 CatalogService is the class that manage catalog. It has methods about CRUD.
*/
public class CatalogService: AbstractService {
    
    /**

        list catalogs by page.
        
        param: onSuccess The Closure called if list catalogs success, The Closure argument catalogs is the query result of Catalog list.
        param: onFail  The closure called if get catalog fail, The closure argument "code" presents the error code, The closure argument "msg" presents the detail reason why fail.
        param: nameLike The query condition to indicate only catalog with similar name will return.
        param: page The query condition to indicate current page.
        param: maxResult The query condition to indicate the number of catalog in each page.
    
        returns: Void
    */
    public func list(onSuccess: (catalogs: [Catalog]) -> Void, onFail: (code: Int?, msg: String) -> Void, nameLike: String, page: Int = 1, maxResult: Int = 100) {
        
        func successHandler(data: AnyObject, msg: String) -> Void {
            let arr: NSArray = data["catalogs"] as! NSArray
            var catalogs = [Catalog]()
            for item in arr {
                catalogs.append(Catalog(id: anyObjectToString(item["id"])!, name: anyObjectToString(item["name"])!))
            }
            onSuccess(catalogs: catalogs)
        }
        
        getHTTP("/catalog/list.api", params: ["nameLike": nameLike, "page": page, "maxResult": maxResult], successHandler: successHandler, failHandler: onFail)
    }
    
    /**
    
    list all catalogs.
    
    param: onSuccess The Closure called if list catalogs success, The Closure argument catalogs is the query result of Catalog list.
    param: onFail  The closure called if get catalog fail, The closure argument "code" presents the error code, The closure argument "msg" presents the detail reason why fail.
    
    returns: Void
    */
    public func list(onSuccess: (catalogs: [Catalog]) -> Void, onFail: (code: Int?, msg: String) -> Void) {
        list(onSuccess, onFail: onFail, nameLike: "", page:1, maxResult: 100000)
    }
    
    /**
    
    get catalog detail.
    
    param: onSuccess The Closure called if get catalog success, catalog .
    param: onFail  The closure called if get catalog fail, The closure argument "code" presents the error code, The closure argument "msg" presents the detail reason why fail.
    param: id The catalog id.
    
    returns: Void
    */
    public func get(onSuccess: (catalog: Catalog) -> Void, onFail: (code: Int?, msg: String) -> Void, id: String) {
        
        func successHandler(data: AnyObject, msg: String) -> Void {
            let catalog = Catalog(id: id, name: String(stringInterpolationSegment: data["name"]), videoNumber: data["videoNumber"] as! UInt!)
            onSuccess(catalog: catalog)
        }
  
        getHTTP("/catalog/get.api", params: ["catalogId": id], successHandler: successHandler, failHandler: onFail)
    }
    
    /**
    
    create catalog.
    
    param: onSuccess The Closure called if create catalog success, The closure's argument "catalog" presents the new created catalog .
    param: onFail  The closure called if get catalog fail, The closure argument "code" presents the error code, The closure argument "msg" presents the detail reason why fail.
    param: name The name of created catalog.
    
    returns: Void
    */
    public func create(onSuccess: (catalog: Catalog) -> Void, onFail: (code: Int?, msg: String) -> Void,  name: String) {
     
        func successHandler(data: AnyObject, msg: String) -> Void {
            
            let catalog = Catalog(id: anyObjectToString(data["id"])!, name: anyObjectToString(data["name"])!)
            onSuccess(catalog: catalog)
        }
        
        postHTTP("/catalog/create.api", params: ["name": name], successHandler: successHandler, failHandler: onFail)
    }
    
    /**
    
    delete catalog.
    
    param: onSuccess The Closure called if delete catalog success, The closure's argument "catalog" presents the deleted catalog .
    param: onFail  The closure called if get catalog fail, The closure argument "code" presents the error code, The closure argument "msg" presents the detail reason why fail.
    param: id The id of deleted catalog.
    
    returns: Void
    */
    public func delete(onSuccess: (catalog: Catalog) -> Void, onFail: (code: Int?, msg: String) -> Void, id: String) {
        func successHandler(data: AnyObject, msg: String) -> Void {
            let catalog = Catalog(id: id, name: String(stringInterpolationSegment: data["name"]))
            onSuccess(catalog: catalog)
        }
        
        postHTTP("/catalog/delete.api", params: ["catalogId": id], successHandler: successHandler, failHandler: onFail)
    }   
}

//define type MediaDuration for Media context
public typealias MediaDuration = UInt
//define type MediaSize for Media context
public typealias MediaSize = UInt

/*
  Video represents the Video/Audio which is being stored in onecloud video platform.
*/
public class Video: PropertyChangeTrait {
    public var id: String?
    {
        didSet {
            propertyChange("id", newValue: id, oldValue: oldValue)
        }
    }
    
    public var name: String?
    {
        didSet {
            propertyChange("name", newValue: name, oldValue: oldValue)
        }
    }
    
    public var description: String?
    {
        didSet {
            propertyChange("description", newValue: description, oldValue: oldValue)
        }
    }
    
    public var duration: MediaDuration?
    {
        didSet {
            propertyChange("duration", newValue: duration, oldValue: oldValue)
        }
    }
    
    //the size of video.
    public var size: MediaSize?
    {
        didSet {
            propertyChange("size", newValue: size, oldValue: oldValue)
        }
    }
    
    public var catalog: Catalog?
    {
        didSet {
            propertyChange("catalog", newValue: catalog, oldValue: oldValue)
        }
    }
    
    //status in video's life cycle, eg: UPLOADING, PROCESSING and so on.
    public var status: String?
    {
        didSet {
            propertyChange("status", newValue: status, oldValue: oldValue)
        }
    }
    
    //video type, only VIDEO or AUDIO is avaliable now.
    public var type: String?
    {
        didSet {
            propertyChange("type", newValue: type, oldValue: oldValue)
        }
    }
    
    //all transcodedVideo which is transcoded by this video
    public var transcodedVideos: [TranscodedVideo]?
    {
        didSet {
            propertyChange("transcodedVideos", newValue: transcodedVideos, oldValue: oldValue)
        }
    }

    //the progress of upload status, from 0.0 to 1.0
    public var uploadProgress: Double = 0.0
    {
        didSet {
            propertyChange("uploadProgress", newValue: uploadProgress, oldValue: oldValue)
        }
    }
  
    public convenience init (id: String?, name: String?, description: String?, duration: MediaDuration?, size: MediaSize?, catalog: Catalog?, status: String?, type: String?) {
        self.init(id: id, name: name, description: description, duration: duration, size: size, catalog: catalog, status: status, type: type, transcodedVideos: nil)
    }
    
    public init(id: String?, name: String?, description: String?, duration: MediaDuration?, size: MediaSize?, catalog: Catalog?, status: String?, type: String?, transcodedVideos: [TranscodedVideo]?) {
        self.id = id
        self.name = name
        self.description = description
        self.duration = duration
        self.size = size
        self.catalog = catalog
        self.status = status
        self.type = type
        self.transcodedVideos = transcodedVideos
    }
    
    public func isVideo() -> Bool {
        return "VIDEO" == type
    }
    
    public func isAudio() -> Bool {
        return "AUDIO" == type
    }
    
    public func isUploading() -> Bool {
        return "UPLOADING" == status
    }
    
    public func isProgressing() -> Bool {
        return "PROCESSING" == status
    }
    
    public func isAuditSuccess() -> Bool {
        return "AUDIT_SUCCESS" == status
    }
}

/*
TranscodedVideo represents The Video/Audio which is transcoded from Video by custom transcode stragety, stragety is composed of different clarity, resolution, bitrate and so on.
*/
public struct TranscodedVideo {
    public var clarity: String!    //the name of clarity, usually is locale language.
    public var resolution: String! //the name of resolution, eg: 640X360
    public var m3u8: String?       //the url to play this V/A.
    public var code: TranscodedVideoCode!  //code to easy deploy.
}

/**
  Deploy code of TranscodedVideo
*/
public struct TranscodedVideoCode {
    public var auto: String?   //Deploy in html context, This code detect user's browser and choose appropriate html5 or flash code.
    public var html5: String?  //Deploy in html5 context.
    public var flash: String?  //Deploy in flash context.
    public var portable: String?   //Deploy in protable device web browser.
    public var mp4: String?    //The url of mp4.
    public var flv: String?    //The url of flv.
}

/**
    The component to create video.
*/
class VideoCreator {
    
    /**
        create a video instance from anyobject.
    
        param: item The item contains all data to create video.
        returns: video instance.
    */
    func create(item: AnyObject) -> Video {
        let id = anyObjectToString(item["id"])
        let name = anyObjectToString(item["name"])
        let duration = anyObjectToUInt(item["duration"])
        let size = anyObjectToUInt(item["size"])
        let catalog = Catalog(id: anyObjectToString(item["catalogId"])!, name: anyObjectToString(item["catalogName"])!)
        let status = anyObjectToString(item["status"])
        let type = anyObjectToString(item["type"])
        let desc = anyObjectToString(item["description"])
        
        var v = Video(id: id, name: name, description: desc, duration: duration, size: size, catalog: catalog, status: status, type: type)
        
        if let embedCodes = item["embedCodes"] as? NSArray {
            var transcodedVideos = [TranscodedVideo]()
            
            for ec in embedCodes {
                var tvc = TranscodedVideoCode(auto: anyObjectToString(ec["autoAdaptionCode"]), html5: anyObjectToString(ec["html5Code"]),
                    flash: anyObjectToString(ec["flashCode"]), portable: anyObjectToString(ec["portableCode"]),
                    mp4: anyObjectToString(ec["mp4Code"]), flv: anyObjectToString(ec["flvCode"]))
                
                var tv = TranscodedVideo(clarity: anyObjectToString(ec["clarity"]), resolution: anyObjectToString(ec["resolution"]),
                    m3u8: anyObjectToString(ec["filePath"]), code: tvc)
                transcodedVideos.append(tv)
            }
            v.transcodedVideos = transcodedVideos
        }
        
        return v
    }

    /**
        update the video property.
        
        param： updatedVideo The video expect to be updated.
        param： item The object used to update video.
    */
    func update(updatedVideo: Video, item: AnyObject) {
        let v = create(item)
        
        updatedVideo.id = v.id
        updatedVideo.name = v.name
        updatedVideo.duration = v.duration
        updatedVideo.size = v.size
        updatedVideo.catalog = v.catalog
        updatedVideo.status = v.status
        updatedVideo.type = v.type
        updatedVideo.transcodedVideos = v.transcodedVideos
    }
}

//extension videoCreator to convert type
extension VideoCreator {
    func anyObjectToString(ao: AnyObject?) -> String? {
        return ConvertUtil.anyObjectToString(ao)
    }
    
    func anyObjectToUInt(ao: AnyObject?) -> UInt! {
        return ConvertUtil.anyObjectToUInt(ao)
    }
    
    func anyObjectToInt(ao: AnyObject?) -> Int {
        return ConvertUtil.anyObjectToInt(ao)
    }
}

/**
    VideoService is the class to manage video, it has methods about CRUB.
*/
public class VideoService: AbstractService
{
    private lazy var videoCreator: VideoCreator = VideoCreator()   //response of create video, lazy init to improve preformance.
    
    /**
        query the video list by condition.
    
        param： onSuccess The closure called if query success, The closure's argument videos presents the query result of video list.
        param： onFail The closure called if query fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
        param： catalogId The id of catalog where query video.
        param： catalogNameLike the name of catalog where query video.
        param： page The current page
        param： maxResult The number of video in each page.
    */
    public func list(onSuccess: (videos: [Video]) -> Void, onFail: (code: Int?, msg: String) -> Void, catalogId: String, catalogNameLike: String = "", nameLike: String = "", page: UInt = 1, maxResult: UInt = 100) -> Void {
        
        func successHandler(data: AnyObject, msg: String) -> Void {
            
            var videoStrArr = data["videos"] as! NSArray
            var vs = [Video]()
            
            for item in videoStrArr {
                vs.append(videoCreator.create(item))
            }
            
            onSuccess(videos: vs)
        }
        
        getHTTP("/video/list.api", params: ["catalogId": catalogId, "catalogNameLike": catalogNameLike, "nameLike": nameLike, "page": page, "maxResult": maxResult], successHandler: successHandler, failHandler: onFail)
    }
    
    /**
    query video info.
    
    param： onSuccess The closure called if query success, The closure's argument video presents the query result of video info.
    param： onFail The closure called if query fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param： id The id of video.
    
    returns： Void
    */
    public func get(onSuccess: (video: Video) -> Void, onFail: (code: Int?, msg: String) -> Void, id: String) {
        func successHandler(data: AnyObject, msg: String) {
            onSuccess(video: videoCreator.create(data))
        }
  
        getHTTP("/video/get.api", params: ["videoId": id], successHandler: successHandler, failHandler: onFail)
    }
    
    /**
    upload local video to server
    
    param： onSuccess The closure called if upload success, The closure's argument video presents the upload success video.
    param： onFail The closure called if upload fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param： filePath vidoe's file path.
    param： catalogId The id of catalog which video will upload to
    param： name The video's name
    @description The video's description.
    
    returns： Video The uploading video
    */
    public func upload(onSuccess: (video: Video) -> Void, onFail: (code: Int?, msg: String) -> Void, filePath: String, catalogId: String, name: String, description: String) -> Video {
        
        func progressHandler(val: Double) {
            NSLog("upload progress is \(val)")
        }
        
        return upload(onSuccess, onFail: onFail, onProgress: progressHandler, filePath: filePath, catalogId: catalogId, name: name, description: description)
    }
    
    /**
    upload local video to server
    
    param： onSuccess The closure called if upload success, The closure's argument video presents the upload success video.
    param： onFail The closure called if upload fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  onProgress The closure to notify upload progress, The closure's argument val presents the progress value, from 0.0 to 1.0
    param： filePath vidoe's file path.
    param： catalogId The id of catalog which video will upload to
    param： name The video's name
    @description The video's description.
    
    returns： Video The uploading video
    */
    public func upload(onSuccess: (video: Video) -> Void, onFail: (code: Int?, msg: String) -> Void, onProgress: (val: Double) -> Void, filePath: String, catalogId: String, name: String, description: String) -> Video {
        
        let lf = LocalFile(contentsOfFile: filePath)
        let v = Video(id: nil, name: lf?.name, description: nil, duration: nil, size: lf?.size, catalog: nil, status: "UPLOADING", type: nil)
        
        func progressHandler(val: Double) {
            v.uploadProgress = val
            onProgress(val: val)
        }
        
        func successHandler(data: AnyObject, msg: String) {
            videoCreator.update(v, item: data)
            onSuccess(video: v)
        }
        
        uploadHTTP("/video/upload.api", method: HTTPMethod.POST, filePath: filePath, params: ["catalogId": catalogId, "name": name, "description": description], progress: progressHandler, successHandler: successHandler, failHandler: onFail)

        return v
    }
    
    /**
    delete video
    
    param： onSuccess The closure called if delete success, The closure's argument msg present delete detail.
    param： onFail The closure called if delete fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  id The id of deleted video.
    
    returns： Void
    */
    public func delete(onSuccess: (msg: String) -> Void, onFail: (code: Int?, msg: String) -> Void, id: String) {
        func successHandler(data: AnyObject, msg: String) {
            onSuccess(msg: msg)
        }
        
        postHTTP("/video/delete.api", params: ["videoId": id], successHandler: successHandler, failHandler: onFail)
    }
    
    /**
    update video meta info
    
    param： onSuccess The closure called if update success, The closure's argument msg present update detail.
    param： onFail The closure called if update fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  id The id of updated video.
    param:  name: The new video name.
    param:  description The new video description.
    
    returns： Void
    */
    public func update(onSuccess: (msg: String) -> Void, onFail: (code: Int?, msg: String) -> Void, id: String, name: String, description: String) {
        func successHandler(data: AnyObject, msg: String) {
            onSuccess(msg: msg)
        }
        
        postHTTP("/video/update.api", params: ["videoId": id, "name": name, "description": description], successHandler: successHandler, failHandler: onFail)
    }
}

//Usage describe how many resource has been used in specified time.
public class Usage <T> {
    var startAt: NSDate //start time
    var endAt: NSDate   //end time
    var usage: T        //measure of resouce used
    
    public init(var startAt: NSDate, var endAt: NSDate, var usage: T) {
        self.startAt = startAt
        self.endAt = endAt
        self.usage = usage
    }
}

//Usage field presents the usage's kind.
public enum UsageField: String {
    case Day = "DAY"
    case Hour = "HOUR"
}

/**
   UsageService response for query multi resource usage.
*/
public class UsageService: AbstractService {
    
    
    /**
    query the usage of ip
    
    param： onSuccess The closure called if query success, The closure's argument usages present the usage list of query result.
    param： onFail The closure called if query fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  field The usage' kind, eg: DAY, HOUR.
    param:  startAt The start time.
    param:  endAt The end time.
    
    returns： Void
    */
    public func ip(onSuccess: (usages: [Usage<UInt>]) -> Void, onFail: (code: Int?, msg: String) -> Void, field: UsageField, startAt: NSDate, endAt: NSDate) {
        usage(onSuccess, onFail: onFail, field: field, startAt: startAt, endAt: endAt, action: "/resource/uniqueIP/list.api", usageItem: "uniqueIP")
    }
    
    /**
    query the usage of storage
    
    param： onSuccess The closure called if query success, The closure's argument usages present the usage list of query result.
    param： onFail The closure called if query fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  field The usage' kind, eg: DAY, HOUR.
    param:  startAt The start time.
    param:  endAt The end time.
    
    returns： Void
    */
    public func storage(onSuccess: (usages: [Usage<UInt>]) -> Void, onFail: (code: Int?, msg: String) -> Void, field: UsageField, startAt: NSDate, endAt: NSDate) {
         usage(onSuccess, onFail: onFail, field: field, startAt: startAt, endAt: endAt, action: "/resource/storage/list.api", usageItem: "storage")
    }
    
    /**
    query the usage of bandwidth
    
    param： onSuccess The closure called if query success, The closure's argument usages present the usage list of query result.
    param： onFail The closure called if query fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  field The usage' kind, eg: DAY, HOUR.
    param:  startAt The start time.
    param:  endAt The end time.
    
    returns： Void
    */
    public func bandwidth(onSuccess: (usages: [Usage<UInt>]) -> Void, onFail: (code: Int?, msg: String) -> Void, field: UsageField, startAt: NSDate, endAt: NSDate) {
        usage(onSuccess, onFail: onFail, field: field, startAt: startAt, endAt: endAt, action: "/resource/bandwidth/list.api", usageItem: "bandwidth")
    }
    
    /**
    query the usage of play times of video
    
    param： onSuccess The closure called if query success, The closure's argument usages present the usage list of query result.
    param： onFail The closure called if query fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  field The usage' kind, eg: DAY, HOUR.
    param:  startAt The start time.
    param:  endAt The end time.
    
    returns： Void
    */
    public func playTimes(onSuccess: (usages: [Usage<UInt>]) -> Void, onFail: (code: Int?, msg: String) -> Void, field: UsageField, startAt: NSDate, endAt: NSDate) {
        usage(onSuccess, onFail: onFail, field: field, startAt: startAt, endAt: endAt, action: "/resource/videoPlayedTimes/list.api", usageItem: "playedTimes")
    }
    
    /**
    query the usage of new add video
    
    param： onSuccess The closure called if query success, The closure's argument usages present the usage list of query result.
    param： onFail The closure called if query fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  field The usage' kind, eg: DAY, HOUR.
    param:  startAt The start time.
    param:  endAt The end time.
    
    returns： Void
    */
    public func videoAdded(onSuccess: (usages: [Usage<UInt>]) -> Void, onFail: (code: Int?, msg: String) -> Void, field: UsageField, startAt: NSDate, endAt: NSDate) {
        usage(onSuccess, onFail: onFail, field: field, startAt: startAt, endAt: endAt, action: "/resource/videoAdded/list.api", usageItem: "added")
    }
    
    /**
    query the usage of total video count
    
    param： onSuccess The closure called if query success, The closure's argument usages present the usage list of query result.
    param： onFail The closure called if query fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  field The usage' kind, eg: DAY, HOUR.
    param:  startAt The start time.
    param:  endAt The end time.
    
    returns： Void
    */
    public func videoTotal(onSuccess: (usages: [Usage<UInt>]) -> Void, onFail: (code: Int?, msg: String) -> Void, field: UsageField, startAt: NSDate, endAt: NSDate) {
        usage(onSuccess, onFail: onFail, field: field, startAt: startAt, endAt: endAt, action: "/resource/videoTotal/list.api", usageItem: "total")
    }
    
    private func usage(onSuccess: (usages: [Usage<UInt>]) -> Void, onFail: (code: Int?, msg: String) -> Void, field: UsageField, startAt: NSDate, endAt: NSDate, action: String, usageItem: String) {
        
        func successHandler(data: AnyObject, msg: String) {
            var arr = data["resources"] as! NSArray
            var usages = [Usage<UInt>]()
            
            for item in arr {
                usages.append(Usage<UInt>(startAt: toDate(item["startAt"]), endAt: toDate(item["endAt"]), usage: anyObjectToUInt(item[usageItem])))
            }
            
            onSuccess(usages: usages)
        }
        
        getHTTP(action, params: ["field": field.rawValue, "startAt": toString(startAt), "endAt": toString(endAt)], successHandler: successHandler, failHandler: onFail)
    }
    
    //NSDate convert to string
    private func toString(d: NSDate) -> String {
        return getFormatter() .stringFromDate(d)
    }
    
    //anyObject convert to NSDate
    private func toDate(ao: AnyObject?) -> NSDate {
        return toDate(anyObjectToString(ao)!)
    }
    
    //String convert to NSDate
    private func toDate(str: String) -> NSDate {
        return getFormatter() .dateFromString(str)!
    }
    
    private func getFormatter() -> NSDateFormatter {
        var f = NSDateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }
}

/**
    present a local file, get file meta info, md5...
*/
public class LocalFile {
    
    public var contentsOfFile: String
    private lazy var nsdata: NSData = { [unowned self] in
        return NSData(contentsOfFile: self.contentsOfFile)!
    }()
    
    public lazy var size: UInt = { [unowned self] in
        return self.attribute[NSFileSize] as! UInt
    }()
    
    private lazy var attribute: [NSObject: AnyObject] = { [unowned self] in
        return self.filemgr.attributesOfItemAtPath(self.contentsOfFile, error: nil)!
    }()
    
    public var name: String
    {
        return self.contentsOfFile.lastPathComponent.stringByDeletingPathExtension
    }
    
    public lazy var mimeType: String = { [unowned self] in
            return "application/octet-stream"
    }()
    
    private lazy var filemgr = NSFileManager.defaultManager()
    
    public init?(contentsOfFile: String) {
        self.contentsOfFile = contentsOfFile
    }
    
    public func md5() -> String {
        var ns: NSData! = nsdata.md5()
        var s = String(stringInterpolationSegment: ns)
        
        s.removeAtIndex(s.startIndex)
        s.removeAtIndex(s.endIndex.predecessor())
        s.replace(" ", withReplace: "")

        return s
    }
    
    public func exist() -> Bool {
        return filemgr.fileExistsAtPath(contentsOfFile)
    }
    
  }

/**
    Read part data from local file.
*/
public class MultipartLocalFileReader {
    
    public static let MULTI_PART_SIZE: UInt = 1024 * 1024   //part max size
    
    private var localFile: LocalFile
    
    public init(f: LocalFile) {
        self.localFile = f
    }
    
    /**
        read part data from file.
        param: part The number of part.
        returns:    part file content.
    */
    public func read(part: UInt) -> NSData? {
        let file: NSFileHandle? = NSFileHandle(forReadingAtPath: localFile.contentsOfFile)
        if nil == file {
            NSLog("open file fail")
        }

        if part > totalPart() {
            return nil
        }
        
        var offset: UInt64 = UInt64(Int((part - 1) * getPartSize()))
        
        file?.seekToFileOffset(offset)
        var partFile: NSData?
        if part == totalPart() { //last part of file
            NSLog("read last part data of file \(localFile.contentsOfFile)")
            partFile = file?.readDataToEndOfFile()
        } else {
            NSLog("read \(part)th data of file \(localFile.contentsOfFile)")
            
            //read part data
            partFile = file?.readDataOfLength(Int(getPartSize()))
        }
        
        file?.closeFile()
        
        return partFile
    }
    
    //get total part of file.
    public func totalPart() -> UInt {
       return UInt(ceil(Double(localFile.size) / Double(getPartSize())))
    }
    
    private func getPartSize() -> UInt {
        return MultipartLocalFileReader.MULTI_PART_SIZE
    }
}

/**
    A mutilpart upload task.
*/
public struct MultipartTask {
    var uploadId: String    //id to identify upload task.
    var fileName: String    //uploading file name.
    var fileMD5: String     //uploading file md5 to compare with other file.
}

/**
    Part task.
*/
public struct Multipart {
    var number: UInt    //part number
    var key: String?    //part key generated by server
    var md5: String?    //part content md5.
}

/**
    present a video which is multipart uploading.
*/
public class MultipartVideo: Video {
    var filePath: String
    var file: LocalFile
    
    var task: MultipartTask?
    var uploadedParts = [Multipart]()
    var leftParts = [Multipart]()
    
    var totalPart: UInt?
    var partSize: UInt?
    
    var cancelable: Bool = false
    var halt: Bool = false {
        didSet {
            propertyChange("halt", newValue: halt, oldValue: oldValue)
        }
    }
    
    public init (filePath: String, id: String?, name: String?, description: String?, duration: MediaDuration?, size: MediaSize?, catalog: Catalog?, status: String?, type: String?) {
        
        self.filePath = filePath
        self.file = LocalFile(contentsOfFile: filePath)!
        
        super.init(id: id, name: name, description: description, duration: duration, size: size, catalog: catalog, status: status, type: type, transcodedVideos: nil)
    }
    
    func allUploaded() -> Bool {
        return uploadedParts.count == Int(totalPart!)
    }
    
    func getUploadedPartNumbers() -> [UInt] {
        return getNumbers(uploadedParts)
    }
    
    func getUploadedPartNumbers() -> [String] {
        return getNumbers(uploadedParts).map(){(n: UInt) -> String in
            return "\(n)"
        }
    }
    
    func getNumbers(parts: [Multipart]) -> [UInt] {
        return parts.map({(part: Multipart) -> UInt in
            return part.number
        })
    }
}

/**
    MultipartService is response for manage miltipart upload file.
*/
public class MultipartService: AbstractService {
    
    /**
        upload file by multipart.
    
        param： onSuccess The closure called if upload success, The closure's argument video present the new created video.
        param： onFail The closure called if upload fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.

        returns: MultipartVideo, The uploading video.
    */
    public func upload(onSuccess: (video: Video) -> Void, onFail: (code: Int?, msg: String) -> Void, filePath: String, catalog: Catalog) -> MultipartVideo {
        
        let lf = LocalFile(contentsOfFile: filePath)
        var mv = MultipartVideo(filePath: filePath, id: nil, name: lf?.name, description: nil, duration: nil, size: lf?.size, catalog: catalog, status: "UPLOADING", type: nil)
        
        upload(onSuccess, onFail: onFail, multipartVideo: mv)
        
        return mv
    }
    
    /**
        upload parts iteration.
    
        param： onSuccess The closure called if upload success, The closure's argument video present the new created video.
        param： onFail The closure called if upload fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
        param:  multipartVideo The video whose unuploading parts will be uploaded in iteration way.
    
        returns: Void.
    */
    private func uploadPartsIteration(onSuccess :(video: Video) -> Void,  onFail: (code: Int?, msg: String) -> Void, multipartVideo mv: MultipartVideo) {
       
        //all parts has been uploaded
        if mv.allUploaded() {
            //assemble
            
            sort(&mv.uploadedParts, {
                return $0.number < $1.number
            })
            
            //finish the last job.
            complete({ (video, msg) -> Void in
                mv.id = video.id
                mv.name = video.name
                mv.description = video.description
                mv.type = video.type
                mv.status = video.status
                mv.size = video.size
                mv.duration = video.duration
                mv.halt = false
                mv.cancelable = false
                
                onSuccess(video: mv)
                
                }, onFail: onFail, uploadId: mv.task!.uploadId, partKeys: mv.uploadedParts.map({ (part: Multipart) -> String in
                    return part.key!
                }), catalogId: mv.catalog!.id)
            
            return
        }
        
        var part = mv.leftParts.removeLast()
        var partNumber = part.number
     
        //update video's progress
        var onProgress = { (val: Double) -> Void in
            var uploaded = 0
            var total = mv.size
            
            uploaded += Int(mv.partSize!) * mv.uploadedParts.count
            
            if mv.totalPart == part.number {
                let lastPartSize = mv.size! - (mv.totalPart! - 1) * mv.partSize!
                uploaded += Int(Double(lastPartSize) * val)
            } else {
                uploaded += Int(Double(mv.partSize!) * val)
            }
            
            mv.uploadProgress = Double(uploaded) / Double(total!)
            
            NSLog("multipart upload progress is \(mv.uploadProgress), part progresss is \(val)")
        }
        
        self.uploadPart({ (partKey, partMD5) -> Void in

            part.key = partKey
            part.md5 = partMD5
            
            mv.uploadedParts.append(part)
            
            self.uploadPartsIteration(onSuccess, onFail: onFail, multipartVideo: mv)
            
            }, onFail: onFail, onProgress: onProgress, uploadId: mv.task!.uploadId, filePath: mv.filePath, partNumber: partNumber)
        
    }
    
    /**
    upload multipartVideo.
    
    param： onSuccess The closure called if upload success, The closure's argument video present the new created video.
    param： onFail The closure called if upload fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  multipartVideo The video should be uploaded.
    
    returns: Void.
    */
    public func upload(onSuccess :(video: Video) -> Void,  onFail: (code: Int?, msg: String) -> Void, multipartVideo mv: MultipartVideo) {
        
        mv.halt = false
        
        let fileName = mv.file.name
        let fileMD5 = mv.file.md5()
        
        var warpOnFail = {(code: Int?, msg: String) -> Void in
            mv.halt = true
            onFail(code: code, msg: msg)
        }
        
        //3. upload left parts.
        var uploadLeftParts =  {() -> () in
            
            NSLog("begin upload left parts")

            let reader = MultipartLocalFileReader(f: mv.file)
            let total = reader.totalPart()
            mv.totalPart = total
            mv.partSize = reader.getPartSize()
            
            let uploadedNumbers = mv.uploadedParts.map(){ (part: Multipart) -> UInt in
                return part.number
            }
            let uploadedNumbersSet = Set(uploadedNumbers)
            
            
            let totalNumbers = (1...total).map(){$0}
            let totalNumbersSet = Set(totalNumbers)
            
            let needUploadNumbersSet = totalNumbersSet.subtract(uploadedNumbersSet)
            let needUploadNumbers = Array(needUploadNumbersSet)

            for number in needUploadNumbers {
                mv.leftParts.append(Multipart(number: number, key: nil, md5: nil))
            }
            
            self.uploadPartsIteration(onSuccess, onFail: warpOnFail, multipartVideo: mv)
        }
        
        //2. query which part is uploaded.
        var queryParts = {() -> () in
            self.getParts({ (parts) -> Void in
            
                NSLog("has uploaded \(parts.count) parts")
                mv.uploadedParts += parts
                
                uploadLeftParts()
                
            }, onFail: warpOnFail, uploadId: mv.task!.uploadId)
        }
        
        //1. query task exist info, if not exist, init one.
        func initTask() {
        
        list({ (tasks: [MultipartTask]) -> Void in
            
            for task in tasks {
                if task.fileMD5 == fileMD5 && task.fileName == fileName {
                    NSLog("find matched multipart task\(task)")
                    mv.task = task
                    queryParts()
                    break
                }
            }
            
            if nil == mv.task {
                NSLog("init new multipart task")
                self.initMultipart({ (uploadId) -> Void in
                    mv.task = MultipartTask(uploadId: uploadId, fileName: fileName, fileMD5: fileMD5)
                    queryParts()
                }, onFail: warpOnFail, fileName: fileName, fileMD5: fileMD5)
            }
            
        }, onFail: warpOnFail, fileNameLike: nil, fileMD5Equal: nil)
        }
        
        initTask()
    }
    
    /**
    init multipart upload context.
    
    param： onSuccess The closure called if init success, The closure's argument uploadId present upload task id.
    param： onFail The closure called if init fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  fileName The video filename.
    param:  fileMD5 The video MD5.
    
    returns: Void.
    */
    public func initMultipart(onSuccess: (uploadId: String) -> Void, onFail: (code: Int?, msg: String) -> Void, fileName: String, fileMD5: String) {
     
        NSLog("init multipart upload context")
        
        postHTTP("/video/multipartUpload/init.api", params: ["fileName": fileName, "fileMD5": fileMD5], successHandler: { (data, msg) -> Void in
             onSuccess(uploadId: self.anyObjectToString(data["uploadId"])!)
        }, failHandler: onFail)
    }
    
    /**
    upload video part.
    
    param： onSuccess The closure called if upload success, The closure's argument partKey present the key of part, key is created by server, The closure's argument partMD5 present the md5 of part content.
    param： onFail The closure called if upload fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  onProgress The closure called when upload progress changed, The closure's argument val present the upload progress value.
    param:  uploadId The upload task id.
    param:  filePath The video local path.
    param:  partNumber The part number.
    
    returns: Void.
    */
    public func uploadPart(onSucess: (partKey: String, partMD5: String) -> Void, onFail: (code: Int?, msg: String) -> Void, onProgress: (val: Double) -> Void, uploadId: String, filePath: String, partNumber: UInt) {
        
        NSLog("begin upload part \(partNumber)")
 
        var lFile = LocalFile(contentsOfFile: filePath)
        var reader = MultipartLocalFileReader(f: lFile!)
        var fileData = reader.read(partNumber)
      
        if nil == fileData {
            onFail(code: nil, msg: "No data found")
            NSLog("end uploadPart for part is not exist")
            return
        }

        func successHandlerProxy(data: AnyObject, msg: String) {
            onSucess(partKey: anyObjectToString(data["partKey"])!, partMD5: anyObjectToString(data["partMD5"])!)
        }

        uploadHTTP("/video/multipartUpload/uploadPart.api", method: HTTPMethod.POST, fileData: fileData!, fileName: lFile!.name, mimeType: lFile!.mimeType, params: ["uploadId": uploadId, "partNumber": partNumber], progress: onProgress, successHandler: successHandlerProxy, failHandler: onFail)
    }
    
    /**
    upload video part.
    
    param： onSuccess The closure called if upload success, The closure's argument partKey present the key of part, key is created by server, The closure's argument partMD5 present the md5 of part content.
    param： onFail The closure called if upload fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  uploadId The upload task id.
    param:  filePath The video local path.
    param:  partNumber The part number.
    
    returns: Void.
    */
    public func uploadPart(onSucess: (partKey: String, partMD5: String) -> Void, onFail: (code: Int?, msg: String) -> Void, uploadId: String, filePath: String, partNumber: UInt) {
        
        func onProgress(val: Double) {
            NSLog("upload part progress is \(val)")
        }
        
        uploadPart(onSucess, onFail: onFail, onProgress: onProgress, uploadId: uploadId, filePath: filePath, partNumber: partNumber)
    }
    
    /**
    complete multipart upload, this method will create a video.
    
    param： onSuccess The closure called if complete success, The closure's argument video present the new created video, The closure's argument msg present the creation detail.
    param： onFail The closure called if complete fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  uploadId The upload task id.
    param:  partKeys The List contain each part's key.
    param:  catalogId The id determine which catalog will hold created video.
    
    returns: Void.
    */
    public func complete(onSuccess: (video: Video, msg: String) -> Void, onFail: (code: Int?, msg: String) -> Void, uploadId: String, partKeys: [String], catalogId: String) {
        
        var params = ["uploadId": uploadId, "catalogId": catalogId]
   
        var count = 1
        for pn in partKeys {
            params["part\(count++)"] = pn
        }
        
        postHTTP("/video/multipartUpload/complete.api", params: params, successHandler: { (data: AnyObject, msg: String) -> Void in
            onSuccess(video: VideoCreator().create(data), msg: msg)
        }, failHandler: onFail)
    }
    
    /**
    query multipart tasks by condition
    
    param： onSuccess The closure called if query success, The closure's argument tasks present the multipart task list of query result.
    param： onFail The closure called if query fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  fileNameLike The tasks with similar filename will be return.
    param:  fileMD5Equal The tasks with similar filemd5 will be return.
    
    returns: Void.
    */
    public func list(onSuccess: (tasks: [MultipartTask]) -> Void, onFail: (code: Int?, msg: String) -> Void, fileNameLike: String?, fileMD5Equal: String?) {
       
        var params = [String: AnyObject]()
        params["fileNameLike"] = fileNameLike
        params["fileMD5Equal"] = fileMD5Equal
        
        getHTTP("/video/multipartUpload/list.api", params: params, successHandler: { (data, msg) -> Void in
            let multipartUploads = data["multipartUploads"] as! NSArray
            
            var tasks = [MultipartTask]()
            for item in multipartUploads {
                tasks.append(MultipartTask(uploadId: self.anyObjectToString(item["uploadId"])!, fileName: self.anyObjectToString(item["fileName"])!, fileMD5: self.anyObjectToString(item["fileMD5"])!))
            }
            
            onSuccess(tasks: tasks)
            
        }, failHandler: onFail)
    }
    
    /**
    abort multipart task
    
    param： onSuccess The closure called if abort success, The closure's argument fileName present the filename of aborted task.
    param： onFail The closure called if abort fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  fileNameLike The tasks with similar filename will be return.
    param:  fileMD5Equal The tasks with similar filemd5 will be return.
    
    returns: Void.
    */
    public func abort(onSuccess: (fileName: String) -> Void, onFail: (code: Int?, msg: String) -> Void, uploadId: String) {
        
        postHTTP("/video/multipartUpload/abort.api", params: ["uploadId": uploadId], successHandler: { (data, msg) -> Void in
            onSuccess(fileName: self.anyObjectToString(data["fileName"])!)
        }, failHandler: onFail)
    }
    
    /**
    query all parts of multipart task
    
    param： onSuccess The closure called if query success, The closure's argument parts present the Multipart List of task.
    param： onFail The closure called if query fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  uploadId The multipart task id.
    
    returns: Void.
    */
    public func getParts(onSuccess: (parts: [Multipart]) -> Void, onFail: (code: Int?, msg: String) -> Void, uploadId: String) {
        
        getHTTP("/video/multipartUpload/getParts.api", params: ["uploadId": uploadId], successHandler: { (data, msg) -> Void in
            var uploadedParts = data["uploadedParts"] as! NSArray
            var parts = [Multipart]()
            
            for up in uploadedParts {
                parts.append(Multipart(number: self.anyObjectToUInt(up["partNumber"]), key: self.anyObjectToString(up["partKey"])!, md5: self.anyObjectToString(up["partMD5"])!))
            }
            
            onSuccess(parts: parts)
        }, failHandler: onFail)
    }
    
    /**
    delete special parts of multipart task, usually you don't call this method
    
    param： onSuccess The closure called if delete success.
    param： onFail The closure called if delete fail, The closure's argument code presents error code, The closure's argument msg presents the detail reason why fail.
    param:  partKeys The key list for which part should be deleted.
    
    returns: Void.
    */
    public func deleteParts(onSuccess: () -> Void, onFail: (code: Int?, msg: String) -> Void, partKeys: [String]) {
        var str = ""
        
        for var i = 0; i < partKeys.count; i++ {
            if 0 != i {
                str += ","
            }

            str += partKeys[i]
        }
        
        postHTTP("/video/multipartUpload/deleteParts.api", params: ["partKeys": str], successHandler: { (data, msg) -> Void in
            onSuccess()
        }, failHandler: onFail)
    }
}

/**
    AbstractService is a base class, specific biz class should inherit. It provide usful methods to send http request to server.
*/
public class AbstractService {
    
    private let host:String!
    private let accessKey:String!
    private let accessSecret:String!

    private lazy var factory: NetServiceFactory = NetServiceFactory()
    
    public init(host:String, accessKey:String, accessSecret:String) {
        self.host = host
        self.accessKey = accessKey
        self.accessSecret = accessSecret

    }
    
    private func getNetService() -> NetService {
        return factory.create(host, accessKey: accessKey, accessSecrect: accessSecret)
    }
    
    internal func getHTTP(action:String, params:Dictionary<String, AnyObject>, successHandler:(data: AnyObject, msg: String) -> Void, failHandler: (code: Int?, msg: String) -> Void) -> Void {
        getNetService().get(action, params: params, netServiceResponseHandler: getNetServiceResponseHander(successHandler, failHandler: failHandler))
    }
    
    internal func postHTTP(action:String, params:Dictionary<String, AnyObject>, successHandler:(data: AnyObject, msg: String) -> Void, failHandler: (code: Int?, msg: String) -> Void) -> Void {
        getNetService().post(action, params: params, netServiceResponseHandler: getNetServiceResponseHander(successHandler, failHandler: failHandler))
    }
    
    internal func uploadHTTP(action:String, method: HTTPMethod, filePath: String, params: Dictionary<String, AnyObject>, progress: (value: Double) -> Void, successHandler:(data: AnyObject, msg: String) -> Void, failHandler: (code: Int?, msg: String) -> Void) {
        
        getNetService().uploadHTTP(action, method: method, filePath: filePath, params: params, progress: progress, netServiceResponseHandler: getNetServiceResponseHander(successHandler, failHandler: failHandler))
     }
    
    internal func uploadHTTP(action:String, method: HTTPMethod, fileData: NSData, fileName: String, mimeType: String, params: Dictionary<String, AnyObject>, progress: (value: Double) -> Void, successHandler:(data: AnyObject, msg: String) -> Void, failHandler: (code: Int?, msg: String) -> Void) {
        
        getNetService().uploadHTTP(action, method: method, fileData: fileData, fileName: fileName, mimeType: mimeType, params: params, progress: progress, netServiceResponseHandler: getNetServiceResponseHander(successHandler, failHandler: failHandler))
    }

    //to call approprite handler after handle response from server.
    private func getNetServiceResponseHander(successHandler:(data: AnyObject, msg: String) -> Void, failHandler: (code: Int?, msg: String) -> Void) -> ((response: NetServiceResponse) -> Void) {
        return {(response:
            NetServiceResponse) -> Void in
            
            switch response {
            case let .Result(data, msg):
                self.runOnMainQueue({ () -> Void in
                    successHandler(data: data, msg: msg!)
                })
            case let .Error(code, msg):
                self.runOnMainQueue({ () -> Void in
                    failHandler(code: code, msg: msg!)
                })
            }
        }
    }

    //run on main queue, this method will make sure trigger ui refresh if need.
    private func runOnMainQueue(closure: () -> Void) {
        dispatch_async(dispatch_get_main_queue(), closure)
    }
}

//extension this class to convert type
extension AbstractService {
    internal func anyObjectToString(ao: AnyObject?) -> String? {
        return ConvertUtil.anyObjectToString(ao)
    }
    
    internal func anyObjectToUInt(ao: AnyObject?) -> UInt! {
        return ConvertUtil.anyObjectToUInt(ao)
    }
    
    internal func anyObjectToInt(ao: AnyObject?) -> Int {
        return ConvertUtil.anyObjectToInt(ao)
    }
}

class ConvertUtil {
    static func anyObjectToString(ao: AnyObject?) -> String? {
        if nil == ao {
            return nil
        }
        
        if ao is NSString {
            return (ao as! String)
        } else {
            return String(stringInterpolationSegment: ao!).stringByRemovingPercentEncoding!
        }
    }
    
    static func anyObjectToUInt(ao: AnyObject?) -> UInt! {
        return UInt(anyObjectToInt(ao))
    }
    
    static func anyObjectToInt(ao: AnyObject?) -> Int {
        return anyObjectToString(ao)!.toInt()!
    }
}

internal protocol NetService {
    func get(action:String, params:[String: AnyObject], netServiceResponseHandler:(response:NetServiceResponse) -> Void)
    func post(action:String, params:[String: AnyObject], netServiceResponseHandler:(response:NetServiceResponse) -> Void)
    func uploadHTTP(action:String, method: HTTPMethod, filePath: String, params: Dictionary<String, AnyObject>, progress: (value: Double) -> Void, netServiceResponseHandler:(response:NetServiceResponse) -> Void)
    func uploadHTTP(action:String, method: HTTPMethod, fileData: NSData, fileName: String, mimeType: String, params: Dictionary<String, AnyObject>, progress: (value: Double) -> Void, netServiceResponseHandler:(response:NetServiceResponse) -> Void)

}

public enum NetServiceResponse {
    case Error(code:Int?, msg:String?)
    case Result(data:Dictionary<String,AnyObject>, msg:String?)
}

/**
    NetServiceImpl is a implementation of netservice, it call SwiftHTTP framework to send http request.
*/
public class NetServiceImpl: NetService {
    
    var host: String!
    var accessKey: String!
    var accessSecrect: String!
    
    public init(host: String!, accessKey: String!, accessSecrect: String!) {
        self.host = host;
        
        self.accessKey = accessKey
        self.accessSecrect = accessSecrect
    }
    
    public func get(action:String, var params:[String:AnyObject],
        netServiceResponseHandler:(response:NetServiceResponse) -> Void) {
    
        var tuple = initUrlAndParams(action, params: params)
        NSLog("send get request")
        HTTPTask().GET(tuple.url, parameters: tuple.params, completionHandler: getHTTPResponseHandler(netServiceResponseHandler))
    }
    
    public func post(action:String, var params:[String:AnyObject],
        netServiceResponseHandler:(response:NetServiceResponse) -> Void) {
            
        var tuple = initUrlAndParams(action, params: params)
        NSLog("send post request")
        HTTPTask().POST(tuple.url, parameters: tuple.params, completionHandler: getHTTPResponseHandler(netServiceResponseHandler))
    }
    
    public func uploadHTTP(action:String, method: HTTPMethod, filePath: String, params: Dictionary<String, AnyObject>, progress: (value: Double) -> Void, netServiceResponseHandler:(response:NetServiceResponse) -> Void) {
       
        var fileUrl = NSURL(fileURLWithPath: filePath)
        var file = HTTPUpload(fileUrl: fileUrl!)

        uploadHTTP(action, method: method, file: file, params: params, progress: progress, netServiceResponseHandler: netServiceResponseHandler)
    }

    public func uploadHTTP(action:String, method: HTTPMethod, fileData: NSData, fileName: String, mimeType: String, params: Dictionary<String, AnyObject>, progress: (value: Double) -> Void, netServiceResponseHandler:(response:NetServiceResponse) -> Void) {
       uploadHTTP(action, method: method, file: HTTPUpload(data: fileData, fileName: fileName, mimeType: mimeType), params: params, progress: progress, netServiceResponseHandler: netServiceResponseHandler)
    }
    
    private func uploadHTTP(action:String, method: HTTPMethod, file: HTTPUpload, params: Dictionary<String, AnyObject>, progress: (value: Double) -> Void, netServiceResponseHandler:(response:NetServiceResponse) -> Void) {
        var tuple = initUrlAndParams(action, params: params)
        
        var encodeParams = tuple.params
        encodeParams["uploadFile"] = file
        NSLog("append file \"\(file)\" parameter")
        
        NSLog("send upload request")
        HTTPTask().upload(tuple.url, method: method, parameters: encodeParams, progress: progress, completionHandler: getHTTPResponseHandler(netServiceResponseHandler))
    }

    
    private func initUrlAndParams(action: String,  var params:[String:AnyObject]) -> (url: String, params: Dictionary<String, AnyObject>) {
        let url = getUrl(action)
        let params = encode(params)
        
        NSLog("prepare send request to \"\(url)\" width params \"\(params)\"")
        return (url, params)
    }
    
    private func getUrl(action: String) -> String {
        return host + action
    }
    
    //get a common http response handler, this handler response for valid reponse and create ResonseResult.
    private func getHTTPResponseHandler(netServiceResponseHandler:(response:NetServiceResponse) -> Void) -> (httpResp: AnyObject) -> Void {
        return { (httpResp: AnyObject) -> Void in
            
            //io error or security error
            if let err = httpResp.error {
                netServiceResponseHandler(response: .Error(code: nil, msg: String(stringInterpolationSegment: err)))
                return
            }
            
            if let data: AnyObject = (httpResp as! HTTPResponse).responseObject {
                let nsData = (data as! NSData)
            
                //all response must be json format.
                if !(nsData.isValidJson()) {
                    NSLog("response data is invalid json: \(nsData.toNSString())")
                    netServiceResponseHandler(response: .Error(code: nil, msg: nsData.toNSString()?.toString()))
                    return
                }
                
                let json: AnyObject! = nsData.toJson()
                NSLog("get response json: \(json)")
                
                let code = json["statusCode"] as! Int
                let msg = json["message"] as! String
                
                if 0 != code {  // 0 means server answer success
                    netServiceResponseHandler(response: .Error(code: code, msg: msg))
                    return
                }
                
                var dict = json as! Dictionary<String, AnyObject>
                dict.removeValueForKey("statusCode")
                dict.removeValueForKey("message")
                
                netServiceResponseHandler(response: .Result(data: dict, msg: msg))
                return
            }
            
            netServiceResponseHandler(response: .Error(code: nil, msg: "Unkown Issue"))
        }

    }
    
    //append security url parameters.
    func encode(var parameters: Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject> {
        parameters["time"] = Int((NSDate().timeIntervalSince1970 * 1000))
        parameters["accessKey"] = accessKey
        parameters["sign"] = getSign(parameters)
        
        return parameters
    }
    
    /**
        create digit sign for each request
        @param  parameters  url parameters.
        @returns sign.
    */
    func getSign(parameters: Dictionary<String, AnyObject>) -> String! {
        
        let sortedKeys = Array(parameters.keys).sorted(<)
        var code = ""
        
        //serialize parameters
        for k in sortedKeys {
           code += k + "\(parameters[k]!)"
        }
    
        NSLog("get sign phase 1: \(code)")
        
        //append accessSecrect
        code = accessSecrect + code + accessSecrect
        NSLog("get sign phase 2: \(code)")
        
        //md5
        let md5: String! = code.md5()!.lowercaseString
        NSLog("get sign md5: \(md5)")
        
        return md5
    }
}

//A factory response for create NetService.
internal class NetServiceFactory {
    func create(host: String, accessKey: String, accessSecrect: String) -> NetService {
        return NetServiceImpl(host: host, accessKey: accessKey, accessSecrect: accessSecrect)
    }
}

//PropertyChangeDelegate is a delegate get notified when specific object's property has changed.
public protocol PropertyChangeDelegate {
    func onChange(property: String, newValue: Any?, oldValue: Any?)
}

public class PropertyChangeTrait {
    var propertyChangeDelegate: PropertyChangeDelegate?
    
    func propertyChange(property: String, newValue: Any?, oldValue: Any?) {
        if let d = propertyChangeDelegate {
            d.onChange(property, newValue: newValue, oldValue: oldValue)
        }
    }
}

extension String {
    func toNSString() -> NSString? {
        return NSString(string: self)
    }
    
    mutating func replace(replaced: String, withReplace: String) {
        let arr = self.componentsSeparatedByString(replaced)
        self = withReplace.join(arr)
    }
}

extension NSData {
    func toNSString() -> NSString? {
        return NSString(data: self, encoding: NSUTF8StringEncoding)
    }
    
    func isValidJson() -> Bool {
        return toNSString()!.isValidJson()
    }
    
    func toJson() -> AnyObject? {
        return toNSString()!.toJson()
    }
}

extension NSString {
    func toJson() -> AnyObject? {
        let jsonData = self.dataUsingEncoding(NSUTF8StringEncoding)
        let json: AnyObject! = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
                
        return json
    }
    
    func isValidJson() -> Bool {
        var json:AnyObject? = toJson()
        if nil == json {
            return false
        }
        
        return NSJSONSerialization.isValidJSONObject(toJson()!)
    }
    
    func toString() -> String {
        return self as! String
    }
}