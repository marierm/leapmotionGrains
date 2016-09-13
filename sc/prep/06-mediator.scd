(
OSCdef(\mediatorLeft, { |msg, timeStamp|
	msg[1].switch(
		1, {
			~grLeft.play; // Start the granulator.
			\leftOn.postln;
			~linksL = [
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
			~linksL.do(_.free);
			// ~recBufs.do({|i| i.removeDependant(~grLeft); });
		}
	);
},~leapReceivers[\left].oscPath, recvPort: ~leapReceivers[\left].port);

OSCdef(\mediatorRight, { |msg, timeStamp|
	msg[1].switch(
		1, {
			~grRight.play; // Start the granulator.
			\rightOn.postln;
			~linksR = [
				~link.new(
					\rOrient, 		// pitch, roll, yaw
					[\rate,],
					[[8.0,0.125,\exp].asSpec],
					~grRight,
					1
				),
				~link.new(
					\rPos, 		// x, y, z
					[\pos,\granFreq, \granDur],
					[[0,1].asSpec, [1,100, \exp].asSpec, [0.01, 1, \exp].asSpec],
					~grRight, 
					0 // offset 
				),
				~link.new(
					\rSphere,
					[\panW],
					[[0.2,3].asSpec],
					~grRight
				)
			];
		},
		0, {
			~grRight.stop; // Stop the granulator.
			\rightOff.postln;
			~linksR.do(_.free);
			// ~recBufs.do({|i| i.removeDependant(~grLeft); });
		}
	);
},~leapReceivers[\right].oscPath, recvPort: ~leapReceivers[\right].port);


// Free everything when number of hands is zero.
//  This is a fail safe mechanism.
OSCdef(\mediatorCleanup, { |msg, timeStamp|
	(msg[1] == 0).if({
		~grLeft.group.release;
	});
},~leapReceivers[\numHands].oscPath, recvPort: ~leapReceivers[\numHands].port);



~recBufs.do({|i|
	i.addDependant(~grLeft);
	i.addDependant(~grRight);
});

)


