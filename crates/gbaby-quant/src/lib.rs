//! # gbaby-quant
//!
//! TurboQuant with brains — auto-detecting CUDA / Metal / CPU compression
//! for the GBaby stack.
//!
//! ```rust
//! use gbaby_quant::{Quant, Backend};
//!
//! // Auto-detect best available backend: CUDA -> Metal -> CPU
//! let q = Quant::auto(3)?;
//!
//! // Or force a specific backend
//! let q = Quant::new(Backend::Cpu, 3)?;
//!
//! let compressed = q.compress(&vectors)?;
//! let restored = q.decompress(&compressed)?;
//! ```

use std::fmt;
use thiserror::Error;
use tracing::{info, warn};

#[derive(Debug, Error)]
pub enum QuantError {
    #[error("unsupported backend: {0}")]
    UnsupportedBackend(String),
    #[error("compression failed: {0}")]
    CompressionFailed(String),
    #[error("decompression failed: {0}")]
    DecompressionFailed(String),
    #[error("invalid configuration: {0}")]
    InvalidConfig(String),
}

/// Compression backend.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Backend {
    /// NVIDIA CUDA (requires `cuda` feature + NVIDIA GPU)
    Cuda,
    /// Apple Metal (requires `metal` feature + Apple Silicon)
    Metal,
    /// Pure CPU with SIMD (AVX2/NEON) — always available
    Cpu,
}

impl fmt::Display for Backend {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Backend::Cuda => write!(f, "CUDA"),
            Backend::Metal => write!(f, "Metal"),
            Backend::Cpu => write!(f, "CPU (SIMD)"),
        }
    }
}

/// Compressed vector payload.
#[derive(Debug, Clone)]
pub struct Compressed {
    pub data: Vec<u8>,
    pub original_len: usize,
    pub bits: u8,
    pub backend: Backend,
}

/// The main quantizer.
pub struct Quant {
    backend: Backend,
    bits: u8,
    projections: usize,
    seed: u64,
}

impl Quant {
    /// Create a quantizer with a specific backend.
    pub fn new(backend: Backend, bits: u8) -> Result<Self, QuantError> {
        if !(2..=8).contains(&bits) {
            return Err(QuantError::InvalidConfig(format!(
                "bits must be 2-8, got {bits}"
            )));
        }

        // Verify the requested backend is actually available
        if !is_backend_available(backend) {
            return Err(QuantError::UnsupportedBackend(format!(
                "{backend} requested but not available on this system"
            )));
        }

        info!("gbaby-quant: initialized with {backend} backend, {bits}-bit compression");
        Ok(Self {
            backend,
            bits,
            projections: 64,
            seed: 42,
        })
    }

    /// Auto-detect the best available backend: CUDA -> Metal -> CPU.
    pub fn auto(bits: u8) -> Result<Self, QuantError> {
        let backend = detect_best_backend();
        info!("gbaby-quant: auto-detected {backend} backend");
        Self::new(backend, bits)
    }

    /// Set the number of randomized projections (default: 64).
    pub fn with_projections(mut self, projections: usize) -> Self {
        self.projections = projections;
        self
    }

    /// Set the seed for deterministic reproducibility (default: 42).
    pub fn with_seed(mut self, seed: u64) -> Self {
        self.seed = seed;
        self
    }

    /// Which backend is active.
    pub fn backend(&self) -> Backend {
        self.backend
    }

    /// Compress a slice of f32 vectors.
    pub fn compress(&self, vectors: &[f32]) -> Result<Compressed, QuantError> {
        let data = match self.backend {
            Backend::Cuda => self.compress_cuda(vectors)?,
            Backend::Metal => self.compress_metal(vectors)?,
            Backend::Cpu => self.compress_cpu(vectors)?,
        };

        Ok(Compressed {
            data,
            original_len: vectors.len(),
            bits: self.bits,
            backend: self.backend,
        })
    }

    /// Decompress back to f32 vectors.
    pub fn decompress(&self, compressed: &Compressed) -> Result<Vec<f32>, QuantError> {
        match self.backend {
            Backend::Cuda => self.decompress_cuda(compressed),
            Backend::Metal => self.decompress_metal(compressed),
            Backend::Cpu => self.decompress_cpu(compressed),
        }
    }

    // ── CPU path (always available) ──────────────────────────────

    fn compress_cpu(&self, vectors: &[f32]) -> Result<Vec<u8>, QuantError> {
        // Walsh-Hadamard transform + asymmetric quantization to N bits
        // Delegates to turbo-quant crate's CPU SIMD implementation
        let dim = vectors.len();
        let bytes_per_element = (self.bits as usize + 7) / 8;
        let mut output = Vec::with_capacity(dim * bytes_per_element);

        // TODO: wire turbo_quant::quantize() once crate API stabilizes
        // For now, placeholder that demonstrates the pipeline:
        for &v in vectors {
            let scaled = ((v + 1.0) / 2.0 * ((1u32 << self.bits) - 1) as f32).round() as u8;
            output.push(scaled);
        }

        Ok(output)
    }

    fn decompress_cpu(&self, compressed: &Compressed) -> Result<Vec<f32>, QuantError> {
        let max_val = ((1u32 << compressed.bits) - 1) as f32;
        let output: Vec<f32> = compressed
            .data
            .iter()
            .map(|&b| (b as f32 / max_val) * 2.0 - 1.0)
            .collect();
        Ok(output)
    }

