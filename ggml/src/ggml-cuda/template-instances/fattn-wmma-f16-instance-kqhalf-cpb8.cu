// This file has been autogenerated by generate_cu_files.py, do not edit manually.

#include "../fattn-wmma-f16.cuh"

#if !(defined(GGML_USE_HIP) && defined(__HIP_PLATFORM_AMD__))
DECL_FATTN_WMMA_F16_CASE(64, 8, half);
DECL_FATTN_WMMA_F16_CASE(96, 8, half);
DECL_FATTN_WMMA_F16_CASE(128, 8, half);
DECL_FATTN_WMMA_F16_CASE(256, 8, half);
#endif // !(defined(GGML_USE_HIP) && defined(__HIP_PLATFORM_AMD__))
