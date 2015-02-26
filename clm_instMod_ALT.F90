module clm_instMod

  use IrrigationMod, only : irrigation_type
  use TemperatureType, only : temperature_type
  use decompMod, only : bounds_type, get_proc_clumps, get_clump_bounds
  
  implicit none
  save
  
  ! ALTERNATIVE: Rather than having arrays of each science instance, we could instead make
  ! clm_inst itself an object. Then we would have nclumps instances of clm_inst, each of
  ! which has a single instance of irrigation_type, temperature_type, etc. I suspect that
  ! would have some benefits and some drawbacks compared to this implementation.
  type(irrigation_type), allocatable :: irrigation_inst(:)
  type(temperature_type), allocatable :: temperature_inst(:)

contains

  subroutine clm_instInit()
    integer :: nclumps, nc
    type(bounds_type) :: bounds_clump

    nclumps = get_proc_clumps()

    allocate(irrigation_inst(nclumps))
    allocate(temperature_inst(nclumps))
    
    !$OMP PARALLEL DO PRIVATE(nc, bounds_clump)
    do nc = 1, nclumps
       call get_clump_bounds(nc, bounds_clump)
       
       call irrigation_inst(nc)%init(bounds_clump)
       call temperature_inst(nc)%init(bounds_clump, nc)
    end do
  end subroutine clm_instInit

end module clm_instMod
