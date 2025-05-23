#if !defined(GGML_USE_MUSA) && (CUDART_VERSION >= 11070 || defined(GGML_USE_HIP))
#define USE_CUB
#endif // !defined(GGML_USE_MUSA) && (CUDART_VERSION >= 11070 || defined(GGML_USE_HIP))

#ifdef USE_CUB

#if defined(GGML_USE_HIP)
// Workaround for gfx*-generic
#if defined(__gfx10_1_generic__)
#define __gfx1010__ __gfx10_1_generic__
#elif defined(__gfx10_3_generic__)
#define __gfx1030__ __gfx10_3_generic__
#elif defined(__gfx11_generic__)
#define __gfx1100__ __gfx11_generic__
#elif defined(__gfx12_generic__)
#define __gfx1201__ __gfx12_generic__
#endif

#include <hipcub/hipcub.hpp>
using namespace hipcub;
#else
#include <cub/cub.cuh>
using namespace cub;
#endif // defined(GGML_USE_HIP)

#endif // USE_CUB

#include "sumrows.cuh"
#include "sum.cuh"

#include <cstdint>

void sum_f32_cuda(ggml_cuda_pool & pool, const float * x, float * dst, const int64_t ne, cudaStream_t stream) {
#ifdef USE_CUB
    size_t tmp_size = 0;
    DeviceReduce::Sum(nullptr,       tmp_size, x, dst, ne, stream);
    ggml_cuda_pool_alloc<uint8_t> tmp_alloc(pool, tmp_size);
    DeviceReduce::Sum(tmp_alloc.ptr, tmp_size, x, dst, ne, stream);
#else
    // Use (inefficient) sum_rows implementation as a fallback.
    sum_rows_f32_cuda(x, dst, ne, 1, stream);
    GGML_UNUSED(pool);
#endif // USE_CUB
}

void ggml_cuda_op_sum(ggml_backend_cuda_context & ctx, ggml_tensor * dst) {
    const ggml_tensor * src0 = dst->src[0];

    GGML_ASSERT(src0->type == GGML_TYPE_F32);
    GGML_ASSERT( dst->type == GGML_TYPE_F32);
    GGML_ASSERT(ggml_is_contiguously_allocated(src0));

    const float * src0_d = (const float *) src0->data;
    float * dst_d = (float *) dst->data;

    const int64_t ne = ggml_nelements(src0);

    ggml_cuda_pool & pool = ctx.pool();
    cudaStream_t stream = ctx.stream();

    sum_f32_cuda(pool, src0_d, dst_d, ne, stream);
}
