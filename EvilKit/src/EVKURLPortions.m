#import "EVKURLPortions.h"
#import "NSURL+ComponentAdditions.h"

@implementation EVKStaticStringPortion {
    NSString* string;
}

- (instancetype)initWithString:(NSString *)str {
    if((self = [super init])) {
        string = str;
    }

    return self;
}

+ (instancetype)portionWithString:(NSString *)str {
    return [[EVKStaticStringPortion alloc] initWithString:str];
}

- (NSString *)evalutatePortionWithURL:(NSURL *)url {
    return string;
}

@end

@implementation EVKFullURLPortion {
    BOOL percentEncoded;
}

- (instancetype)initWithPercentEncoding:(BOOL)encoded {
    if((self = [super init])) {
        percentEncoded = encoded;
    }

    return self;
}

+ (instancetype)portionWithPercentEncoding:(BOOL)encoded {
    return [[EVKFullURLPortion alloc] initWithPercentEncoding:encoded];
}

- (NSString *)evalutatePortionWithURL:(NSURL *)url {
    return percentEncoded ? percentEncode([url absoluteString]) : [url absoluteString];
}

@end

@implementation EVKPathPortion

- (NSString *)evalutatePortionWithURL:(NSURL *)url {
    return [url pathComponent];
}

@end

@implementation EVKTrimmedResourceSpecifierPortion

- (NSString *)evalutatePortionWithURL:(NSURL *)url {
    return [url trimmedResourceSpecifier];
}

@end

@implementation EVKQueryPortion

- (NSString *)evalutatePortionWithURL:(NSURL *)url {
    return [url queryString];
}

@end

@implementation EVKRegexSubstitutionPortion {
    NSRegularExpression *_regex;
    NSString *_template;
}

- (instancetype)initWithRegex:(NSRegularExpression *)regex template:(NSString *)str {
    if((self = [super init])) {
        _regex = regex;
        _template = str;
    }

    return self;
}

+ (instancetype)portionWithRegex:(NSRegularExpression *)regex template:(NSString *)template {
    return [[EVKRegexSubstitutionPortion alloc] initWithRegex:regex template:template];
}


- (NSString *)evalutatePortionWithURL:(NSURL *)url {
    NSMatchingOptions opts = NSMatchingWithTransparentBounds | NSMatchingWithoutAnchoringBounds;
    return [_regex stringByReplacingMatchesInString:[url absoluteString]
                                            options:opts
                                              range:NSMakeRange(0, [[url absoluteString] length])
                                       withTemplate:_template];
}

@end

@implementation EVKTranslatedQueryPortion {
     NSDictionary<NSString *, EVKQueryItemLexicon *> *paramTranslations;
 }

 - (instancetype)initWithDictionary:(NSDictionary<NSString *, EVKQueryItemLexicon *> *)dict {
     if((self = [super init])) {
         paramTranslations = dict;
     }

     return self;
 }

 + (instancetype)portionWithDictionary:(NSDictionary<NSString *,EVKQueryItemLexicon *> *)dict {
     return [[EVKTranslatedQueryPortion alloc] initWithDictionary:dict];
 }

 - (NSString *)evalutatePortionWithURL:(NSURL *)url {
     NSMutableArray *ret = [NSMutableArray new];
     EVKQueryItemLexicon *t;
     NSURLQueryItem *translatedItem;

     for(NSURLQueryItem *item in [url queryItems]) {
         if((t = paramTranslations[[item name]]) &&
             (translatedItem = [t translateItem:item])) {
             [ret addObject:translatedItem];
         }
     }

     NSURLComponents *c = [[NSURLComponents alloc] init];
     [c setQueryItems:ret];
     return [c percentEncodedQuery];
 }

 @end