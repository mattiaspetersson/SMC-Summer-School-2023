// SMC Summer School 1: SuperCollider Crash Course

/*
SuperCollider is divided into 3 main parts:
1. scide – an intergrated programmming environment with a text editor, a post window and a help system.
2. sclang – the interpreted language
3. scsynth - a realtime audio server

sclang communicates with scsynth by sending OSC messages to this server. This involves allocating buffers, defining and playing synths as well as signal flows. These OSC messages can be used explicitly, but usually the coder works on a higher abstraction level where they are sent automatically in the background.

It's important to remember that connections and ojects created on the audio server (scsynth) cannot be dynamically changed unless you re-build the audio network. However, you can provide an interface for important parameters by means of arguments. Think of it as a hardware synth – for example a Minimoog – where certain knobs and switches makes selected, useful parameters available, but most of the inner components of the synth cannot be changed unless you re-build it.

SuperCollider automatically declares the variables a-z at startup. These are called Interpreter variables and are useful for testing and quick examples. They are frequently in the docs and I will use them in the following examples. For larger projects it's better practice to declare variables yourself, using descriptive names (e.g. var myVariable;).
*/

// The audio server is predefined in the variable s, so to boot it we can run the line:
s.boot;

// to make a sound we define a synth and add it to the server:
(
SynthDef(\myFirstSynth, {|freq = 200, amp = 0.1|
	var sig;
	sig = Saw.ar(freq, amp);
	Out.ar(0, sig);
}).add;
)

// to play the synth we just defined we run
x = Synth(\myFirstSynth);
x.free; // stop it

// to expand this sound into more channels we can provide an array of signals
(
SynthDef(\myFirstSynth, {|freq = 200, amp = 0.1|
	var sig;
	sig = Saw.ar(freq, amp);
	Out.ar(0, [sig, sig]);
}).add;
)

x = Synth(\myFirstSynth);
x.free; // stop it

// or use a stereo panner for more flexibility
(
SynthDef(\myFirstSynth, {|freq = 200, amp = 0.1, pan = 0|
	var sig;
	sig = Saw.ar(freq, amp);
	Out.ar(0, Pan2.ar(sig, pan));
}).add;
)

x = Synth(\myFirstSynth);
x.set(\pan, -0.5);
x.free; // stop it

// multi-channel expansion can also be achieved by arraying the arguments.
(
SynthDef(\myFirstSynth, {|freq = 200, amp = 0.1|
	var sig;
	sig = Saw.ar([freq, freq * 1.001, freq * 1.002, freq * 1.003], amp);
	Out.ar(0, sig);
}).add;
)
x = Synth(\myFirstSynth);
x.set(\freq, 100); // change the frequency argument
x.free; // stop it

// with an added envelope generator
(
SynthDef(\myFirstSynth, {|freq = 200, amp = 0.1, gate = 1|
	var sig, env;
	env = EnvGen.kr(Env.asr(0.3, 1, 1.3), gate, doneAction: 2); // check help for Done
	sig = Saw.ar([freq, freq * 1.001, freq * 1.002, freq * 1.003], amp * env);
	Out.ar(0, sig);
}).add;
)
x = Synth(\myFirstSynth);
x.set(\gate, 0); // stop it by setting the gate to 0 (doneAction: 2 frees it automatically)