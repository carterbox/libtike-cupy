#include <cufft.h>

#ifndef _PTYCHOFFT
#define _PTYCHOFFT

class ptychofft {
private:
  bool is_free = false;

  float2 *f;   // complex object. (ntheta, nz, n)
  float2 *g;   // complex data. (ntheta, nscan, detector_size, detector_size)
  float2 *prb; // complex probe function. (nethat, nsca, probe_size, probe_size)
  float *scan; // vertical, horizonal scan positions. (ntheta, nscan, 2)
               // Negative scan positions are skipped in kernel executions.

  cufftHandle plan2d; // 2D FFT plan

  dim3 BS3d; // 3d thread block on GPU

  // 3d thread grids on GPU for different kernels
  dim3 GS3d0, GS3d1, GS3d2;

public:
  size_t ntheta;        // number of projections
  size_t nz;            // object vertical size
  size_t n;             // object horizontal size
  size_t nscan;         // number of scan positions for 1 projection
  size_t detector_size; // detector width and height
  size_t probe_size;    // probe size in 1 dimension

  // constructor, memory allocation
  ptychofft(size_t ntheta, size_t nz, size_t n, size_t nscan,
            size_t detector_size, size_t probe_size);
  // destructor, memory deallocation
  ~ptychofft();
  // free memory early
  void free();
  // forward ptychography operator FQ
  void fwd(size_t g, size_t f, size_t scan, size_t prb);
  // adjoint ptychography operator
  // if flg = 0, with respect to object f = Q*F*g
  // if flg == 1, with respect to probe prb = Q*F*g
  void adj(size_t g, size_t f, size_t scan, size_t prb, int flg);
};

#endif
