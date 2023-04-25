//
//  MultipartFormDataRequest.swift
//  AzureCommunicationUIChat
//
//  Created by Mohamad Mujeeb Urahaman on 01/03/23.
//

import Foundation

struct MultipartFormDataRequest {
    private let boundary: String = UUID().uuidString
    var httpBody = NSMutableData()
    let fileName: String
    let storageAccountEndPoint: String = "https://acsdocumentsa.blob.core.windows.net/"
    let containerName: String = "docfiles/"
    let storageAccountBlobSASToken: String = "?sv=2021-10-04&st=2023-04-25T20%3A04%3A18Z&se=2024-12-17T21%3A04%3A00Z&sr=c&sp=racwdxltf&sig=36l4ulqAYH2in4sqie2iTKYNChR3Z8NzRGiTT5giq28%3D"
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    func addTextField(named name: String, value: String) {
        httpBody.appendString(textFormField(named: name, value: value))
    }
    
    func addDataField(fieldName: String, fileName: String, data: Data, mimeType: String) {
        httpBody.append(dataFormField(fieldName: fieldName,fileName:fileName,data: data, mimeType: mimeType))
    }
    
    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    private func dataFormField(fieldName: String,
                               fileName: String,
                               data: Data,
                               mimeType: String) -> Data {
        let fieldData = NSMutableData()
        
        fieldData.appendString("--\(boundary)\r\n")
        fieldData.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        fieldData.appendString("Content-Type: \(mimeType)\r\n")
        fieldData.appendString("\r\n")
        fieldData.append(data)
        fieldData.appendString("\r\n")
        return fieldData as Data
    }
    
    func asURLRequest() -> URLRequest {
        
        let fullUrl = "\(storageAccountEndPoint)\(containerName)\(fileName)\(storageAccountBlobSASToken)"
        
//        var date:String
//        let formatter3 = DateFormatter()
//        formatter3.dateFormat = "E, dd MMM y HH:mm:ss"
//        if #available(iOS 15, *) {
//            date = formatter3.string(from: Date.now)+" GMT"
//        } else {
//            date = ""
//        }
        var request = URLRequest(url: URL(string: fullUrl)!)
        request.httpMethod = "PUT"
        //request.setValue("attachment; filename=\(fileName)", forHTTPHeaderField: "x-ms-blob-content-disposition")
        request.setValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
        //        request.setValue("v1", forHTTPHeaderField: "x-ms-meta-m1")
        //        request.setValue("v2", forHTTPHeaderField: "x-ms-meta-m2")
        //        request.setValue("2020-04-08", forHTTPHeaderField: "x-ms-version")
        //        request.setValue(date, forHTTPHeaderField: "x-ms-date")
        //        request.setValue("0", forHTTPHeaderField: "content-length")
        //        request.setValue("https://msftdocshareupload.blob.core.windows.net", forHTTPHeaderField: "x-ms-copy-source")
        //        request.setValue("msftdocshareupload:21W6szt/FqODHTrUi4pO3aONN9wZfSghYGWcn2hhA+yW2OvcFt0OEH+eSSXTaLkh0pTassMV6Gdm+ASt27xF8A==", forHTTPHeaderField: "Authorization")
        request.setValue(getMimeType(filenameORfileExtension: self.fileName), forHTTPHeaderField: "content-type")
        
        httpBody.appendString("--\(boundary)--")
        request.httpBody = httpBody as Data
        //print("allHTTPHeaderFields -> ")
        //print(request.allHTTPHeaderFields)
        return request
    }
    
    func getMimeType(filenameORfileExtension: String) -> String {
        var mimeType = "image/png"
        if filenameORfileExtension == "pdf" || filenameORfileExtension.lowercased().contains(".pdf") {
            mimeType = "application/pdf"
        } else if filenameORfileExtension.lowercased().contains("jpeg") || filenameORfileExtension.lowercased().contains("jpg") {
            mimeType = "image/jpeg"
        } else if filenameORfileExtension.lowercased().contains("heic") {
            mimeType = "image/heic"
        } else if filenameORfileExtension.lowercased().contains("doc") || filenameORfileExtension.lowercased().contains("docx") {
            mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        } else if filenameORfileExtension.lowercased().contains("txt") || filenameORfileExtension.lowercased().contains("text") {
            mimeType = "text/plain"
        }
        return mimeType
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

extension URLSession {
    func dataTask(with request: MultipartFormDataRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTask {
        return dataTask(with: request.asURLRequest(), completionHandler: completionHandler)
    }
}
