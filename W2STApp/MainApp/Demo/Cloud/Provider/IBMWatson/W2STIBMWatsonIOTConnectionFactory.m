/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

#import "ST_BlueMS-Swift.h"
#import "W2STIBMWatsonIOTFeatureListener.h"
#import "W2STIBMWatsonIOTConnectionFactory.h"
#import <MQTTFramework/MQTTFramework.h>

#define BLUEMX_PAGE_DATA @"https://%@.internetofthings.ibmcloud.com/dashboard/"
#define BLUEMX_BROKER @"%@.messaging.internetofthings.ibmcloud.com"
#define BLUEMX_BROKER_PORT 8883
#define BLUEMX_USERNAME @"use-token-auth"

@implementation W2STIBMWatsonIOTConnectionFactory{
    NSString *mOrganization;
    NSString *mType;
    NSString *mDeviceId;
    NSString *mAuth;
    
}

+(instancetype)createWithOrganization:(NSString*)organization
                           deviceType:(NSString*)type
                             deviceId:(NSString*)deviceId
                           authTocken:(NSString*)auth{
    return [[W2STIBMWatsonIOTConnectionFactory alloc] initWithOrganization:organization
                                                          deviceType:type
                                                            deviceId:deviceId
                                                          authTocken:auth];
}

-(instancetype)initWithOrganization:(NSString*)organization
                         deviceType:(NSString*)type
                           deviceId:(NSString*)deviceId
                         authTocken:(NSString*)auth{
    
    self = [super init];
    
    mOrganization = organization;
    mType = type;
    mDeviceId = deviceId;
    mAuth = auth;
    
    return self;
}

-(id<BlueMSCloudIotClient>) getSession{
    MCMQTTCFSocketTransport *transport = [[MCMQTTCFSocketTransport alloc] init];
    transport.host = [NSString stringWithFormat:BLUEMX_BROKER,mOrganization];
    transport.port = BLUEMX_BROKER_PORT;
    transport.tls=YES;
    
    MCMQTTSession *session = [[MCMQTTSession alloc] init];
    session.transport = transport;
    session.userName=BLUEMX_USERNAME;
    session.password=mAuth;
    session.clientId= [NSString stringWithFormat:@"d:%@:%@:%@",mOrganization,
                       mType,mDeviceId ];
    return [[BlueMSCloudIotMQTTClient alloc]init:session];
}


-(NSURL*) getDataUrl{
    NSString *url = [NSString stringWithFormat:BLUEMX_PAGE_DATA,mOrganization ];
    return [NSURL URLWithString:url];
}

-(id<BlueSTSDKFeatureDelegate>)getFeatureDelegateWithSession:(id<BlueMSCloudIotClient>)session{
    BlueMSCloudIotMQTTClient *connection = (BlueMSCloudIotMQTTClient*)session;
    return [[W2STIBMWatsonIOTFeatureListener alloc]initWithSession:connection.connection];
}

-(BOOL)isSupportedFeature:(BlueSTSDKFeature*)feature{
    return true;
}

-(BOOL)enableCloudFwUpgradeForNode:(nonnull BlueSTSDKNode *)node
                        connection:(nonnull id<BlueMSCloudIotClient>)cloudConnection
                          callback:(nonnull OnFwUpgradeAvailableCallback)callback{
    return false;
}

@end
