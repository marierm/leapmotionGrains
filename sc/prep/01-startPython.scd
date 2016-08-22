(
// Running this will open a new terminal window where python 2 (not
// python 3) runs the script ../pythonLeap/leap.py.  If there is an
// error or the terminal does not open, try running this manually in a
// terminal: /path/to/python /path/to/this/folder/pythonLeap/leap.py

~leapOSCreceiver = Proto({
	Platform.case(
	\osx, { ~pythonPath = "python"; },
	\linux, { ~pythonPath = "/usr/bin/python2"; },
	\windows, { "I don't know where python is on windows.".postln }
	);

	~leapPy = "../../pythonLeap/leap.py".resolveRelative;

	~prep = {
		~pythonPID = (~pythonPath + ~leapPy).runInTerminal;
	};
});

~leapOSCreceiver.prep;
)