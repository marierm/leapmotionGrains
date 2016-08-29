// A link is a connection between a ~leapReceiver and a sound
// parameter.  It takes these parameters:
// - source : a Symbol that is a key in the ~leapReceivers dictionary.
// - dests : an Array of Symbols that are parameters of the grasNullateur Synth.
// - specs : an Array of  ControlSpecs for mapping the data.
// 
// This will only do one-to-one mapping.

// GrasNullateur takes these arguments:

// arg granFreq=8, out=0, granDur=0.2, bufnum=0, rate=1,
// pos=0.5, panW=0.0, panC=0.0, amp=0.1, env= -1;

(
forkIfNeeded {
	~link = Proto({
		~initialize = { |source, dests, specs|
			forkIfNeeded {
				~leapReceivers = topEnvironment.at(\leapReceivers);
				~source = ~leapReceivers.at(source);
				~specs = specs ? Array.fill(~source.numChan, {});
				~dests = dests ? Array.fill(~source.numChan, {});
				~bus = Bus.control(Server.default, ~source.numChan);
				~defs = ~source.numChan.collect({|i|
					SynthDef(
						(source++"-to-"++dests[i]), {
							|in=0, out=0|
							var input;
							input = In.kr(in, 1);
							input = specs[i].map(input);
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
					~gr.map(dest, ~bus.subBus(i));
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
		\lOrient,
		[\granFreq, \granDur, \rate],
		[[8,100].asSpec, [0.01, 2].asSpec, [0.25,4.0,\exp].asSpec]
	);
});