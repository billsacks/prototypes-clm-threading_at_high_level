# prototypes-clm_threading\_at\_high\_level
Prototype for reorganizing CLM's threading so it occurs at a higher level,
preventing complexity with array passing.

Compiling and running
=====================

Compile with:

    make

Run with (using bash):

    export OMP_NUM_THREADS=4
    ./prototype


Basic idea
==========

There is a separate instance of each CLM object for every clump (which typically
corresponds to each thread). This would be done together with changing the lower
bound for each processor to be 1.


Things to particularly examine
==============================

* IrrigationMod.F90

    Shows what a science module can look like.

* clm\_instMod.F90

    Shows how the multiple instances (one per clump) are handled.

* clm\_driver.F90

    Shows what the driver loop would look like, in terms of calls to subroutines.


Advantages
==========

* Calling subroutines becomes much easier

    You no longer need to subset arrays by their bounds when calling things. And
    you no longer need to explicitly declare the lower bounds of arrays in the
    argument declaration.

* You can do intuitive whole-array operations

    this%foo(:) = 0.\_r8 now works as expected - because the 'this' object only
    contains information for this particular clump

* You can use scalar variables in an intuitive way

    e.g., recall the case that caused a crop threading bug in the past, because
    of the use of a scalar.

    Now you can have a scalar member of a class, and this will just apply to a
    single clump - which is generally what you would want.


Challenges
==========

All of these challenges represent one-time, up-front costs. Once done, I believe
the code will be cleaner, and I do not see any major challenges in terms of
working with the code long-term. But they do represent possibly significant
one-time costs.

**Note: Mariana points out that we could have an array of global seg maps (one
per clump). That may end up being a relatively easy way to handle i/o (history,
restart, etc.). This fits in with something I have been imagining, which is:
Basically, each clump can be thought of quite similarly to a proc now.**

* Need to rework anything that refers to bounds\_proc (i.e., proc-level bounds)

    I'm pretty sure bounds\_proc will become meaningless - only bounds\_clump
    will have any meaning moving forward.

    In many ways, this represents a simplification of the system - there will no
    longer be two representations of bounds - but it will take some up-front
    work.

* Need instances of the subgrid types (patch\_type, col\_type, etc.) to be
  declared and passed explicitly, as is done for the science types.

    It will no longer work to have a single instance of each of these types used
    via 'use' statements: You will need nclumps instances, passed explicitly.

    To facilitate this, we may want a higher-level subgridType, and have nclumps
    instances of that. That way, you could pass just subgrid\_inst(nc) rather
    than having to pass patch\_inst(nc), col\_inst(nc), etc. (Note that the
    subgridType would then have a single patch\_type instance, a single
    col\_type instance, etc.)

    Also note that we could avoid passing this explicitly to all subroutines if
    we want, by passing subgrid\_inst to the constructor of each science object,
    storing a reference to the subgrid\_inst in the science object. (As proposed
    above for bounds.)

* More generally, you cannot have patch-level, col-level, etc. arrays declared
  as module variables. These all need to be members of some object, in order to
  handle threading consistently.

    I'm not sure if this is an issue at this point - all such variables may
    already be gone.

* Need to rework some decomposition-related code

* Need to figure out how to handle code that is currently called outside a
  threaded region.

    I think this solution will be cleanest to the extent that we can move as
    much as possible within threaded regions.

    For I/O things that involve reading scalars from files (such as from the
    parameter file): we may want to just have separate instances of the
    parameter data in each thread's object, and live with a bit of duplication.

    For I/O of arrays (e.g., patch-level or col-level arrays), could this be
    done within a threaded region? If not, we need to figure out how to handle
    this. This rework of i/o of arrays may be the biggest challenge.

    We may be able to handle some problems by having loops over clumps that are
    done outside threaded regions - so each clump is handled sequentially.

  **This may end up not being too much of an issue, if Mariana's idea of having
    multiple global seg maps simplifies things significantly**

* May need some rework of routines (such as dynSubgridDriver) that create
threads at a lower level than the driver.

    If we need to maintain the ability to create threaded regions at a lower level
    like this, I think we would need to pass the whole array (nclumps) of the
    derived types into routines like dynSubgridDriver.
