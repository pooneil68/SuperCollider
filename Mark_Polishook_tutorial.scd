
{ SinOsc.ar(200, 0, 0.5) }.play;

// modulate freq
{ SinOsc.ar(XLine.kr(2000, 200), 0, 0.5) }.freqscope;

// modulate freq
{ SinOsc.ar(SinOsc.ar(XLine.kr(1, 1000, 9), 0, 200, 800), 0, 0.25) }.play;

// modulate phase
{ SinOsc.ar(800, SinOsc.ar(XLine.kr(1, 1000, 9), 0, 2pi), 0.25) }.play;

//-------------------------
(
SynthDef("anExample", {
    Out.ar(
        0,
        SinOsc.ar(
            [440, 443] + SinOsc.kr([7, 8], 0, 7),
			// コントロール・レートはCPUサイクルをセーブする
            0,
            0.2
        )
    )
}).add;
)

Synth("anExample")

//-------------------------
// バスにオーディオを乗せる
// デフォルトでは、SuperColliderはオーディオに対して128のバスを持ちます。バスは配列の中の要素として存在します。

// オーディオ・バス（チャンネル）の配列 [ channel0, channel1, channel2, channel3, channel4, ... , ..., ..., etc., ... channel127 ]
//オーディオ・バスにデータを乗せるには、オーディオ・レートで動作するOutというugenを使います。
(
SynthDef("dataForABus", {
    Out.ar(
        0,        // 1チャンネル分のオーディオをバス0に書き込む
        Saw.ar(100, 0.1)
    )
}).add;
)

Synth("dataForABus");
// SynthDefブラウザーが示す様に、
(
// 評価してみて下さい
SynthDescLib.global.read;
SynthDescLib.global.browse;
)
// この例は（1チャンネル分の）オーディオ出力をチャンネル0に乗せます。

// バスからオーディオを取得する
// オーディオ・バスからデータを取得するには、.arメッセージをInというugenに送ります。
(
SynthDef("dataFromABus", {
    Out.ar(
        0,
        [    //　左チャンネルはオーディオ・バスから入力を得る
            In.ar(0, 1),
            SinOsc.ar(440, 0.2),
        ]
    )
}).add;
)

(
Synth("dataForABus");    // チャンネル0にノコギリ波をシンセサイズする
Synth("dataFromABus");    // それをチャンネル1のサイン波で変調する
)

// ▼06 - Table of contents ▼
// SynthDefのプロパティに関する議論を続けるために、次を評価してみて下さい。
(
SynthDescLib.global.read;
SynthDescLib.global.browse;
)
// そして、それぞれのシンセのためのコントロールをリストと表示するボックスに注目して下さい。
// コントロールは（大抵は）アーギュメントである
// シンセが生成される時や、動作中に情報を与えたいと思う時には、SynthDefにコントロールをセットします。このための最も一般的な方法は、1つ、またはそれ以上のアーギュメントをSynthDefに含めるということです。
// 次の例では、それぞれのアーギュメントはデフォルト値を持ちます。そのような場合には、もし必要なところにアーギュメントを与えるのを忘れたとしても、SynthDefが自動的に供給します。加えて、シンセが生成される時に必要となるものを示すアーギュメントに対するデフォルト値は、コードがより読みやすくします。
(
// デフォルト値を持つ2つのアーギュメント
SynthDef("withControls", { arg freq = 440, mul = 0.22;
    Out.ar(
        0,
        SinOsc.ar([freq, freq+1], 0, mul)
    )
}).add;
)

Synth("withControls", [\freq, 440, \mul, 0.1]);
// 配列の中のアイテムはSynthDefのコントロールに渡される値です。

// 配列の中にそれぞれのコントロールを書く場合には、次の様にシンボル（バックスラッシュの後に名前が続く）を用いることもできますし、
Synth("withControls", [\freq, 440, \mul, 0.1]);
// または、次の様に文字列（引用符の中に名前）を用いることもでき、
Synth("withControls", ["freq", 440, "mul", 0.1]);
// その後に値が続きます。

// いずれの場合でも、そのパターンは、[ controlName, value, controlName, value].です。

// シンセにコントロールを渡す第３の方法もあります。前の例のシンセは次の様に書くこともできます。
Synth("withControls", [0, 440, 1, 0.1]);
// このパターンは次の様になります。
// [ controlIndex, value, controlIndex, value].
// この手法のディスアドバンテージは、コントロールをインデックス番号として表現するのは説明的ではなく、それゆえに名前をシンボルまたは文字列として与えるよりも読みにくくなるでしょう。

// コントロールはリセットすることもできる
// 次の例は、シンセが生成された後に（動作中に）どのようにしてコントロールをリセットすることができるのかということを示しています。
(
SynthDef("resetMyControls", { arg freq = 440, mul = 0.22;
    Out.ar(
        0,
        SinOsc.ar([freq, freq+1], 0, mul)
    )
}).add;
)

~aSynth = Synth("resetMyControls", [\freq, 440, \mul, 0.06]);
~aSynth.set(\freq, 600, \mul, 0.25);
~aSynth.set(\freq, 800, \mul, 0.10);
~aSynth.set(\freq, 700, \mul, 0.10);
// aSynthの前の~はグローバル変数を定義します。このようにすることの主なアドバンテージは、次の様に明示的に宣言する必要がないということです。
var aSynth; // '~'のない変数はまず宣言しなければならない！！
// もっと正確に言えば、~という文字は「aSynth」という変数をcurrentEnvironmentという名前で知られるオブジェクトのインスタンスの中に配置します。詳しくは、SuperColliderのヘルプ・システムでEnvironmentというドキュメントを参照して下さい。

