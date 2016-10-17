/**
 Extending \b PubNub class with properties and methods which can be used internally by \b PubNub client.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */

#import "PNPrivateImports.h"
#import "PNConnectionChannelDelegate.h"
#import "PNServiceChannelDelegate.h"
#import "PNMessageChannelDelegate.h"
#import "PNDelegate.h"
#import "PNMacro.h"
#import "PubNub.h"


@class PNConfiguration, PNReachability, PNCryptoHelper, PNBaseRequest, PNCache;


#pragma mark Static

typedef enum _PNPubNubClientState {

    // Client instance was reset
    PNPubNubClientStateReset,
    
    // Client instance was just created
    PNPubNubClientStateCreated,
    
    // Client is trying to establish connection to remote PubNub services
    PNPubNubClientStateConnecting,
    
    // Client successfully connected to remote PubNub services
    PNPubNubClientStateConnected,
    
    // Client is disconnecting from remote services
    PNPubNubClientStateDisconnecting,
    
    // Client closing connection because configuration has been changed while client was connected
    PNPubNubClientStateDisconnectingOnConfigurationChange,
    
    // Client is disconnecting from remote services because of network failure
    PNPubNubClientStateDisconnectingOnNetworkError,
    
    // Client disconnected from remote PubNub services (by user request)
    PNPubNubClientStateDisconnected,

    PNPubNubClientStateSuspended,
    
    // Client disconnected from remote PubNub service because of network failure
    PNPubNubClientStateDisconnectedOnNetworkError
} PNPubNubClientState;


#pragma mark - Private interface declaration

@interface PubNub (Protected)


#pragma mark - Properties

/**
 Stores current client state.
 */
@property (nonatomic, assign) PNPubNubClientState state;

/**
 Stores reference on observation center which has been configured for this \b PubNub client.
 */
@property (nonatomic, strong) PNObservationCenter *observationCenter;

/**
 Reference on channels which is used to communicate with \b PubNub service
 */
@property (nonatomic, strong) PNMessagingChannel *messagingChannel;

/**
 Reference on channels which is used to send service messages to \b PubNub service
 */
@property (nonatomic, strong) PNServiceChannel *serviceChannel;

/**
 Stores reference on crypto helper tool which is used on message encryption/descryption.
 */
@property (nonatomic, strong) PNCryptoHelper *cryptoHelper;

/**
 Stores reference on local \b PubNub cache instance which will cache some portion of data.
 */
@property (nonatomic, strong) PNCache *cache;

/**
 Stores reference on configuration which was used to perform initial PubNub client initialization.
 */
@property (nonatomic, strong) PNConfiguration *clientConfiguration;

/**
 Stores reference on current client identifier.
 */
@property (nonatomic, copy) NSString *uniqueClientIdentifier;

/**
 Stores reference on client delegate
 */
@property (nonatomic, pn_desired_weak) id<PNDelegate> clientDelegate;

/**
 Stores whether library is performing one of async locking methods or not (if yes, other calls will be placed
 into pending set)
 */
@property (nonatomic, assign, getter = isAsyncLockingOperationInProgress) BOOL asyncLockingOperationInProgress;

/**
 Stores whether client updating client identifier or not
 */
@property (nonatomic, assign, getter = isUpdatingClientIdentifier) BOOL updatingClientIdentifier;

/**
 Stores whether client is restoring connection after network failure or not
 */
@property (nonatomic, assign, getter = isRestoringConnection) BOOL restoringConnection;


#pragma mark - Instance methods

/**
 Reschedule \b PubNub method call. Depending on whether client will perform some actions on it's own, this method will
 deal with procedural lock to make sure that re-scheduled method will be triggered in time.
 
 @param methodBlock
 Block which contains reference on method call which should be launched again w/o handling block modification.
 */
- (void)rescheduleMethodCall:(void(^)(void))methodBlock;

/**
 @brief Check whether delegate should be notified about some runtime event (errors will be 
        notified w/o regard to this flag)
 
 @param channel              Reference on connection channel at which callback is fired.
 @param checkCompletionBlock Check completion block which pass only one parameter - \c YES in 
                             case if reporting channel is in correct state and it's callback 
                             should be taken into account.
 */
- (void)checkShouldChannelNotifyAboutEvent:(PNConnectionChannel *)channel
                                 withBlock:(void (^)(BOOL shouldNotify))checkCompletionBlock;

