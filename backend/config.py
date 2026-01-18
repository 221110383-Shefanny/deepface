"""
Configuration for DeepFace Backend
Forces CPU-only mode to avoid CUDA/GPU errors
"""

import os
import warnings

# Suppress TensorFlow warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'  # 0=all, 1=info, 2=warning, 3=error

# Force CPU-only mode (disable GPU) - use empty string for cleaner output
os.environ['CUDA_VISIBLE_DEVICES'] = ''  # Disable CUDA - empty string is cleaner

# Disable oneDNN custom operations (optional, for cleaner output)
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'

# Suppress deprecation warnings
warnings.filterwarnings('ignore', category=DeprecationWarning)
warnings.filterwarnings('ignore', category=FutureWarning)

print("🔧 Configuration loaded:")
print("   ✅ CPU-only mode enabled (GPU disabled)")
print("   ✅ TensorFlow warnings suppressed")
print("   ✅ CUDA disabled (CUDA_VISIBLE_DEVICES='')")