// SynthDefはコントロールのそれぞれにラグ・タイムを定義することができます。ugenGraphFuncの後に配列として書くラグは、あるコントロール値から他のコントロール値にスムーズに変化する時間を指定します。
(
SynthDef("controlsWithLags", { arg freq = 440, mul = 0.22;
    Out.ar(
        0,
        SinOsc.ar([freq, freq+1], 0, mul)
    )
}, [1, 1]).add;
)

~aSynth = Synth("controlsWithLags", [\freq, 550, \mul, 0.1]);
~aSynth.set(\freq, 600, \mul, 0.5);

// SynthDefの中にラグタイムの配列を含めるというオプションがあるということは、前に議論したSynthDefのテンプレートは再定義されなければならないということを意味します。
// 前のSynthDefのためのテンプレート。ラグタイムの配列なし。
SynthDef(
    "i am a synthdef",            // 第１アーギュメントは名前
    { .... i am a ugenGraphFunc ... }    // 第２アーギュメントはugenGraphFunc
)

// ラグタイムの配列付きで再定義したSynthDefのためのテンプレート
// ラグタイムの配列のためのクラス定義は'rates'と呼ぶ
SynthDef(
	"i am a synthdef",            // 名前
	{ .... i am a ugenGraphFunc ... },    // ugenGraphFunc
	[ ... lagTimes ... ]            // rates
	)
// どちらのテンプレートを用いるかという選択はユーザー次第です。もし、SynthDefにラグタイムを含める必要があるのであれば、第２のテンプレート、すなわち、レートの配列を含むもの、を使います。

// HomeBrowseSearchIndexes ▼07 - Table of contents ▼
// しかしながら、.scopeメッセージはインターナル・サーバーに対してしか機能しません。つまり、これを使うためにはインターナル・サーバーがオンになっていなければならないということです。これを手動でやるためには、インターナル・サーバーのbootボタンを押すか、コードとして次の様に実行します。
s
Server.internal.boot;
// この例を実行してスコープ・ウィンドウに注目して下さい。
(
{
    SinOsc.ar([440.067, 441.013], 0, 1)
    *
    SinOsc.ar([111, 109], 0, 0.2)
}.scope;
)
// これは同じシンセシスのプロセスをSnythDefとして表現したものです。以下に示す様に、上の例で関数の中に書かれているコードが、単にそのままOutの第２アーギュメントになっているということに注目して下さい。
(
SynthDef("ringMod", {
    Out.ar(
        0,
        SinOsc.ar([440.067, 441.013], 0, 1) * SinOsc.ar([111, 109], 0, 0.2)
    )
}).add;
)

Synth("ringMod")

// HomeBrowseSearchIndexes ▼08 - Table of contents ▼
// 最も簡単なシンセシスのプロセスはただ1つのUGenを実行するものです。例えば、
{ Saw.ar(500, 0.1) }.scope;
{ Formlet.ar(Saw.ar(22), 400, 0.01, 0.11, 0.022) }.scope

// マルチ・チャンネルへの拡張
// 任意のアーギュメント（コントロール）スロットに配列を与えることで、1つのUGenを2チャンネルに拡張できます。
{ Saw.ar([500, 933], 0.1) }.scope;
// 同じことを他の（長い）書き方で書くと次の様になります。
{ [ Saw.ar(500, 0.1), Saw.ar(933, 0.1)] }.scope;

// UnaryOpUGenの探求
// UGenにメッセージを送ることで、多くのシンセシス・プロセスを生成することができます。
{ SinOsc.ar(500, 0, 0.5) }.scope;
{ SinOsc.ar(500, 0, 0.5).distort }.scope;
// .distortメッセージ（UGenに送られたメッセージ）は単項演算です。.distortメッセージがSinOsc UGenの出力を変調しているのが聞こえるでしょう。これによってより多くのパーシャルが生まれます。

// 質問：.distortメッセージはどこから来ているのでしょうか？
// 答え：それはAbstractFunctionの中で定義されています。UGenクラスはAbstractFunctionのサブクラスです。原理的には、AbstractFunctionの中で定義されている全てのメソッドがUGenに適用できるはずです。
{ SinOsc.ar(500, 0, 0.5) }.scope;
// .cubedは単項演算の一つ
{ SinOsc.ar(500, 0, 0.5).cubed }.scope;

//----------------------------------------
// HomeBrowseSearchIndexes ▼09 - Table of contents ▼

// 2項演算
// ミキシング＝加算
// 2つ、またはそれ以上のUGenをミックスするには加算します。
(
    // 2つのノコギリ波をミックスする
    {
        Saw.ar(500, 0.05)    // オブジェクト
	+            // オペレータ
        Saw.ar(600, 0.06)    // オペランド
    }.scope;
)
// 加算の結果は1つのBinaryOpUGenになります。

// 次の例は、3つのUGenが加算を通して合体することによって何が起きるのかを示します。最初に、2つのUGenが1つのBinarOpUGenに合体します。その結果に加算演算子ともう1つのUGen（オペランド）が続き、もう1つのBinaryOpUGenを生成します。
(
{
    // 最初の2つのUGenは1つのBinaryOpUGenに合体する
    Saw.ar(500, 0.05)
    +
    Saw.ar(600, 0.06)
    +
    // このUGenはBinaryOpUGenに対するオペランドと‘+’オペレータ
    Saw.ar(700, 0.07)
}.scope;
)