/**
 Launch heartbeat timer if possible (if client connected and there is channels on which client subscribed at this
 moment).
 */
- (void)launchHeartbeatTimer;

/**
 Disable previously launched heartbeat timer.
 */
- (void)stopHeartbeatTimer;

/**
 @brief      Disable previously launched heartbeat timer.
 
 @discussion In case if stop is called as part of timer re-launch process, this method won't 
             remove reference on heartbeat timer dispatch source on instance property.
 
 @param forRelaunch Whether timer has been stopped for further re-launch.
 */
- (void)stopHeartbeatTimer:(BOOL)forRelaunch;

/**
 @brief      Completely destroy GCD timer.
 @discussion Mostly this method drops requirement to execute code on private queue and should be 
             called as last possible action in client life-cycle.
 
 @param shouldClearReference Whether reference on GCD timer should be destroyed or not.
 
 @since 3.7.9.2
 */
- (void)destroyHeartbeatTimer:(BOOL)shouldClearReference;


#pragma mark - Requests management methods

/**
 * Sends message over corresponding communication channel
 */
- (void)sendRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing;


#pragma mark - Handler methods

/**
 @brief Handle locking operation completion and pop new one from pending invocations list.
 
 @param shouldStartNext                  If set to \c YES next postponed method call will be
                                         executed.
 @param isBurstExecutionLockingOperation Whether one of burst execution locking operations has been
                                         completed or not.
 */
- (void)handleLockingOperationComplete:(BOOL)shouldStartNext
        burstExecutionLockingOperation:(BOOL)isBurstExecutionLockingOperation;

/**
 @brief Handle locking operation completion and pop new one from pending invocations list.
 
 @param operationPostBlock               Block which is called when locking operation completed.
 @param shouldStartNext                  If set to \c YES next postponed method call will be
                                         executed.
 @param isBurstExecutionLockingOperation Whether one of burst execution locking operations has been
                                         completed or not.
 */
- (void)handleLockingOperationBlockCompletion:(void (^)(void))operationPostBlock
                              shouldStartNext:(BOOL)shouldStartNext
               burstExecutionLockingOperation:(BOOL)isBurstExecutionLockingOperation;

/**
 @brief Process list of postponed method calls and execute next one in a row.

 @since 3.7.9
 */
- (void)callNextPostponedMethod;


#pragma mark - Misc methods

/**
 Retrieve request execution possibility code. If everything is fine, than 0 will be returned, in other case it will
 be treated as error and mean that request execution is impossible
 */
- (NSInteger)requestExecutionPossibilityStatusCode;

/**
 Allow to perform code which should lock asynchronous methods execution till it ends and in case if code itself
 should be postponed, corresponding block is passed.
 
 @param codeBlock
 Block of code which should be performed if procedural lock is turned off.
 
 @param postponedCodeBlock
 Block of code which will be called if procedural lock is on and doesn't allow to run another operation,
 */
- (void)performAsyncLockingBlock:(void (^)(void))codeBlock
         postponedExecutionBlock:(void (^)(void))postponedCodeBlock
  burstExecutionLockingOperation:(BOOL)isBurstExecutionLockingOperation;

/**
 * Place selector into list of postponed calls with corresponding parameters If 'placeOutOfOrder' is specified,
 * selector will be placed first in FIFO queue and will be executed as soon as it will be possible.
 */
- (void)postponeSelector:(SEL)calledMethodSelector forObject:(id)object
          withParameters:(NSArray *)parameters outOfOrder:(BOOL)placeOutOfOrder
      burstExecutionLock:(BOOL)requiresBurstExecutionLock;

/**
 @brief Wrap around NSNotificationCenter to simplify notification sending.
 
 @param notificationName Name of notification which should be sent.
 @param object           Reference on object along with which notification should be sent.
 @param callbackToken    Reference on unique token which has been provided to observer along with
                         callback block.

 @since 3.7.9
 */
- (void)sendNotification:(NSString *)notificationName withObject:(id)object
        andCallbackToken:(NSString *)callbackToken;

/**
 Convert provided client state informatino into human-readable format.
 
 @param state
 One field from \b PNPubNubClientState enumerator.
 
 @return Formatted string
 */
- (NSString *)humanReadableStateFrom:(PNPubNubClientState)state;

#pragma mark -


@end
