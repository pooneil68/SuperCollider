//まずは、Hello Worldと、サーバーのブート:

"Hello world"
Server.default = s = Server.internal.boot;

//そして、実際に音の出るサンプル。シンプルだけど出てくる音はなかなか面白い。
play({SinOsc.ar(LFNoise0.kr(12, mul: 600, add: 1000), 0.3)})

//さらにもう一つ音の出るサンプル。
play({RLPF.ar(Dust.ar([12, 15]), LFNoise1.ar(1/[3, 4], 1500, 1600), 0.02)})
// ここで、Dust.arの仲の12と15や、LFNoise1の3と4の数値をいろいろ変化させてみろ、との指示。こうやって実際に数値を変えてすぐに実践できるのがSCの良さの一つかもしれない。

// 加算合成のサンプル。こうやって書くとわかりやすい。
play({
    var sines = 10, speed = 6;
    Mix.fill(sines,
        {arg x;
            Pan2.ar(
                SinOsc.ar(x+1*100,
                    mul: max(0,
                        LFNoise1.kr(speed) +
                        Line.kr(1, -1, 30)
                    )
                ), rand2(1.0))})/sines})

// 1.2 メッセージと引数
rand(100)
exprand(1.0, 100.0)
thisThread.randSeed = 666; {rand(10.0)} ! 10;

// そのあとは様々なメッセージの紹介。くりかえし、小数点の桁の切り捨て、ソートなど。
dup("echo", 20)
round([3.141, 5.9265, 358.98], 0.01)
sort([23, 54, 678, 1, 21, 91, 34, 78])
round(dup({exprand(1, 10)}, 100), 0.1)
sort(round(dup({exprand(1, 10)}, 100), 0.1))
sort(round(dup({exprand(1, 10)}, 100), 0.1)).plot

// 1.3 ネスティング(Nesting)
exprand(1.0, 1000.0)
dup({exprand(1.0, 1000.0)}, 100)
sort(dup({exprand(1.0, 1000.0)}, 100))
round(sort(dup({exprand(1.0, 1000.0)}, 100)), 0.01)

// こうしたネストの使用を音響合成の例でみてみる。
play(
    {
        CombN.ar(
            SinOsc.ar(
                midicps(
                    LFNoise1.ar(3, 24,
                        LFSaw.ar([5, 5.123], 0, 3, 80)
                    )
                ),
                0, 0.4),
            1, 0.3, 2)
    }
)
// 様々なユニットジェネレータがネストされている。

// 1.4 レシーバー.メッセージ、コメント (Receiver.message, Comments)
// 1.3の例では、大文字で始まる命令にメッセージがドット(.)で接続されていた。SinOsc.ar、LFNoise1.ar など。これらはユニットジェネレータ(UGens)と呼ばれ、デジタルオーディオに特化した数値のストリームを出力する。これらはより広範な定義でいうと「レシーバー(Receiver)」と呼ばれるもの。レシーバーは、引数をもったメッセージからの指令によって動作する。

LFNoise1.kr(10,100)
// これは「-100から100の範囲でランダムな値を生成するタイプ1の低周波のノイズ生成器でノイズを1秒に10個生成する」という意味になる。

// 数(Numbers)、関数(functions)、配列(arrays)、文字列(strings)もメッセージをドットで継いで何をするか伝えることができる。

[45, 13, 10, 498, 78].sort
"echo".dup(20)
50.midicps
444.cpsmidi
100.rand
{100.rand}.dup(50)
[1.001, 45.827, 187.18].round(0.1)
"I've just picked up a fault in the AE35 unit".speak

// メッセージを利用した書式は、ドットで継いでいくことでネストを実現できる。
1000.0
1000.0.rand
1000.0.rand.round(0.01)
1000.0.rand.round(0.01).post
{1000.0.rand.round(0.01).postln}.dup(100).plot
{1000.0.rand.round(0.01).postln}.dup(100).postln.sort.plot
1000.0.rand.round(0.01).postln.asString.speak

// 1.5 エンクロージャー (Enclosures)
exprand(1, 1000.0)
{exprand(1, 1000.0)}
// 上のほうは、毎回評価する度に1から1000の間の指数的な乱数を出力する。ところが下の例では、常に"a Function"という出力がされる。では関数(Function)とは何なのか? 以下のサンプルで考察してみる。

