program main
    use taptempo, only: manage_command_line, measure_tempo

    implicit none

    call manage_command_line()
    call measure_tempo()
end program main
