# 目的
  为了方便的使用亦云视频提供的在线视频服务，通过封装亦云视频提供的Restful接口，简化IOS开发者开发复杂度，提供SDK访问方式 。
#快速开始
    1.下载并作为库项目导入。
    2.链接VideoSDK.swift文件。
    3.导入第三方库CryptoSwift.framwork和SwiftHTTP.framework，本项目已包含一个副本
#使用
    1.初始化SDK
      let sdk = VideoSDK(host: ovp, accessKey: accessKey, accessSecret: accessSecret)
    2.获得服务
      let catalogService = sdk.getCatalogService()
    3.调用接口
      catalogService.list({ (catalogs) -> Void in
            onSuccess(sdk: sdk)
      }, onFail: onFail)
#接口
##目录接口
### List
  根据查询条件返回视频视频目录列表，根据page和maxResult来对结果行数进行控制。
  
  public func list(onSuccess : (catalogs : [Catalog]) -> Void, onFail : (code : Int?, msg : String) -> Void, nameLike : String, page : Int = 1, maxResult : Int = 100)
### Get
  该接口根据给定的CatalogId返回具体的Catalog信息。
  
  public func get(onSuccess : (catalog : Catalog) -> Void, onFail : (code : Int?, msg : String) -> Void, id : String) 
### Create
  用户可以调用该接口创建一个分类。
  
  public func create(onSuccess : (catalog : Catalog) -> Void, onFail : (code : Int?, msg : String) -> Void,  name : String) 
### Delete
  用户可以调用该接口对视频目录进行删除。只有没有视频的视频目录才能被删除。
  
  public func delete(onSuccess : (catalog : Catalog) -> Void, onFail : (code : Int?, msg : String) -> Void, id : String) 

##视频接口
### List
 根据查询条件列出视频列表
 
 public func list(onSuccess : (videos : [Video]) -> Void, onFail : (code : Int?, msg : String) -> Void, catalogId:String, catalogNameLike:String = "", nameLike:String = "", page:UInt = 1, maxResult : UInt = 100) -> Void 
### Get
 用户可以通过该接口获得一个视频的基本信息。
 
 public func get(onSuccess : (video : Video) -> Void, onFail : (code : Int?, msg : String) -> Void, id : String)
### Upload
 用户可以通过这个接口来上传一个视频，建议大于100M的文件调用断点续传的接口进行上传。该接口还会在上传完视频进行一次转码，转码完成之后会使用回调链接来通知客户程序。
 
 public func upload(onSuccess : (video : Video) -> Void, onFail : (code : Int?, msg : String) -> Void, filePath : String, catalogId : String, name : String, description : String) -> Video

### Delete
 用户可以调用该接口来删除一个视频，删除视频之后所有的转码之后的视频都会被删除，之前拷贝的代码将会无法播放。
 
 public func delete(onSuccess : (msg : String) -> Void, onFail : (code : Int?, msg : String) -> Void, id : String)
##断点上传接口
### Upload
使用Multipart Upload模式上传视频。

public func upload(onSuccess : (video : Video) -> Void, onFail : (code : Int?, msg : String) -> Void, filePath : String, catalog : Catalog) -> MultipartVideo

### InitMultipart
 使用Multipart Upload模式传输数据前，必须先调用该接口来通知Vocchio 云平台初始化一个Multipart Upload事件。该接口会返回一个Vocchio云平台创建的全局唯一的Upload ID，用于标识本次Multipart Upload事件。用户可以根据这个ID来发起相关的操作，如中止Multipart Upload、查询Multipart Upload等。
 
 public func initMultipart(onSuccess : (uploadId : String) -> Void, onFail : (code : Int?, msg : String) -> Void, fileName : String, fileMD5 : String) 
### uploadPart
 在初始化一个Multipart Upload之后，可以根据指定的File Name和 Upload ID来分块（Part）上传数据。每一个上传的Part都有一个标识它的号码（part number，范围是1~10,000）。对于同一个Upload ID，该号码不但唯一标识这一块数据，也标识了这块数据在整个文件内的相对位置。如果你用同一个part号码，上传了新的数据，那么服务器上已有的这个号码的Part数据将被覆盖。除了最后一块Part以外，其他的part最小为1MB；最后一块Part没有大小限制。
  
 public func uploadPart(onSucess : (partKey : String, partMD5 : String) -> Void, onFail : (code : Int?, msg : String) -> Void, onProgress : (val : Double) -> Void, uploadId : String, filePath : String, partNumber : UInt)
### complete
 在将所有数据Part都上传完成后，必须调用Complete Multipart Upload API来完成整个文件的Multipart Upload。在执行该操作时，用户必须提供所有有效的数据Part的列表（包括partNumber和partKey）；服务器收到用户提交的Part列表后，会逐一验证每个数据Part的有效性。当所有的数据Part验证通过后，服务器将把这些数据part组合成一个完整的文件，并且开始转码操作。
