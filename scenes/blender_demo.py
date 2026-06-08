"""blender_demo.py — minimal Cycles scene to validate the GPU render lane.
Run via: blender -b -P gpu_enable.py -P scenes/blender_demo.py
gpu_enable.py (run first) forces Cycles onto the GPU. This builds a chrome
sphere on a glossy floor with a sunset world, then renders one still.
"""
import os, math, bpy

# clean slate
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete()

# chrome hero sphere
bpy.ops.mesh.primitive_uv_sphere_add(radius=1.4, location=(0, 0, 1.4))
bpy.ops.object.shade_smooth()
chrome = bpy.data.materials.new("chrome"); chrome.use_nodes = True
bsdf = chrome.node_tree.nodes["Principled BSDF"]
bsdf.inputs["Base Color"].default_value = (0.85, 0.88, 0.95, 1)
bsdf.inputs["Metallic"].default_value = 1.0
bsdf.inputs["Roughness"].default_value = 0.04
bpy.context.active_object.data.materials.append(chrome)

# glossy floor
bpy.ops.mesh.primitive_plane_add(size=40, location=(0, 0, 0))
floor = bpy.data.materials.new("floor"); floor.use_nodes = True
fb = floor.node_tree.nodes["Principled BSDF"]
fb.inputs["Base Color"].default_value = (0.1, 0.1, 0.14, 1)
fb.inputs["Roughness"].default_value = 0.15
bpy.context.active_object.data.materials.append(floor)

# sunset world
world = bpy.data.worlds["World"]; world.use_nodes = True
world.node_tree.nodes["Background"].inputs[0].default_value = (1.0, 0.5, 0.2, 1)
world.node_tree.nodes["Background"].inputs[1].default_value = 0.6

# sun + camera
bpy.ops.object.light_add(type="SUN", location=(-5, -5, 8))
bpy.context.active_object.data.energy = 4.0
bpy.ops.object.camera_add(location=(0, -7, 3),
                          rotation=(math.radians(72), 0, 0))
bpy.context.scene.camera = bpy.context.active_object

# render settings
scene = bpy.context.scene
scene.cycles.samples = 64
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
out = os.path.join(os.getcwd(), "output", "blender_demo.png")
os.makedirs(os.path.dirname(out), exist_ok=True)
scene.render.filepath = out
print(f"[blender_demo] rendering -> {out}")
bpy.ops.render.render(write_still=True)
print("[blender_demo] done")
