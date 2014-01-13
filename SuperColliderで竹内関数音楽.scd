// SuperColliderで竹内関数音楽
// "http://d.hatena.ne.jp/aike/20120723"
(
    var scale, arpeggiator, tarai;
    var bar = 0;

    SynthDef("tone", {|freq=440|
        var out;
        out = SinOsc.ar(freq);
        out = out * Line.kr(0.5, 0, 0.5, doneAction:2);
        out = Pan2.ar(out);
        Out.ar(0, out);
    }).send(s);

    scale = Array.new(20);
    20.do{|i|
        scale.add(Scale.dorian.degreeToFreq(i, 62.midicps, 1));
    };

    arpeggiator = {|x, y, z|
        var w = 0.11;
        var a = [x, y, z].sort;
        2.do {
            Synth("tone", [freq: a[0]]);
            w.wait;
            Synth("tone", [freq: a[0] * 2]);
            w.wait;
            Synth("tone", [freq: a[1]]);
            w.wait;
            Synth("tone", [freq: a[1] * 2]);
            w.wait;
            Synth("tone", [freq: a[2]]);
            w.wait;
            Synth("tone", [freq: a[2] * 2]);
            w.wait;
            Synth("tone", [freq: a[1]]);
            w.wait;
            Synth("tone", [freq: a[1] * 2]);
            w.wait;
        };
    };

    tarai = {|x, y, z|
        bar = bar + 1;
        postln(' ' ++ bar ++ ': ['++ x ++ ', ' ++ y ++ ', ' ++ z ++ ']');
        arpeggiator.value(scale[x + 1], scale[y + 1], scale[z + 1]);
        if ( x <= y, {
            y;
        },{
            tarai.value(
                tarai.value(x - 1, y, z),
                tarai.value(y - 1, z, x),
                tarai.value(z - 1, x, y)
            );
        });
    };

    Task({
        // tarai.value(10, 5, 0);
        // tarai.value(6, 3, 0);
        tarai.value(4, 3, 0);
    }).play;
)
