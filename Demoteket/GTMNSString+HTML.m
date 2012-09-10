//
//  GTMNSString+HTML.m
//  Dealing with NSStrings that contain HTML
//
//  Copyright 2006-2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

//#import "GTMDefines.h"
#import "GTMNSString+HTML.h"

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// Ordered by uchar lowest to highest for bsearching
static NSString *gAsciiHTMLEscapeMapString[] = {
	// A.2.2. Special characters
	@"&quot;",
	@"&amp;",
	@"&apos;",
	@"&lt;",
	@"&gt;",
	
    // A.2.1. Latin-1 characters
	@"&nbsp;",
	@"&iexcl;",
	@"&cent;",
	@"&pound;",
	@"&curren;",
	@"&yen;",
	@"&brvbar;",
	@"&sect;",
	@"&uml;",
	@"&copy;",
	@"&ordf;",
	@"&laquo;",
	@"&not;",
	@"&shy;",
	@"&reg;",
	@"&macr;",
	@"&deg;",
	@"&plusmn;",
	@"&sup2;",
	@"&sup3;",
	@"&acute;",
	@"&micro;",
	@"&para;",
	@"&middot;",
	@"&cedil;",
	@"&sup1;",
	@"&ordm;",
	@"&raquo;",
	@"&frac14;",
	@"&frac12;",
	@"&frac34;",
	@"&iquest;",
	@"&Agrave;",
	@"&Aacute;",
	@"&Acirc;",
	@"&Atilde;",
	@"&Auml;",
	@"&Aring;",
	@"&AElig;",
	@"&Ccedil;",
	@"&Egrave;",
	@"&Eacute;",
	@"&Ecirc;",
	@"&Euml;",
	@"&Igrave;",
	@"&Iacute;",
	@"&Icirc;",
	@"&Iuml;",
	@"&ETH;",
	@"&Ntilde;",
	@"&Ograve;",
	@"&Oacute;",
	@"&Ocirc;",
	@"&Otilde;",
	@"&Ouml;",
	@"&times;",
	@"&Oslash;",
	@"&Ugrave;",
	@"&Uacute;",
	@"&Ucirc;",
	@"&Uuml;",
	@"&Yacute;",
	@"&THORN;",
	@"&szlig;",
	@"&agrave;",
	@"&aacute;",
	@"&acirc;",
	@"&atilde;",
	@"&auml;",
	@"&aring;",
	@"&aelig;",
	@"&ccedil;",
	@"&egrave;",
	@"&eacute;",
	@"&ecirc;",
	@"&euml;",
	@"&igrave;",
	@"&iacute;",
	@"&icirc;",
	@"&iuml;",
	@"&eth;",
	@"&ntilde;",
	@"&ograve;",
	@"&oacute;",
	@"&ocirc;",
	@"&otilde;",
	@"&ouml;",
	@"&divide;",
	@"&oslash;",
	@"&ugrave;",
	@"&uacute;",
	@"&ucirc;",
	@"&uuml;",
	@"&yacute;",
	@"&thorn;",
	@"&yuml;",
	
	// A.2.2. Special characters cont'd
	@"&OElig;",
	@"&oelig;",
	@"&Scaron;",
	@"&scaron;",
	@"&Yuml;",
	
	// A.2.3. Symbols
	@"&fnof;",
	
	// A.2.2. Special characters cont'd
	@"&circ;",
	@"&tilde;",
	
	// A.2.3. Symbols cont'd
	@"&Alpha;",
	@"&Beta;",
	@"&Gamma;",
	@"&Delta;",
	@"&Epsilon;",
	@"&Zeta;",
	@"&Eta;",
	@"&Theta;",
	@"&Iota;",
	@"&Kappa;",
	@"&Lambda;",
	@"&Mu;",
	@"&Nu;",
	@"&Xi;",
	@"&Omicron;",
	@"&Pi;",
	@"&Rho;",
	@"&Sigma;",
	@"&Tau;",
	@"&Upsilon;",
	@"&Phi;",
	@"&Chi;",
	@"&Psi;",
	@"&Omega;",
	@"&alpha;",
	@"&beta;",
	@"&gamma;",
	@"&delta;",
	@"&epsilon;",
	@"&zeta;",
	@"&eta;",
	@"&theta;",
	@"&iota;",
	@"&kappa;",
	@"&lambda;",
	@"&mu;",
	@"&nu;",
	@"&xi;",
	@"&omicron;",
	@"&pi;",
	@"&rho;",
	@"&sigmaf;",
	@"&sigma;",
	@"&tau;",
	@"&upsilon;",
	@"&phi;",
	@"&chi;",
	@"&psi;",
	@"&omega;",
	@"&thetasym;",
	@"&upsih;",
	@"&piv;",
	
	// A.2.2. Special characters cont'd
	@"&ensp;",
	@"&emsp;",
	@"&thinsp;",
	@"&zwnj;",
	@"&zwj;",
	@"&lrm;",
	@"&rlm;",
	@"&ndash;",
	@"&mdash;",
	@"&lsquo;",
	@"&rsquo;",
	@"&sbquo;",
	@"&ldquo;",
	@"&rdquo;",
	@"&bdquo;",
	@"&dagger;",
	@"&Dagger;",
    // A.2.3. Symbols cont'd
	@"&bull;",
	@"&hellip;",
	
	// A.2.2. Special characters cont'd
	@"&permil;",
	
	// A.2.3. Symbols cont'd
	@"&prime;",
	@"&Prime;",
	
	// A.2.2. Special characters cont'd
	@"&lsaquo;",
	@"&rsaquo;",
	
	// A.2.3. Symbols cont'd
	@"&oline;",
	@"&frasl;",
	
	// A.2.2. Special characters cont'd
	@"&euro;",
	
	// A.2.3. Symbols cont'd
	@"&image;",
	@"&weierp;",
	@"&real;",
	@"&trade;",
	@"&alefsym;",
	@"&larr;",
	@"&uarr;",
	@"&rarr;",
	@"&darr;",
	@"&harr;",
	@"&crarr;",
	@"&lArr;",
	@"&uArr;",
	@"&rArr;",
	@"&dArr;",
	@"&hArr;",
	@"&forall;",
	@"&part;",
	@"&exist;",
	@"&empty;",
	@"&nabla;",
	@"&isin;",
	@"&notin;",
	@"&ni;",
	@"&prod;",
	@"&sum;",
	@"&minus;",
	@"&lowast;",
	@"&radic;",
	@"&prop;",
	@"&infin;",
	@"&ang;",
	@"&and;",
	@"&or;",
	@"&cap;",
	@"&cup;",
	@"&int;",
	@"&there4;",
	@"&sim;",
	@"&cong;",
	@"&asymp;",
	@"&ne;",
	@"&equiv;",
	@"&le;",
	@"&ge;",
	@"&sub;",
	@"&sup;",
	@"&nsub;",
	@"&sube;",
	@"&supe;",
	@"&oplus;",
	@"&otimes;",
	@"&perp;",
	@"&sdot;",
	@"&lceil;",
	@"&rceil;",
	@"&lfloor;",
	@"&rfloor;",
	@"&lang;",
	@"&rang;",
	@"&loz;",
	@"&spades;",
	@"&clubs;",
	@"&hearts;",
	@"&diams;"
};

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// Ordered by uchar lowest to highest for bsearching
static unichar gAsciiHTMLEscapeMapInt[] = {
	// A.2.2. Special characters
	32,
	38,
	39,
	60,
	62,
	
    // A.2.1. Latin-1 characters
	160,
	161,
	162,
	163,
	164,
	165,
	166,
	167,
	168,
	169,
	170,
	171,
	172,
	173,
	174,
	175,
	176,
	177,
	178,
	179,
	180,
	181,
	182,
	183,
	184,
	185,
	186,
	187,
	188,
	189,
	190,
	191,
	192,
	193,
	194,
	195,
	196,
	197,
	198,
	199,
	200,
	201,
	202,
	203,
	204,
	205,
	206,
	207,
	208,
	209,
	210,
	211,
	212,
	213,
	214,
	215,
	216,
	217,
	218,
	219,
	220,
	221,
	222,
	223,
	224,
	225,
	226,
	227,
	228,
	229,
	230,
	231,
	232,
	233,
	234,
	235,
	236,
	237,
	238,
	239,
	240,
	241,
	242,
	243,
	244,
	245,
	246,
	247,
	248,
	249,
	250,
	251,
	252,
	253,
	254,
	255,
	
	// A.2.2. Special characters cont'd
	338,
	339,
	352,
	353,
	376,
	
	// A.2.3. Symbols
	402,
	
	// A.2.2. Special characters cont'd
	710,
	732,
	
	// A.2.3. Symbols cont'd
	913,
	914,
	915,
	916,
	917,
	918,
	919,
	920,
	921,
	922,
	923,
	924,
	925,
	926,
	927,
	928,
	929,
	931,
	932,
	933,
	934,
	935,
	936,
	937,
	945,
	946,
	947,
	948,
	949,
	950,
	951,
	952,
	953,
	954,
	955,
	956,
	957,
	958,
	959,
	960,
	961,
	962,
	963,
	964,
	965,
	966,
	967,
	968,
	969,
	977,
	978,
	982,
	
	// A.2.2. Special characters cont'd
	8194,
	8195,
	8201,
	8204,
	8205,
	8206,
	8207,
	8211,
	8212,
	8216,
	8217,
	8218,
	8220,
	8221,
	8222,
	8224,
	8225,
    // A.2.3. Symbols cont'd
	8226,
	8230,
	
	// A.2.2. Special characters cont'd
	8240,
	
	// A.2.3. Symbols cont'd
	8242,
	8243,
	
	// A.2.2. Special characters cont'd
	8249,
	8250,
	
	// A.2.3. Symbols cont'd
	8254,
	8260,
	
	// A.2.2. Special characters cont'd
	8364,
	
	// A.2.3. Symbols cont'd
	8465,
	8472,
	8476,
	8482,
	8501,
	8592,
	8593,
	8594,
	8595,
	8596,
	8629,
	8656,
	8657,
	8658,
	8659,
	8660,
	8704,
	8706,
	8707,
	8709,
	8711,
	8712,
	8713,
	8715,
	8719,
	8721,
	8722,
	8727,
	8730,
	8733,
	8734,
	8736,
	8743,
	8744,
	8745,
	8746,
	8747,
	8756,
	8764,
	8773,
	8776,
	8800,
	8801,
	8804,
	8805,
	8834,
	8835,
	8836,
	8838,
	8839,
	8853,
	8855,
	8869,
	8901,
	8968,
	8969,
	8970,
	8971,
	9001,
	9002,
	9674,
	9824,
	9827,
	9829,
	9830
};

