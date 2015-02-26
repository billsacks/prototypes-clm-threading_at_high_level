module decompMod

  ! This module is just being used as a stub in this prototype. Do not make much of how
  ! this is implemented - I just needed something.
  !
  ! The one feature that reflects my vision for the true implementation is that
  ! bounds_type no longer has beginning indices (begg, begl, etc.): In the new
  ! implementation, the beginning indices will be 1 for all procs and all clumps!
  
  implicit none
  save

  ! ------------------------------------------------------------------------
  ! The following parameters are defined to simplify the prototype. In the real CLM they
  ! are runtime variables
  ! ------------------------------------------------------------------------

  integer, parameter :: nclumps = 4

  ! These define the number of grid cells, landunits, etc. on this processor
  integer, parameter :: numg = 15
  integer, parameter :: numl = 25
  integer, parameter :: numc = 35
  integer, parameter :: nump = 45

  ! ------------------------------------------------------------------------
  ! end parameters
  ! ------------------------------------------------------------------------
  
  
  type bounds_type
     ! Note that we no longer have a lower bound, because the lower bound is always 1,
     ! for all clumps and all procs!

     ! ALTERNATIVE: because there is no begg, etc., we could rename these to numg, numl,
     ! etc.
     integer :: endg
     integer :: endl
     integer :: endc
     integer :: endp
     ! endCohort will also be here, but is not implemented in this prototype

     ! may still have the 'level' component, but that isn't implemented here
     integer :: clump_index
  end type bounds_type

contains

  integer function get_proc_clumps()
    get_proc_clumps = nclumps
  end function get_proc_clumps
   
  subroutine get_clump_bounds(n, bounds)
    integer, intent(in) :: n  ! clump index
    type(bounds_type), intent(out) :: bounds

    ! Of course, the real implementation of this routine looks quite different. This is
    ! just a stub for the sake of this prototype.

    ! Divide points evenly among clumps, putting any leftovers in the last clump
    
    if (n < nclumps) then
       bounds%endg = numg / 4
       bounds%endl = numl / 4
       bounds%endc = numc / 4
       bounds%endp = nump / 4
    else
       bounds%endg = numg - 3 * (numg / 4)
       bounds%endl = numl - 3 * (numl / 4)
       bounds%endc = numc - 3 * (numc / 4)
       bounds%endp = nump - 3 * (nump / 4)
    end if

    bounds%clump_index = n
  end subroutine get_clump_bounds

end module decompMod
