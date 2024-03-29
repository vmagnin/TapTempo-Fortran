# TapTempo Fortran

A command line `taptempo` written in modern Fortran and under GPL-3.0-or-later license. Listen to a song and hit enter key with style and you'll get the corresponding number of beats per minute (BPM). This tool is very useful to quickly find the tempo of a song. You can also use it to measure your heart rate: (gently) put one hand around your throat and tap the enter key at each beat.

The original TapTempo was written in C++, but lots of porting in other languages have been developed via the [LinuxFr website](https://linuxfr.org/wiki/taptempo). There is even a [TapTempo Federation](https://github.com/Taptempo-Federation).


## Compilation and execution

You need a modern Fortran compiler.

You can easily build and run the project using the Fortran Package Manager fpm (https://github.com/fortran-lang/fpm) at the root of the project directory:

```
$ fpm build
$ fpm run
 Hit Enter key for each beat (q to quit).

 [Hit enter key one more time to start BPM computation...]

Tempo:      85. BPM
Tempo:      83. BPM
Tempo:      84. BPM
Tempo:      84. BPM
Tempo:      81. BPM q
```

To add options, put them after `--`:

```
$ fpm run -- -r 3 -s 8 -p 2
```

Or you can also use the `build.sh` script if you don't have fpm installed, or just simply type:

```
$ gfortran -o taptempo src/taptempo.f90 app/main.f90
$ ./taptempo
```

## Options

```
Usage: taptempo [options]

Options :
  -h, --help            display this help message
  -o, --output          save the results in the taptempo.txt file
  -p, --precision       change the number of decimals for the tempo,
                        the default is 0 decimal places, the max is 5 decimals
  -r, --reset-time      change the time in seconds to reset the calculation,
                        the default is 5 seconds
  -s, --sample-size     change the number of samples needed to calculate the tempo,
                        the default is 5 samples, the minimum is 2
  -v, --version         print the version number
```

## Contributing

* Post a message in the GitHub *Issues* tab to discuss the feature you want to work on, or on the Fortran Discourse:
https://fortran-lang.discourse.group/t/tap-tempo-a-toy-project/2180
* Concerning coding conventions, follow the stdlib conventions:
https://github.com/fortran-lang/stdlib/blob/master/STYLE_GUIDE.md
* When ready, make a *Pull Request*.

## Technical information

* https://en.wikipedia.org/wiki/Tempo
* https://musicmachinery.com/2009/03/02/in-search-of-the-click-track/

* Introduced by Fortran 90:
  * [SYSTEM_CLOCK()](https://gcc.gnu.org/onlinedocs/gfortran/SYSTEM_005fCLOCK.html)
    * My first idea was to use `cpu_time()` but I soon realised that the process was idle while the `read(*, '(a1)') key` was waiting for an input! That’s why I finally used `system_clock()`.
    * A 64 bits integer can go up to 2**63-1 = +9223372036854775807. Even if the clock resolution is nanosecond, we could count 9223372036 seconds ~ 106751 days ~ 292 years.

* Introduced by Fortran 2003:
  * [COMMAND\_ARGUMENT\_COUNT()](https://gcc.gnu.org/onlinedocs/gfortran/COMMAND_005fARGUMENT_005fCOUNT.html)
  * [GET\_COMMAND\_ARGUMENT()](https://gcc.gnu.org/onlinedocs/gfortran/GET_005fCOMMAND_005fARGUMENT.html)

* Introduced by Fortran 2008:
  * [ISO\_FORTRAN\_ENV real64 and int64](https://gcc.gnu.org/onlinedocs/gfortran/ISO_005fFORTRAN_005fENV.html)