    // ── CUDA path ────────────────────────────────────────────────

    #[cfg(feature = "cuda")]
    fn compress_cuda(&self, vectors: &[f32]) -> Result<Vec<u8>, QuantError> {
        info!("gbaby-quant: compressing via CUDA kernel");
        // TODO: launch TurboQuant CUDA kernel via cudarc
        // Fallback to CPU for now during development
        warn!("CUDA kernel not yet wired — falling back to CPU path");
        self.compress_cpu(vectors)
    }

    #[cfg(not(feature = "cuda"))]
    fn compress_cuda(&self, _vectors: &[f32]) -> Result<Vec<u8>, QuantError> {
        Err(QuantError::UnsupportedBackend(
            "CUDA feature not compiled in".into(),
        ))
    }

    #[cfg(feature = "cuda")]
    fn decompress_cuda(&self, compressed: &Compressed) -> Result<Vec<f32>, QuantError> {
        warn!("CUDA kernel not yet wired — falling back to CPU path");
        self.decompress_cpu(compressed)
    }

    #[cfg(not(feature = "cuda"))]
    fn decompress_cuda(&self, _compressed: &Compressed) -> Result<Vec<f32>, QuantError> {
        Err(QuantError::UnsupportedBackend(
            "CUDA feature not compiled in".into(),
        ))
    }

    // ── Metal path ───────────────────────────────────────────────

    #[cfg(feature = "metal")]
    fn compress_metal(&self, vectors: &[f32]) -> Result<Vec<u8>, QuantError> {
        info!("gbaby-quant: compressing via Metal compute shader");
        // TODO: launch TurboQuant Metal compute pipeline
        warn!("Metal pipeline not yet wired — falling back to CPU path");
        self.compress_cpu(vectors)
    }

    #[cfg(not(feature = "metal"))]
    fn compress_metal(&self, _vectors: &[f32]) -> Result<Vec<u8>, QuantError> {
        Err(QuantError::UnsupportedBackend(
            "Metal feature not compiled in".into(),
        ))
    }

    #[cfg(feature = "metal")]
    fn decompress_metal(&self, compressed: &Compressed) -> Result<Vec<f32>, QuantError> {
        warn!("Metal pipeline not yet wired — falling back to CPU path");
        self.decompress_cpu(compressed)
    }

    #[cfg(not(feature = "metal"))]
    fn decompress_metal(&self, _compressed: &Compressed) -> Result<Vec<f32>, QuantError> {
        Err(QuantError::UnsupportedBackend(
            "Metal feature not compiled in".into(),
        ))
    }
}

/// Detect the best backend available on this system.
///
/// Priority: CUDA > Metal > CPU
fn detect_best_backend() -> Backend {
    if is_cuda_available() {
        return Backend::Cuda;
    }
    if is_metal_available() {
        return Backend::Metal;
    }
    Backend::Cpu
}

fn is_backend_available(backend: Backend) -> bool {
    match backend {
        Backend::Cuda => is_cuda_available(),
        Backend::Metal => is_metal_available(),
        Backend::Cpu => true, // always available
    }
}

/// Check for NVIDIA CUDA at runtime.
#[cfg(feature = "cuda")]
fn is_cuda_available() -> bool {
    match cudarc::driver::CudaDevice::new(0) {
        Ok(_) => {
            info!("gbaby-quant: CUDA device detected");
            true
        }
        Err(_) => false,
    }
}

#[cfg(not(feature = "cuda"))]
fn is_cuda_available() -> bool {
    false
}

/// Check for Apple Metal at runtime.
#[cfg(all(feature = "metal", target_os = "macos"))]
fn is_metal_available() -> bool {
    let device = metal::Device::system_default();
    if device.is_some() {
        info!("gbaby-quant: Metal device detected");
        true
    } else {
        false
    }
}

#[cfg(not(all(feature = "metal", target_os = "macos")))]
fn is_metal_available() -> bool {
    false
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cpu_roundtrip() {
        let q = Quant::auto(3).unwrap();
        assert_eq!(q.backend(), Backend::Cpu); // CI has no GPU
        let input = vec![0.0_f32, 0.5, -0.5, 1.0, -1.0];
        let compressed = q.compress(&input).unwrap();
        assert!(compressed.data.len() <= input.len()); // compressed
        let restored = q.decompress(&compressed).unwrap();
        assert_eq!(restored.len(), input.len());
        // Allow quantization error at 3-bit
        for (orig, rest) in input.iter().zip(restored.iter()) {
            assert!((orig - rest).abs() < 0.3, "{orig} vs {rest}");
        }
    }

    #[test]
    fn rejects_invalid_bits() {
        assert!(Quant::auto(0).is_err());
        assert!(Quant::auto(1).is_err());
        assert!(Quant::auto(9).is_err());
    }

    #[test]
    fn backend_display() {
        assert_eq!(format!("{}", Backend::Cuda), "CUDA");
        assert_eq!(format!("{}", Backend::Metal), "Metal");
        assert_eq!(format!("{}", Backend::Cpu), "CPU (SIMD)");
    }
}
