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

~leapReceivers.do(_.print_(false)); // Stop printing incoming OSC messages.
// ~leapReceivers.do(_.print_(true)); // Start printing incoming OSC messages.

// ~leap.do(_.calibration); 
// ~leap.do(_.stopCalibration);

"./prep/03-grasNullateur.scd".loadRelative; // granulator core.
"./prep/04-liveRecording.scd".loadRelative; // live recording mechanism (gui).

~gr.play; // Start granulator.

"./prep/05-mapping.scd".loadRelative; // 
~link1.free;



~recBufs[0].preRec;

x = {|pos=0,rate=1,freq=20|GrainBuf.ar(1, Impulse.ar(freq), 0.4, ~recBufs[0].buf,rate, pos )}.play;
x.set(\pos, (~recBufs[0].onsets[0]- 10000)/~recBufs[0].frames, \rate, 1);
x.set(\pos, (~recBufs[0].onsets[1] - 10000)/~recBufs[0].frames , \rate, 1);
x.set(\pos, 0, \rate, 1);