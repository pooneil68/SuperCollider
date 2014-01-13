Server.default = s = Server.internal.boot;
// 01. Introductory Remarks
{ SinOsc.ar([440, 442], 0, 0.2) }.play;

// Tutorial #1: First Steps
  "Hello World!".postln;
  8.rand;
  8.0.rand;
// Blocks (and variables)
(
"Call me, ".post;
"Ishmael.".postln;
)
// Tutorial #2: Start Your Engines
  s.quit;
  s.boot;
// Tutorial #3: Functions and Other Functionality
"Function evaluated".postln;
f = { "Function evaluated".postln; };
f.value;
f;

f = { "Evaluating...".postln; 2 + 3; };
f.value;

f = 3;            // Here I make f equal to a number
f.value;        // Post window says: 3, i.e it returns itself
f.value;        // Still says 3

f = { 3.0.rand; };    // Here it's a Function.
f.value;        // 3.0.rand means return a random value from 0 to 3.0 exclusive.
f.value;        // something different
f.value;        // something different

f = { arg a; a.value + 3 };    // call 'value' on the arg; polymorphism awaits!
f.value(3);            // 3.value = 3, so this returns 3 + 3 = 6
g = { 3.0.rand; };
f.value(g);            // here the arg is a Function. Cool, huh?
f.value(g);            // try it again, different result

f = { arg a, b;    a - b;};
f.value(5, 3);
f.value(5, 1);

// Polymorphism
f = { arg a; a.value + 3 };
f.value(3);               // Send an int
f.value( 3.0.rand );   //Send a float
f.value({ 3.0.rand; });   //Send a function
//...either way .value works just fine

// Named parameters
f = { arg a, b; a / b; };
f.value(b: 2, a: 10);
f.value(b: 3, a: 10.0);
f.value(b: 3, a: 10);

// Default arguments
f = { arg a, b = 2; a + b; };
f.value(2);    // 2 + 2
f.value(4);    // 2 + 2
f.value(a:4, b:3);

f = { arg a, b; a + b; };
g = { |a, b| a + b; };
f.value(2, 3);
g.value(2, 4);

// Method variables
(
f = { arg a, b;
    var firstResult, finalResult;
    firstResult = a + b;
    finalResult = firstResult * 2;
    finalResult;
};
f.value(2, 3);    // this will return (2 + 3) * 2 = 10
)

// scope
f = { var foo; foo = 3; foo; };
f.value;
foo;  // this will cause an error as 'foo' is only valid within f.

// block
(
var myFunc;
myFunc = { |input| input.postln; };
myFunc.value("foo");    // arg is a String
myFunc.value("bar");
)

myFunc;            // throws an error

// Tutorial #4: Functions and Sound
{ SinOsc.ar(440, 0, 0.2) }.play;
{ SinOsc.ar([440, 442], 0, 0.2) }.play;

// Instantiation methods
  x = SinOsc.ar(440, 0, 0.2) //audio rate
  x = SinOsc.kr(440, 0, 0.2) //control rate

// Unit generators
(
{ var ampOsc;
	ampOsc = SinOsc.kr(0.5, 1.5pi, 0.5, 0.5);
	SinOsc.ar([440, 442], 0, ampOsc);
	}.play;
)

// Tutorial #5: Stereo
a = ["foo", "bar"]; // "foo" is at index 0; "bar" is at index 1
a.at(0);
a.at(1);
a.at(2); // returns "nil", as there is no object at index 2
// there's a shorthand for at that you'll see sometimes:
a[0];            // same as a.at(0);
a[1];            // same as a.at(0);
a[2];            // same as a.at(0);

