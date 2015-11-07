//
//  HttpEngine+Book.m
//  DDDict
//
//  Created by Peter on 13-6-12.
//
//

#import "HttpEngine+Book.h"
#import "WordInfo.h"
#import "DataManager.h"
#import "TMCache.h"

@implementation HttpEngine (Book)

- (WordInfo *)parseWord:(NSDictionary *)word
{
    WordInfo *info = [[WordInfo alloc] init];
    info.wordId = [word[TAG_ID] integerValue];
    info.content = word[TAG_CONTENT];

    if(word[TAG_US_PHONETIC]==nil)
        info.isChinese = YES;
    else
        info.isChinese = NO;
    
    NSArray *trans = word[TAG_TRAN];
    for (NSDictionary *tran in trans)
    {
        TranslateInfo *tranInfo = [TranslateInfo infoWithContent:tran[TAG_CONTENT] property:tran[TAG_PROPERTY]];
        tranInfo.wordId = [tran[TAG_EN_ID] intValue];
        [info addTranslate:tranInfo];
    }
    
    info.localSaved = NO;
    return info;
}

- (void)searchWord:(NSString *)key delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_KEY] = key;
    params[TAG_LIMIT] = @(10);
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpWordSearch properties:PROP_NORMAL_NO_WAITDLG params:params];
    request.timeout = 1;
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error){
        //parse data here return id
        NSArray *words = data;
        NSMutableArray *result = [NSMutableArray array];
        for (NSDictionary *word in words)
        {
            WordInfo *info = [self parseWord:word];
            [result addObject:info];
        }
        return result;
    } responseBlock:block];
}

- (WordInfo *)parseWordInfo:(NSDictionary *)data
{
    if (data.allKeys.count == 0)
    {
        return nil;
    }
    WordInfo *wordInfo = [[WordInfo alloc] init];
    NSDictionary *wordDict = data;
    wordInfo.wordId = [wordDict[TAG_ID] integerValue];
    wordInfo.content = wordDict[TAG_CONTENT];
    for (NSDictionary *tran in wordDict[TAG_TRAN])
    {
        TranslateInfo *tranInfo = [[TranslateInfo alloc] init];
        tranInfo.content = tran[TAG_CONTENT];
        tranInfo.property = tran[TAG_PROPERTY];
        [wordInfo addTranslate:tranInfo];
    }
    
    wordInfo.usPhonetic = wordDict[TAG_US_PHONETIC];
    wordInfo.ukPhonetic = wordDict[TAG_UK_PHONETIC];
    
    NSDictionary *past = wordDict[TAG_PAST];
    for (NSDictionary *dict in past[TAG_TENSE])
    {
        [wordInfo addPastTense:dict[TAG_CONTENT]];
    }
    
    NSDictionary *definition = wordDict[TAG_DEFINITION];
    for (NSDictionary *dict in definition)
    {
        EnglishDefInfo *info = [[EnglishDefInfo alloc] init];
        info.content = dict[TAG_CONTENT];
        info.property = dict[TAG_PROPERTY];
        info.example = dict[TAG_EXAM];
        [wordInfo addEnglishDefinition:info];
    }
    
    for (NSDictionary *dict in past[TAG_PARTICIPLE])
    {
        [wordInfo addPastParticiple:dict[TAG_CONTENT]];
    }
    
    for (NSDictionary *dict in wordDict[TAG_PHRASE])
    {
        PhraseInfo *info = [PhraseInfo infoWithContent:dict[TAG_CONTENT] translate:dict[TAG_TRAN]];
        [wordInfo addPhrase:info];
    }
    
    for (NSDictionary *dict in wordDict[TAG_SENTENCE])
    {
        PhraseInfo *info = [PhraseInfo infoWithContent:dict[TAG_CONTENT] translate:dict[TAG_TRAN]];
        [wordInfo addSentence:info];
    }
    
    for (NSDictionary *dict in wordDict[TAG_CONJUGATE])
    {
        WordBasicInfo *conjugate = [[WordBasicInfo alloc] init];
        conjugate.wordId = [dict[TAG_ID] intValue];
        conjugate.content = dict[TAG_CONTENT];
        
        TranslateInfo *tranInfo = [[TranslateInfo alloc] init];
        tranInfo.content = dict[TAG_TRAN];
        tranInfo.property = dict[TAG_PROPERTY];
        [conjugate addTranslate:tranInfo];
        [wordInfo addConjugate:conjugate];
    }
    
    for (NSDictionary *dict in wordDict[TAG_SYNO])
    {
        SynoInfo *syno = [[SynoInfo alloc] init];
        syno.content = dict[TAG_TRAN][TAG_CONTENT];
        syno.property = dict[TAG_TRAN][TAG_PROPERTY];
        
        for (NSDictionary *wd in dict[TAG_WORD])
        {
            WordBasicInfo *word = [[WordBasicInfo alloc] init];
            word.wordId = [wd[TAG_ID] intValue];
            word.content = wd[TAG_CONTENT];
            [syno addWord:word];
        }
        
        [wordInfo addSyno:syno];
    }
    return wordInfo;
}