// MixというUGenを用いることで前の例と同じ結果になります。
(
{
    // ミックスしたいUGenを配列の中に入れる
    Mix.ar(
        [
            Saw.ar(500, 0.05),
            Saw.ar(600, 0.06),
            Saw.ar(700, 0.06)
        ]
    )
}.scope
)

// もしくは、Mix.arFillを使って似た様な結果を生成することもできます。この関数が実行される時には毎回、アーギュメントiはインクリメントされます。つまり、1回目に関数が実行される時にはiは0に等しく、2回目には1、3回目には２、という様になります。
{ Mix.arFill(3, { arg i; Saw.ar(500 + ((i+1) * 100), 0.05) }) }.scope;

// スケーリング＝掛算
// 低い周波数のオシレータを用いる次の例は、WhiteNoiseジェネレータに対してエンベロープを適用します。これは、1つのUGenを他のUGenと掛算することにより、双方をスケーリングするということをデモするものです。
{ WhiteNoise.ar(0.1) * SinOsc.kr(1, 1) }.scope;
// 次の例は、2つのノイズを生成するUgenがサイン波でスケーリングされてBinaryOpUGenを生成し、それがまた別のBinaryOpUGenに加算されるというものです。
(
    // ... 汽車のまね？
    {
        (WhiteNoise.ar(0.1) * SinOsc.kr(1, 1))
        +
        (BrownNoise.ar(0.1) * SinOsc.kr(2, 1))
    }.scope;
)

//エンベロープ
// UGenの任意のアスペクト、例えば、周波数、位相、振幅といったものをダイナミックに変調するにはエンベロープを使います。
// 振幅を変調する
{ SinOsc.ar(440, 0, 0.1) * EnvGen.kr(Env.sine(1), doneAction: 2) }.scope;

// EnvGenのtimeScaleアーギュメント（コントロール）は、エンベロープの継続時間を変調します。
(
SynthDef("timeScale", { arg ts = 1;
    Out.ar(
		0,
        SinOsc.ar(440, 0, 0.4)
		*
		EnvGen.kr(Env.sine(1), doneAction: 2, timeScale: ts)
		)
	}
).add;
)

Synth("timeScale");
Synth("timeScale", [\ts, 0.1]); // timeScaleコントロールはエンベロープの継続時間

//  ... エンベロープの時間をシンセが作られるたびに毎回違ったものにスケーリングする
0.01.rrand(0.3)

(
r = Routine({
    loop({
        Synth("timeScale", [\ts, 0.01.rrand(0.3)]);
        0.5.wait;
    })
});
)
r.play

// 加算合成
// 加算合成とはその名が示す通りのものです。コンポーネントはお互いに加えられ（または合計され）ます。
67.0.rrand(2000)
12.reciprocal * 0.75

(
{    // 関数を12回実行する
    var n = 12;
    Mix.arFill(
        n,
        {
            SinOsc.ar(
                [67.0.rrand(2000), 67.0.rrand(2000)],
                0,
                n.reciprocal * 0.75
            )
        }
    )
    *
    EnvGen.kr(Env.perc(11, 6), doneAction: 2)
}.scope
)

// それぞれのコンポーネントにエンベロープを与える
// 前の例のそれぞれのコンポーネントに別々のエンベロープを与えることによって、より微妙なテクスチャーを生成することができます。
(
{
	var n = 12;
    Mix.arFill(
		n,     // n個のサイン波を生成する
		{
			SinOsc.ar( // それぞれがlow.rrand(high)の範囲内で起こりうる周波数
				[67.0.rrand(2000), 67.0.rrand(2000)],    // ... 実数の値
				0,
                n.reciprocal  // それぞれのサイン波の振幅をスケーリングする
                              // nの値に従って
				)
			*
			EnvGen.kr(  // サイン波のそれぞれにエンベロープを与える
				Env.sine(2.0.rrand(17)),
				doneAction: 0    // サウンド全体が完了した時にだけ
                                 // エンベロープを解放する（なぜ？）
				)
			}
		)
	*    // パッチ全体に対してエンベロープを与える
	EnvGen.kr(
        Env.perc(11, 6),
        doneAction: 2,
        levelScale: 0.75
		)
	}.scope
)

// （もしくはKlang ugenを用いることで同じ様な結果が得られます）

// リング変調
// 2つのUGenを掛算することでリング変調を生成します。
{ SinOsc.ar(440, 0, 0.571) }.scope
{ SinOsc.kr(2.reciprocal) }.scope

// キャリアの振幅を低周波オシレータ（LFO）で変調
{ SinOsc.ar(440, 0, 0.571) * SinOsc.kr(2.reciprocal) }.scope

// LFOの周波数を可聴帯域にすることで追加の周波数成分を生成する
{ SinOsc.kr(880) }.scope
{ SinOsc.ar(440, 0, 0.571) * SinOsc.kr(880) }.scope

// 低周波のオシレータ（lfo）でモジュレータの振幅を変調する
(
    {
        SinOsc.ar(440, 0, 0.571)
        *
        (SinOsc.kr(880)   // モジュレータとlfoを括弧の中に包み込む
        *                 // なぜ？
        SinOsc.kr([6.99, 8.01].reciprocal)
        )
    }.scope
)