// Multi-channel expansion
  { [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;
  { SinOsc.ar([440, 442], 0, 0.2) }.play; //equivalent to above

(
{ var freq;
    freq = [[660, 880], [440, 660], 1320, 880].choose;
	// freq.println;
    SinOsc.ar(freq, 0, 0.2);
}.play;
)

// Panning
{ PinkNoise.ar(0.2) }.play
{ PinkNoise.ar(0.2) !2}.play // 左右同じ
{ PinkNoise.ar([0.2, 0.2]) }.play // 左右違う
{ Pan2.ar(PinkNoise.ar(0.2), 0) }.play; //fixed at 0
{ Pan2.ar(PinkNoise.ar(0.2), -0.3) }.play; //fixed at -0.3
{ Pan2.ar(PinkNoise.ar(0.2), SinOsc.kr(0.5)) }.play; //moving

// Tutorial #6: Mixing
{ PinkNoise.ar(0.2) }.play;
{ SinOsc.ar(440, 0, 0.2) }.play;
{ Saw.ar(660, 0.2) }.play;

{ PinkNoise.ar(0.2) + SinOsc.ar(440, 0, 0.2) + Saw.ar(660, 0.2) }.play;

// The 'Mix' class
{ Mix.new(
	[SinOsc.ar(440, 0, 0.2), Saw.ar(660, 0.2)])
	.postln }.play;
// a BinaryOpUGen

// ...or to mix an array of arrays, i.e. an array of stereo channels, into a single stereo channel:

{
	var a, b;
	a = [SinOsc.ar(440, 0, 0.2), Saw.ar(662, 0.2)];
    b = [SinOsc.ar(442, 0, 0.2), Saw.ar(660, 0.2)];
    // Mix([a, b]).postln;
    Mix([a, b]);
}.play;
// [ a BinaryOpUGen, a BinaryOpUGen ]
// Note that Mix() is equivalent to Mix.new().

// Mixing on a loop
// Mixは 'new'以外のclass methodとして'fill'を持っている。
// Mix.fill allows you to mix the same UGen multiple times with parameters:

(
  var n = 8;
  {
    Mix.fill(n,
      { SinOsc.ar(500 + 500.0.rand, 0, 1 / n) }
    )
  }.play;
)
// The mul arg of each SinOsc is set to 1 / n, thus ensuring that the total amplitude will not go outside -1 and 1

{Mix([SinOsc.ar(500 + 500.0.rand, 0, 1 / 2)],
	 [SinOsc.ar(500 + 500.0.rand, 0, 1 / 2)])}.play;
// この場合、ふたつのrandは同じものを返すので同じ音の高さになる

// Mixing on a loop with an index parameter
// increments with each call:
(
  var n = 8;
{
	Mix.fill(n,
		{
			arg index;
			var freq;
			index.postln;
			freq = 440 + ( 2 * index );
			freq.postln;
			SinOsc.ar(freq , 0, 1 / n);
			}
		)
	}.play;
)

// Tutorial #7: Scoping and Plotting

// Make a graph of the signal produced by the output of the Function:

{ PinkNoise.ar(0.2) + Saw.ar(660, 0.2) }.plot; //default 0.01
{ PinkNoise.ar(0.2) + Saw.ar(660, 0.2) }.plot(1); // 1 sec
{ PinkNoise.ar(0.2) + SinOsc.ar(440, 0, 0.2) + Saw.ar(660, 0.2) }.plot;

f = { PinkNoise.ar(0.2) + SinOsc.ar(440, 0, 0.2) + Saw.ar(660, 0.2) }
f.plot;
f.play;

// Scoping
{ PinkNoise.ar(0.2) + Saw.ar(660, 0.2) }.scope;
{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.scope;

{ Ringz.ar(PinkNoise.ar([0.1, 0.2]).scope(\pink), 2000, 1, 0.25) }.play; // multichannel works

s.scope; // can still separately scope the output of the server

// Scoping with zoom
// Just add the named parameter:
{ PinkNoise.ar(0.2) + Saw.ar(660, 0.2) }.scope(zoom: 10);

// Scoping any time
// Scope the internal server anytime:

  {
    [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)]
  }.play(Server.internal);
  Server.internal.scope; //or s.scope if internal is default

// Tutorial #8: Help

{ SinOsc.ar(440, 0, 0.2) }.play;
play({ SinOsc.ar(440, 0, 0.2) });

// Programmatically navigating the API
Group.superclass; //this will return 'Node'
Group.superclass.openHelpFile;
Group.findRespondingMethodFor('set'); //Node-set
Group.findRespondingMethodFor('postln'); //Object-postln
Group.helpFileForMethod('postln'); //opens Object help file

// Tutorial #9: SynthDefs

Functions create SynthDefs
If you play a function, behind the scenes it creates a SynthDef:

//these two are equivalent
{ SinOsc.ar(440, 0, 0.2) }.play;
// now here's an equivalent SynthDef
SynthDef.new("tutorial-SinOsc", { Out.ar(0, SinOsc.ar(440, 0, 0.2)) }).play;

//これで"tutorial-SinOsc"というSynthDefを作った。
SynthDef.new("tutorial-SinOsc",{ Out.ar(0, SinOsc.ar(440, 0, 0.2)) } );
// それをplayする
Synth("tutorial-SinOsc");

// (The first argument to SynthDef.new identifies the SynthDef, the second is a function known as a 'UGen Graph Function', since it tells the synth how to connect various UGens together to make a synth)

SynthDef.new("tutorial-SinOsc-stereo", { var outArray;
    outArray = [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)];
    Out.ar(0, outArray)})
Synth("tutorial-SinOsc-stereo");

// Manipulate a SynthDef
// SynthDef.new returns a Synth, which you can manipulate / free:
  x = { SinOsc.ar(660, 0, 0.2) }.play;
  y = SynthDef.new("myDef",
      { Out.ar(1, SinOsc.ar(440, 0, 0.2)) }).play;
  x.free; // free just x
  y.free; // free just y

// execute first, by itself
SynthDef.new("tutorial-PinkNoise", { Out.ar(0, PinkNoise.ar(0.3)) }).add;

// then:
x = Synth.new("tutorial-PinkNoise");
y = Synth.new("tutorial-PinkNoise");
x.free; y.free;

// Send and load
  SynthDef.new("myDef",
      { Out.ar(0, PinkNoise.ar(0.3)) }).send(s);
  x = Synth.new("myDef");
  y = Synth.new("myDef");

// Objects evaluate only on the client
  f = { SinOsc.ar(440 + 200.rand, 0, 0.2) };
  x = f.play;
  y = f.play;
  z = f.play; //playするたびrandが評価されている
  x.free; y.free; z.free;

  SynthDef("myDef",
      { Out.ar(0, SinOsc.ar(440 + 200.rand, 0, 0.2)) }).send(s);
  x = Synth("myDef");
  y = Synth("myDef");
  z = Synth("myDef"); // randはsendしたときだけ評価
  x.free; y.free; z.free;

// Use arguments to create variety
SynthDef("tutorial-Rand", { Out.ar([0,1], SinOsc.ar(Rand(440, 660), 0, 0.2)) }).add;
x = Synth("tutorial-Rand");
y = Synth("tutorial-Rand");
z = Synth("tutorial-Rand");
x.free; y.free; z.free;

// Change values after instantiation
(
SynthDef("tutorial-args", { arg freq = 440, out = 0;
    Out.ar(out, SinOsc.ar(freq, 0, 0.2));
}).add;
)
x = Synth("tutorial-args"); // no args, so default values
y = Synth("tutorial-args", ["freq", 660]);        // change freq
z = Synth("tutorial-args", ["freq", 880, "out", 1]);    // change freq and output channel
x.free; y.free; z.free;

// Synth understands some methods which allow you to change the values of args after a synth has been created, one example is set:
SynthDef.new("myDef", { arg freq = 440, out = 0;
	Out.ar(out, SinOsc.ar(freq, 0, 0.2));
	}).send(s);
x = Synth.new("myDef");
x.set("freq", 660);  // 新しいのを作るのではなくて、xを変える。
x.set("freq", 880, "out", 1);

// Use symbols not strings
// Symbols are more 'typesafe':
"a String" === "a String"; //false
\aSymbol === 'aSymbol';    //true
"this" === \this;          //false

// Tutorial #10: Busses

// Read and write to bus indices
// Use bus indices directly (first arg is 'base' index, second argument is number of channels, counting up from that):

In.ar(0, 1); // this will return 'an OutputProxy'
// an OutputProxy
In.ar(0, 4); // this will return an Array of 4 OutputProxies
// [ an OutputProxy, an OutputProxy, an OutputProxy, an OutputProxy ]

// This throws an error. Can't write a control rate signal to an audio rate bus
{Out.ar(0, SinOsc.kr)}.play;
// This will work as the audio rate signal is downsampled to control rate
{Out.kr(0, SinOsc.ar)}.scope;

{Out.ar(0, SinOsc.ar)}.scope;

// Multiple synths on the same bus are summed
(
SynthDef("tutorial-args", { arg freq = 440, out = 0;
    Out.ar(out, SinOsc.ar(freq, 0, 0.2));
}).add;
)
// both write to bus 1, and their output is mixed
x = Synth("tutorial-args", ["out", 1, "freq", 660]);
y = Synth("tutorial-args", ["out", 1, "freq", 770]);

// Set the (constant) value of a kr bus
// Use .set to send a fixed value:
b = Bus.control(s, 2); // Get a two channel control Bus
c = Bus.audio(s);     // Get a one channel private audio Bus (one is the default)

//
s.reboot; // this will restart the server app and thus reset the bus allocators
b = Bus.control(s, 2);    // a 2 channel control Bus
b.index;         // this should be zero
b.numChannels         // Bus also has a numChannels method
c = Bus.control(s);
c.numChannels;        // the default number of channels is 1
c.index;        // note that this is 2; b uses 0 and 1

b = Bus.control(s, 2);
b.free; // free the indices. You can't use this Bus object after that

//----------------------
(
SynthDef("tutorial-Infreq", { arg bus, freqOffset = 0;
    // this will add freqOffset to whatever is read in from the bus
    Out.ar(0, SinOsc.ar(In.kr(bus) + freqOffset, 0, 0.5));
}).add;

SynthDef("tutorial-Outfreq", { arg freq = 400, bus;
    Out.kr(bus, SinOsc.kr(1, 0, freq/40, freq));
}).add;

b = Bus.control(s,1);
)

(
x = Synth.new("tutorial-Outfreq", [\bus, b]);
y = Synth.after(x, "tutorial-Infreq", [\bus, b]);
z = Synth.after(x, "tutorial-Infreq", [\bus, b, \freqOffset, 200]);
)
x.free; y.free; z.free; b.free;

//----------------------
(
// the arg direct will control the proportion of direct to processed signal
SynthDef("tutorial-DecayPink", { arg outBus = 0, effectBus, direct = 0.5;
    var source;
    // Decaying pulses of PinkNoise. We'll add reverb later.
    source = Decay2.ar(Impulse.ar(1, 0.25), 0.01, 0.2, PinkNoise.ar);
    // this will be our main output
    Out.ar(outBus, source * direct);
    // this will be our effects output
    Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef("tutorial-DecaySin", { arg outBus = 0, effectBus, direct = 0.5;
    var source;
    // Decaying pulses of a modulating sine wave. We'll add reverb later.
    source = Decay2.ar(Impulse.ar(0.3, 0.25), 0.3, 1, SinOsc.ar(SinOsc.kr(0.2, 0, 110, 440)));
    // this will be our main output
    Out.ar(outBus, source * direct);
    // this will be our effects output
    Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef("tutorial-Reverb", { arg outBus = 0, inBus;
    var input;
    input = In.ar(inBus, 1);

    // a low-rent reverb
    // aNumber.do will evaluate its function argument a corresponding number of times
    // {}.dup(n) will evaluate the function n times, and return an Array of the results
    // The default for n is 2, so this makes a stereo reverb
    16.do({ input = AllpassC.ar(input, 0.04, { Rand(0.001,0.04) }.dup, 3)});

    Out.ar(outBus, input);
}).add;

b = Bus.audio(s,1); // this will be our effects bus
)

(
x = Synth.new("tutorial-Reverb", [\inBus, b]);
y = Synth.before(x, "tutorial-DecayPink", [\effectBus, b]);
z = Synth.before(x, "tutorial-DecaySin", [\effectBus, b, \outBus, 1]);
)

// Change the balance of wet to dry
y.set(\direct, 1); // only direct PinkNoise
z.set(\direct, 1); // only direct Sine wave
y.set(\direct, 0); // only reverberated PinkNoise
z.set(\direct, 0); // only reverberated Sine wave
x.free; y.free; z.free; b.free;

//----------------------
// Map a bus to a Synth argument
(
// make two control rate busses and set their values to 880 and 884.
b = Bus.control(s, 1); b.set(880);
c = Bus.control(s, 1); c.set(884);
// and make a synth with two frequency arguments
x = SynthDef("tutorial-map", { arg freq1 = 440, freq2 = 440;
    Out.ar(0, SinOsc.ar([freq1, freq2], 0, 0.1));
}).play(s);
)
// Now map freq1 and freq2 to read from the two busses
x.map(\freq1, b, \freq2, c);
// Now make a Synth to write to the one of the busses
y = {Out.kr(b, SinOsc.kr(1, 0, 50, 880))}.play(addAction: \addToHead);
// free y, and b holds its last value
y.free;
// use Bus-get to see what the value is. Watch the post window
b.get({ arg val; val.postln; f = val; });
// set the freq2, this 'unmaps' it from c
x.set(\freq2, f / 2);
// freq2 is no longer mapped, so setting c to a different value has no effect
c.set(200);
x.free; b.free; c.free;

//---------------------------------
// make a Bus object and set its values
b = Bus.control(s, 1); b.set(880);
// execute this altogether
(
f = nil; // just to be sure
b.get({ arg val; f = val; });
f.postln;
)
// f equals nil, but try it again and it's as we expected!
f.postln;

//---------------------------------
// Order of execution
x = Synth("default", [\freq, 300]);
// add a second synth immediately after x
y = Synth("default", [\freq, 450], x, \addAfter);
x.free; y.free;

// These two lines of code are equivalent
// x = Synth("default", [\freq, 300]); これをやってから
y = Synth.new("default", [\freq, 450], x, \addAfter);
y = Synth.after(x, "default", [\freq, 450]);

//---------------------------------
// Tutorial #11: Groups
(
// a stereo version
SynthDef(\tutorial_DecaySin2, { arg outBus = 0, effectBus, direct = 0.5, freq = 440;
    var source;
    // 1.0.rand2 returns a random number from -1 to 1, used here for a random pan
    source = Pan2.ar(Decay2.ar(Impulse.ar(Rand(0.3, 1), 0, 0.125), 0.3, 1,
        SinOsc.ar(SinOsc.kr(0.2, 0, 110, freq))), Rand(-1.0, 1.0));
    Out.ar(outBus, source * direct);
    Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef(\tutorial_Reverb2, { arg outBus = 0, inBus;
    var input;
    input = In.ar(inBus, 2);
    16.do({ input = AllpassC.ar(input, 0.04, Rand(0.001,0.04), 3)});
    Out.ar(outBus, input);
}).add;
)

// now we create groups for effects and synths
(
~sources = Group.new;
~effects = Group.after(~sources);     // make sure it's after
~bus = Bus.audio(s, 2);         // this will be our stereo effects bus
)

// now synths in the groups. The default addAction is \addToHead
(
x = Synth(\tutorial_Reverb2, [\inBus, b], ~effects);
y = Synth(\tutorial_DecaySin2, [\effectBus, ~bus, \outBus, 0], ~sources);
z = Synth(\tutorial_DecaySin2, [\effectBus, ~bus, \outBus, 0, \freq, 660], ~sources);
)

// we could add other source and effects synths here
~sources.free; ~effects.free; // this frees their contents (x, y, z) as well
~bus.free;
// remove references to ~sources and ~effects environment variables:
currentEnvironment.clear;

// to be sure, create a new Environment:
Environment.new.push;

// some code..

// restore old environment
currentEnvironment.pop;

//-------------------------
{ SinOsc.ar(mul: 0.2) }.scope(1);
// watch the post window;
s.queryAllNodes;
// our SinOsc synth is within the default group (ID 1)
// the scope node ('stethoscope') comes after the default group, so no problems

//-------------------------
g = Group.new;
// make 4 synths in g
// 1.0.rand2 returns a random number from -1 to 1.
4.do({ { arg amp = 0.1; Pan2.ar(SinOsc.ar(440 + 110.rand, 0, amp), 1.0.rand2) }.play(g); });
g.set(\amp, 0.005); // turn them all down
g.free;

//-------------------------
// Tutorial #12: Buffers
s.boot;
b = Buffer.alloc(s, 100, 2);    // allocate 2 channels, and 100 frames
b.free;  // free the memory (when you're finished using it)

b = Buffer.alloc(s, s.sampleRate * 8.0, 2); // 8 second stereo
b.free;

// read a soundfile
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
// now play it
(
x = SynthDef("tutorial-PlayBuf",{ arg out = 0, bufnum;
    Out.ar( out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum))
    )
}).play(s,[\bufnum, b]);
)
x.free; b.free;

// ----------------------
(
SynthDef("tutorial-Buffer-cue",{ arg out=0,bufnum;
    Out.ar(out,
        DiskIn.ar( 1, bufnum )
    )
}).add;
)

b = Buffer.cueSoundFile(s,Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff", 0, 1);
y = Synth.new("tutorial-Buffer-cue", [\bufnum,b], s);

b.free; y.free;

// ----------------------
// watch the post window
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
b.bufnum;
b.numFrames;
b.numChannels;
b.sampleRate;
b.free;

// ----------------------
// with an action function
// note that the vars are not immediately up-to-date
(
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", action: { arg buffer;
    ("numFrames after update:" + buffer.numFrames).postln;
    x = { PlayBuf.ar(1, buffer, BufRateScale.kr(buffer)) }.play;
});

// Note that the next line will execute BEFORE the action function
("numFrames before update:" + b.numFrames).postln;
)
x.free; b.free;

// ----------------------
// Recording into Buffers
b = Buffer.alloc(s, s.sampleRate * 5, 1); // a 5 second 1 channel Buffer

// record for four seconds
(
x = SynthDef("tutorial-RecordBuf",{ arg out=0,bufnum=0;
    var noise;
    noise = PinkNoise.ar(0.3);    // record some PinkNoise
    RecordBuf.ar(noise, bufnum);     // by default this loops
}).play(s,[\out, 0, \bufnum, b]);
)

// free the record synth after a few seconds
x.free;

// play it back
(
SynthDef("tutorial-playback",{ arg out=0,bufnum=0;
    var playbuf;
    playbuf = PlayBuf.ar(1,bufnum);
    FreeSelfWhenDone.kr(playbuf); // frees the synth when the PlayBuf has played through once
    Out.ar(out, playbuf);
}).play(s,[\out, 0, \bufnum, b]);
)
b.free;

// ----------------------
// Accessing Data
b = Buffer.alloc(s, 8, 1);
b.set(7, 0.5);             // set the value at 7 to 0.5
b.get(7, {|msg| msg.postln});    // get the value at 7 and post it when the reply is received
b.free;

b = Buffer.alloc(s,16);
b.setn(0, [1, 2, 3]);       // set the first 3 values
b.getn(0, 3, {|msg| msg.postln});    // get them
b.setn(0, Array.fill(b.numFrames, {1.0.rand}));    // fill the buffer with random values
b.getn(0, b.numFrames, {|msg| msg.postln});    // get them
b.free;

(
// make some white noise
v = FloatArray.fill(44100, {1.0.rand2});
b = Buffer.alloc(s, 44100);
)
(
// load the FloatArray into b, then play it
b.loadCollection(v, action: {|buf|
    x = { PlayBuf.ar(buf.numChannels, buf, BufRateScale.kr(buf), loop: 1)
        * 0.2 }.play;
});
)
x.free;

// now get the FloatArray back, and compare it to v; this posts 'true'
// the args 0, -1 mean start from the beginning and load the whole buffer
b.loadToFloatArray(0, -1, {|floatArray| (floatArray == v).postln });
b.free;

// ----------------------
// see the waveform
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
b.plot;

// play the contents
// this takes one arg: loop. If false (the default) the resulting synth is
// freed automatically
b.play;             // frees itself
x = b.play(true);        // loops so doesn't free
x.free; b.free;

// ----------------------
// Other Uses For Buffers
b = Buffer.alloc(s, 512, 1);
b.cheby([1,0,1,1,0,1]);
(
x = play({
    Shaper.ar(
        b,
        SinOsc.ar(300, 0, Line.kr(0,1,6)),
        0.5
    )
});
)
x.free; b.free;

// ----------------------
// Tutorial #13: Scheduling Events
// TempoClock - Musical sequencing, can change tempo and is aware of meter changes
// SystemClock - Actual time, in seconds
// AppClock - Also runs in seconds but has a lower system priority (better for graphic updates and other non-timecritical activities)

// Schedule relative to current time
// Say 'hello' in 5 seconds:
SystemClock.sched(5, { "hello".postln });

// Schedule for an absolute time
// Provide a time at which to say 'hello':
(
var timeNow = TempoClock.default.beats;
"Time is now: ".post; timeNow.postln;
"Scheduling for: ".post; (timeNow + 5).postln;
TempoClock.default.schedAbs(timeNow + 5,
    { "Time is later: ".post; thisThread.clock.beats.postln; nil });
)

// -----------------------
(
var timeNow;
TempoClock.default.tempo = 2;    // 2 beats/sec, or 120 BPM
timeNow = TempoClock.default.beats;
"Time is now: ".post; timeNow.postln;
"Scheduling for: ".post; (timeNow + 5).postln;
TempoClock.default.schedAbs(timeNow + 5,
    { "Time is later: ".post; thisThread.clock.beats.postln; nil });
)

// -----------------------
// schedule objects that will take some action.

// fires many times (but looks like it should fire just once)
TempoClock.default.sched(1, { rrand(1, 3).postln; });
// fires once
TempoClock.default.sched(1, { rrand(1, 3).postln; nil });

// -----------------------
// Tutorial #14: Scheduling with Routines and Tasks

r = Routine({
	"abcde".yield;
    "fghij".yield;
    "klmno".yield;
    "pqrst".yield;
    "uvwxy".yield;
    "z{|}~".yield;
});
r.next;
// Successive calls to r.next yield the following:

6.do({ r.next.postln });

//
r = Routine({
	1.postln.yield;
    2.postln.yield;
    1.postln.yield;
  });
TempoClock.default.sched(0, r); //instead of r.next
r.play; //shorthand for the use of TempoClock

// Scheduling routines
r = Routine({
    var delta;
    loop {
        delta = rrand(1, 3) * 0.5;
        "Will wait ".post; delta.postln;
        delta.yield;
    }
});

r.next;
TempoClock.default.sched(0, r);
r.stop;

//------------------------------------
// Now let's replace the posting statements with instructions to play a synth. Preparation:
(
SynthDef(\singrain, { |freq = 440, amp = 0.2, sustain = 1|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.perc(0.01, sustain), doneAction: 2);
    Out.ar(0, sig ! 2);    // sig ! 2 is the same as [sig, sig]
}).add;

r = Routine({
    var delta;
    loop {
        delta = rrand(1, 3) * 0.5;
        Synth(\singrain, [freq: exprand(200, 800), amp: rrand(0.1, 0.5), sustain: delta * 0.8]);
        delta.yield;
    }
});
)

r.play;
r.stop;

//------------------------------------
// Schedule a Task instead
(
t = Task({
    loop {
        [60, 62, 64, 65, 67, 69, 71, 72].do({ |midi|
            Synth(\singrain, [freq: midi.midicps, amp: 0.2, sustain: 0.1]);
            0.125.wait;
        });
    }
}).play;
)

// probably stops in the middle of the scale
t.stop;
t.play;    // should pick up with the next note
t.stop;

//------------------------------------
// When do you want to start?
(
f = {
    Task({
        loop {
            [60, 62, 64, 65, 67, 69, 71, 72].do({ |midi|
                Synth(\singrain, [freq: midi.midicps, amp: 0.2, sustain: 0.1]);
                0.25.wait;
            });
        }
    });
};
)

t = f.value.play(quant: 4); // start on next 4-beat boundary
u = f.value.play(quant: [4, 0.5]);    // next 4-beat boundary + a half-beat
t.stop; u.stop;

// ---------------------------------
// Using data routines in note sequencing
(
var midi, dur;
midi = Routine({
    [60, 72, 71, 67, 69, 71, 72, 60, 69, 67].do({ |midi| midi.yield });
});
dur = Routine({
    [2, 2, 1, 0.5, 0.5, 1, 1, 2, 2, 3].do({ |dur| dur.yield });
});

SynthDef(\smooth, { |freq = 440, sustain = 1, amp = 0.5|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: 2);
    Out.ar(0, sig ! 2)
}).add;

r = Task({
    var delta;
    while {
        delta = dur.next;
        delta.notNil
    } {
        Synth(\smooth, [freq: midi.next.midicps, sustain: delta]);
        delta.yield;
    }
 }).play(quant: TempoClock.default.beats + 1.0);
)

// A note on server messaging and timing
(
t = Task({
    loop {
        Synth(\singrain, [freq: exprand(400, 1200), sustain: 0.08]);
        0.1.wait;
    }
}).play;
)
t.stop;

//----------
(
t = Task({
    loop {
        s.makeBundle(s.latency, {
            Synth(\singrain, [freq: exprand(400, 1200), sustain: 0.08]);
        });
        0.1.wait;
    }
}).play;
)
t.stop;

// -----------------------------------
// Tutorial #15: Scheduling with Patterns

//routine to output MIDI note numbers to play a couple of phrases
r = Routine({
    [60, 72, 71, 67, 69, 71, 72, 60, 69, 67].do({ |midi| midi.yield });
});

while { (m = r.next).notNil } { m.postln };

// Pseq (Pattern-sequence) to spit out the values in the array one by one
p = Pseq([60, 72, 71, 67, 69, 71, 72, 60, 69, 67], 1);
r = p.asStream;
while { (m = r.next).notNil } { m.postln };

// 'Over the Rainbow' example
(
var midi, dur;
midi = Pseq([60, 72, 71, 67, 69, 71, 72, 60, 69, 67], 1).asStream;
dur = Pseq([2, 2, 1, 0.5, 0.5, 1, 1, 2, 2, 3], 1).asStream;

SynthDef(\smooth, { |freq = 440, sustain = 1, amp = 0.5|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: 2);
    Out.ar(0, sig ! 2)
}).add;

r = Task({
    var delta;
    while {
        delta = dur.next;
        delta.notNil
    } {
        Synth(\smooth, [freq: midi.next.midicps, sustain: delta]);
        delta.yield;
    }
}).play(quant: TempoClock.default.beats + 1.0);
)

//
p = Pwhite(0.0, Pseries(0.01, 0.01, inf), 100).asStream;
    // .all pulls from the stream until it returns nil
    // obviously you don't want to do this for an 'inf' length stream!
p.all.plot;

//
p = Pn(Pshuf([1, 2, 3, 4, 5], 1), inf).asStream;
p.nextN(15);    // get 15 values from the pattern's stream

p.nextN(15).plot; // これでplotできる

// Playing notes with a pattern: Pbind
(
SynthDef(\smooth, { |freq = 440, sustain = 1, amp = 0.5|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: 2);
    Out.ar(0, sig ! 2)
}).add;
)

