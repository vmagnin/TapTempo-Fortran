! A command line taptempo written in modern Fortran style
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2021-11-01

module taptempo
    ! Reals working precision and 64 bits integers:
    use, intrinsic :: iso_fortran_env, only: wp=>real64, int64

    implicit none

    ! Tap Tempo Version:
    character(len=*), parameter :: version = "1.0.0"

    ! Default values of the command options:
    integer :: s = 5                ! Stack size
    integer :: p = 0                ! Precision
    integer :: r = 5                ! Reset time in seconds
    logical :: out_flag = .false.   ! Flag for the ouput file

    private

    public :: manage_command_line, measure_tempo

contains

    subroutine print_version
        print '(A)', "TapTempo Fortran "//version
        print '(A)', "Copyright (C) 2021 Vincent Magnin and the Fortran-lang community"
        print '(A)', "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>"
        print '(A)', "This is free software: you are free to change and redistribute it."
        print '(A)', "There is NO WARRANTY, to the extent permitted by law."
    end subroutine


    subroutine print_options
        print '(A)'
        print '(A)', "Usage: taptempo [options]"
        print '(A)'
        print '(A)', "Options :"
        print '(A)', "  -h, --help            display this help message"
        print '(A)', "  -o, --output          save the results in the taptempo.txt file"
        print '(A)', "  -p, --precision       change the number of decimals for the tempo,"
        print '(A)', "                        the default is 0 decimal places, the max is 5 decimals"
        print '(A)', "  -r, --reset-time      change the time in seconds to reset the calculation,"
        print '(A)', "                        the default is 5 seconds"
        print '(A)', "  -s, --sample-size     change the number of samples needed to calculate the tempo,"
        print '(A)', "                        the default is 5 samples, the minimum is 2"
        print '(A)', "  -v, --version         print the version number"
        print '(A)'
        print '(A)', "Home page: <https://github.com/vmagnin/TapTempo-Fortran>"
    end subroutine


    subroutine manage_command_line
        integer :: i, nb, status
        character(len=100) :: args

        nb = command_argument_count()
        if (nb == 0) return

        i = 0
        do while (i < nb)
            i = i + 1
            call get_command_argument(i, value=args)

            select case(trim(args))
                case("-h", "--help")
                    call print_version()
                    call print_options()
                    stop
                case("-o", "--output")
                    out_flag = .true.
                case("-p", "--precision")
                    i = i + 1
                    call get_command_argument(i, value=args)
                    read(args, *, iostat=status) p
                    if (status /= 0) print '(A)', "Problem with -p: the default value will be used"
                    p = max(0, min(p, 5))   ! 0 <= p <= 5
                case("-r", "--reset-time")
                    i = i + 1
                    call get_command_argument(i, value=args)
                    read(args, *, iostat=status) r
                    if (status /= 0) print '(A)', "Problem with -r: the default value will be used"
                case("-s", "--sample-size")
                    i = i + 1
                    call get_command_argument(i, value=args)
                    read(args, *, iostat=status) s
                    if (status /= 0) print '(A)', "Problem with -s: the default value will be used"
                    s = max(2, s)
                case("-v", "--version")
                    call print_version()
                    stop
                case default
                    print '(2A)', "Unknown option ignored: ", trim(args)
            end select
        end do
    end subroutine manage_command_line


    subroutine measure_tempo
        character(len=1) :: key
        integer(int64) :: count       ! Count of the processor clock
        real(wp) :: rate              ! Number of clock ticks per second
        integer :: i
        integer :: my_file            ! Unit of the output file
        real(wp), dimension(s) :: t   ! Time FIFO stack
        real(wp) :: t0                ! Time origin
        real(wp) :: bpm               ! Beats Per Minute
        integer :: oldest
        character(len=28) :: fmt

        ! Format used for printing the tempo:
        write(fmt, '(A, I1, A)') '("Tempo: ", f10.', p, ', " BPM ")'
        ! Stack initialization:
        t = 0

        if (out_flag) then
            open(newunit=my_file, file="taptempo.txt", status="replace")
            write(my_file, '(A)') "#    t         bpm"
        end if

        print '(A)', "Hit Enter key for each beat (q to quit)."

        ! Infinite loop:
        i = 0
        do
            ! Reading the standard input:
            read '(a1)', key

            if (key == 'q') exit

            call system_clock(count, rate)
            ! Updating the time FIFO stack:
            t(2:s) = t(1:s-1)
            t(1) = count / rate

            i = i + 1

            if (i == 1) then
                print '(A)', "[Hit enter key one more time to start BPM computation...]"
                t0 = t(1)
            else
                ! Verify that the user is actively tapping:
                if (t(1) - t(2) <= r) then
                    ! Oldest time in the stack:
                    oldest = min(i, s)
                    ! Computes and prints the beats per minute:
                    bpm = 60 / ((t(1) - t(oldest)) / (oldest - 1))
                    write(*, fmt, advance="no") bpm
                    if (out_flag) write(my_file, '(F9.3, F12.5)') t(1)-t0, bpm
                else
                    print '(A)', "Time reset"
                    i = 1
                    t(2:s) = 0
                end if
            end if
        end do

        print '(A)', "I don't know why you say goodbye..."
        if (out_flag) close(my_file)

    end subroutine measure_tempo

end module taptempo
