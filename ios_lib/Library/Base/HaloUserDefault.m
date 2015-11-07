
#import "HaloUserDefault.h"
#import "NSStringExt.h"

@interface HaloUserDefault()
@property (nonatomic,strong) NSUserDefaults *defaults;
@end

@implementation HaloUserDefault

SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloUserDefault)

#pragma mark Instance method

- (void)initialize
{
    /*just a place holder funcation*/
}

- (BOOL)boolForKey:(NSInteger)key defaultValue:(BOOL)defaultValue
{
    NSNumber *result = nil;
    if (key >= KAccountSpecifiedInfoIndex)
    {
        result = [[self currentAccountDict] objectForKey:[NSString stringWithFormat:@"%d", key]];        
    }
    else 
    {
        result = [_defaults objectForKey:[NSString stringWithFormat:@"%d",key]];
    }
    
    return result != nil ? [result boolValue] : defaultValue;
}

- (NSInteger)intForKey:(NSInteger)key defaultValue:(NSInteger)defaultValue
{
	NSNumber *result = nil;
    if (key >= KAccountSpecifiedInfoIndex)
    {
        result = [[self currentAccountDict] objectForKey:[NSString stringWithFormat:@"%d",key]];
    }
    else 
    {
        result = [_defaults objectForKey:[NSString stringWithFormat:@"%d",key]];        
    }
    
    return result != nil ? [result integerValue] : defaultValue;
}

- (double)doubleForKey:(NSInteger)key defaultValue:(double)defaultValue
{
	NSNumber *result = nil;
    
    if (key >= KAccountSpecifiedInfoIndex)
    {
        result = [[self currentAccountDict] objectForKey:[NSString stringWithFormat:@"%d",key]];        
    }
    else
    {
        result = [_defaults objectForKey:[NSString stringWithFormat:@"%d",key]];
    }
    
    return result != nil ? [result doubleValue] : defaultValue;
}

- (int64_t)longLongForKey:(NSInteger)key defaultValue:(double)defaultValue
{
    NSNumber *result = nil;
    
    if (key >= KAccountSpecifiedInfoIndex)
    {
        result = [[self currentAccountDict] objectForKey:[NSString stringWithFormat:@"%d",key]];        
    }
    else
    {
        result = [_defaults objectForKey:[NSString stringWithFormat:@"%d",key]];
    }
    
    return result != nil ? [result longLongValue] : defaultValue;
}

- (NSString*)stringForKey:(NSInteger)key defaultValue:(NSString*)defaultValue
{
	NSString *result = nil;
    if (key >= KAccountSpecifiedInfoIndex)
    {
        result = [[self currentAccountDict] objectForKey:[NSString stringWithFormat:@"%d", key]];
    }
    else 
    {
        result = [_defaults stringForKey:[NSString stringWithFormat:@"%d",key]];
    }
    
    return result != nil ? result : defaultValue;
}

- (NSDate*)dateForKey:(NSInteger)key defaultValue:(NSDate*)defaultValue
{
	NSDate *result = nil;
    if (key >= KAccountSpecifiedInfoIndex)
    {
        result = [[self currentAccountDict] objectForKey:[NSString stringWithFormat:@"%d",key]];        
    }
    else
    {
        result = [_defaults objectForKey:[NSString stringWithFormat:@"%d",key]];
    }
    
    return result != nil ? result : defaultValue;
}

- (NSObject*)valueForKey:(NSString*)key defaultValue:(NSObject*)defaultValue
{
    NSObject *result = [_defaults objectForKey:key];
	if (!result)
    {
		result = defaultValue;
	}
	return result;
}

- (NSInteger)intForStringKey:(NSString *)key defaultValue:(NSInteger)defaultValue;
{
    NSObject *result = [_defaults objectForKey:key];
	if (!result)
    {
		result = @(defaultValue);
	}
	return [(NSNumber *)result integerValue];
}


- (void)setAccountData:(id)data forKey:(NSInteger)key
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setDictionary:[self currentAccountDict]];
    [dict setObject:data forKey:[NSString stringWithFormat:@"%d",key]];
    [_defaults setObject:dict forKey:[self accountKey]];
}

