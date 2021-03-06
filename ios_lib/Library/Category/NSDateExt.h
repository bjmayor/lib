//
//  NSDateExt.h
//  HaloSlimFramework
//
//  Created by  on 13-6-8.
//
//

#import <Foundation/Foundation.h>

typedef enum
{
    EDateStyleYMDHM = 0,//yMd hms
    EDateStyleMDHM, // no年
    EDateStyleHM,//hour minute
    EDateStyleYMD,
    EDateStyleSmart, //xx s before,if date after now will display '1 s ago'
    EDateStyleSmartWithAfter, //xx s before or after xx s
    EDateStyleSimple
}HaloDateStyle;


@interface NSDate (Ext)
+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
- (NSString*)formatDateStyle:(HaloDateStyle)style;

- (NSString*)formatFullDate;
//- (NSString*)formatDateStyle:EDateStyleYMD;
//- (NSString*)formateTime;

- (NSString*)formatDateSimple;
- (NSString*)formatDateSmart;
- (NSString*)formatDateCountdown;
- (NSString*)formatDateSmartWithAfter:(BOOL)after;
- (NSString*)intervalSince1970;

- (NSUInteger)daysAgo;
- (NSUInteger)daysAgoAgainstMidnight;
- (NSString *)stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger)weekday;

+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime;

- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfDay;
- (NSDate *)endOfWeek;

+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)dbFormatString;
+ (void)resetFormatterLocale;
@end
