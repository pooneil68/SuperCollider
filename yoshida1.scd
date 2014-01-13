Server.default = s = Server.internal.boot;
Server.default = s = Server.local;

(
SynthDef.new("tutorial-args", { arg freq = 440, out = 0;
    Out.ar(out, SinOsc.ar(freq, 0, 0.2) !2);
}).add;
)
x = Synth.new("tutorial-args");

// \singrain をdefineする
SynthDef(\singrain, { |freq = 440, amp = 0.2, sustain = 1|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.perc(0.01, sustain), doneAction: 2);
    Out.ar(0, sig ! 2);    // sig ! 2 is the same as [sig, sig]
}).add;

// taskをdefineする
t = Task({
    loop {
        [60, 62, 64, 65, 67, 69, 71, 72].do({ |midi|
            Synth(\singrain, [freq: midi.midicps, amp: 0.2, sustain: 0.1]);
            0.125.wait;
        });
    }
});

// taskをplayする
t.play;    // should pick up with the next note
t.stop;

SynthDef(\smooth, { |freq = 440, sustain = 1, amp = 0.5|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: 2);
    Out.ar(0, sig ! 2)
}).add;

(
p = Pbind(
    \instrument, \singrain,
	\midinote, Pseq([62, 64, 65, 62, 64, 65, 64, 67], 1),
    \dur,      Pseq([ 1,0.5,  1,1.5,  1,0.5,  1,1.5], 1)
);
)
p.play(quant: 1);

//	\midinote, Pseq([60,62,64,65,67,69,71,72], 1),

(
SynthDef(\snare, {|amp= 0.1, attack= 0.01, release= 0.3, filter= 600, pan= 0|
	var snd, env, efx;
	env= EnvGen.kr(Env.perc(attack, release), doneAction:2);
	snd= PinkNoise.ar(env*amp);
	efx= BPF.ar(snd, filter, 0.5, 3);
	Out.ar(0, Pan2.ar(efx, pan));
}).add;
)

k = Pbind(\instrument, \snare, \delta, 2, \preamp, 4.5, \amp, 0.32);

TempoClock.default.tempo = 120/60;

p.play(quant: 1);
k.play(quant: 1);
p.stop;
k.stop;

//------------
(
s = Server.local;
s.recSampleFormat = 'int16';
s.recChannels = 1;
s.recHeaderFormat = 'wav';
s.prepareForRecord("/Users/pooneil/Desktop/SuperCollider/yoshida0113b.wav"); // you have to call this first
s.record;

p = Pn(
	Pbind(
    \instrument, \fm2,
	\midinote, Pseq([ 38, 40, 41, 38, 40, 41], 1),
    \dur,      Pseq([1.5,0.5,  1,1.5,  1,0.5], 1),
	\bus, [0], \carPartial, 1, \modPartial, 1,
	\mul, 0.05, \sustain, 1, \pan, 0.3
), 8).play(quant: 1);
q = Pn(
	Pbind(
    \instrument, \fm3,
	\midinote, Pseq([62, 64, 65, 62, 64, 65, 64, 67], 1),
    \dur,      Pseq([ 1,0.5,  1,1.5,  1,0.5,  1,1.5], 1),
		\bus, [0], \carPartial, 1, \modPartial, 1.97534,
	\mul, 0.05, \sustain, 6, \pan, -0.3
), 6).play(quant: 1);

wait(5);
s.stopRecording; // this closes the file
)

(
SynthDef("fm2", { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, mul = 0.05, sustain = 1, pan = 0;
    var mod, car, env;
	env = Env.linen(0.05, sustain, 0.1);
    mod = SinOsc.ar(freq * modPartial, 0,
        freq * index * LFNoise1.kr(5.reciprocal).abs);
    car = EnvGen.kr(env,1,doneAction: 2) * SinOsc.ar((freq * carPartial) + mod, 0, mul);
    Out.ar(bus, Pan2.ar(car,pan))
}).add;
)
(
SynthDef("fm3", { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, mul = 0.05, sustain = 1, pan = 0;
    var mod, car, env;
	// modPartial = MouseX.kr(1, 3, 1).poll;
	env = Env.linen(0.05, sustain, 0.1);
    mod = SinOsc.ar(freq * modPartial, 0,
        freq * index * LFNoise1.kr(5.reciprocal).abs);
    car = EnvGen.kr(env,1,doneAction: 2) * SinOsc.ar((freq * carPartial) + mod, 0, mul);
    Out.ar(bus, Pan2.ar(car,pan))
}).add;
)
