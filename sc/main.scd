// Make sure Leap motion daemon is started.
// Starting leap.py may be required:
// In a terminal, cd to  ../pythonLeap/ and type
// python leap.py
// python 2 is required.
// LeapMotion SDK and liblo.
// use pip to install liblo and thread.  (pip install)
// SC3 plugins required
// Required quarks:
// dewdrop_lib




"./prep/01-startPython.scd".loadRelative; // Start the python process.
"./prep/02-leapReceivers.scd".loadRelative; // Create the OSC receivers.
// ~leap[\numHands], ~leap[\lPos], ~leap[\rPos], ~leap[\lOrient], ~leap[\rOrient]
// ~leap[\lSphere], ~leap[\rOrient]

~leap.do(_.print_(false)); // Stop printing incoming OSC messages.

// ~leap.do(_.calibration); 
// ~leap.do(_.stopCalibration);

"./prep/03-grasNullateur.scd".loadRelative; // granulator core.
"./prep/04-liveRecording.scd".loadRelative; // live recording mechanism (gui).


~recBufs[0].preRec;

x = {|pos=0,rate=1,freq=20|GrainBuf.ar(1, Impulse.ar(freq), 0.4, ~recBufs[0].buf,rate, pos )}.play;
x.set(\pos, (~recBufs[0].onsets[0]- 10000)/~recBufs[0].frames, \rate, 1);
x.set(\pos, (~recBufs[0].onsets[1] - 10000)/~recBufs[0].frames , \rate, 1);
x.set(\pos, 0, \rate, 1);











////////////////////////////////////////////////////////////////////////////////////////////////
// Move the mouse to vary the threshold
(
x = {
    var sig, chain, onsets, pips;

    // A simple generative signal
    // sig = LPF.ar(Pulse.ar(TIRand.kr(63, 75, Impulse.kr(2)).midicps), LFNoise2.kr(0.5).exprange(100, 10000)) * Saw.ar(2).range(0, 1);
    // or, uncomment this line if you want to play the buffer in
    sig = PlayBuf.ar(1, ~gr.buffers[12], BufRateScale.kr(d), loop: 1);

    chain = FFT(b, sig);

    onsets = Onsets.kr(chain, MouseX.kr(0,1), \mkl);

    // You'll hear percussive "ticks" whenever an onset is detected
    pips = WhiteNoise.ar(EnvGen.kr(Env.perc(0.001, 0.1, 0.2), onsets));
    Out.ar(0, Pan2.ar(sig, -0.75, 0.2) + Pan2.ar(pips, 0.75, 1));
}.play;
)
x.free; // Free the synth

//[0] onset trigger 
//[1] corrected to minima time of last onset
//[2] most recent slope measurement
//[3] average slope calculation 
//[4] raw detection function
//[5] raw peakpick function
 
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav")
//minimal example
(
{    
//var source = SoundIn.ar; 
var source = PlayBuf.ar(1,~gr.buffers[12],loop:1);
var slopeanalysis = AttackSlope.kr(source,peakpicksize:20,sumthreshold:40); 

//slopeanalysis.poll;

K2A.ar(slopeanalysis);

//old now [4,5,1]
//K2A.ar([slopeanalysis[0],100*slopeanalysis[1],slopeanalysis[2]])

//K2A.ar([slopeanalysis[0],100*slopeanalysis[1],slopeanalysis[2]])


}.plot(10.0,minval:0.0,maxval:1.0)
)



~gr.play;
~gr.stop;
~gr.free;
~gr.dump
~gr.envBufs.do(_.plot)
~gr.buffers[0].play;
Segmentation

x = Synth.tail(Server.default, \grasNullateur, [
	\buf, ~granulator.buffers[0]
]);

~granulator.granSynth.set(\panC, 0);
~granulator.granSynth.set(\panW, 1);
~granulator.granSynth.set(\granDur, 1);
~granulator.granSynth.set(\granFreq, 40);
~granulator.granSynth.set(\env, ~granulator.envBufs[40]);
~granulator.granSynth.set(\amp, 0.5);