// 振幅変調 AM
// モジュレーター、もし低周波のオシレータである場合には、その出力が正の値に制限されているか正の値に制限されていないかの違いは、変調の振幅のみに表れます。UGenを正の値のみに制限するために.absメッセージを使っています。
// 低周波のオシレータ（lfo）でキャリアの振幅を変調する
SinOsc.kr(2.reciprocal).abs

{ SinOsc.ar(440, 0, 0.571) * SinOsc.kr(2.reciprocal).abs }.scope

// lfoを用いてモジュレータの振幅を変調する
(
    {
        SinOsc.ar(440, 0, 0.571)
        *
        (SinOsc.kr(880).abs   // モジュレータとlfoを括弧の中に包み込む
        *                     // なぜ？
        SinOsc.kr([6.99, 8.01].reciprocal)
        )
    }.scope
)

// モジュレータの出力を正の値に制限して低周波のオシレータの周波数を上げることにより、（サイドバンドを生成することによって）著しく音色が変化させます。
// lfoの周波数を可聴帯域にして.absメッセージをモジュレータに適用する
{ SinOsc.ar(440, 0, 0.571) * SinOsc.kr(880).abs }.scope

// 前の例をリング変調（.absメッセージの無いもの）と比較せよ
// ... 何が違うだろう？
{ SinOsc.ar(440, 0, 0.571) * SinOsc.kr(880) }.scope

//------------------------------------
// HomeBrowseSearchIndexes ▼10 - Table of contents ▼

// LPF（ローパス・フィルター）を使って入力ソースから高い周波数成分を減算します。
(
SynthDef("subtractive", {
    Out.ar(
        0,
        LPF.ar(
            Pulse.ar(440, 0.5, 0.1),    // フィルターをかけるソース
            Line.kr(8000, 660, 6)        // フィルターの周波数をLineでコントロールする
        )
    )
}).add;
)

Synth("subtractive")

(
SynthDef("subtractive0", {
    Out.ar(
        0,
        LPF.ar(
            Pulse.ar(440, 0.5, 0.1),    // フィルターをかけるソース
            Line.kr(8000, 660, 0.5)        // フィルターの周波数をLineでコントロールする
        )
    )
}).add;
)

Synth("subtractive0")
Synth("subtractive")

// RLFP（レゾナント・ローパス・フィルター）は、高い周波数成分を取り除き、フィルターの（カットオフ・ポイントの）周波数を強調するためによく使います。
(
SynthDef("passLowFreqs2", {
    Out.ar(
        0,
        RLPF.ar(
            Saw.ar([220, 221] + LFNoise0.kr(1, 100, 200), 0.2),
            [LFNoise0.kr(4, 600, 2400), LFNoise0.kr(3, 600, 2400)],
            0.1
        )
    )
}).add;
)

Synth("passLowFreqs2")

//Rezonzはとても、とても、とても強力なフィルターです。特定の周波数帯域を強調する時に使います。カットオフが非常にシャープなためにノイズをピッチに変えてしまいます。
(
SynthDef("noiseToPitch", { arg out = 0, mul = 1;
    Out.ar(
        out,
        Resonz.ar(
            WhiteNoise.ar(mul),
            LFNoise0.kr(4, 110, 660),
            [0.005, 0.005]
        )
    )
}).add;
)

(
// 左右のチャンネルをアクティブ化する
Synth("noiseToPitch", [\out, 0, \mul, 1]);
Synth("noiseToPitch", [\out, 1, \mul, 1]);
)

// HomeBrowseSearchIndexes ▼12 - Table of contents ▼
// 複数の部分からなるシンセシス
(
// ディスクからサウンド・ファイルを読み込む
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// モノのサンプル・プレーヤー ... １チャンネルのみ
SynthDef("aMonoSamplePlayer", { arg bus = 0, bufnum = 0, rateScale = 1;
    Out.ar(
        bus,
        PlayBuf.ar(
            1,
            bufnum,
            BufRateScale.kr(bufnum) * rateScale
        )
        *
        EnvGen.kr(Env.sine(BufDur.kr(bufnum)))
    )
}).add;
)

(
// SynthDefをテストする ... 動く？（はい、大丈夫。左チャンネルで再生する。）
Synth("aMonoSamplePlayer", [\bus, 0, \bufNum, b]);
)


(
// コンポーネントの再利用の非常にシンプルな例 ...
// \busアーギュメントを使用して、同じSynthDefから作られたシンセを別のチャンネルにアサインする
// この場合には、1チャンネルのサウンド・ファイルを2チャンネルで再生する
// それぞれのチャンネルの再生レートを変えることで効果を明白にする
Synth("aMonoSamplePlayer", [\bus, 0, \bufNum, b, \rateScale, 0.99]);
Synth("aMonoSamplePlayer", [\bus, 1, \bufNum, b, \rateScale, 1.01]);
)

// 実行の順序
// もう一度、次の例はどのようにしてシンセをソースとエフェクトのグループに配置するのかを示します。２つのグループは２つのシンセが適切な順序で実行されることを保証します。
(
// エンベロープなしのフィルター　ー永遠にとどまる
SynthDef("soundFileFilter", { arg bus = 0, freq = 440, rq = 0.05;
    ReplaceOut.ar(
        bus,
        BPF.ar(            // a bandpass filter
            In.ar(0, 2),
            [freq * 0.99, freq * 1.5],
            rq
        )
    )
}).add;
)