(
p = Pbind(
        // the name of the SynthDef to use for each note
    \instrument, \smooth,
        // MIDI note numbers -- converted automatically to Hz
    \midinote, Pseq([60, 72, 71, 67, 69, 71, 72, 60, 69, 67], 1),
        // rhythmic values
    \dur, Pseq([2, 2, 1, 0.5, 0.5, 1, 1, 2, 2, 3], 1)
).play;
)

//--------------------------------
(
SynthDef(\bass, { |freq = 440, gate = 1, amp = 0.5, slideTime = 0.17, ffreq = 1100, width = 0.15,
        detune = 1.005, preamp = 4|
    var    sig,
        env = Env.adsr(0.01, 0.3, 0.4, 0.1);
    freq = Lag.kr(freq, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
        * EnvGen.kr(env, gate, doneAction: 2);
    sig = LPF.ar(sig, ffreq);
    Out.ar(0, sig ! 2)
}).add;

TempoClock.default.tempo = 132/60;

p = Pxrand([
    Pbind(
        \instrument, \bass,
        \midinote, 36,
        \dur, Pseq([0.75, 0.25, 0.25, 0.25, 0.5], 1),
        \legato, Pseq([0.9, 0.3, 0.3, 0.3, 0.3], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,
        \midinote, Pseq([36, 48, 36], 1),
        \dur, Pseq([0.25, 0.25, 0.5], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,
        \midinote, Pseq([36, 42, 41, 33], 1),
        \dur, Pseq([0.25, 0.25, 0.25, 0.75], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,
        \midinote, Pseq([36, 39, 36, 42], 1),
        \dur, Pseq([0.25, 0.5, 0.25, 0.5], 1),
        \amp, 0.5, \detune, 1.005
    )
], inf).play(quant: 1);
)

// totally cheesy, but who could resist?
(
SynthDef(\kik, { |preamp = 1, amp = 1|
    var    freq = EnvGen.kr(Env([400, 66], [0.08], -3)),
        sig = SinOsc.ar(freq, 0.5pi, preamp).distort * amp
            * EnvGen.kr(Env([0, 1, 0.8, 0], [0.01, 0.1, 0.2]), doneAction: 2);
    Out.ar(0, sig ! 2);
}).add;

// before you play:
// what do you anticipate '\delta, 1' will do?
k = Pbind(\instrument, \kik, \delta, 1, \preamp, 4.5, \amp, 0.32).play(quant: 1);
)

p.stop;
k.stop;