x.set(\panC, 0);
x.set(\panW, 1);
x.set(\granDur, 0.1);
x.set(\granFreq, 2);
x.set(\env, ~granulator.envBufs[0]);

x.map(\env, 100);

{Out.kr( 100, MouseY.kr(741,845))}.play;


~granulator.envBufs[104]

i = 0;
r = (fork  {
loop {
	x.set(\env, ~granulator.envBufs[1]);
	1.wait;
	i.postln;
	i = i+1;
}
});
r.resume
r.stop

(
// Load sounds in buffers.

)


~envBufs.last

~envBuf1 = 
~envBuf2 = Buffer.alloc(Server.default, 1024);
~envBuf2.setn(0, Env.perc(0.001).asSignal(1024) );

Env.perc(0.001).asSignal(1024).blend(Env.sine.asSignal(1024), 0.9).plot

Env.perc(0.9, 0.1).asSignal(1024).plot

u = 

Array.geom(20, 0.001, 0.001.reciprocal.pow(1/20)).collect({ |i|
	Env.perc(i, 1-i).plot;
});

Array.series(25, 0.01, 0.02).collect({ |i|
	Env([0,1,1,0], [i, 1 - (i * 2), i],'sine').plot;
});


(0.01,0.05..0.5).size

// Fill enveloppe buffers.
~envBuf1.setn(0, Env.sine.asSignal(1024) );
~envBuf2.setn(0, Env.perc(0.001).asSignal(1024) );



x = Synth.tail(s, \granulo2000, [\buf, ~buffers[0], \env1, ~envBuf1, \env2, ~envBuf2]);
x.free;
~envBuf1.plot




// ~leap.do(_.free);

(
~prIntR = PresetInterpolatorServer( InterpolatorServer(7) );
~prIntR.connect(0, ~leap[\rPos]);
~prIntR.connect(3, ~leap[\rOrient]);
~prIntR.connect(6, ~leap[\rSphere]);
// ~prIntR.disconnect(0)
~prIntR.gui
)

(
~prIntL = PresetInterpolatorServer.newLoad(("clork"++1++"*").resolveRelative.pathMatch.sort.last.resolveRelative);
// ~prIntL = PresetInterpolatorServer( InterpolatorServer(7) );
~prIntL.connect(0, ~leap[\lPos]);
~prIntL.connect(3, ~leap[\lOrient]);
~prIntL.connect(6, ~leap[\lSphere]);
// ~prIntL.disconnect(0)
~prIntL.gui
)


~leapReceivers
SynthDef(\pulse, {
	|freq=220, db = -40, width=0.5, ffreq=4000, rq=0.5|
	Out.ar(
		0,
		BMoog.ar(
			Pulse.ar([freq,freq*1.001], width, db.dbamp),
			ffreq,
			rq
		)
	);
}).add;

x = Synth.tail(s, \pulse);
x.free;
x.map(
	* ([[\freq, \db, \width, \ffreq, \rq ]] ++
	[~prIntL.cursor.parameters.collect(_.bus)]).flop.flatten;
);

x.map( \freq, ~prIntL.cursor.parameters[0].bus,
	\db, ~prIntL.cursor.parameters[1].bus,
	\width, ~prIntL.cursor.parameters[2].bus,
	\ffreq, ~prIntL.cursor.parameters[3].bus
);

x.map(\freq,  ~prIntL.cursor.parameters[0].bus);

~prIntL.cursor.parameters[0].bus.get;
~prIntL.cursor.parameters[0].value


~prIntL.newSave(Date.getDate.format("clork"++1++"_%Y-%m-%d_%H-%M-%S.pri").resolveRelative);
s.plotTree



~buffers[13].play