// ２つのグループを作成する。１つはソース用、他の１つはエフェクト用
(
~source = Group.head(s);
~effect = Group.tail(s);
)

// シンセをそれぞれ適切なグループの先頭に追加する
// シンセを適切なグループの最後に追加しても同じ結果になる
(
Synth.head(~effect, "soundFileFilter", [\out, 0, \freq, 500.rrand(1000), \rq, 0.04.rrand(0.1)]);
Synth.head(~source, "aMonoSamplePlayer", [\bus, 0, \bufNum, b]);
)

// サンプルをループする
// サウンド・ファイルを何度も何度も繰り返し再生するには、PlayBufのloopアーギュメント（コントロール）を使います。
// しかし、PlayBufのインスタンスのloopアーギュメントに任せてファイル全体をループする代わりに、正確な繰り返しが起きる様にスケジューリングすることで、より細かくコントロールすることもできます。

// この例は３つのSynthDefを使用しています。第1のSynthDefはサンプル・プレーヤーで、バッファ全体を永遠にループし続けます。第2のSynthDefはその入力をリング変調します。第3のSynthDefはその入力に対してローパス・フィルターを適用します。
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
// サウンド・ファイルを読み込む
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// サウンド・ファイル全体をループ再生するサンプル・プレーヤーを定義する
SynthDef("aLoopingSamplePlayer", { arg outBus = 0, bufnum = 0, rateScale = 1, mul = 1;
    Out.ar(
        outBus,
        PlayBuf.ar(
            1,
            bufnum,
            BufRateScale.kr(bufnum) * rateScale + LFNoise1.kr(2.reciprocal, 0.05),
            loop: 1    // 停止することなくサウンド・ファイルを繰り返し再生する
        )
        *
        mul
    )
}).add;

// オーディオ・ソースに振幅変調を適用する
SynthDef("ampMod", { arg inBus = 0, outBus = 0, modFreq = 1;
    Out.ar(
        outBus,
        [In.ar(inBus, 1) * SinOsc.kr(modFreq), In.ar(inBus, 1) * SinOsc.kr(modFreq - 0.02)]
    )
}).add;

// オーディオ・ソースにローパス・フィルターを適用する
SynthDef("aLowPassFilter", { arg inBus = 0, outBus = 0, freq = 300, freqDev = 50, boost = 1;
    Out.ar(
        outBus,
        RLPF.ar(
            In.ar(inBus, 2),
            Lag.kr(LFNoise0.kr(1, freqDev, freq), 1),
            0.1
        )
        *
        boost
    )
}).add;
)

// ２つのグループを定義する。１つはソースのためで、他方はエフェクトのため
(
~source = Group.head(s);
~effect = Group.tail(~s);
)

(
// ソース・グループにサンプル・プレーヤーを追加する
Synth.head(
    ~source,
    "aLoopingSamplePlayer", [\outBus, 3, \bufNum, b, \rateScale, 1, \mul, 0.051]);
// エフェクト・グループの先頭に振幅変調シンセを追加する
Synth.head(
    ~effect,
    "ampMod", [\inBus, 3, \outBus, 5, \modFreq, 1]);
// エフェクト・グループの最後にフィルタリングを追加する
Synth.tail(
    ~effect,
    "aLowPassFilter", [\inBus, 5, \outBus, 0, \boost, 5])
)

// ここでは、シンセとグループの配置は同じです。一部のアーギュメント（コントロール）を変えることでエフェクトの音色が劇的に変わります。
(
~source = Group.head(s);
~effect = Group.tail(~s);
)

(
Synth.head(
    ~source,
    "aLoopingSamplePlayer", [\outBus, 3, \bufNum, b, \rateScale, 1, \mul, 0.051]);
Synth.head(
    ~effect,
    "ampMod", [\inBus, 3, \outBus, 5, \modFreq, 1000]);
Synth.tail(
    ~effect,
    "aLowPassFilter", [\inBus, 5, \outBus, 0, \freq, 500, \freqDev, 200, \boost, 7])
)

// HomeBrowseSearchIndexes ▼13 - Table of contents ▼
// 時間ベースのフィルター
// Delay、CombそしてAlpassといったUGenは時間ベースのエフェクトを生成します。これは空間や位置の感覚を与えるリバーブなどのエフェクトを作るのに適しています。

// 2つのSynthDef。第1のSynthDefはグレインを生成し、第2のSynthDefはそれらを遅らせる
//  グレインを生成するSynthDefは左チャンネル
// グレインを遅らせるSynthDefは右チャンネル
(
SynthDef("someGrains", { arg centerFreq = 777, freqDev = 200, grainFreq = 2;
    var gate;
    gate = Impulse.kr(grainFreq);
    Out.ar(
        0,
        SinOsc.ar(
            LFNoise0.kr(4, freqDev, centerFreq),
            0,
            EnvGen.kr(Env.sine(0.1), gate, 0.1)
        )
    )
}).add;

SynthDef("aDelay", { arg delay = 0.25;
    Out.ar(
        1,
        DelayN.ar(
            In.ar(0, 1),
            delay,
            delay
        )
    )
}).add;
)

// グレインをテストして ... オフにしなさい
// 全て左チャンネルだけ ... グッド！
Synth("someGrains");


// ２つのグループを作成。第1はソース、第2はエフェクト。
(
~source = Group.head(s);
~effects = Group.tail(s);
)

