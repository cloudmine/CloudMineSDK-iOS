//
//  CloudMine.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

/**
 * @mainpage
 *
 * @section important Important
 * This framework uses <a href="https://developer.apple.com/library/ios/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html" target="_blank">ARC</a> (Automatic Reference Counting) and is thus compatible only with XCode 4.1 or higher and iOS 4 or higher.
 *
 * @section intro Introduction
 * The native iOS library allows you to interact with your CloudMine remote data store, create and manage user accounts, and execute your custom server-side code snippets in a clean, object-oriented fashion, without having to manage connection pools or assemble URLs.
 *
 * Before getting started, you must first use the <strong><a href="interface_c_m_a_p_i_credentials.html">CMAPICredentials</a></strong> singleton to configure your app's identifier and secret from your <a href="https://cloudmine.me/dashboard" target="_blank">CloudMine Dashboard</a>.
 *
 * The most important classes to know are <a href="interface_c_m_store.html"><strong>CMStore</strong></a> and <a href="interface_c_m_user.html"><strong>CMUser</strong></a>. <strong>CMStore</strong> is like a box for all your app's <a href="http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller#Concepts" target="_blank">models</a>. All of your storage and retrieval operations are coordinated through it. CMUser represents an account for a user of your app. See the <a href="interface_c_m_user.html">framework reference</a> for more details on users, security, and session tokens.
 *
 * Each of your model classes that you want to be managed by a CMStore <em>must</em> either extend <strong><a href="interface_c_m_object.html">CMObject</a></strong> or implement <strong><a href="protocol_c_m_serializable-p.html">CMSerializable</a></strong>. The former provides an easier-to-use turnkey implementation, and is recommended over implementing the latter yourself. You must also implement <tt><a href="https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/Reference/Reference.html" target="_blank">initWithCoder:</a></tt> and <tt><a href="https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/Reference/Reference.html" target="_blank">encodeWithCoder:</a></tt> in all <strong>CMObject</strong> subclasses so the framework knows how to serialize your objects.
 *
 * If you need to store geospatial information within any of your objects, use an instance of the provided <strong><a href="interface_c_m_geo_point.html">CMGeoPoint</a></strong> class.
 *
 * All operations that involve a remote call are performed asynchronously. This means that you don't need to worry about blocking the UI thread when interacting with CloudMine. Each one of these methods takes one or more callback <a href="https://developer.apple.com/library/ios/#documentation/cocoa/Conceptual/Blocks/Articles/00_Introduction.html" target="_blank">blocks</a> as the last parameter(s) that will be executed when the operation completes.
 *
 * The framework has the following external framework dependencies, which you must setup in your app's XCode project:
 * - CFNetwork
 * - SystemConfiguration
 * - MobileCoreServices
 * - CoreGraphics
 * - UIKit
 * - libz
 *
 * The <a href="https://cloudmine.me/docs/ios/tutorial" target="_blank">video walkthrough</a> below shows you how to do this.
 */

#import "CMAPICredentials.h"
#import "CMDate.h"
#import "CMDistance.h"
#import "CMUntypedObject.h"
#import "CMFile.h"
#import "CMGeoPoint.h"
#import "CMACL.h"
#import "CMMimeType.h"
#import "CMObject.h"
#import "CMObjectClassNameRegistry.h"
#import "CMObjectDecoder.h"
#import "CMObjectEncoder.h"
#import "CMObjectOwnershipLevel.h"
#import "CMObjectSerialization.h"
#import "CMPagingDescriptor.h"
#import "CMSerializable.h"
#import "CMCoding.h"
#import "CMServerFunction.h"
#import "CMSortDescriptor.h"
#import "CMStore.h"
#import "CMStoreCallbacks.h"
#import "CMStoreOptions.h"
#import "CMNullStore.h"
#import "CMUser.h"
#import "CMUserAccountResult.h"
#import "CMWebService.h"
#import "CMAppDelegateBase.h"

#import "CMSocialLoginViewController.h"

#import "CMACLFetchResponse.h"
#import "CMObjectFetchResponse.h"
#import "CMObjectUploadResponse.h"
#import "CMFileFetchResponse.h"
#import "CMFileUploadResult.h"
#import "CMDeleteResponse.h"
#import "CMChannelResponse.h"
#import "CMUserResponse.h"

#import "UIImageView+CloudMine.h"
