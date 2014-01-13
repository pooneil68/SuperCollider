(
SynthDef("up-piano-20", {
    arg freq=440, gate=1, amp=1, pan=0, downRate=20000, mix=0.25, room=0.15, damp=0.5;
    var x, y, env;
    env = Env.asr(5,1,5, -3);
    x = SinOsc.ar(freq,0,amp);
    y = LFNoise2.ar(0.2,downRate/100,downRate);
    x = Latch.ar(x, Impulse.ar(y));
    x = FreeVerb.ar(x,mix,room,damp);
    x = EnvGen.kr(env,gate,doneAction: 2) * x;
    Out.ar(0, Pan2.ar(x,pan));
}).store;
)

(
// Stacked Chord Loop

var bpm          = 80;
var nodeArray    = Array.new();
var chordArray   = Array.new();
var scaleArray   = #[  12,  14,   4,   5,   7,   9,  11];
var weightArray  = #[ 0.1,0.05, 0.3, 0.1,0.05, 0.2, 0.2];

/**
 * sequencers
 */
var sequencer = Task({
    var note, node;
    loop({
        if( 0.15.coin, {
            note = scaleArray.wchoose(weightArray) + 51;
            if( 0.2.coin, {
                note = note + 12;
            });
            while( { chordArray.includes(note) }, {
                note = scaleArray.wchoose(weightArray) + 51;
            });
            chordArray = chordArray.addFirst(note);
            node = Synth.tail( nil, "up-piano-20", [
                \freq, note.midicps,
                \amp, (0.05.rand2 + 0.1)*0.5,
                \pan, 0.8.rand2,
                \downRate, 10000.rand2 + 15000,
                \mix, 0.5.rand2 + 0.5
            ]);
            nodeArray = nodeArray.addFirst(node);
            if( chordArray.size > 5, {
                chordArray.pop;
                s.sendMsg( "/n_set", nodeArray.pop.nodeID, \gate, 0.0 );
            });
            chordArray.postln;
        });
        1.wait;
    });
}, TempoClock(bpm/60));


/**
 * music start
 */
SystemClock.sched(0,{sequencer.start});
)