// グレインをディレイに配置する ... ソースは左でディレイをかけられたソースは右
(
Synth.head(~source, "someGrains");
Synth.head(~effects, "aDelay");
)

// フィードバック・フィルター
// CombやAllpassフィルターは、自分の出力を入力にフィードバックするUGenの例です。Allpassフィルターは一般的にCombフィルターと比較した場合に音はあまり違って聞こえません。しかしながら、Allpassフィルターはそれを通過する信号の位相を変えます。このため、これはUGenのネットワーク中で用いる時に便利なのです。
// インターナル・サーバーを起動！！
// 最初はCombフィルターで次がAllpassフィルター（パラメータは同じ）。両者を比較せよ。
(
{
    CombN.ar(
        SinOsc.ar(500.rrand(1000), 0, 0.2) * Line.kr(1, 0, 0.1),
        0.3,
        0.25,
        6
    )
}.scope;
)

// 前の例とそんなに大きな違いは無い
(
{
    AllpassN.ar(
        SinOsc.ar(500.rrand(1000), 0, 0.2) * Line.kr(1, 0, 0.1),
        0.3,
        0.25,
        6
    )
}.scope;
)

// 最初はCombフィルターで次がAllpassフィルター（パラメータは同じ）。両者を比較せよ。
// ２つの例はもっと短いディレイ・タイムを持つ ... 0.1秒
(
{
    CombN.ar(
        SinOsc.ar(500.rrand(1000), 0, 0.2) * Line.kr(1, 0, 0.1),
        0.1,
        0.025,
        6
    )
}.scope;
)

// ディレイ・タイムを短くすると、allpassフィルターはcombフィルターよりより広がって聞こえるようになる
(
{
    AllpassN.ar(
        SinOsc.ar(500.rrand(1000), 0, 0.2) * Line.kr(1, 0, 0.1),
        0.1,
        0.025,
        6
    )
}.scope
)

// リバーブレーション
// 次の例は、James McCartneyによるもので、.playではなく.scopeを使っているということと、変数が関数の中で宣言されているという変更を加えています。この例はSuperCollider 2の配布物の中の一部分のドキュメントであった01 Why SuperColliderからのものです。
// これは事実上Schroederのリバーブの実装で、信号はCombフィルターの並列バンクを通過し、連続したいくつかのAllpassフィルターを通るというものです。
(
{
var s, z, y;
    // ランダムな10ボイス分のサイン波のパーカッション・サウンド：
s = Mix.ar(Array.fill(10, { Resonz.ar(Dust.ar(0.2, 50), 200 + 3000.0.rand, 0.003)}) );
    // リバーブのプリ・ディレイ・タイム：
z = DelayN.ar(s, 0.048);
    // 並列に7つの長さを変調されたcombによるディレイ：
y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
    // 4つのallpassによるディレイの２つの並列したチェーン（合計8個）：
4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
    // オリジナルのサウンドをリバーブに加えてそれを再生：
s+(0.2*y)
}.scope
)

// コンポーネント
(
SynthDef("filteredDust", {
    Out.ar(
        2,
        Mix.arFill(10, { Resonz.ar(Dust.ar(0.2, 50), Rand(200, 3200), 0.003) })
    )
}).add;

SynthDef("preDelay", {
    Out.ar(
        4,
        DelayN.ar(In.ar(2, 1), 0.048, 0.048)
    )
}).add;

SynthDef("combs", {
    Out.ar(
        6,
        Mix.arFill(7, { CombL.ar(In.ar(4, 1), 0.1, LFNoise1.kr(Rand(0, 0.1), 0.04, 0.05), 15) })
    )
}).add;

SynthDef("allpass", { arg gain = 0.2;
    var source;
    source = In.ar(6, 1);
    4.do({ source = AllpassN.ar(source, 0.050, [Rand(0, 0.05), Rand(0, 0.05)], 1) });
    Out.ar(
        8,
        source * gain
    )
}).add;

SynthDef("theMixer", { arg gain = 1;
    Out.ar(
        0,
        Mix.ar([In.ar(2, 1), In.ar(8, 2)]) * gain
    )
}).add;
)

// それぞれの行が実行されると、それぞれは最後のノードになる。結果は、"filteredDust"が最初のノードになり、
// "theMixer"が最後のノードになる。これは我々が望んだ通りである。
(
Synth.tail(s, "filteredDust");
Synth.tail(s, "preDelay");
Synth.tail(s, "combs");
Synth.tail(s, "allpass");
Synth.tail(s, "theMixer");
)

// または、グループを使って前の例のシンセの実行の順序をコントロールします。
(
~source = Group.tail(s);
~proc1 = Group.tail(s);
~proc2 = Group.tail(s);
~proc3 = Group.tail(s);
~final = Group.tail(s);
)

// 以下のノードは、上で並べた通りに、グループにアサインされる
// それゆえ、これらは正しい順序で実行される
(
Synth.head(~final, "theMixer");
Synth.head(~proc3, "allpass");
Synth.head(~proc2, "combs");
Synth.head(~proc1, "preDelay");
Synth.head(~source, "filteredDust");
)
// 上に示した様に正しい順序にグループを配置することはそれにアサインされるシンセもまた正しい順序になるということを保証します。

