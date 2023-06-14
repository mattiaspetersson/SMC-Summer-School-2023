// SMC Summer School 3: Ambisonics with ATK

/*
Ambisonics panning is different from discrete, pairwise panning in that it uses all speakers to project an image of the soundfield. In its simplest form called First Order Ambisonics, FOA, it can be undestood as a mix between three virtual microphones, placed in the middle of a sphere. One of these mics is omni-directional, the other two have a figure 8 pattern where one is placed on the x-axis, pointing to the left, and one on the y-axis, pointing up. By altering the mix between these virtual mics, we can create a sense of directionality within the sphere. As such, it is very similar to how M/S stereo works.

The paradigm allows for spatialisation techniques not possible with discrete panning and encourages a focus on the complete, perceived soundfield image, rather than the available speakers.

The Ambisonics Toolkit is a library that extends SuperCollider's, very basic, standard implementation of Ambisonics. It includes First Order (FOA) as well as Higher Order Ambisonics (HOA). In short, HOA allows for higher resolution in the soundfield with better directional precision, with the drawback of higher demands on processing power and speaker systems. The following examples uses FOA, but feel free to explore the various HOA examples in the extensive documentation.

The ATK paradigm involves a three step process:
1. Encoding the signal into Ambisonics' B-format, a 4-channel typically described as W, X, Y, Z (omni, left/right, front/back, up/down).
2. Transforming the soundfield, e.g. by pushing it in a certain direction, rotating it etc.
3. Decoding the result for your monitoring system (i.e. a specific multichannel speaker setup, stereo or headphones).
*/

(
// make sure you have enough outputs
s.options.numOutputBusChannels = 32;
s.options.numInputBusChannels = 2;

// Instead of s.boot; we can use waitForBoot.
// This creates a Routine that allows for checking that certain server tasks have been completed before moving on.
// E.g. to make sure that soundfiles have been loaded into buffers before trying to play them.
s.waitForBoot{
	// A mono sound source to test with
	SynthDef(\dust, {|out = 2, gate = 1, density = 18, freq = 3600|
		var sig, dust, env;
		dust = Dust.kr(density);
		env = EnvGen.kr(Env.asr(), gate, doneAction: 2);
		sig = BPF.ar(WhiteNoise.ar(0.2), freq, 0.3, Decay.kr(dust, TRand.kr(0.1, 0.5, dust)));
		sig = sig * env;
		sig = FoaEncode.ar(sig, FoaEncoderMatrix.newOmni); // encode the signal to an omnidirectional soundfield
		Out.ar(out, sig);
	}).add;

	// Synth that transforms the FOA-encoded signal by pushing the soundfield image into certain directions. See FoaPush docs!
	SynthDef(\push, {|bus, angle = 0.5pi, azimuth, elevation, lagTime = 0.05|
		var sig;
		sig = In.ar(bus, 4);
		sig = FoaTransform.ar(sig, 'push', angle, azimuth.lag(lagTime), elevation.lag(lagTime)); // lag adds an interpolation to avoid clicks
		ReplaceOut.ar(bus, sig); // ReplaceOut overwrites the incoming signal (otherwise the transformed signal will be mixed with the source)
	}).add;

	// First Order Ambisonics Decoder Synth for Lilla Salen
	SynthDef(\LSfoaDecoder, {|foaInput|
		var foa;
		foa = In.ar(foaInput, 4);
		//Out.ar(0, KMHLSDome1h1pN.ar(*foa));
		Out.ar(0, FoaDecode.ar(foa, FoaDecoderMatrix.kmhLillaSalen));
		// Note: the * before the foa array populates the decoder arguments one by one, using the array elements
		// It could be explicitly written as KMHLSDome1h1pN.ar(foa[0], foa[1], foa[2], foa[3]);
	}).add;

	// HRTF Decoder for Headphone monitoring
	~hrtf = FoaDecoderKernel.newListen;

	// UHJ Decoder for stereo monitoring
	~uhj = FoaDecoderKernel.newUHJ;

	// Note: The kernel decoders load impulse responses into buffers this needs to be handled outside of the SynthDef.
	// We have to make sure that the server has loaded these kernels before building the SynthDefs
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

	// Buses and Groups
	~foaBus = Bus.audio(s, 4); // an internal bus to use for the 4 channel Ambisonics B-format signal
	~sources = Group(s); // a group for sound sources
	~transforms = Group.after(~sources); // another group for transforms that placed after the sources

	s.sync;

	// start your preferred decoder synth and make sure it is placed after the transforms group
	~decoder = Synth.after(~transforms, \LSfoaDecoder, [\foaInput, ~foaBus]);
	//~decoder = Synth.after(~transforms, \PHfoaDecoder, [\foaInput, ~foaBus]);
	//~decoder = Synth.after(~transforms, \UHJfoaDecoder, [\foaInput, ~foaBus]);
};
)

// start the source synth. Set the output to the previously defined FOA bus and place it in the ~sources group.
x = Synth(\dust, [\out, ~foaBus], ~sources);

// start the push transform synth. Set the input to listen to
~xform = Synth(\push, [\bus, ~foaBus], ~transforms);
x.free;
s.meter;

// The push transform has three parameters:
// • angle: pi/2 = push to plane wave, 0 = omni directional
// • azimuth: pi --> -pi
// • elevation: -pi --> pi (effective range is 0 --> pi, since we don't have speakers below us here)
~xform.set(\angle, pi/2, \azimuth, 0.15, \elevation, 0.1);

// use FoaXformDisplay to learn more about what's going on!
f = FoaXformDisplay();

// control parameters using a Routine
(
r = Routine{
	inf.do{|i|
		~xform.set(
			\azimuth, (i%100).linlin(0, 99, 0.25pi, -0.25pi),
			\elevation, (i%500).linlin(0, 499, -pi, pi)
		);
		0.01.wait;
	};
}.play;
)
r.stop; x.free;

// control parameters using a Pattern
(
p = Ppar([
	Pbind(
		\instrument, \dust,
		\out, ~foaBus,
		\group, ~sources,
		\freq, Prand([900, 1800, 2700, 3600, 4500], inf),
		\dur, 0.25
	),

	Pbind(
		\type, \set,
		\id, ~xform.nodeID,
		\args, #[\azimuth, \elevation],
		\azimuth, Pwhite(0.25pi, -0.25pi),
		\elevation, Pwhite(-pi, pi),
		\dur, 0.25
	)
]).play
)
p.stop;