(
~scaleSynths = ~map.collect({|value, name|
	// Un nouveau bus pour chacun des paramètres.
	~ctlBuses.put( name, Bus.control() );
	// Un synth pour chacun des paramètres
	Synth.head(
		Server.default,
		name,
		// Le synth met des valeurs sur le nouveau bus.
		[ \out, ~ctlBuses[name] ]
		// value[0] contient le nom du bus (qui est le même que le nom du
		// message OSC) qui va affecter ce paramètre.
	).map(\in, ~ctlBuses[value[0]]);
});
)

(
// Toucher la tablette démarre un granulotron.
OSCdef(
	\touch,
	{|msg|
		msg[1].asInteger.switch(
			1,
			{
				~granulotron.isPlaying.not.if({
					~granulotron = Synth.tail(
						Server.default,
						\granulotron, [
							\bufL, ~buffers[4][0],
							\bufR, ~buffers[4][1]
						]
					);
					~granulotron.map(
						\rate, ~ctlBuses[\rate],
						\amp, ~ctlBuses[\amp],
						\centerPos, ~ctlBuses[\centerPos],
						\granFreq, ~ctlBuses[\granFreq],
						\granDur, ~ctlBuses[\granDur],
					);
					NodeWatcher.register(~granulotron, true);
				})
			},
			0, {
				~granulotron.isPlaying.if({
					~granulotron.set(\gate, 0)
				});
			}
		)
	}
);
)

// Un peu de ménage.
(
~oscDefs.do(_.free);
~ctlBuses.do(_.free);
~buffers.do({|i| i.do(_.free)});
~scaleSynths.do(_.free);
~granulotron.free;
)






x = Synth(\in_grain_test, [\envbuf, -1]);
x.free;