- (void)setBool:(BOOL)value forKey:(NSInteger)key
{
    if (key >= KAccountSpecifiedInfoIndex)
    {
        [self setAccountData:[NSNumber numberWithBool:value] forKey:key];
    }
    else 
    {
        [_defaults setObject:[NSNumber numberWithBool:value] forKey:[NSString stringWithFormat:@"%d",key]];        
    }
	[_defaults synchronize];
}

- (void)setInt:(NSInteger)value forKey:(NSInteger)key
{
    if (key >= KAccountSpecifiedInfoIndex)
    {
        [self setAccountData:[NSNumber numberWithInteger:value] forKey:key];
    }
    else 
    {
        [_defaults setObject:[NSNumber numberWithInteger:value] forKey:[NSString stringWithFormat:@"%d",key]];        
    }
	[_defaults synchronize];
}

- (void)setDouble:(double)value forKey:(NSInteger)key
{
    if (key >= KAccountSpecifiedInfoIndex)
    {
        [self setAccountData:[NSNumber numberWithDouble:value] forKey:key];
    }
    else 
    {
        [_defaults setObject:[NSNumber numberWithDouble:value] forKey:[NSString stringWithFormat:@"%d",key]];        
    }
	[_defaults synchronize];
}

- (void)setLongLong:(int64_t)value forKey:(NSInteger)key
{
    if (key >= KAccountSpecifiedInfoIndex)
    {
        [self setAccountData:[NSNumber numberWithLongLong:value] forKey:key];
    }
    else 
    {
        [_defaults setObject:[NSNumber numberWithLongLong:value] forKey:[NSString stringWithFormat:@"%d",key]];        
    }
	[_defaults synchronize];
}

- (void)setString:(NSString*)value forKey:(NSInteger)key
{    
    if (key >= KAccountSpecifiedInfoIndex)
    {
        [self setAccountData:value forKey:key];
    }
    else 
    {
        [_defaults setObject:value forKey:[NSString stringWithFormat:@"%d",key]];
    }
    
	[_defaults synchronize];
}

- (void)setDate:(NSDate*)value forKey:(NSInteger)key
{
    if (key >= KAccountSpecifiedInfoIndex)
    {
        [self setAccountData:value forKey:key];
    }
    else
    {
        [_defaults setObject:value forKey:[NSString stringWithFormat:@"%d",key]];
    }
	[_defaults synchronize];
}

- (void)setData:(NSObject*)value forKey:(NSInteger)key
{
    if (key >= KAccountSpecifiedInfoIndex)
    {
        [self setAccountData:value forKey:key];
    }
    else
    {
        [_defaults setObject:value forKey:[NSString stringWithFormat:@"%d",key]];
    }
	[_defaults synchronize];
}

- (void)setValue:(NSObject *)value forKey:(NSString *)key
{
    [_defaults setObject:value forKey:key];
	[_defaults synchronize];
}

/*read defaults in Settings.bundle to 'Registration Domain' in-memory-only */
- (void)registerDefaultDefaults
{
	NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Root" ofType:@"plist"];
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
	NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	NSMutableDictionary *defaultDefaults = [NSMutableDictionary dictionaryWithCapacity:prefSpecifierArray.count];
	for (NSDictionary *prefItem in prefSpecifierArray)
	{
		id key          = [prefItem objectForKey:@"Key"];
		id defaultValue = [prefItem objectForKey:@"DefaultValue"];
		if(!key || !defaultValue)
			continue;
		[defaultDefaults setObject:defaultValue forKey:key];
	}
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultDefaults];	
}

- (id)init
{
	if ((self = [super init]))
	{
		self.defaults = [NSUserDefaults standardUserDefaults];
		[self registerDefaultDefaults];
	}
	return self;
}

- (NSString *)accountKey
{
    NSString *key = [self stringForKey:SETTING_KEY_UID defaultValue:@""];
    return key.length > 0 ? [key MD5String] : nil;
}

- (NSDictionary *)currentAccountDict
{
    if([[self accountKey] length] == 0) return nil;
    
    NSDictionary *dict = [_defaults objectForKey:[self accountKey]];
    if (!dict)
    {
        dict = [NSDictionary dictionary];
        [_defaults setObject:dict forKey:[self accountKey]];
    }
    return dict;
}
@end
