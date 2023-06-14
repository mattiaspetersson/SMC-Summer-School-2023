// SMC Summer School 4: Ambisonics panning with gestural control
(
s.options.numOutputBusChannels = 32;
s.options.numInputBusChannels = 2;

s.waitForBoot{
	// This time we use a stereo soundfile summed to mono
	b = Buffer.read(s, "/Users/mattpete/Dropbox/work/ljudarkivet/field/machine.wav");

	// a synthdef with possibilities to play a soundfile from a certain position and
	// an embedded FoaRTT transformer (rotate, tilt and tumble)
	SynthDef(\soundfile, {|out, buf, rate = 1, gate = 1, pos, rotate, tilt, tumble|
		var sig, env;
		env = EnvGen.kr(Env.asr(0.02, 1, 0.9), gate, doneAction: 2);
		sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, gate, pos * BufFrames.kr(buf), 1);
		// sum to mono and apply envelope
		sig = sig.sum * env;
		// encode the signal using newDirection set to the default values
		sig = FoaEncode.ar(sig, FoaEncoderMatrix.newDirection(0, 0));
		sig = FoaTransform.ar(sig, 'rtt', rotate.lag(0.02), tilt.lag(0.02), tumble.lag(0.02));
		Out.ar(out, sig);
	}).add;

	// First Order Ambisonics Decoder Synth for Lilla Salen
	SynthDef(\LSfoaDecoder, {|foaInput|
		var foa;
		foa = In.ar(foaInput, 4);
		//Out.ar(0, KMHLSDome1h1pN.ar(*foa));
		Out.ar(0, FoaDecode.ar(foa, FoaDecoderMatrix.kmhLillaSalen));
	}).add;

	// HRTF Decoder for Headphone monitoring
	~hrtf = FoaDecoderKernel.newListen;

	// UHJ Decoder for stereo monitoring
	~uhj = FoaDecoderKernel.newUHJ;

	s.sync;

	SynthDef(\PHfoaDecoder, {|foaInput|
		var foa;
		foa = In.ar(foaInput, 4);
		foa = FoaDecode.ar(foa, ~hrtf);
		Out.ar(0, foa);
	}).add;

	// stereo decoder
	SynthDef(\UHJfoaDecoder, {|foaInput|
		var foa;
		foa = In.ar(foaInput, 4);
		foa = FoaDecode.ar(foa, ~uhj);
		Out.ar(0, foa);
	}).add;

	~sources = Group(s);
	~foaBus = Bus.audio(s, 4); // an internal bus to use for the 4 channel Ambisonics B-format signal

	s.sync;

	// start your preferred decoder synth and make sure it is placed after the transforms group
	~decoder = Synth.after(~sources, \LSfoaDecoder, [\foaInput, ~foaBus]);
	//~decoder = Synth.after(~sources, \PHfoaDecoder, [\foaInput, ~foaBus]);
	//~decoder = Synth.after(~sources, \UHJfoaDecoder, [\foaInput, ~foaBus]);
};
)

// Test the source synth. Set the output to the previously defined FOA bus.
x = Synth(\soundfile, [\buf, b, \out, ~foaBus, \pos, 0.1]);
x.free;
s.meter;

/*
Use phone sensors to trigger the sound and control panning.
For this example i'm using an app called GyrOSC. Available here:
http://www.bitshapesoftware.com/instruments/gyrosc/

To receive OSC data from the phone we need to:
1. Make sure the devices are on the same network
2. Set the app in your phone to send to the IP of your computer and check the port it's sending on.
3. Create OSC responder functions to deal with the incoming data.

In SC we can use OSCFunc or OSCdef to define those responder functions.
We need to know the OSC address to be able to separate the messages.
*/

FoaXformDisplay();

// trace all incoming OSC messages
OSCFunc.trace(true);
OSCFunc.trace(false);
(
// define a couple of OSCdefs to trigger and pan sounds
// use the buttons in the app to trigger playback at different positions in the soundfile.

~synths = Array.fill(9); // create an empty array to keep track of running synths
OSCdef(\buttons, {|msg|
	var slot = msg[1] - 1;
	if(msg[2] == 1, { // if button is pressed, start a synth
		~synths[slot] = Synth(\soundfile, [\buf, b, \rate, rrand(1.0, 2.0), \out, ~foaBus, \pos, slot/9], ~sources);
	}, {
		~synths[slot].set(\gate, 0);
	});
}, '/gyrosc/button', recvPort: 50000);

// set RTT values with gyroscope sensor
OSCdef(\gyro, {|msg| // 1 = pitch, 2 = roll, 3 = yaw
	~sources.set(
		\rotate, msg[3],
		\tilt, msg[2],
		\tumble, msg[1]
	);
}, '/gyrosc/gyro', recvPort: 50000);
)