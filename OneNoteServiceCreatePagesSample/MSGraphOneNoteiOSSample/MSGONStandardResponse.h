//*********************************************************
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the ""License"");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED ON AN  *AS IS* BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS
// OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT.
//
// See the Apache Version 2.0 License for specific language
// governing permissions and limitations under the License.
//*********************************************************

#import <Foundation/Foundation.h>

@interface MSGONStandardResponse: NSObject

@property int httpStatusCode;
@property (copy) NSString* correlationId;

@end

@interface MSGONStandardErrorResponse: MSGONStandardResponse

@property (copy) NSString *message;

@end

@interface MSGONCreateSuccessResponse: MSGONStandardResponse

@property (copy) NSString *oneNoteClientUrl;
@property (copy) NSString *oneNoteWebUrl;

@end

@interface MSGONGetSuccessResponse: MSGONStandardResponse

@property (copy) id oDataContext;
@property (copy) NSString *body;

@end