//--------------------------------------
// HomeBrowseSearchIndexes ▼14 - Table of contents ▼
// キャリアとモジュレータ
(
SynthDef("fm1", { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, mul = 0.05;

    // インデックスの値は通常は0から24まで
    // carPartial :: modPartial => car/mod ratio

    var mod;
    var car;

    mod = SinOsc.ar(
        freq * modPartial,
        0,
        freq * index * LFNoise1.kr(5.reciprocal).abs
    );

    car = SinOsc.ar(
        (freq * carPartial) + mod,
        0,
        mul
    );

    Out.ar(
        bus,
        car
    )
}).add;
)

(
Synth("fm1", [\bus, 0, \freq, 440, \carPartial, 1, \modPartial, 2.4]);
Synth("fm1", [\bus, 1, \freq, 442, \carPartial, 1, \modPartial, 2.401]);
)

// 周波数変調とリバーブ
// これは（SC2の配布物の中の）"01 Why SuperCollider document"からのリバーブ
(
SynthDef("preDelay", { arg inbus = 2;
    Out.ar(
        4,
        DelayN.ar(In.ar(inbus, 1), 0.048, 0.048)
    )
}).add;

SynthDef("combs", {
    Out.ar(
        6,
        Mix.arFill(7, { CombL.ar(In.ar(4, 1), 0.1, LFNoise1.kr(Rand(0, 0.1), 0.04, 0.05), 15) })
    )
}).add;

SynthDef("allpass", { arg gain = 0.2;
    var source;
    source = In.ar(6, 1);
    4.do({ source = AllpassN.ar(source, 0.050, [Rand(0, 0.05), Rand(0, 0.05)], 1) });
    Out.ar(
        8,
        source * gain
    )
}).add;

SynthDef("theMixer", { arg gain = 1;
    Out.ar(
        0,
        Mix.ar([In.ar(2, 1), In.ar(8, 2)]) * gain
    )
}).add;
)

(
Synth("fm1", [\bus, 2, \freq, 440, \carPartial, 1, \modPartial, 1.99, \mul, 0.071]);
Synth("fm1", [\bus, 2, \freq, 442, \carPartial, 1, \modPartial, 2.401, \mul, 0.071]);
Synth.tail(s, "preDelay");
Synth.tail(s, "combs");
Synth.tail(s, "allpass");
Synth.tail(s, "theMixer", [\gain, 0.64]);
)

// コンポーネント
// "fm"のSynthDefを、1つのSynthDefはモジュレータ、1つのSynthDefはキャリアという2つの部分に分割することでより機能性 が高まる。キャリアのシグナルを2つまたはそれ以上のモジュレータで加工することができる。
(
SynthDef("carrier", { arg inbus = 2, outbus = 0, freq = 440, carPartial = 1, index = 3, mul = 0.2;

    // インデックスの値は通常は0から24まで
    // carPartial :: modPartial => car/mod ratio

    var mod;
    var car;

    mod = In.ar(inbus, 1);

    Out.ar(
        outbus,
        SinOsc.ar((freq * carPartial) + mod, 0, mul);
    )
}).add;

SynthDef("modulator", { arg outbus = 2, freq, modPartial = 1, index = 3;
    Out.ar(
        outbus,
        SinOsc.ar(freq * modPartial, 0, freq)
        *
        LFNoise1.kr(Rand(3, 6).reciprocal).abs
        *
        index
    )
}).add;
)

(
var freq = 440;
// 左チャンネルのためのモジュレータ
Synth.head(s, "modulator", [\outbus, 2, \freq, freq, \modPartial, 0.649, \index, 2]);
Synth.head(s, "modulator", [\outbus, 2, \freq, freq, \modPartial, 1.683, \index, 2.31]);

// 右チャンネルのためのモジュレータ
Synth.head(s, "modulator", [\outbus, 4, \freq, freq, \modPartial, 0.729, \index, 1.43]);
Synth.head(s, "modulator", [\outbus, 4, \freq, freq, \modPartial, 2.19, \index, 1.76]);

// 左と右のチャンネルのためのキャリア
Synth.tail(s, "carrier", [\inbus, 2, \outbus, 0, \freq, freq, \carPartial, 1]);
Synth.tail(s, "carrier", [\inbus, 4, \outbus, 1, \freq, freq, \carPartial, 0.97]);
)

//コンポーネントとリバーブ
// この例は前に定義されたリバーブと２つのシンセ定義（モジュレータが１つのSynthDefで他方はキャリア）で説明したモデルを組み合わせています。
(
var freq;
// キャリアとモジュレータのためのランダムな基本周波数を生成する
freq = 330.0.rrand(500);

// 左チャンネルのためのモジュレータ
Synth.head(s, "modulator", [\outbus, 60, \freq, freq, \modPartial, 0.649, \index, 2]);
Synth.head(s, "modulator", [\outbus, 60, \freq, freq, \modPartial, 1.683, \index, 2.31]);

// 右チャンネルのためのモジュレータ
Synth.head(s, "modulator", [\outbus, 62, \freq, freq, \modPartial, 1.11, \index, 1.43]);
Synth.head(s, "modulator", [\outbus, 62, \freq, freq, \modPartial, 0.729, \index, 1.76]);

// 左と右のチャンネルのためのキャリア
Synth.tail(s, "carrier", [\inbus, 60, \outbus, 100, \freq, freq, \carPartial, 1]);
Synth.tail(s, "carrier", [\inbus, 62, \outbus, 100, \freq, freq+1, \carPartial, 2.91]);

Synth.tail(s, "preDelay", [\inbus, 100]);
Synth.tail(s, "combs");
Synth.tail(s, "allpass");
Synth.tail(s, "theMixer", [\gain, 0.2]);
)

