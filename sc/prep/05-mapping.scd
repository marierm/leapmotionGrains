// A link is a connection between a ~leapReceiver and a sound
// parameter.  It takes these parameters:
// - source : a Symbol that is a key in the ~leapReceivers dictionary.
// - dests : an Array of Symbols that are parameters of the grasNullateur Synth.
// - specs : an Array of  ControlSpecs for mapping the data.
// - synth : The granulator synth.
// 
// This will only do one-to-one mapping.

// GrasNullateur takes these arguments:

// arg granFreq=8, out=0, granDur=0.2, bufnum=0, rate=1,
// pos=0.5, panW=0.0, panC=0.0, amp=0.1, env= -1;

(
forkIfNeeded {
	~link = Proto({
		~initialize = { |source, dests, specs, granu, offset=0|
			forkIfNeeded {
				~leapReceivers = topEnvironment.at(\leapReceivers);
				~source = ~leapReceivers.at(source);
				~specs = specs ? Array.fill(~source.numChan, {});
				~dests = dests ? Array.fill(~source.numChan, {});
				~granu = granu;
				~nodeMap = NodeMap.new;
				~bus = Bus.control(Server.default, ~dests.size);
				~defs = ~specs.collect({|spec, i|
					SynthDef(
						(source++"-to-"++dests[i]), {
							|in=0, out=0|
							var input;
							input = In.kr(in, 1);
							input = spec.map(input);
							Out.kr(out, input);
						});
				});
				~defs.do(_.add);
				Server.default.sync;
				~synths = ~defs.collect({ |def, i|
					Synth.head(Server.default, def.name, [
						\in, ~source.bus.subBus(i),
						\out, ~bus.subBus(i)
					])
				});
				
				~dests.do({|dest, i|
					~granu.granSynth.map(dest, ~bus.subBus(i));
				});
			};
			currentEnvironment;
		};
		~free = {
			~synths.do(_.free);
			~bus.free;
		};

	});
	

	~link1 = ~link.new(
		\lOrient, 		// yaw, pitch, roll
		[\granFreq, \granDur, \rate],
		[[2,10].asSpec, [2, 0.01].asSpec, [0.25,4.0,\exp].asSpec],
		~gr // This granulator is created in main.scd with ~gr.play.
	);

	~link2 = ~link.new(
		\lPos, 		// x, y, z
		[\pos],
		[[0,1].asSpec],
		~gr, // This granulator is created in main.scd with ~gr.play.
		0 // offset: 1 will link only y; 2 will link only z
	);
});



// ~link1.free;
// ~link2.free;

// ~link1.bus.get;

// ~link2.bus.get;

// ~gr.granSynth.set(\granFreq, 1, \pos, 0.1, \env, -1, \bufnum, 4, \granDur, 3, \rate, 1);

// ~gr.help