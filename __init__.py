import os
from comfy.model_management import register_model

MODEL_DIR = os.path.join(os.path.dirname(__file__), "models")

# Register FLUX models inside ComfyUI
register_model("Flux_T5XXL", os.path.join(MODEL_DIR, "flux_t5xxl_fp16.safetensors"))
register_model("Flux_AE", os.path.join(MODEL_DIR, "flux_ae.safetensors"))
register_model("Flux_CLIP", os.path.join(MODEL_DIR, "flux_clip_i.safetensors"))

print("✅ FluXXX models loaded successfully!")