- (void)getZhWordDetail:(NSInteger)wordId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_ID] = @(wordId);
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpWordZhDetail properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error){
        //parse data here return id
        WordInfo *wordInfo = [[WordInfo alloc] init];
        wordInfo.wordId = wordId;
        for (NSDictionary *word in data)
        {
            WordBasicInfo *basic = [WordBasicInfo wordWithId:[word[TAG_ID] integerValue] content:word[TAG_CONTENT]];
            NSArray *tran = word[TAG_TRAN];
            for (NSDictionary *t in tran)
            {
                TranslateInfo *info = [TranslateInfo infoWithContent:t[TAG_CONTENT] property:t[TAG_PROPERTY]];
                [basic addTranslate:info];
            }
            [wordInfo addChineseTran:basic];
        }
        return wordInfo;
    } responseBlock:block];

}

- (void)getWordDetail:(NSInteger)wordId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_ID] = @(wordId);
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpWordDetail properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error){
        return [self parseWordInfo:data];
    } responseBlock:block];

}

- (void)getWordDetailByKey:(NSString *)word delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[TAG_KEY] = word;
    HaloHttpRequest *request = [self makeGetRequestByTag:EHttpWordDetailByKey properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error){
        return [self parseWordInfo:data];
    } responseBlock:block];
}

- (void)sync:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    HaloUserDefault *userDefault = [HaloUserDefault sharedInstance];
    NSString *syncTime = [userDefault stringForKey:SETTING_KEY_SYNC_TIME defaultValue:@"0"];
    NSDate *syncLocalTime = [userDefault dateForKey:SETTING_KEY_SYNC_LOCAL_TIME defaultValue:nil];
    NSDate *now = [NSDate date];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    DataManager *dataManager = [DataManager sharedInstance];
    if([dataManager bookIsNull])
    {
        syncTime = 0;
        syncLocalTime = 0;
    }
    NSLog(@"stamp %@ %@",syncTime,syncLocalTime);
    params[TAG_STAMP] = syncTime;
    
    NSArray *add = [dataManager getSyncUserAddWords:syncLocalTime];
    if (add.count > 0)
    {
        params[TAG_ADD] = add;
    }
    if ([syncTime longLongValue] > 0)
    {
        NSArray *del = [dataManager getSyncUserDelWordIds:syncLocalTime];
        if (del.count > 0)
        {
            params[TAG_DEL] = del;
        }        
    }
    HaloHttpRequest *request = [self makePostRequestByTag:EHttpWordSync properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error){
        [userDefault setString:data[TAG_STAMP] forKey:SETTING_KEY_SYNC_TIME];
        [userDefault setDate:now forKey:SETTING_KEY_SYNC_LOCAL_TIME];
//        NSLog(@"sync data %@",data);
        NSArray *ids = [dataManager syncUserWords:data[TAG_ADD] delIds:data[TAG_DEL]];
        if (ids.count > 0)
        {
//            NSLog(@"network ids %@",ids);
            [self queryBatch:ids delegate:delegate responseBlock:^(id error, id data, id userInfo) {
                if (error == nil)
                {
//                    NSLog(@"network data %@",data);
                    for (WordInfo *info in data)
                    {
                        [dataManager addWord:info];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSyncFinished object:nil];
                    });
                }
            }];
        }
        return nil;
    } responseBlock:block];
}

- (void)queryBatch:(NSArray *)ids delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[TAG_IDS] = [ids componentsJoinedByString:@","];
    HaloHttpRequest *request = [self makeGetRequestByTag:EhttpWordQueryBatch properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error){
        NSMutableArray *result = [NSMutableArray array];
        NSArray *words = data;
        for (NSDictionary *word in words)
        {
            WordInfo *info = [self parseWord:word];
            [result addObject:info];
        }
        return result;
    } responseBlock:block];
}

- (NSString *)parseSentenceToHTML:(id)data
{
    NSMutableString *html = [NSMutableString string];
    for (NSDictionary *item in data)
    {
        [html appendFormat:@"<li>%@<span class='line2'>%@</span></li>",[item[TAG_CONTENT] escapeHTML],[item[TAG_TRAN] escapeHTML]];
    }
    return [NSString stringWithFormat:@"<ul class='nav tran'>%@</ul>",html];
}

- (void)getWordAllPhrase:(NSInteger)wordId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSDictionary *params = [NSDictionary dictionaryWithObject:@(wordId) forKey:TAG_ID];
    HaloHttpRequest *request = [self makePostRequestByTag:EHttpWordAllPhrase properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        return [self parseSentenceToHTML:data];
    } responseBlock:block];
}

- (void)getWordAllSentence:(NSInteger)wordId delegate:(id<HaloHttpRequestDelegate>)delegate responseBlock:(ResponseBlock)block
{
    NSDictionary *params = [NSDictionary dictionaryWithObject:@(wordId) forKey:TAG_ID];
    HaloHttpRequest *request = [self makePostRequestByTag:EHttpWordAllSentence properties:PROP_NORMAL_NO_WAITDLG params:params];
    [self startHttpRequest:request delegate:delegate parseBlock:^id(HaloHttpRequest *r, id data, NSError *error) {
        return [self parseSentenceToHTML:data];
    } responseBlock:block];
}
@end
