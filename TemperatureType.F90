module TemperatureType

  ! There is nothing interesting in this module. It is just here to act as a stub to
  ! illustrate some things in IrrigationMod.
  
  use decompMod, only : bounds_type
  implicit none

  type, public :: temperature_type
     real, pointer :: mytemp_col(:)

   contains
     procedure, public :: Init

     procedure, private :: InitAllocate
     procedure, private :: InitCold
  end type temperature_type

contains

  subroutine Init(this, bounds, nc)
    class(temperature_type), intent(inout) :: this
    type(bounds_type), intent(in) :: bounds

    ! nc = clump index. In reality, we wouldn't have any need to pass in the clump
    ! index. Here I'm doing it simply so that I can make the temperature values differ on
    ! each clump.
    integer, intent(in) :: nc

    call this%InitAllocate(bounds)
    call this%InitCold(bounds, nc)
  end subroutine Init

  subroutine InitAllocate(this, bounds)
    class(temperature_type), intent(inout) :: this
    type(bounds_type), intent(in) :: bounds

    ! Note that lower bounds are now implicitly 1
    allocate(this%mytemp_col(bounds%endc))
  end subroutine InitAllocate

  subroutine InitCold(this, bounds, nc)
    class(temperature_type), intent(inout) :: this
    type(bounds_type), intent(in) :: bounds

    ! nc = clump index. In reality, we wouldn't have any need to pass in the clump
    ! index. Here I'm doing it simply so that I can make the temperature values differ on
    ! each clump.
    integer, intent(in) :: nc

    integer :: c

    ! Note that loops can now start at 1, and the end index can safely be taken from the
    ! length of the array, rather than using the bounds derived type (if you want to)
    do c = 1, size(this%mytemp_col)
       this%mytemp_col(c) = 100. * nc + c
    end do

  end subroutine InitCold

end module TemperatureType
