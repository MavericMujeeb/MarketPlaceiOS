//------------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "MSALTokenParameters.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Token parameters to be used when MSAL is getting a token silently.
 */
@interface MSALSilentTokenParameters : MSALTokenParameters

#pragma mark - Configuring MSALSilentTokenParameters

/**
 Ignore any existing access token in the cache and force MSAL to
 get a new access token from the service.
 */
@property (nonatomic) BOOL forceRefresh;

/**
 1. When Sso Extension is presenting on the device
    Default is YES. when Sso Extension failed to return a (new) access token, tries with existing refresh token in the cache, and return results.
    If set to NO, when Sso Extension failed to return a (new) access token, ignores existing refresh token in local cahce, and return Sso Extension error.
 2. When Sso Extension is not presenting on the device
    This parameter is ignored, and tries with existing refresh token in the cache.
 */
@property (nonatomic) BOOL allowUsingLocalCachedRtWhenSsoExtFailed;

#pragma mark - Constructing MSALSilentTokenParameters

/**
 Initialize a MSALSilentTokenParameters with scopes and account.
 
 @param scopes      Permissions you want included in the access token received
                    in the result in the completionBlock. Not all scopes are
                    guaranteed to be included in the access token returned.
 @param account     An account object retrieved from the MSALResult object that MSAL should return a token for.
 */
- (instancetype)initWithScopes:(NSArray<NSString *> *)scopes
                       account:(MSALAccount *)account NS_DESIGNATED_INITIALIZER;

/**
Initialize a MSALSilentTokenParameters with scopes and account.

@param scopes      Permissions you want included in the access token received
                   in the result in the completionBlock. Not all scopes are
                   guaranteed to be included in the access token returned.
*/
- (instancetype)initWithScopes:(NSArray<NSString *> *)scopes NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
