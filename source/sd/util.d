module sd.util;

/**
Returns the home directory of current user.
Convenient location to save settings
ONLY implemented for POSIX systems so far
*/
string getHomeDir(){
    import std.path : expandTilde;
    return expandTilde("~");
}