({
	~audioFilePath = "../samples/granulotron/*.wav".resolveRelative;
	~fileNames = List[];
	~currentBuf = 0;
	~numLiveRecBuf = 5;
	~sr = Server.default.sampleRate;
	~liveRecMaxLen = ~sr * 30.0; // seconds to samples.
	~preRecLength = ~sr * 4.0; // seconds to samples.
	~liveRecBufNumChan = 2;
	~destBuf = 0;
	// Live buffers lengths in seconds.
	~liveBuffersLengths = Array.fill(~numLiveRecBuf, { 1.0 });
	~prevBuf = { ~setBuf.value(~currentBuf - 1); };
	~nextBuf = { ~setBuf.value(~currentBuf + 1); };
	~setBuf = { |number|
		~currentBuf = number % ~numBuffers;
		"Switching to recording ".post;
		~currentBuf.postln;
		// ~allBuffers[~currentBuf][0].path.postln;
		~granulotron.isPlaying.if({
			~liveRecBufNumChan.do({|i|
				~granulotron.set(
					[\bufL, \bufR][i],
					~allBuffers[~currentBuf][i]
				);
			});
		});
		~centerPosSynth.isPlaying.if({
			"pos mul  is ".post;
			~liveBuffersLengths[~currentBuf].postln;
			~centerPosSynth.set(
				\mul,
				~liveBuffersLengths[~currentBuf]
			);
		});
	};
	
	// Copy last ~preRecLength seconds in a buffer. 
	~copyLiveRecBuf = { |liveRecBufNum=0|
		"Copying liveRecBuf to buffer ".post;
		liveRecBufNum.postln;
		~destBuf = liveRecBufNum.asInteger;
		// ~preRecLength = len * ~sr;
		~recorder[0].set(\id, 0, \t_trig, 1.0);
	};

	~startRecBuf = { |liveRecBufNum=0|
		// Really choose buffer when stopping.
		// Use this buffer if we overflow.
		~destBuf = liveRecBufNum.asInteger;
		// ~preRecLength = len * ~sr;
		~recorder[0].set(\id, 1, \t_trig, 1.0);
	};

	~stopRecBuf = { |liveRecBufNum=0|
		~destBuf = liveRecBufNum.asInteger;
		~recorder[0].set(\id, 2, \t_trig, 1.0);
	};

	~oscFunc = OSCFunc({ |msg|
		var bufPos, id;
		bufPos = msg[3];
		id = msg[2];
		~liveRecBufNumChan.do({|i|
			id.switch(
				0, { // use preRec
					~liveBuffersLengths[~destBuf] = (~preRecLength / ~sr);
					"Copying buffer ".post;
					~liveRecBuf[i].bufnum.post;
					" to buffer ".post;
					~liveBuffers[~destBuf][i].bufnum.postln;
					"Length: ".post;
					~liveBuffersLengths[~destBuf].post;
					" seconds.".postln;
					~liveRecBuf[i].copyLoopTo(
						buf: ~liveBuffers[~destBuf.asInteger][i],
						dstStartAt: 0,
						srcStartAt: (bufPos - ~preRecLength),
						numSamples: ~preRecLength
					);
				},
				1, { // Start recording buffer.
					"Recording started for buffer ".post;
					~liveBuffers[~destBuf][i].bufnum.postln;
					"LiveRecBuf position was: ".post;
					~startRecPos = bufPos;
					~startRecPos.postln;
				},
				2, { // Stop recording buffer.  (Copy LiveRecBuf to another Buffer.)
					var len;
					len = (bufPos - ~startRecPos) % ~liveRecMaxLen;
					~liveBuffersLengths[~destBuf] = len / ~sr;
					"Recorded ".post;
					~liveBuffersLengths[~destBuf].post;
					"seconds to buffer ".post;
					~liveBuffers[~destBuf][i].bufnum.postln;
					~liveRecBuf[i].copyLoopTo(
						buf: ~liveBuffers[~destBuf.asInteger][i],
						dstStartAt: 0,
						srcStartAt: ~startRecPos,
						numSamples: len
					);
				}
			);
		});
		"outside: ".post;
		~liveBuffersLengths.postln;
	}.inEnvir(BP(1)), "/tr", Server.default.addr);

	~liveRecBuf = ~liveRecBufNumChan.collect({ |chan|
		Buffer.alloc(
			Server.default, ~liveRecMaxLen, 1
		);
	});
	// ~buffers = ~audioFilePath.pathMatch.collect({ |path|
	// 	~fileNames.add(path.basename);
	// 	// On assume que ce sont des fichiers 2 canaux (pour l'instant).
	// 	[
	// 		Buffer.readChannel(Server.default, path, channels: [0]),
	// 		Buffer.readChannel(Server.default, path, channels: [1])
	// 	]
	// });
	~liveBuffers = ~numLiveRecBuf.collect({ |i|
		~liveRecBufNumChan.collect({|chan|
			Buffer.alloc(
				Server.default, ~liveRecMaxLen, 1
			);
		});
	});


	// ~allBuffers = ~liveBuffers ++ ~buffers;
	~allBuffers = ~liveBuffers;
	~numBuffers = ~allBuffers.size;

	
	~prepList = ~prepList.deepCopy.addFunc({
		{
			SynthDef(\granulotron, {
				arg out=0, gate=1, att=0.2, rel=0.01;
				var trig;
				trig = Impulse.ar(\freq.kr(110));
				Out.ar(out,
					TGrains.ar(
						numChannels: 2,
						trigger: trig,
						bufnum: [\bufL.kr(0), \bufR.kr(1)],		// multichannel expansion!
						rate: \rate.kr(1),
						centerPos: \centerPos.kr(0.5),
						dur: \granDur.kr(0.1),
						pan: [-1,1] * \pan.kr(1),
						amp: \amp.kr(0.1),
						interp: 4
					) * EnvGen.kr(Env.asr(att, 1, rel), gate, doneAction:2);
				)
			}).add;

			~centerPosBus = Bus.control(s,1);
			
			~bus = Bus.audio(s, 2);
			SynthDef(\record, {
				arg in=0, buf=0, t_trig, id=0;
				var phasor;
				phasor = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
				BufWr.ar(
					SoundIn.ar(in),
					bufnum: buf,
					phase: phasor
				);
				SendTrig.kr(t_trig, id, phasor);
			}).add;
			
			SynthDef(\centerPosScaler, {
				arg input=1.0, out=0, mul=1.0;
				Out.kr(out, input * mul );
			}).add;


			Server.default.sync;
			// Always recording, looping over ~liveRecMaxLen samples.
			~recorder = ~liveRecBufNumChan.collect({ |i|
				Synth.head(Server.default, \record, [
					\buf, ~liveRecBuf[i],
					\in, i,
					\id, i
				]);
			});
		}.fork;
	});



	~asPatternList = ~asPatternList.deepCopy.addFunc({
		//Make sure everything is clean.
		~granulotron.isPlaying.if({
			~granulotron.free;
			~pitcher.free;
			~centerPosSynth.free;
		});

		~server.makeBundle(nil,{

			~granulotron = Synth.after(~pitcher, \granulotron, [
				// \out, ~bus.index,
				\out, 0,
				\bufL, ~allBuffers[~currentBuf][0],
				\bufR, ~allBuffers[~currentBuf][1]
				// \amp, 0.1
			]);

			~centerPosSynth = Synth.before(~granulotron, \centerPosScaler, [
				\out, ~centerPosBus,
				\mul, ~liveBuffersLengths[~currentBuf]
			]);

			~granulotron.map( \amp, ~ampBus);

			~granulotron.map( \freq, ~freqBuses.subBus(0));
			
			// Map interpolator
			[\rate, \granDur].do({|i,j|
				~granulotron.map(i, ~interpolator.cursor.parameters[j+2].bus)
			});

			// centerPos: interpolator[1] -> centerPosSynth -> centerPosBus -> granulotron
			~centerPosSynth.map(\input, ~interpolator.cursor.parameters[1].bus);
			~granulotron.map(\centerPos, ~centerPosBus);

			~pitcher.map( *
				~notes.size.collect({|i|
					[~interpolId + i , ~interpolator.cursor.parameters[0].bus]
				}).flat;			
			);
			NodeWatcher.register(~granulotron);
		});
		1.asPattern;
	});

	~stopCleanupList = ~stopCleanupList.deepCopy.addFunc({
		~granulotron.isPlaying.if({
			~granulotron.release(~relTime);
		});
	});

	~freeCleanupList = ~freeCleanupList.deepCopy.addFunc({
		~bus.free;
		~allBuffers.do({|i| i.do(_.free) });
		~liveRecBuf.do(_.free);
		~centerPosBuses.do(_.free);
	});
})