如果文件过大，该接口可能会调用超时，超时之后视频平台依然会继续在后台合并文件并且转码。
如果合并文件之后的文件MD5值与给定的文件MD5值不一致，但是链接已经超时，视频平台也会通过回调地址通知MD5值不一致的错误。请参考回调说明章节。

 public func complete(onSuccess : (video : Video, msg : String) -> Void, onFail : (code : Int?, msg : String) -> Void, uploadId : String, partKeys : [String], catalogId : String) 
### List
 用户可以通过该接口查询到那些已经初始化但是还没有Complete或者About的MultipartUpload事件。
 
 public func list(onSuccess : (tasks : [MultipartTask]) -> Void, onFail : (code : Int?, msg : String) -> Void, fileNameLike : String?, fileMD5Equal : String?)
### Abort
 未调用completeMultipartUpload之前调用该接口可以中止一个上传进程，调用该接口成功之后，该进程所有上传的块将会从服务器删除。
  
 public func abort(onSuccess : (fileName : String) -> Void, onFail : (code : Int?, msg : String) -> Void, uploadId : String) {

### GetParts    
 根据给定的uploadId查询出所有已有的在服务器上的块的信息，包括partNumber、partKey和partMD5。获取到这些信息之后，请自行验证服务器上的分片和将要续传的分片内容是否一致。
 
 public func getParts(onSuccess : (parts : [Multipart]) -> Void, onFail : (code : Int?, msg : String) -> Void, uploadId : String) {
    
### DeleteParts
 删除上传的文件分片。
一般情况下，你并不需要手动删除分片，只需要重新上传相应的块变能覆盖错误的分片。但是，在某些情况下，例如你在客户端修改了分片的数量，使得整个文件的分片比已经上传在服务器保存的分片少，你就要手动将服务器上多余的分片调用该接口进行删除。你可以通过 getUploadParts 接口获得所有服务器上的分片信息。

public func deleteParts(onSuccess : () -> Void, onFail : (code : Int?, msg : String) -> Void, partKeys : [String])

##统计接口
### IP
 查询多个相邻时间段内播放视频的不重复IP数，不重复IP数指的是在该段时间内相同IP的访问只被计算一次。查询结果返回一个包含开始时间，结束时间，以及在该段时间内播放视频的不重复IP数的元组数组。
 	
 public func ip(onSuccess : (usages : [Usage<UInt>]) -> Void, onFail : (code : Int?, msg : String) -> Void, field : UsageField, startAt : NSDate, endAt : NSDate)
### Storage
 查询多个相邻时间段内视频的存储信息。返回一个包含开始时间，结束时间，以及视频存储信息的元组数组，视频存储信息以字节为单位。

 public func storage(onSuccess : (usages : [Usage<UInt>]) -> Void, onFail : (code : Int?, msg : String) -> Void, field : UsageField, startAt : NSDate, endAt : NSDate)

### Bandwidth
 查询多个相邻时间段内播放视频的流量信息。返回一个包含开始时间，结束时间，以及播放视频的流量信息的元组数组，流量信息以字节为单位。
 
 public func bandwidth(onSuccess : (usages : [Usage<UInt>]) -> Void, onFail : (code : Int?, msg : String) -> Void, field : UsageField, startAt : NSDate, endAt : NSDate)

### PlayTimes 
 查询多个相邻时间段内视频的播放次数。返回一个包含开始时间，结束时间，以及播放视频数的元组数组。
 
 public func playTimes(onSuccess : (usages : [Usage<UInt>]) -> Void, onFail : (code : Int?, msg : String) -> Void, field : UsageField, startAt : NSDate, endAt : NSDate)
### VideoAdded 
 查询多个相邻时间段内新增视频个数。返回一个包含开始时间，结束时间，以及新增视频个数的元组数组。
 
 public func videoAdded(onSuccess : (usages : [Usage<UInt>]) -> Void, onFail : (code : Int?, msg : String) -> Void, field : UsageField, startAt : NSDate, endAt : NSDate)
### VideoTotal 
 查询多个相邻时间段内总的视频个数。返回一个包含开始时间，结束时间，以及总的视频个数的元组数组。
 
 public func videoTotal(onSuccess : (usages : [Usage<UInt>]) -> Void, onFail : (code : Int?, msg : String) -> Void, field : UsageField, startAt : NSDate, endAt : NSDate) 
# 文件组织

<p> |-CryptoSwift.framework </p>
 <p>|---Headers </p>
<p> |---Modules</p>
<p> |-----CryptoSwift.swiftmodule</p>
<p> |-SwiftHTTP.framework</p>
<p> |---Headers</p>
<p> |---Modules</p>
<p> |-----SwiftHTTP.swiftmodule</p>
<p>  |-VideoSDK</p>
<p>  |-VideoSDK.xcodeproj</p>
<p>  |---project.xcworkspace</p>
<p>  |-----xcuserdata</p>
<p>  |-------kinghai.xcuserdatad</p>
<p>  |---xcuserdata</p>
<p>  |-----kinghai.xcuserdatad</p>
<p>  |-------xcschemes</p>
<p>  |-VideoSDKTests</p>

# TODOs
# Contact
  