dup(rand(1000.0), 5)   // ランダムに数を選択して、それをくりかえす
dup({rand(1000.0)}, 5) // ランダムに選択するという関数(機能)を、くりかえす
// 上の行は、ランダムに選択された数値を5回同じ値でくりかえす。それに対して下の行の場合は、毎回違う値を5回くりかえすことになる。(つまりは、ランダムな値をピックアップするという機能をくりかえしているということか?)

// 関数は様々なメッセージを解釈する。plot, play, scope, dup… など。
{LFNoise0.ar}.play  // ランダムな数列を再生(ノイズ)
{LFNoise0.ar(10000)}.plot // ランダムな数列をプロット
{LFNoise0.ar(10000)}.scope // 再生して波形を表示

{100.rand}.dup(10) // 10コのランダムな数を選択
{100.rand} ! 10 // 上と同じ
{100.rand}.dup(10).postln.plot // 10個の数を選択し、表示した後プロット
{100.rand}.dup(100).sort.plot // 100個の数を選択し、ソートした後プロット

// 1.6 マルチチャンネル
// SCの大括弧にはもう一つ意味があって、マルチチャンネルをあらわすという話。
// UGen(ユニットジェレータ)の引数にArrayが用いられた場合には、いかなる場合にもマルチチャンネルとみなされる。
{Blip.ar(25, LFNoise0.kr(5, 12, 14), 0.3)}.play // 単一チャンネル
{Blip.ar(25, LFNoise0.kr([5, 10], 12, 14), 0.3)}.play // ステレオ
{Blip.ar(25, LFNoise0.kr([5, 10, 2, 25], 12, 14), 0.3)}.play // 4ch
{Blip.ar(25, LFNoise0.kr([5, 4, 7, 9, 5, 1, 9, 2], 12, 14), 0.3)}.play // 8ch

// 1.7 ヘルプ
{PMOsc.ar(440, 550, 7)}.play
// PMOscのヘルプを参照すると、その引数の内容が示されている。
// ar(carfreq, modfreq, pmindex = 0, modphase = 0, mul = 1, add = 0)

// ネスティングを使用して、より面白いサウンドにしてみる。MouseXとMouseYを使用して、マウスからの入力でモジュレータの周波数とインデックス値を変更できるようにしている。
{PMOsc.ar(440, MouseY.kr(1, 550), MouseX.kr(1, 15))}.play

{PMOsc.ar(100, 500, 10, 0, 0.5)}.play
{PMOsc.ar(carfreq: 100, modfreq: 500, pmindex: 10, mul: 0.5)}.play
{PMOsc.ar(carfreq: 100, mul: 0.5, pmindex: 10, modfreq: 500)}.play

// ヘルプの活用の実践として、もうひとつ別のサンプルで考察。
{
    Blip.ar(
        TRand.kr( // frequency or VCO
            100, 1000, // range
            Impulse.kr(Line.kr(1, 20, 60))), // trigger
        TRand.kr( // number of harmonics or VCF
            1, 10, // range
            Impulse.kr(Line.kr(1, 20, 60))), // trigger
        Linen.kr( // mul, or amplitude, VCA
            Impulse.kr(Line.kr(1, 20, 60)), // trigger
            0, // attack
            0.5, // sustain level
            1/Line.kr(1, 20, 60)) // trigger
        )
}.play
// VCO、VCF、VCAという構成の古典的なアナログシンセサイザーを模した減算合成のサンプル。ネストされた要素の内側から外側へと読み解いていく。
// 3つのLine.krのインスタンスが、それぞれImpulseへ数を送出している。それらが、LinenとTRandをトリガーしている。2つのTRandは、Blipの周波数とハーモニクスの数をランダムに決定している。

// ここで、.krと.arの違いについての解説。UGenへのメッセージ.krと.arは、生成される数値のストリームの数を決定している。.arはオーディオレイトの略で、サンプリング周波数と同じ数のストリームを生成(44.1kHzだったら毎秒44100のストリーム)。.krはコントロールレイトの略で、一秒に1ダースほどしか数を生成しない。.krをコントロールに関する部分に使用する計算量の節約になる。

