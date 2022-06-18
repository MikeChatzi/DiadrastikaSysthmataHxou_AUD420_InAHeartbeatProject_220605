
// ACTIVATE SERVER
s.boot;

// LIBRARY EXTENSIONS
Platform.userExtensionDir;

// ABOUT WAV
~sound = Buffer.read(s, "/Users/zanpol/Desktop/Spring Birds Chirping Sound Effect [FREE DOWNLOAD].wav");

~sound2 = Buffer.read(s, "/Users/zanpol/Desktop/Factory sound design (student project).wav");

~sound.bufnum;
~sound2.bufnum;
// numSamples = numFrames * numChannels

// CHECK AVAILABLE PORTS AND CONNECT
SerialPort.devices;
~port = SerialPort.new("/dev/tty.usbmodem14101", 115200);

// CREATE A ROUTINE TO COLLECT ARDUINO'S LIGHT SENSOR DATA
(
~charArray = [ ];
~getValues = Routine.new({
	var ascii;
	{
		ascii = ~port.read.asAscii;
		if(ascii.isDecDigit, {~charArray = ~charArray.add(ascii)});
		if(ascii == $a, {
			~val = ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
	});
}.loop;
}).play;
)

// MAIN VARIABLE COLLECTING THE CLEAN ARDUINO DATA
~val;

// CREATE SYNTH AND CONNECT IT TO 1ST WAV (BIRD SOUNDS)
(
SynthDef.new(\play, {
	arg sawFreq=2, amp=0.3, buf=0, rate=1, spos=0, pan=0, out=0;
	var saw, sig;
	saw = LFSaw.ar(sawFreq).range(2, 20);
	sig = PlayBuf.ar(2, ~sound.bufnum, rate, startPos: spos);
	sig = sig * saw * amp;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)


// CREATE SYNTH AND CONNECT IT TO 2ND WAV (MACHINE SOUNDS)
(
SynthDef.new(\dead, {
	arg sawFreq=2, amp=0.25, buf=0, rate=1, spos=0, pan=0, out=0;
	var saw, sig;
	saw = LFSaw.ar(sawFreq).range(2, 20);
	sig = PlayBuf.ar(2, ~sound2.bufnum, rate, startPos: spos);
	sig = sig * saw * amp;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)


// CREATE SYNTH FOR A KICK TO GIVE A HEART FEELING
(
SynthDef("KD", {
	arg freqA=1000, freqB=100, freqC=10, freqDur1=0.01, freqDur2=0.2, freqC1=1, freqC2=(-1),
	atk=0.01, rel=2, c1=1, c2=(-12), amp=1.3, pan=0, out=0;
	var sig, env, freqSweep;

	freqSweep=Env([freqA, freqB, freqC], [freqDur1, freqDur2], [freqC1, freqC2]).ar;
	env = Env([0, 1, 0], [atk, rel], [c2, c2]).kr(2);
	sig = SinOsc.ar(freqSweep, pi/2);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

// ANOTHER SYNTH FOR KICK
(
SynthDef("KDD", {
	arg freqA=700, freqB=80, freqC=10, freqDur1=0.01, freqDur2=0.2, freqC1=1, freqC2=(-1),
	atk=0.05, rel=1, c1=1, c2=(-12), amp=1.3, pan=0, out=0;
	var sig, env, freqSweep;

	freqSweep=Env([freqA, freqB, freqC], [freqDur1, freqDur2], [freqC1, freqC2]).ar;
	env = Env([0, 1, 0], [atk, rel], [c2, c2]).kr(2);
	sig = SinOsc.ar(freqSweep, pi/2);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)


// CREATE SYNTH
(
SynthDef.new(\saw, {
	arg cutoff=1000, amp=0.4;
	var sig;
	sig = Saw.ar([50,51]);
	sig = RLPF.ar(sig, cutoff.lag(0.02), 0.25, 0.2);
	Out.ar(0, sig * amp);
}).add;
)


// CREATE ANOTHER SYNTH
(
SynthDef.new(\saw2, {
	arg cutoff=1000, amp=0.15;
	var sig;
	sig = Saw.ar([48,52]);
	sig = RLPF.ar(sig, cutoff.lag(0.02), 0.25, 0.2);
	Out.ar(0, sig * amp);
}).add;
)


// CONNECT SYNTHS TO VARIABLES
~birds = Synth.new(\play);
~nobirds = Synth.new(\dead);

~kick = (dur: [0.9, 0.25].pseq, \instrument: \KD, freqA: [300, 500].pseq) +> \kickdrum;
~kickk = (dur: [0.9, 0.25].pseq, \instrument: \KDD, freqA: [250, 650].pseq) +> \kickdrumm;

~synth = Synth(\saw, [\cutoff, 1000]);
~synth2 = Synth(\saw2, [\cutoff, 1000]);


// CREATE ROUTINES AND CHANGE A PARAMETER OF YOUR SYNTHS WITH THE ~VAL SO THEY CHANGE DYNAMICALLY
(
~controlb = Routine.new({
{
		~birds.set(\sawFreq, ~val.linexp(0, 1023, 1, 3));
		0.01.wait;
		~birds.set(\amp, ~val.linexp(0, 1023, 0.45, 0.001));
		0.01.wait;
	}.loop;
}).play;
)

(
~controlnb = Routine.new({
{
		~nobirds.set(\sawFreq, ~val.linexp(0, 1023, 1, 3));
		0.01.wait;
		~nobirds.set(\amp, ~val.linexp(0, 1023, 0.04, 19.9));
		0.01.wait;
	}.loop;
}).play;
)

(
~controlk = Routine.new({
	{
		~kick.set(\dur, ~val.linexp(0, 1023, 0.9, 0.01), ~val.linexp(0, 1023, 0.4, 0.004));
		0.01.wait;
	}.loop;
}).play;
)

(
~controlkk = Routine.new({
	{
		~kickk.set(\dur, ~val.linexp(0, 1023, 1, 0.009), ~val.linexp(0, 1023, 0.1, 0.003));
		0.01.wait;
	}.loop;
}).play;
)



(
~control = Routine.new({
	{
		~synth.set(\cutoff, ~val.linexp(0, 1023, 500, 8000));
		0.01.wait;
		~synth.set(\amp, ~val.linexp(0, 1023, 0.2, 10));
		0.01.wait;
	}.loop;
}).play;
)

(
~control2 = Routine.new({
	{
		~synth2.set(\cutoff, ~val.linexp(0, 1023, 400, 7000));
		0.01.wait;
		~synth2.set(\amp, ~val.linexp(0, 1023, 0.1, 2.5));
		0.01.wait;
	}.loop;
}).play;
)
