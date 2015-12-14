//
//  CMTestEncoder.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 4/19/14.
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//

#import "CMObject.h"
#import "CMCoding.h"

@interface CMTestEncoderInt : CMObject

@property (nonatomic, assign) NSInteger anInt;

@end

@interface CMTestEncoderInt32 : CMObject

@property (nonatomic, assign) int32_t anInt;

@end

@interface CMTestEncoderBool : CMObject

@property (nonatomic, assign) BOOL aBool;

@end

@interface CMTestEncoderFloat : CMObject

@property (nonatomic, assign) CGFloat aFloat;

@end

@interface CMTestEncoderUUID : CMObject

@property (nonatomic, strong) NSUUID *uuid;

@end

@interface CMTestEncoderNSCoding : NSObject <CMCoding>

@property (nonatomic, copy) NSString *aString;
@property (nonatomic, assign) NSInteger anInt;

@end

@interface CMTestEncoderNSCodingParent : CMObject

@property (nonatomic, strong) CMTestEncoderNSCoding *something;

@end

@interface CMTestEncoderNSCodingDeeper : CMTestEncoderNSCoding <CMCoding>

@property (nonatomic, strong) CMTestEncoderFloat *nestedCMObject;

@end