// もう1つのImpulseは、Linenをトリガーしている。これはエンベロープと呼ばれるもので、音量の変化の形を作りだしている。Linenの引数は順番に、トリガー、アタックタイム、サステイン(持続)レベル、ディケイ(減衰)タイム。

// このサンプルでは、3つのImpulseと2つのTRandと4つのLineといったUGenがそれぞれ独立して使用されてる。これらを連動させていくにはどうすれば良いのか? そのためには、変数を用いなければならない。

// 1.8 変数
(
a = 440;
b = 3;
c = "math operations";
[c, a, b, a*b, a + b, a.pow(b), a.mod(b)]
)

//これは、以下のプログラムと同じ。
["math operations", 440, 3, 440*3, 440 + 3, 440.pow(3), 440.mod(3)]

//次にマウスの位置でSinOscのエンベロープを変化させる例。変数を使用することで、Impuluseのタイミングと減衰時間を一致させている。
(
{
r = MouseX.kr(1/3, 10);
SinOsc.ar(mul: Linen.kr(Impulse.kr(r), 0, 1, 1/r))
}.play
)

{Linen.kr(Impulse.kr(1/3), 0, 1, 3)}.plot
{Linen.kr(Impulse.kr(1), 0, 1, 1)}.plot
{Linen.kr(Impulse.kr(10), 0, 1, 1/10)}.plot

// さらに変数を使用したより複雑なサンプル。「1.7 ヘルプ」で使用した減算合成のサンプルを変数を使用して書き直している。
(
p = { // 変数pに関数を代入している
//r = Line.kr(1, 20, 60); // 演奏タイミング
r = LFTri.kr(1/10) * 3 + 7;
// t = Impulse.kr(r); // トリガー
t = Dust.kr(r);
e = Linen.kr(t, 0, 0.5, 1/r); // エンベロープを生成
// f = TRand.kr(1, 10, t); // ランダムな値をトリガーから生成
f = e + 1 * 4;
Blip.ar(f*100, f, e) // 生成された値でBlipを合成
}.play
)

p.free;  // 演奏の終了

// 変数を使用することで、すぐに全体の挙動を変更できる。たとえば、r = Line.kr(1, 20, 60); を r = LFTri.kr(1/10) * 3 + 7; に変更するだけで演奏タイミングが変化する。
// 周波数も、f = TRand.kr(1, 10, t); から f = e + 1 * 4; とするだけですぐに変化する。

(
{ // carrier and modulator not linked
    r = Impulse.kr(10);
    c = TRand.kr(100, 5000, r);
    m = TRand.kr(100, 5000, r);
	PMOsc.ar([c, c], m, 12)*0.3
}.play
)

(
{
    var rate = 4, carrier, modRatio; // declare variables
    // carrier = LFNoise0.kr(rate) * 500 + 700;
	carrier = dup(LFNoise0.kr(rate) * 500 + 700, 2); // stereo
    modRatio = MouseX.kr(1, 2.0);
    // modulator expressed as ratio, therefore timbre
    PMOsc.ar(carrier, carrier*modRatio, 12)*0.3
}.play
)

// 問題
// ステレオにせよ。
(
{ // carrier and modulator not linked
    r = Impulse.kr([10, 10]); // ステレオに
    c = TRand.kr(100, 5000, r);
    m = TRand.kr(100, 5000, r);
    PMOsc.ar(c, m, 12)*0.3
}.play
)

(
{
    var rate = 4, carrier, modRatio; // declare variables
    carrier = LFNoise0.kr([rate, rate]) * 500 + 700; // ステレオに
    modRatio = MouseX.kr(1, 2.0);
    // modulator expressed as ratio, therefore timbre
    PMOsc.ar(carrier, carrier*modRatio, 12)*0.3
}.play
)

// indexの範囲を、Linke.krを使って1から12まで変化するようにせよ

(
{ // carrier and modulator not linked
    r = Impulse.kr([10, 10]); // ステレオに
    c = TRand.kr(100, 5000, r);
    m = TRand.kr(100, 5000, r);
    i = Line.kr(1, 12, 60); //
    PMOsc.ar(c, m, i)*0.3
}.play
)

