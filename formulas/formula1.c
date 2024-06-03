#include "formulas.h"
#include <math.h>
#include <immintrin.h>
#include <stddef.h> // for size_t

float formula1_sequential(float *x, unsigned int length)
{
  float sum = 0;
  float product = 1;
  for (int k = 0; k < length; k++)
  {
    sum += sqrtf(x[k]);
    product *= (x[k] * x[k] + 1);
  }
  return sqrtf(1 + cbrtf(sum) / product);
}

float formula1_parallel_old(float *x, unsigned int length)
{
  __m128 sum_sqrt_x = _mm_setzero_ps();
  __m128 prod_x2_plus_1 = _mm_setzero_ps();

  __m128 ones = _mm_set1_ps(1.0f);

  for (size_t i = 0; i < length; ++i)
  {
    __m128 x_vec = _mm_load_ps(x + i); // load four floats

    __m128 sqrt_x_vec = _mm_sqrt_ps(x_vec);
    sum_sqrt_x = _mm_add_ps(sum_sqrt_x, sqrt_x_vec);

    __m128 x2_vec = _mm_mul_ps(x_vec, x_vec);
    __m128 x2_vec_plus_1 = _mm_add_ps(x2_vec, ones);
    prod_x2_plus_1 = _mm_mul_ps(prod_x2_plus_1, x2_vec_plus_1);
  }

  sum_sqrt_x = _mm_hadd_ps(sum_sqrt_x, sum_sqrt_x);
  sum_sqrt_x = _mm_hadd_ps(sum_sqrt_x, sum_sqrt_x);
  float sum_sqrt_x_f = _mm_cvtss_f32(sum_sqrt_x);

  // Manual reduction for product since hmul_ps doesn't exist
  float prod_array[4];
  _mm_storeu_ps(prod_array, prod_x2_plus_1);
  float prod_x2_plus_1_f = prod_array[0] * prod_array[1] * prod_array[2] * prod_array[3];

  float fraction = cbrtf(sum_sqrt_x_f) / prod_x2_plus_1_f;

  return sqrtf(1 + fraction);
}

float formula1_parallel(float *x, unsigned int length)
{
  __m128 sum_sqrt_x = _mm_setzero_ps();
  __m128 prod_x2_plus_1 = _mm_set1_ps(1.0f); // Initialize to 1 for multiplication

  __m128 ones = _mm_set1_ps(1.0f);

  // Adjust the loop to process four floats at a time
  for (size_t i = 0; i < length; i += 4)
  {
    __m128 x_vec = _mm_loadu_ps(x + i); // load four floats, use loadu for potentially unaligned data

    __m128 sqrt_x_vec = _mm_sqrt_ps(x_vec);          // square root of each element
    sum_sqrt_x = _mm_add_ps(sum_sqrt_x, sqrt_x_vec); // accumulating the sum of square roots

    __m128 x2_vec = _mm_mul_ps(x_vec, x_vec);                   // x squared
    __m128 x2_vec_plus_1 = _mm_add_ps(x2_vec, ones);            // x^2 + 1
    prod_x2_plus_1 = _mm_mul_ps(prod_x2_plus_1, x2_vec_plus_1); // accumulating the product
  }

  // Horizontal add to sum up all elements in sum_sqrt_x
  sum_sqrt_x = _mm_hadd_ps(sum_sqrt_x, sum_sqrt_x);
  sum_sqrt_x = _mm_hadd_ps(sum_sqrt_x, sum_sqrt_x);
  float sum_sqrt_x_f = _mm_cvtss_f32(sum_sqrt_x);

  // Manual reduction for product since hmul_ps doesn't exist
  float prod_array[4];
  _mm_storeu_ps(prod_array, prod_x2_plus_1);
  float prod_x2_plus_1_f = prod_array[0] * prod_array[1] * prod_array[2] * prod_array[3];

  // Calculate the final expression
  float fraction = cbrtf(sum_sqrt_x_f) / prod_x2_plus_1_f;

  return sqrtf(1.0f + fraction);
}

float formula1(float *x, unsigned int length)
{
  return formula1_parallel(x, length);
}
