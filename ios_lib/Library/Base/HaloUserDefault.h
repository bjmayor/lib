
#import <Foundation/Foundation.h>
typedef enum
{
	ELaunchViewLast,
	ELaunchViewRoot
} LaunchViewType;

enum {
    SETTING_KEY_USER_VERIFIED = 0,
    SETTING_KEY_SESSIONID = 1,
    SETTING_KEY_PWD = 3,
    SETTING_KEY_USERID_TYPE = 5,
    SETTING_KEY_UID = 6,
    SETTING_KEY_ACCOUNT_ID = 7,
    SETTING_KEY_COUNTRY_CODE = 8,
    SETTING_KEY_COUNTRY_ISO = 9,
    
    SETTING_KEY_UPDATE = 100,
    SETTING_KEY_UPDATE_ALERT_TIME = 101,
    SETTING_KEY_UPDATE_VERSION = 102,
    SETTING_KEY_UPDATE_URL = 103,
    SETTING_KEY_UPDATE_LAST_CHECK = 104,
    SETTING_KEY_UPDATE_DESC = 105,
    SETTING_KEY_UPDATE_TIME = 106,
    SETTING_KEY_FIRST_SHAKE = 107,

};
#define KAccountSpecifiedInfoIndex 1000
@interface HaloUserDefault : NSObject 
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloUserDefault)

- (void)initialize;

- (BOOL)boolForKey:(NSInteger)key defaultValue:(BOOL)defaultValue;
- (NSInteger)intForKey:(NSInteger)key defaultValue:(NSInteger)defaultValue;
- (double)doubleForKey:(NSInteger)key defaultValue:(double)defaultValue;
- (int64_t)longLongForKey:(NSInteger)key defaultValue:(double)defaultValue;
- (NSString*)stringForKey:(NSInteger)key defaultValue:(NSString*)defaultValue;
- (NSDate*)dateForKey:(NSInteger)key defaultValue:(NSDate*)defaultValue;
- (NSObject*)valueForKey:(NSString*)key defaultValue:(NSObject*)defaultValue;
- (NSInteger)intForStringKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

- (void)setBool:(BOOL)value forKey:(NSInteger)key;
- (void)setInt:(NSInteger)value forKey:(NSInteger)key;
- (void)setDouble:(double)value forKey:(NSInteger)key;
- (void)setLongLong:(int64_t)value forKey:(NSInteger)key;
- (void)setString:(NSString*)value forKey:(NSInteger)key;
- (void)setDate:(NSDate*)value forKey:(NSInteger)key;
- (void)setData:(NSObject*)value forKey:(NSInteger)key;
- (void)setValue:(NSObject*)value forKey:(NSString*)key;
@end