(
{
    var rate = 4, carrier, modRatio, index; // declare variables
    carrier = LFNoise0.kr([rate, rate]) * 500 + 700; // ステレオに
    modRatio = MouseX.kr(1, 2.0);
    index = Line.kr(1, 12, 60);
    // modulator expressed as ratio, therefore timbre
    PMOsc.ar(carrier, carrier*modRatio, index)*0.3
}.play
)

// それぞれのreceiver.messageのペアの引数を定義せよ。※これはちょっと面倒なんで省略

// 演奏スピードを、また別のLine.krを使用して、1から20まで変化するようにせよ
{Line.kr(1, 12, 60)}.plot;

(
{ // carrier and modulator not linked
    t = Line.kr(1, 20, 60);
    r = Impulse.kr([t, t]); // ステレオに
    c = TRand.kr(100, 5000, r);
    m = TRand.kr(100, 5000, r);
    // i = Line.kr(1, 12, 60); //
    i = Line.kr(6, 12, 6); //
    PMOsc.ar(c, m, i)*0.3
}.play
)

(
{
    var rate, carrier, modRatio, index; // declare variables
    rate = Line.kr(1, 20, 60);
    carrier = LFNoise0.kr([rate, rate]) * 500 + 700; // ステレオに
    modRatio = MouseX.kr(1, 2.0);
    index = Line.kr(1, 12, 60);
    // modulator expressed as ratio, therefore timbre
    PMOsc.ar(carrier, carrier*modRatio, index)*0.3
}.play
)

// 全ての引数をキーワード付きにせよ。→ これも省略…

// 1.9 Synthの定義

より明白な方法でこの処理を行うことが可能。作成したパッチをSynthDefという形式で包みこんで、名前をつけて特定する。また、この際に名前をつけるだけでなく、出力するバスをOut.arメッセージを使用して指定しなければならない。

{SinOsc.ar}.play // 自動的に一時的なSynth名を生成

// このサンプルをSynthDefを使用して書くと、
SynthDef("sine", {Out.ar(0, SinOsc.ar)}).play
// OUT.ar (bus, channelsArray)

// 右チャンネルに出力する場合は、
SynthDef("sine", {Out.ar(1, SinOsc.ar)}).play

// もしくは、下記のように変数を用いて記述も可能。
(
SynthDef("one_tone_only", {
    var out, freq = 440;
    out = SinOsc.ar(freq);
    Out.ar(0, out)
}).add
)
// これは下記の命令で再生する。
Synth("one_tone_only");

// SynthDefで定義された楽器を呼び出すには2つの方法があることに注意。
// 一つは play メッセージを使用する方法。これは {}.play で音を生成する方法に似ている。
// もう一つは add メッセージを使用してSynthDefをサーバーに追加する方法。この他に .send(s) や WiteDefFile を使用する方法などがあるが、ここでは割愛。

// この例であげた"one_tone_only"は、440Hzのサイン波しか生成できない。たとえば、このSinOscの周波数のように、SynthDefの外部から変化させたい場合は、引数(arg)を用いる。
(
SynthDef("different_tones", {
    arg freq = 440; // 引数freqを宣言し、その初期値を440にする
    var out;
    out = SinOsc.ar(freq)*0.3;
    Out.ar(0, out)
}).play
)
// Synthは、第1引数にはSynthDefで指定した名前、第2引数にはSynthDefで定義された引数(arg)を配列にして渡す。このやり方によって複数の引数を同時に渡すことができる。
// 実際に"different_tones"を使用してみる。
Synth("different_tones", ["freq", 550]);
Synth("different_tones", [\freq, 660]); // "freq" と同じ
Synth("different_tones", ["freq", 880]);

// もし引数を指定しなければ、初期値の440となる
Synth("different_tones")

// 一度の複数の"different_tones"を生成することもできる。
a = Synth("different_tones", ["freq", 64.midicps]);
b = Synth("different_tones", ["freq", 67.midicps]);
c = Synth("different_tones", ["freq", 72.midicps]);
// 上のを止めずに続けて音の高さを変える
a.set("freq", 65.midicps);
c.set("freq", 71.midicps);
a.set("freq", 64.midicps);  c.set("freq", 72.midicps);
// 上のを順番に止めてゆく
a.free;
b.free;
c.free;

