SynthDef("fm2", { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, mul = 0.05, sustain = 1, pan = 0;
    var mod, car, env;
	env = Env.linen(0.05, sustain, 0.1);
    mod = SinOsc.ar(freq * modPartial, 0,
        freq * index * LFNoise1.kr(5.reciprocal).abs);
    car = EnvGen.kr(env,1,doneAction: 2) * SinOsc.ar((freq * carPartial) + mod, 0, mul);
    Out.ar(bus, Pan2.ar(car,pan))
}).add;

SynthDef("fm3", { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, mul = 0.05, sustain = 1, pan = 0;
    var mod, car, env;
	// modPartial = MouseX.kr(1, 3, 1).poll;
	env = Env.linen(0.05, sustain, 0.1);
    mod = SinOsc.ar(freq * modPartial, 0,
        freq * index * LFNoise1.kr(5.reciprocal).abs);
    car = EnvGen.kr(env,1,doneAction: 2) * SinOsc.ar((freq * carPartial) + mod, 0, mul);
    Out.ar(bus, Pan2.ar(car,pan))
}).add;

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
