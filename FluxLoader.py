import os
import comfy.model_management as mm

MODEL_DIR = os.path.join(os.path.dirname(__file__), "models")

# Define model paths
FLUX_MODELS = {
    "Flux_T5XXL": os.path.join(MODEL_DIR, "flux_t5xxl_fp16.safetensors"),
    "Flux_AE": os.path.join(MODEL_DIR, "flux_ae.safetensors"),
    "Flux_CLIP": os.path.join(MODEL_DIR, "flux_clip_i.safetensors"),
}

def load_flux_models():
    """Register FluXXX models with ComfyUI."""
    for name, path in FLUX_MODELS.items():
        if os.path.exists(path):
            mm.register_model(name, path)
            print(f"✅ Loaded {name} from {path}")
        else:
            print(f"❌ WARNING: {name} not found at {path}")

# Load models when ComfyUI starts
load_flux_models()
