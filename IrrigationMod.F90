module IrrigationMod

  use decompMod, only : bounds_type
  implicit none

  ! Here I show a subset of what's in the true irrigation_type, for illustration. This
  ! looks essentially the same as before - i.e., there will not, in general, be any
  ! substantive changes to the derived types to accommodate this new scheme.
  !
  ! ALTERNATIVE: We could store a copy of bounds (or a pointer to bounds) as a component
  ! of the type. This would be set in initialization. Then we wouldn't need to pass the
  ! bounds to every subroutine. This would be possible thanks to the fact that a given
  ! instance of irrigation_type now always operates on the same, fixed bounds. However,
  ! this alternative feels messy for the semi-object-oriented nature of most of the older
  ! CLM code (which derived type would a subroutine take its bounds from?).
  type, public :: irrigation_type
     private
     
     real, pointer, public :: qflx_irrig_patch(:)
     real, pointer, public :: qflx_irrig_col(:)

     ! Note that this scalar is now duplicated across all instances of irrigation_type
     ! (i.e., across all clumps). This duplication of scalars seems like a trivial price
     ! to pay for the simplicity we gain.
     integer :: dtime  ! land model time step
   contains
     procedure, public :: Init
     procedure, public :: CalcIrrigationNeeded
     procedure, public :: SomeOtherRoutine

     procedure, private :: InitAllocate
     procedure, private :: InitCold
     procedure, private :: CalcFoo
  end type irrigation_type

contains

  subroutine Init(this, bounds)
    class(irrigation_type), intent(inout) :: this
    type(bounds_type), intent(in) :: bounds

    call this%InitAllocate(bounds)
    call this%InitCold(bounds)
  end subroutine Init

  subroutine InitAllocate(this, bounds)
    class(irrigation_type), intent(inout) :: this
    type(bounds_type), intent(in) :: bounds

    ! Note that lower bounds are now implicitly 1
    allocate(this%qflx_irrig_patch(bounds%endp))
    allocate(this%qflx_irrig_col(bounds%endc))
  end subroutine InitAllocate

  subroutine InitCold(this, bounds)
    class(irrigation_type), intent(inout) :: this
    type(bounds_type), intent(in) :: bounds
    integer :: p
    
    ! Note that it is now safe to do whole-array assignments like this:
    this%qflx_irrig_col(:) = 0.

    ! Note that loops can now start at 1, and the end index can safely be taken from the
    ! length of the array, rather than using the bounds derived type (if you want to)
    do p = 1, size(this%qflx_irrig_patch)
       this%qflx_irrig_patch(p) = p
    end do
    
  end subroutine InitCold

  subroutine CalcIrrigationNeeded(this, bounds, temperature_inst)
    use TemperatureType, only : temperature_type
    class(irrigation_type), intent(inout) :: this
    type(bounds_type), intent(in) :: bounds
    type(temperature_type), intent(in) :: temperature_inst

    real, allocatable :: foo_col(:)

    ! As with the class-level variables, local variables also implicitly have a lower
    ! bound of 1
    allocate(foo_col(bounds%endc))

    ! Note that array arguments no longer need to have their bounds explicitly specified!
    call this%CalcFoo(bounds, temperature_inst%mytemp_col, foo_col)
    ! In the past, this would have been:
    ! call this%CalcFoo(bounds, temperature_inst%mytemp_col(bounds%begc:bounds%endc), &
    !      foo_col(bounds%begg:bounds%endc))
    
    ! Once again, note that whole-array operations are safe
    this%qflx_irrig_col(:) = foo_col(:) * 2.
    
  end subroutine CalcIrrigationNeeded

  ! The following routine illustrates the interface for a routine that has an array argument
  subroutine SomeOtherRoutine(this, bounds, mytemp_col)
    class(irrigation_type), intent(inout) :: this
    type(bounds_type), intent(in) :: bounds

    ! Note that array arguments no longer need their lower bound to be declared!
    real, intent(in) :: mytemp_col(:)
    ! In the past this would have been:
    ! real, intent(in) :: mytemp_col( bounds%begc: )

    integer :: c

    ! Assertions could look like this (rather than asserting on the upper bound... now we
    ! can assert on size, since the lower bound is always 1):
    ! SHR_ASSERT((size(mytemp_col) == bounds%endc), errMsg(__FILE__, __LINE__))

    ! Once again, note that loops start at 1
    do c = 1, bounds%endc
       this%qflx_irrig_col(c) = this%qflx_irrig_col(c) + mytemp_col(c)
    end do
  end subroutine SomeOtherRoutine
    
  subroutine CalcFoo(this, bounds, mytemp_col, foo_col)
    class(irrigation_type), intent(in) :: this
    type(bounds_type), intent(in) :: bounds

    ! Note that array arguments no longer need their lower bound to be declared!
    real, intent(in) :: mytemp_col(:)
    real, intent(out) :: foo_col(:)
    ! In the past this would have been:
    ! real, intent(in) :: mytemp_col( bounds%begc: )
    ! real, intent(out) :: foo_col( bounds%begc: )
    

    integer :: c

    ! Once again, note that loops start at 1
    do c = 1, bounds%endc
       foo_col(c) = mytemp_col(c)
    end do
  end subroutine CalcFoo

end module IrrigationMod
