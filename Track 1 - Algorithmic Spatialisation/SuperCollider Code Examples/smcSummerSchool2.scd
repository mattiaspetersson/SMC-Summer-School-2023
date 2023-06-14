// SMC Summer School 2: Sound files and basic panning

// The default number of hardware ins and outs in SC is 2.
// To work with multichannel audio we need to increase this. It needs to be done before (re-)booting the server!
s.options.numOutputBusChannels = 32;
s.options.numInputBusChannels = 2;

// boot the server
s.boot;

// check outputs with the meter
s.meter;

// read your sound file into a buffer (the server must be running!)
b = Buffer.read(s, "/Users/mattpete/Dropbox/work/ljudarkivet/iceSnowWater/iceSounds.aiff");

// define a synth that can playback the file and add it to the server
(
SynthDef(\sample, {|buf, rate = 1|
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate);
	Out.ar(0, sig);
}).add;
)

// play the sample loaded into the buffer
x = Synth(\sample, [\buf, b]);
x.set(\rate, 0.5);
x.free;

// improved version with separated channels and individual stereo panning of the left and right signals
// sent to 4 discrete, individually assignable outputs.
(
SynthDef(\sample, {|outA = 0, outB = 1, outC = 2, outD = 3, buf, rate = 1, panL = 1, panR = -1|
	var smp, sigL, sigR;
	smp = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, loop: 1);
	sigL = Pan2.ar(smp[0], panL);
	sigR = Pan2.ar(smp[1], panR);

	// 4 discrete outputs
	Out.ar(outA, sigL[0]);
	Out.ar(outB, sigL[1]);
	Out.ar(outC, sigR[0]);
	Out.ar(outD, sigR[1]);
}).add;
)
// start the synth and try some values
x = Synth(\sample, [\buf, b]);
x.set(\outA, 3, \outB, 7, \outC, 4, \outD, 12, \panL, -0.5, \panR, 0.7);
x.free;

// automate panning using a Routine
(
r = Routine{
	var speakerArray = Array.series(29); // Lilla Salen has 29 speakers
	var d = speakerArray.scramble; // scramble the order of speaker indices

	// start the synth to play the buffer
	x = Synth(\sample, [\buf, b]);

	// start an iterative function and use the iterator value to set the panning
	inf.do{|i|
		var out = ((i/300)%29).asInteger;
		x.set(
			\outA, d[out],
			\outB, d[out+1],
			\outC, d[out+2],
			\outD, d[out+3]
		);
		x.set(
			\panL, (i%100).linlin(0, 99, -1.0, 1.0),
			\panR, (i%100).linlin(0, 99, 1.0, -1.0)
		);
		0.02.wait;
	};
}.play;
)
r.stop; x.free;