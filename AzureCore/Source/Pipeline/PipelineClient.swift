//
//  PipelineClientBase.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

open class PipelineClient {

    public var logger: ClientLogger

    internal var pipeline: Pipeline
    internal var baseUrl: String

    public init(baseUrl: String, transport: HttpTransportable, policies: [PipelineStageProtocol],
                logger: ClientLogger) {
        self.baseUrl = baseUrl
        if self.baseUrl.suffix(1) != "/" { self.baseUrl += "/" }
        self.logger = logger
        self.pipeline = Pipeline(transport: transport, policies: policies)
    }

    public func run(request: HttpRequest, allowedStatusCodes: [Int],
                    completion: @escaping (Result<Data?, Error>, HttpResponse) -> Void) {
        var pipelineRequest = PipelineRequest(request: request, logger: logger)
        self.pipeline.run(request: &pipelineRequest, completion: { result, httpResponse in
            switch result {
            case .success(let pipelineResponse):
                let deserializedData = pipelineResponse.getValue(forKey: .deserializedData) as? Data

                // invalid status code is a failure
                let statusCode = httpResponse.statusCode ?? -1
                if !allowedStatusCodes.contains(httpResponse.statusCode ?? -1) {
                    var message = "Service returned invalid status code [\(statusCode)]."
                    if let errorData = deserializedData,
                       let errorJson = try? JSONSerialization.jsonObject(with: errorData) {
                        message += " \(String(describing: errorJson))"
                    }
                    let error = HttpResponseError.statusCode(message)
                    completion(.failure(error), httpResponse)
                    return
                }

                if let deserialized = deserializedData {
                    completion(.success(deserialized), httpResponse)
                } else {
                    let error = HttpResponseError.decode("Deserialized data expected but not found.")
                    completion(.failure(error), httpResponse)
                }
            case .failure(let error):
                completion(.failure(error), httpResponse)
            }
        })
    }

    public func request(method: HttpMethod, url: String, queryParams: [String: String], headerParams: HttpHeaders,
                        content: Data? = nil, formContent: [String: AnyObject]? = nil,
                        streamContent: AnyObject? = nil) -> HttpRequest {
        let request = HttpRequest(httpMethod: method, url: url, headers: headerParams)
        request.format(queryParams: queryParams)
        return request
    }

    public func format(urlTemplate: String?, withKwargs kwargs: [String: String] = [String: String]()) -> String {
        var template = urlTemplate ?? ""
        if template.hasPrefix("/") { template = String(template.dropFirst()) }
        var url = baseUrl + template
        for (key, value) in kwargs {
            url = url.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return url
    }
}