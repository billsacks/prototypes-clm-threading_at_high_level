module clm_instMod

  use IrrigationMod, only : irrigation_type
  use TemperatureType, only : temperature_type
  use decompMod, only : bounds_type, get_proc_clumps, get_clump_bounds
  
  implicit none
  save

  public :: clm_instInit
  
  type, public :: clm_inst_type
     type(irrigation_type) :: irrigation_inst
     type(temperature_type) :: temperature_inst
   contains
     procedure, private :: Init
  end type clm_inst_type

  ! We'll have one clm instance for each clump
  type(clm_inst_type), allocatable :: clm_instances(:)

contains

  subroutine clm_instInit()
    ! Initializes ALL instances
    integer :: nclumps, nc
    type(bounds_type) :: bounds_clump

    nclumps = get_proc_clumps()

    allocate(clm_instances(nclumps))
    
    !$OMP PARALLEL DO PRIVATE(nc, bounds_clump)
    do nc = 1, nclumps
       call get_clump_bounds(nc, bounds_clump)
       call clm_instances(nc)%Init(bounds_clump, nc)
    end do
  end subroutine clm_instInit

  subroutine Init(this, bounds, nc)
    ! Initializes a single instance
    class(clm_inst_type), intent(inout) :: this
    type(bounds_type), intent(in) :: bounds

    ! In reality, we probably won't need nc (the clump index). But for this prototype,
    ! it's used to initialize each temperature instance uniquely.
    integer, intent(in) :: nc

    call this%irrigation_inst%init(bounds)
    call this%temperature_inst%init(bounds, nc)
  end subroutine Init

end module clm_instMod