//--------------------------------------
// HomeBrowseSearchIndexes ▼15 - Table of contents ▼
// ルーチンとクロック

// 関数を実行するには.valueメッセージを送る
f = { "hello, world" };
f.value;
// これはルーチンの中に関数を配置したものです。.yieldメッセージを送ることで関数の中の式を評価します。
r = Routine({ "hello, world".yield.postln });

// ルーチンを実行するには、評価して下さい。
// ルーチンを評価するには、.nextメッセージを送る
r.next;
// もう一度やってみましょう。
r.next;
// これは一度ルーチンが"yield"（受け渡し）すると、関数の中にさらなるコードがあるか、resetメッセージを受け取らない限り、終了することを示します。
r.reset;
r.next;

// この引用では、ルーチンに.nextメッセージが送られると、３つの表現（文字列）を順番に引き渡すことを引き起こします。例えば、nextメッセージが送られると、文字列が引き渡され、nextメッセージが送られると、文字列が引き渡さるという様にです。
(
r = Routine({
    "hello, world".yield;
    "what a world".yield;
    "i am a world".yield;
});
)
上の例での最後の.nextメッセージはnilを返すでしょう。最後の表現が引き渡されると、ルーチンはリセットされるまで常にnilを返します。
r.next;
r.next;
r.next;
r.next;
r.reset;
r.next;

// このルーチンを.doメッセージを使って書き直すと、loopを作ります。
(
r = Routine({

    var array;
    array = [ "hello, world", "what a world", "i am a world" ];

    3.do({ array.choose.yield })

});
)

// このdo loopをルーチンの中のループよりももう1回多く実行すると、前の例と同じ様に、３つの文字列とnilを返します。
4.do({ r.next.postln });

// 次に、このルーチンを.waitメッセージを含む形で書き直します。.waitメッセージは、その数字が示す秒単位で指定した時間だけ、ルーチンを「プレイ」するクロックを一時停止させます。
(
r = Routine({

    var array;
    array = [ "hello, world", "what a world", "i am a world" ];

    3.do({ 1.wait; array.choose.postln })

});
)

// 以下のコードが示す様に、ルーチンに.resetメッセージを追加します。このようにして、ルーチンは常に再スタートできる様になります。そして、クロックとともにルーチンをプレイします。
// 以下のコードはSuperColliderがイベントをスケジューリングする時に使用する３つのクロックを示します。
SystemClock.play(r.reset);        // 最も正確
AppClock.play(r.reset);            // GUIで使用する
TempoClock.new.play(r.reset);    // 主に拍でスケジューリングするために使われる

// または、そのプロセスを省略することができ、その場合にはデフォルトとしてTempoClockが使用されます。
r.reset.play;

// ルーチンを用いたシンセシスのスケジューリング
// ルーチンの中にシンセを入れます。シンセの中のSynthDefが必ずエンベロープを持つ様にし、そのエンベロープのdoneActionパラメータを２にセットします。これによって、エンベロープが終了した後に、そのシンセのために必要とされていたメモリが解放されます。
(
SynthDef("fm2", {
    arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, mul = 0.2, ts = 1;

    // インデックスの値は通常0から24まで
    // carPartial :: modPartial => car/mod ratio

    var mod;
    var car;

    mod = SinOsc.ar(
        freq * modPartial,
        0,
        freq * index * LFNoise1.kr(5.reciprocal).abs
    );

    car = SinOsc.ar(
        (freq * carPartial) + mod,
        0,
        mul
    );

    Out.ar(
        bus,
        car * EnvGen.kr(Env.sine(1), doneAction: 2, timeScale: ts)
    )
}).add;
)

(
r = Routine({

    12.do({
        Synth("fm2", [\freq, 400.0.rrand(1200), \carPartial, 0.5.rrand(2), \ts, 0.1.rrand(4)]);
        2.wait;
    })
});
)
r.reset.play;

// ルーチンの中で引き起こされたシンセを、ルーチンの外側で実行するエコー・エフェクト・ユニットを通してプレイします。
(
SynthDef("echoplex", {
    ReplaceOut.ar(
        0,
        CombN.ar(
            In.ar(0, 1),
            0.35,
            [Rand(0.05, 0.3), Rand(0.05, 0.3)],
            // シンセが生成されるたびにランダムな値を生成する
            7,
            0.5
        )
    )
}).add;

// ~sourceグループをルートノードの先頭に追加し、~effectsグループをる−とノードの最後に追加する
~source = Group.head(s);
~effect = Group.tail(s);

r = Routine({

    // ループはinf.doと同じ。例えば、永遠に実行される無限ループを生成する。
    loop({
        Synth.head(    // ~sourceグループの先頭にシンセを追加する
            ~source,
            "fm2",
            [
                \outbus, 0, \freq, 400.0.rrand(1200), \modPartial, 0.3.rrand(2.0),
                \carPartial, 0.5.rrand(11), \ts, 0.1.rrand(0.2)]
        );
        2.wait;
    })
});
// 2つのechoplexesーこれらを~effectsグループの先頭に順に追加する
Synth.head(~effect, "echoplex");
Synth.head(~effect, "echoplex");
)
// ルーチンをプレイする
r.reset.play;

