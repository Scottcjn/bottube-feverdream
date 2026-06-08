"""gpu_enable.py — force Blender Cycles onto the GPU (OptiX > CUDA).

Run as a -P pre-script before your scene script / .blend render so Cycles never
silently falls back to CPU on the render node. Prints the devices it engaged.
"""
import bpy

def enable_gpu():
    prefs = bpy.context.preferences
    cprefs = prefs.addons["cycles"].preferences
    chosen = None
    for backend in ("OPTIX", "CUDA", "HIP", "ONEAPI"):
        try:
            cprefs.compute_device_type = backend
        except TypeError:
            continue
        cprefs.get_devices()
        gpus = [d for d in cprefs.devices if d.type == backend]
        if gpus:
            chosen = backend
            for d in cprefs.devices:
                d.use = (d.type == backend)   # GPUs on, CPU off
            break

    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    if chosen:
        scene.cycles.device = "GPU"
        names = [d.name for d in cprefs.devices if d.use]
        print(f"[gpu_enable] Cycles GPU via {chosen}: {names}")
    else:
        scene.cycles.device = "CPU"
        print("[gpu_enable] WARNING: no GPU found, falling back to CPU")

enable_gpu()
