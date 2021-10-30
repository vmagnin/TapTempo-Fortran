module taptempo
    ! Reals working precision and 64 bits integers:
    use, intrinsic :: iso_fortran_env, only: wp=>real64, int64

    implicit none

    ! Tap Tempo Version:
    character(len=*), parameter :: version = "0.9.0"

    ! Default values of the command options:
    integer :: s = 5    ! Stack size
    integer :: p = 0    ! Precision
    integer :: r = 5    ! Reset time in seconds

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
        print '(A)', "Usage : taptempo [options]"
        print '(A)'
        print '(A)', "Options :"
        print '(A)', "  -h, --help            display this help message"
        print '(A)', "  -p, --precision       change the number of decimal for the tempo,"
        print '(A)', "                        the default is 0 decimal places, the max is 5 decimals"
        print '(A)', "  -r, --reset-time      change the time in seconds to reset the calculation,"
        print '(A)', "                        the default is 5 seconds"
        print '(A)', "  -s, --sample-size     change the number of samples needed to calculate the tempo,"
        print '(A)', "                        the default is 5 samples, the minimum is 2"
        print '(A)', "  -v, --version         print the version number"
    end subroutine


    subroutine manage_command_line
        integer :: i, nb
        character(len=100) :: args

        nb = command_argument_count()
        if (nb == 0) return

        i = 0
        do while (i <= nb)
            i = i + 1
            call get_command_argument(i, value=args)

            select case(trim(args))
                case("-h", "--help")
                    call print_version()
                    call print_options()
                    stop
                case("-p", "--precision")
                    i = i + 1
                    call get_command_argument(i, value=args)
                    read(args, *) p
                    p = min(p, 5)
                case("-r", "--reset-time")
                    i = i + 1
                    call get_command_argument(i, value=args)
                    read(args, *) r
                case("-s", "--sample-size")
                    i = i + 1
                    call get_command_argument(i, value=args)
                    read(args, *) s
                    s = max(2, s)
                case("-v", "--version")
                    call print_version()
                    stop
            end select
        end do
    end subroutine manage_command_line


    subroutine measure_tempo
        character(len=1) :: key
        integer(int64) :: count       ! Count of the processor clock
        real(wp) :: rate              ! Number of clock ticks per second
        integer :: i
        real(wp), dimension(s) :: t   ! Time FIFO stack
        integer :: oldest
        character(len=25) :: fmt

        ! Format used for printing the tempo:
        write(fmt, '(A, I1, A)') '("Tempo: ", f8.', p, ', " BPM")'
        ! Stack initialization:
        t = 0

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
            else
                ! Verify that the user is actively tapping:
                if (t(1) - t(2) <= r) then
                    ! Oldest time in the stack:
                    oldest = min(i, s)
                    ! Computes and prints the beats per minute:
                    print fmt, 60 / ((t(1) - t(oldest)) / (oldest - 1))
                else
                    print '(A)', "Time reset"
                    i = 1
                    t(2:s) = 0
                end if
            end if
        end do

        print '(A)', "I don't know why you say goodbye..."
    end subroutine measure_tempo

end module taptempo
