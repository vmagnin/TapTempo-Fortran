! A command line taptempo written in modern Fortran style
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2021-10-28

program main
    use taptempo, only: manage_command_line, measure_tempo

    implicit none

    call manage_command_line()
    call measure_tempo()
end program main
