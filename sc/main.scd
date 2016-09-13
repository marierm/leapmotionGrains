// Make sure Leap motion daemon is started.
// Required quarks:
// dewdrop_lib, wslib

// Start the python process that connects to the leapmotion.
// 1. Execute this line only once (unless python stops for some reason...)
"./prep/01-startPython.scd".loadRelative;

// 2. Execute this section.
(
fork {
	"./prep/02-leapReceivers.scd".loadRelative; // Create the OSC receivers.
	// ~leap[\numHands], ~leap[\lPos], ~leap[\rPos], ~leap[\lOrient], ~leap[\rOrient]
	// ~leap[\lSphere], ~leap[\rOrient]

	~leapReceivers.do(_.print_(false)); // Stop printing incoming OSC messages.
	// ~leapReceivers.do(_.print_(true)); // Start printing incoming OSC messages.

	// ~leap.do(_.calibration);
	// ~leap.do(_.stopCalibration);
	s.sync;
	"./prep/03-grasNullateur.scd".loadRelative; // creates ~grLeft and ~grRight.
	s.sync;
	"./prep/04-liveRecording.scd".loadRelative; // live recording mechanism (gui).
	s.sync;
	"./prep/05-mapping.scd".loadRelative; //
	s.sync;
	"./prep/06-mediator.scd".loadRelative; //
}
)


// 3. Execute to stop and cleanup (and restart by executing the previous section).
(
~grLeft.free;
~grRight.free;
~leapReceivers.do(_.free);
~lc.free;
~guig.window.close;
~recBufs.do(_.free);
~guis.do({|i| i.window.close});
OSCdef(\mediatorLeft).free;
OSCdef(\mediatorRight).free;
OSCdef(\mediatorCleanup).free;
)