// PMOscを使用したより実践的なSynthDefの例
(
// まずこのブロックを実行
SynthDef("PMCrotale", {
arg midi = 60, tone = 3, art = 1, amp = 0.8, pan = 0;
var env, out, mod, freq;

freq = midi.midicps;
env = Env.perc(0, art);
mod = 5 + (1/IRand(2, 6));

out = PMOsc.ar(freq, mod*freq,
    pmindex: EnvGen.kr(env, timeScale: art, levelScale: tone),
    mul: EnvGen.kr(env, timeScale: art, levelScale: 0.3));

out = Pan2.ar(out, pan);

out = out * EnvGen.kr(env, timeScale: 1.3*art,
    levelScale: Rand(0.1, 0.5), doneAction:2);
Out.ar(0, out); //Out.ar(bus, out);

}).add;
)

// 次に以下の行を実行
Synth("PMCrotale", ["midi", rrand(48, 72).round(1), "tone", rrand(1, 6)])

//-------------------------------------
// 1.10 バス、バッファー、ノード

// PlayBufはオーディオファイルを読み込んで再生する。サウンドファイルの場所は、SuperCollider.appからみた相対パスで指定する。

// ここで、オーディオを格納する変数にバッファー(Buffers)を使用していることに注意。バッファーはチルダ(~)を先頭につけて宣言される。宣言の際にvarが必要ないのはaからzまでの変数と同様。バッファーとして定義することで、その値はパッチのどこからでも参照できるだけでなく、他のパッチや、さらには他のウィンドウからでも参照できるようになる。

~houston = Buffer.read(s, "/Users/pooneil/Desktop/SuperCollider/sounds/a11wlk01-44_1.aiff");
~chooston = Buffer.read(s, "/Users/pooneil/Desktop/SuperCollider/sounds/a11wlk01.wav");
{PlayBuf.ar(1, ~houston)}.play;
{PlayBuf.ar(1, ~chooston)}.play;
// 一度バッファーに読みこまれたサウンドは、バッファー番号、チャンネル数、ファイルパス、フレーム数など様々な情報を取得できる。

[~houston.bufnum, ~houston.numChannels, ~houston.path, ~houston.numFrames];
[~chooston.bufnum, ~chooston.numChannels, ~chooston.path, ~chooston.numFrames];
// これらの情報を活用して、ライヒの"Come out"のように、左右のチャンネルで少しずつ位相をずらしながらループ再生するというような効果も簡単に実装できる。

(  // 左右の位相をずらす
{
    var rate, trigger, frames;
    frames = ~houston.numFrames;

    rate = [1, 1.01];
    trigger = Impulse.kr(rate);
    PlayBuf.ar(1, ~houston, 1, trigger, frames * Line.kr(0, 1, 60)) *
    EnvGen.kr(Env.linen(0.01, 0.96, 0.01), trigger) * rate;
}.play;
)

// では、このようにして読みこんだ2つのサウンドを一箇所からコントロールするにはどうすれば良いのか? ひとつは、ビンテージのアナログシンセサイザーのようにソースをモジュールとして作成し、それぞれをバスで接続するという方法がある。これには、Out.ar と In.ar を用いる。それぞれの引数にバスの番号を指定すると入力と出力が接続される。

// より一般的な方法は、バスオブジェクトを使用する方法だ。
(
// まだコントロールの使用が開始されていないので、0のままで静止している
~kbus1 = Bus.control; // コントロールバス
~kbus2 = Bus.control; // コントロールバス
{
    var speed, direction;
    speed = In.kr(~kbus1, 1) * 0.2 + 1;
    direction = In.kr(~kbus2);
    PlayBuf.ar(1, ~chooston, (speed * direction), loop: 1);
}.play;
)

// コントロールの開始
(
{Out.kr(~kbus1, LFNoise0.kr(12))}.play;
{Out.kr(~kbus2, LFClipNoise.kr(1/4))}.play;
)

// 二番目のバッファーを、同じコントロールバスを利用して開始
// ただし、右チャンネルに出力
(
{
    var speed, direction;
    speed = In.kr(~kbus1, 1) * 0.2 + 1;
    direction = In.kr(~kbus2);
    Out.ar(1, PlayBuf.ar(1, ~houston, (speed * direction), loop: 1));
}.play;
)
このように、コントロールバスを用いることでインデックス番号などを気にせずにダイレクトにアサインすることができる。コードの再利用性も高まる。

