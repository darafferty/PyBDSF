C$TEST  DPOST2
c  main program
      common /cstak/ ds
      double precision ds(1100)
      external handle, dpostd, bc, af
      integer ndx, k, is(1000), nu, nv, nmesh
      real errpar(2), rs(1000)
      logical ls(1000)
      complex cs(500)
      double precision u(200), v(1), mesh(100), dt, ws(500), tstop
      integer temp
      equivalence (ds(1), cs(1), ws(1), rs(1), is(1), ls(1))
c to test dpost on
c      u sub t = u sub xx + f      on (0,1)
c  by setting u1 = u and u2 = u1 sub x and solving
c      u1 sub t = u1 sub xx + f
c                                  on (0,1)
c      u1 sub x = u2
c where f is chosen so that the solution is
c      u(x,t) = exp(xt).
c the port library stack and its aliases.
c initialize the port library stack length.
      call istkin(1100, 4)
      nu = 2
      nv = 0
      errpar(1) = 0
c absolute error.
      errpar(2) = 1e-2
      tstop = 1
      dt = 1d-2
      k = 4
c ndx uniform mesh points on (0,1).
      ndx = 4
      call dumb(0d0, 1d0, ndx, k, mesh, nmesh)
c initial conditions for u1.
      call setd(nmesh-k, 1d0, u)
c initial conditions for u2.
      temp = nmesh-k
      call setd(nmesh-k, 0d0, u(temp+1))
      call dpost(u, nu, k, mesh, nmesh, v, nv, 0d0, tstop, dt, af, bc, 
     1   dpostd, errpar, handle)
c check for errors and stack usage statistics.
      call wrapup
      stop 
      end
      subroutine af(t, x, nx, u, ux, ut, utx, nu, v, vt, nv, a, 
     1   au, aux, aut, autx, av, avt, f, fu, fux, fut, futx, fv, fvt)
      integer nu, nx
      integer nv
      double precision t, x(nx), u(nx, nu), ux(nx, nu), ut(nx, nu), utx(
     1   nx, nu)
      double precision v(1), vt(1), a(nx, nu), au(nx, nu, nu), aux(nx, 
     1   nu, nu), aut(nx, nu, nu)
      double precision autx(nx, nu, nu), av(1), avt(1), f(nx, nu), fu(
     1   nx, nu, nu), fux(nx, nu, nu)
      double precision fut(nx, nu, nu), futx(nx, nu, nu), fv(1), fvt(1)
      integer i
      double precision dexp
      do  1 i = 1, nx
         a(i, 1) = -u(i, 2)
         au(i, 1, 2) = -1
         f(i, 1) = (x(i)-t**2)*dexp(x(i)*t)-ut(i, 1)
         fut(i, 1, 1) = -1
         a(i, 2) = u(i, 1)
         au(i, 2, 1) = 1
         f(i, 2) = u(i, 2)
         fu(i, 2, 2) = 1
   1     continue
      return
      end
      subroutine bc(t, l, r, u, ux, ut, utx, nu, v, vt, nv, b, bu,
     1   bux, but, butx, bv, bvt)
      integer nu
      integer nv
      double precision t, l, r, u(nu, 2), ux(nu, 2), ut(nu, 2)
      double precision utx(nu, 2), v(1), vt(1), b(nu, 2), bu(nu, nu, 2),
     1   bux(nu, nu, 2)
      double precision but(nu, nu, 2), butx(nu, nu, 2), bv(1), bvt(1)
      double precision dexp
      b(1, 1) = u(1, 1)-1d0
      b(1, 2) = u(1, 2)-dexp(t)
      bu(1, 1, 1) = 1
      bu(1, 1, 2) = 1
      return
      end
      subroutine handle(t0, u0, v0, t, u, v, nu, nxmk, nv, k, x, 
     1   nx, dt, tstop)
      integer nxmk, nu, nx
      integer nv, k
      double precision t0, u0(nxmk, nu), v0(1), t, u(nxmk, nu), v(1)
      double precision x(nx), dt, tstop
      common /time/ tt
      double precision tt
      external u1ofx, u2ofx
      integer i1mach
      double precision deesff, eu(2)
      integer temp
c output and checking routine.
      if (t0 .eq. t) return
c u1ofx and u2ofx need time.
      tt = t
      eu(1) = deesff(k, x, nx, u, u1ofx)
      eu(2) = deesff(k, x, nx, u(1, 2), u2ofx)
      temp = i1mach(2)
      write (temp,  1) t, eu
   1  format (14h error in u(x,, 1pe10.2, 4h ) =, 2(1pe10.2))
      return
      end
      subroutine u1ofx(x, nx, u, w)
      integer nx
      double precision x(nx), u(nx), w(nx)
      common /time/ t
      double precision t
      integer i
      double precision dexp
      do  1 i = 1, nx
         u(i) = dexp(x(i)*t)
   1     continue
      return
      end
      subroutine u2ofx(x, nx, u, w)
      integer nx
      double precision x(nx), u(nx), w(nx)
      common /time/ t
      double precision t
      integer i
      double precision dexp
      do  1 i = 1, nx
         u(i) = t*dexp(x(i)*t)
   1     continue
      return
      end
