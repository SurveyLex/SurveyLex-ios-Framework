//
//  Survey.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// An interactive interface that presents a survey (powered by SurveyLex) for the user to fill.
public class Survey {
    
    /// The NeuroLex API URL prefix
    private static let BASE_URL = "https://api.neurolex.ai/1.0/object/surveys/taker/"
    
    private(set) var surveyID = ""
    private var isAlreadyLoading = false
    private var targetVC: UIViewController?
    private(set) var surveyData: SurveyData?
    
    public var delegate: SurveyResponseDelegate?
    
    /**
     Initializes a new `Survey` front-end by providing a JSON data source.
    
     - Parameters:
        - json: The input json source object to display.
     */
    public init(json: JSON, target: UIViewController) {
        self.surveyData = try! SurveyData(json: json)
        self.surveyID = self.surveyData!.surveyId
        self.targetVC = target
    }
    
    /**
     Initializes a new `Survey` by providing the SurveyLex survey ID.
     
     - Parameters:
        - surveyID: The identifier string associated with the survey (for lookup)
        - target: The view controller instance that will present the survey
    */
    public init(surveyID: String, target: UIViewController) {
        self.surveyID = surveyID
        self.targetVC = target
    }
    
    
    private func load(_ completion: @escaping () -> ()) {
        if isAlreadyLoading { return } // An instance is already running
        let address = Survey.BASE_URL + surveyID
        guard let lookupURL = URL(string: address) else {
            delegate?.surveyReturnedResponse(self, response: .invalidRequest, message: nil)
            return
        }

        let urlRequest = URLRequest(url: lookupURL)
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfig.urlCache = nil
        sessionConfig.timeoutIntervalForRequest = 5.0
        let customSession = URLSession(configuration: sessionConfig)
        
        let task = customSession.dataTask(with: urlRequest) {
            data, response, error in
            
            self.isAlreadyLoading = false
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.surveyReturnedResponse(self, response: .connectionError, message: error!.localizedDescription)
                }
                return
            }
            
            do {
                let json = try JSON(data: data!)
                self.surveyData = try SurveyData(json: json) // Might be invalid
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                // Unable to parse JSON from url data, although connection to the server was established
                
                var msg: String?
                if let json = try? JSON(data: data!) {
                    msg = json.dictionary?["message"]?.string
                }
                DispatchQueue.main.async {
                    self.delegate?.surveyReturnedResponse(self,
                                                          response: .invalidRequest,
                                                          message: msg)
                }
            }
        }
        
        task.resume()
    }
    
    /// Load (or reload if have been loaded previously) the survey but do not present it yet. *Requires internet connection*.
    public func load() {
        surveyData = nil // Clear the cache if the survey has been previously loaded
        self.load { self.delegate?.surveyDidLoad(self) }
    }
    
    /// Load the survey and present it to the user when it is ready. *Requires internet connection*.
    public func loadAndPresent() {
        self.load { self.present() }
    }

    
    /// Present the survey, provided that is has been loaded from the server.
    public func present() {
        
        guard surveyData != nil else {
            delegate?.surveyReturnedResponse(self, response: .invalidRequest, message: nil)
            return
        }
        
        guard surveyData!.fragments.count > 0 else {
            delegate?.surveyReturnedResponse(self, response: .emptySurvey, message: nil)
            return
        }
        
        
        let mySurvey = SurveyViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        mySurvey.survey = self
        
        // The reason we copy both the survey and the survey data is to prevent the possiblity of setting survey.surveyData = nil during the survey's presentation to the user.
        mySurvey.surveyData = surveyData!
        
        let nav = SurveyNavigationController(rootViewController: mySurvey)
        self.targetVC?.present(nav, animated: true, completion: nil)
    }
    
}


extension Survey {
    
    /// The response status of the survey.
    public enum Response : Int {
        
        /// The survey was closed before the user submitted their response.
        case cancelled = 0
        
        /// The survey was successfully submitted.
        case submitted = 1
        
        /// An invalid survey ID or authorization header was provided.
        case invalidRequest = -1
        
        /// The user does not have a valid internet connection.
        case connectionError = -2
        
        /// The survey has no content.
        case emptySurvey = -3
    }
}
