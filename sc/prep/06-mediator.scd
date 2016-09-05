(
OSCdef(\mediatorLeft, { |msg, timeStamp|
	msg[1].switch(
		1, {
			~grLeft.play; // Start the granulator.
			\leftOn.postln;
			~links = [
				~link.new(
					\lOrient, 		// pitch, roll, yaw
					[\rate,],
					[[8.0,0.125,\exp].asSpec],
					~grLeft,
					1
				),
				~link.new(
					\lPos, 		// x, y, z
					[\pos,\granFreq, \granDur],
					[[0,1].asSpec, [1,100, \exp].asSpec, [0.01, 1, \exp].asSpec],
					~grLeft, 
					0 // offset 
				),
				~link.new(
					\lSphere,
					[\panW],
					[[0.2,3].asSpec],
					~grLeft
				)
			];
		},
		0, {
			~grLeft.stop; // Stop the granulator.
			\leftOff.postln;
			~links.do(_.free);
		}
	);
},~leapReceivers[\left].oscPath, recvPort: ~leapReceivers[\left].port);


)