@implementation NSString (GTMNSStringHTMLAdditions)

- (NSString *)gtm_stringByUnescapingFromHTML {
	NSRange range = NSMakeRange(0, [self length]);
	NSRange subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range];
	
	// if no ampersands, we've got a quick way out
	if (subrange.length == 0) return self;
	NSMutableString *finalString = [NSMutableString stringWithString:self];
	do {
		NSRange semiColonRange = NSMakeRange(subrange.location, NSMaxRange(range) - subrange.location);
		semiColonRange = [self rangeOfString:@";" options:0 range:semiColonRange];
		range = NSMakeRange(0, subrange.location);
		// if we don't find a semicolon in the range, we don't have a sequence
		if (semiColonRange.location == NSNotFound) {
			continue;
		}
		NSRange escapeRange = NSMakeRange(subrange.location, semiColonRange.location - subrange.location + 1);
		NSString *escapeString = [self substringWithRange:escapeRange];
		NSUInteger length = [escapeString length];
		// a squence must be longer than 3 (&lt;) and less than 11 (&thetasym;)
		if (length > 3 && length < 11) {
			if ([escapeString characterAtIndex:1] == '#') {
				unichar char2 = [escapeString characterAtIndex:2];
				if (char2 == 'x' || char2 == 'X') {
					// Hex escape squences &#xa3;
					NSString *hexSequence = [escapeString substringWithRange:NSMakeRange(3, length - 4)];
					NSScanner *scanner = [NSScanner scannerWithString:hexSequence];
					unsigned value;
					if ([scanner scanHexInt:&value] &&
						value < USHRT_MAX &&
						value > 0
						&& [scanner scanLocation] == length - 4) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
					
				} else {
					// Decimal Sequences &#123;
					NSString *numberSequence = [escapeString substringWithRange:NSMakeRange(2, length - 3)];
					NSScanner *scanner = [NSScanner scannerWithString:numberSequence];
					int value;
					if ([scanner scanInt:&value] &&
						value < USHRT_MAX &&
						value > 0
						&& [scanner scanLocation] == length - 3) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
				}
			} else {
				// "standard" sequences
				for (int i = 0; i < sizeof(gAsciiHTMLEscapeMapInt); ++i) {
					if ([escapeString isEqualToString:gAsciiHTMLEscapeMapString[i]]) {
						[finalString replaceCharactersInRange:escapeRange withString:[NSString stringWithCharacters:(unichar *)&gAsciiHTMLEscapeMapInt length:1]];
						break;
					}
				}
			}
		}
	} while ((subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range]).length != 0);
	return finalString;
} // gtm_stringByUnescapingHTML



@end