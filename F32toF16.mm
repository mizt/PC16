#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import <vector>

const NSCharacterSet *WHITESPACE = [NSCharacterSet whitespaceCharacterSet];
const NSCharacterSet *NEWLINE = [NSCharacterSet newlineCharacterSet];

NSArray *separate(NSString *str, const NSCharacterSet *characterSet) {
	return [str componentsSeparatedByCharactersInSet:(NSCharacterSet *)characterSet];
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		
		NSArray *replace = @[
			@"./69.obj",
			@"./199.obj"
		];
		
		std::vector<unsigned short> vertex;
		std::vector<unsigned char> rgb;
		
		// xx yy zz ... r g b ...
		
		NSMutableString *dst = [NSMutableString stringWithString:@""];
		
		for(int n=0; n<replace.count; n++) {
			
			NSString *src = [NSString stringWithContentsOfFile:replace[n] encoding:NSUTF8StringEncoding error:nil];
			
			if(src.length>0) {
				
				NSLog(@"%@",replace[n]);
				
				NSArray *lines = separate(src,NEWLINE);
				
				for(int k=0; k<lines.count; k++) {
					
					NSArray *arr = separate(lines[k],WHITESPACE);
					if([arr count]>0) {
						if([arr[0] isEqualToString:@"v"]) {
							if([arr count]>=4) {
								
								_Float16 x = [arr[1] floatValue];
								_Float16 y = [arr[2] floatValue];
								_Float16 z = [arr[3] floatValue];
								
								vertex.push_back(*((unsigned short *)&x));
								vertex.push_back(*((unsigned short *)&y));
								vertex.push_back(*((unsigned short *)&z));

#ifdef DEBUG
								[dst appendString:[NSString stringWithFormat:@"v %f %f %f",(float)x,(float)y,(float)z]];
#endif
								
								if([arr count]>=7) {
#ifdef DEBUG
									[dst appendString:[NSString stringWithFormat:@"v %f %f %f",[arr[4] floatValue],[arr[5] floatValue],[arr[6] floatValue]]];
#endif
									rgb.push_back([arr[4] floatValue]*255);
									rgb.push_back([arr[5] floatValue]*255);
									rgb.push_back([arr[6] floatValue]*255);

								}
#ifdef DEBUG
								[dst appendString:@"\n"];
#endif
							}
						}
					}
				}
			}
			
		}
				
		if(vertex.size()>=0) {
			
			NSLog(@"%ld",vertex.size());

			NSMutableData *bin = [[NSMutableData alloc] init];
			[bin appendBytes:vertex.data() length:vertex.size()*2];
			if(rgb.size()>=0&&vertex.size()==rgb.size()) {
				
				NSLog(@"%ld",rgb.size());
				
				[bin appendBytes:rgb.data() length:rgb.size()*1];
				[bin writeToFile:@"./docs/PC.bin" options:NSDataWritingAtomic error:nil];
			}
		}
		
#ifdef DEBUG
		[dst writeToFile:@"./PC.obj" atomically:YES encoding:NSUTF8StringEncoding error:nil];
#endif
		
	}
}