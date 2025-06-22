const F32 = new Uint8Array(4);
const U16toF32 = (u16)=>{
	const u32 = (u16&0x8000)<<16|((((u16>>10)&0x1F)-15+127)&0xFF)<<23|(u16&0x3FF)<<13;
	F32[0] = u32&0xFF;
	F32[1] = (u32>>8)&0xFF;
	F32[2] = (u32>>16)&0xFF;
	F32[3] = (u32>>24)&0xFF;
	return (new Float32Array(F32.buffer))[0];
}

export const PCLoader = Object.freeze({
	
	parse:(url,data,cb)=>{
		
		const len = data.byteLength/((2+1));
		
		const U16 = new Uint16Array(data);
		const v = new Float32Array(len);
		for(var n=0; n<len; n++) {
			v[n] = U16toF32(U16[n]);
		}
		
		const U8 = new Uint8Array(data).slice(len*2);
		
		const rgb = new Float32Array(len);
		for(var n=0; n<len; n++) {
			rgb[n] = U8[n]/255.0;
		}
		
		const result = {};
		result[url] = {
			v:v,
			rgb:rgb
		}
		cb(result);
	},
	
	load:(url,init)=>{
		
		let list = [];
		
		if(typeof(url)==="string") {
			list.push(url);
		}
		else if(Array.isArray(url)) {
			list = url;
		}
		
		if(list.length>=1) {
			
			let loaded = 0;
			let data = {};
			
			const onload = (result) => {
				const key = Object.keys(result)[0];
				data[key] = result[key];
				loaded++;
				if(loaded===list.length) {
					init(data);
				}
			};
			
			const load = (url) => {
				fetch(url).then(response=>response.blob()).then(data=>{
					const fr = new FileReader();
					fr.onloadend = ()=>{
						PCLoader.parse(url,fr.result,onload);
					};
					fr.readAsArrayBuffer(data)
				}).catch(error=>{
					console.error(error);
				});
			}
			
			for(var n=0; n<list.length; n++) {
				load(list[n]);
			}
		}
	}
});