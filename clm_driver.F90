program clm_driver
  use clm_instMod, only : clm_instInit, clm_instances
  use decompMod, only : get_proc_clumps, get_clump_bounds, bounds_type

  implicit none

  integer, external :: OMP_GET_THREAD_NUM
  integer :: nclumps, nc
  type(bounds_type) :: bounds_clump

  ! ------------------------------------------------------------------------
  ! The following would really be done in initialization, but is done in this "driver"
  ! program for simplicity
  ! ------------------------------------------------------------------------

  call clm_instInit()
  
  ! ------------------------------------------------------------------------
  ! Here is what (part of) the run loop would look like.
  !
  ! Note that there is still some threading-related complexity in the driver. The main
  ! purpose of this prototype is to keep the threading-related complexity isolated to the
  ! driver, clm_instMod, and other infrastructure code, so that scientists do not have to
  ! follow any special threading-related conventions when writing their science code.
  !
  ! Note, though: *IF* we could rework the driver so that the bulk of the driver loop
  ! could be within a single nclumps loop (which would require reworking some routines
  ! that are in the middle of the driver loop, which currently cannot work in a threaded
  ! region): THEN we could have an outer driver routine that looked like:
  !   do nc = 1, nclumps
  !      call clm_driver(clm_inst(nc))
  ! and the main clm_driver routine could then be written without any threading-related
  ! knowledge.
  ! ------------------------------------------------------------------------

  nclumps = get_proc_clumps()

  !$OMP PARALLEL DO PRIVATE(nc, bounds_clump)
  do nc = 1, nclumps
     print *, 'executing: ', nc, OMP_GET_THREAD_NUM()

     associate(clm_inst => clm_instances(nc))

     call get_clump_bounds(nc, bounds_clump)

     ! Here is a subroutine call that illustrates passing whole derived types.
     call clm_inst%irrigation_inst%CalcIrrigationNeeded(bounds_clump, &
          clm_inst%temperature_inst)

     ! Here is a subroutine call that illustrates passing arrays.
     call clm_inst%irrigation_inst%SomeOtherRoutine(bounds_clump, &
          mytemp_col = clm_inst%temperature_inst%mytemp_col)
     ! In the past, this would have looked like:
     ! call irrigation_inst%SomeOtherRoutine(bounds_clump, &
     !      mytemp_col = temperature_inst%mytemp_col(bounds_clump%begc:bounds_clump%endc))

     end associate
     
  end do

  ! ------------------------------------------------------------------------
  ! The following is just for the sake of this prototype, to confirm that everything is
  ! working as intended
  ! ------------------------------------------------------------------------

  call print_irrigation

contains

  subroutine print_irrigation
    integer :: nclumps, nc, p, c
    type(bounds_type) :: bounds_clump

    nclumps = get_proc_clumps()

    ! qflx_irrig_patch(p) should be equal to p, for all clumps
    print *, 'QFLX_IRRIG_PATCH:'
    do nc = 1, nclumps
       print *, 'CLUMP ', nc
       call get_clump_bounds(nc, bounds_clump)

       do p = 1, bounds_clump%endp
          print *, p, clm_instances(nc)%irrigation_inst%qflx_irrig_patch(p)
       end do
    end do

    ! mytemp_col(c) should be equal to 100*nc + c
    ! qflx_irrig_col(c) should be equal to 3*mytemp_col(c)
    print *, 'MYTEMP_COL, QFLX_IRRIG_COL:'
    do nc = 1, nclumps
       print *, 'CLUMP ', nc
       call get_clump_bounds(nc, bounds_clump)

       do c = 1, bounds_clump%endc
          print *, c, &
               clm_instances(nc)%temperature_inst%mytemp_col(c), &
               clm_instances(nc)%irrigation_inst%qflx_irrig_col(c)
       end do
    end do    

  end subroutine print_irrigation

end program clm_driver
