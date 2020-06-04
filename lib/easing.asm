.macro easeOutBounce(start, finish, length) {
	.var d = length
	.var b = start
	.var c = finish - start

	.for(var i=0; i <= d; i++) {
		.var t = i/d;
		.if (t < (1/2.75)) {
			.byte floor(c*(7.5625*t*t) + b);
		} else {
			.if (t < (2/2.75)) {
				.byte floor(c*(7.5625*(t-=(1.5/2.75))*t + 0.75) + b)
			} else {
				.if (t < (2.5/2.75)) {
					.byte floor(c*(7.5625*(t-=(2.25/2.75))*t + 0.9375) + b)
				} else {
					.byte floor(c*(7.5625*(t-=(2.625/2.75))*t + 0.984375) + b)		
				}
			}
		} 
	}
}

.macro easeInQuad(start, finish, length) {
	.var d = length
	.var b = start
	.var c = finish - start
	
	.for(var i=0; i <= d; i++) {
		.var t = i/d;
		.byte floor(c *(t*t) + b);
	}
}

.macro easeInQuart(start, finish, length) {
	.var d = length
	.var b = start
	.var c = finish - start
	
	.for(var i=0; i <= d; i++) {
		.var t = i/d;
		.byte floor(c *(t*t*t*t) + b);
	}
}

.macro easeOutQuart(start, finish, length) {
	.var d = length
	.var b = start
	.var c = finish - start

	.for(var i=0; i <= d; i++) {
		.var t = i/d - 1;
		.byte floor(-c *(t*t*t*t - 1) + b);
	}
}

.macro easeOutQuad(start, finish, length) {
	.var d = length
	.var b = start
	.var c = finish - start

	.for(var i=0; i <= d; i++) {
		.var t = i/d - 1;
		.byte floor(-c *(t*t - 1) + b);
	}
}