~liveRec = ~liveRecorder.clone({~bufDur = 60 * s.sampleRate });

~liveRec.prep;
~liveRec.bufDur;
~liveRec.free;


~liveRec.liveRecBuf.dump;

(sr: Server.default.sampleRate, goo: {|self| 21 * self.sr} ).goo

~goo.put(\doo, \raw);
~goo.play

clone



.flop);

		~oscDefsFuncs = IdentityDictionary.newFrom([
			~oscDefsKeys,
			[
				//leapNumHands		
				{|msg, timeStamp|
					(msg[1] == 1).if({
						msg.postln;
						~synthA = Synth.tail(
							Server.default, \granulo2000, [
								\buf, ~buffers[0],
								\env, ~envBuf2,
								\granFreq, 100
							]);
					},{
						~synthA.free;
					});
				},
				//leapLeftOrient		
				{ 
				},
				//leapLeftPos		
				{},
				//leapLeftSphere		
				{},
				//leapRightOrient		
				{},
				//leapRightPos		
				{|msg, timeStamp|
					msg.postln;
				},
				//leapRightSphere		
				{}
			]
		].flop.flatten
);


~moo = Proto({
	~sr = Server.default.sampleRate;
	~liveRecMaxLen = ~sr * 30.0; // seconds to samples.
	~preRecLength = ~sr * 4.0; // seconds to samples.

});

~moo.liveRecMaxLen
~moo.preRecLength