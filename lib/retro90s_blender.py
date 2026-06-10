# SPDX-License-Identifier: MIT
"""
retro90s_blender.py — the retro90s.inc look library, ported to Blender/Cycles.

Mirrors lib/retro90s.inc macro-for-macro so the GPU lane produces the same
authentic mid-90s raytrace look: mirror chrome, refractive glass, glossy plastic,
infinite reflective checkerboards, procedural fractal terrain, gradient skies.

Import in a Blender scene script:
    import sys; sys.path.append("<repo>/lib")
    from retro90s_blender import *
    retro_reset()
    retro_sky_gradient((0.15,0.20,0.55), (1.0,0.55,0.25))
    retro_sun((-0.6,0.7,-0.4), (1.0,0.92,0.78))
    retro_checker_floor((0.9,0.9,0.95), (0.08,0.08,0.12), reflect=0.35)
    s = retro_sphere((0,6,2.2), 2.2, retro_chrome((0.85,0.88,0.95)))
    retro_camera((0,-3,3.2), (0,7,1.8))

Coordinate note: POV-Ray is Y-up, Blender is Z-up. These helpers take POV-style
(x, depth, height) tuples and map them to Blender (x, y=depth, z=height) so scene
descriptions translate directly from the POV-Ray side.
"""
import math
import bpy
from mathutils import Vector


# ----------------------------------------------------------------------------
# small helpers
# ----------------------------------------------------------------------------
def _rgba(c):
    """Accept (r,g,b) or (r,g,b,a) -> (r,g,b,a)."""
    return (c[0], c[1], c[2], c[3] if len(c) > 3 else 1.0)


def _set(bsdf, value, *names):
    """Set the first Principled BSDF input that exists (version-tolerant)."""
    for n in names:
        if n in bsdf.inputs:
            bsdf.inputs[n].default_value = value
            return True
    return False


def _principled(mat):
    return mat.node_tree.nodes.get("Principled BSDF")


def retro_reset():
    """Clear the default scene and set Cycles + sane render defaults."""
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    for block in (bpy.data.meshes, bpy.data.materials):
        for b in list(block):
            if b.users == 0:
                block.remove(b)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 96
    scene.render.resolution_x = 1280
    scene.render.resolution_y = 720
    scene.render.film_transparent = False
    scene.view_settings.view_transform = "Standard"  # punchy 90s look, not Filmic


# ----------------------------------------------------------------------------
# SKY  — vertical gradient world (sky_sphere equivalent)
# ----------------------------------------------------------------------------
def retro_sky_gradient(c_top, c_horizon):
    """World gradient from horizon color (looking out) to top color (looking up)."""
    world = bpy.data.worlds.get("World") or bpy.data.worlds.new("World")
    bpy.context.scene.world = world
    world.use_nodes = True
    nt = world.node_tree
    nt.nodes.clear()
    out = nt.nodes.new("ShaderNodeOutputWorld")
    bg = nt.nodes.new("ShaderNodeBackground")
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    sep = nt.nodes.new("ShaderNodeSeparateXYZ")
    mapr = nt.nodes.new("ShaderNodeMapRange")
    # view direction Z -> 0..1 (down=horizon, up=top)
    nt.links.new(geo.outputs["Incoming"], sep.inputs[0])
    nt.links.new(sep.outputs["Z"], mapr.inputs["Value"])
    mapr.inputs["From Min"].default_value = -0.15
    mapr.inputs["From Max"].default_value = 0.6
    nt.links.new(mapr.outputs["Result"], ramp.inputs["Fac"])
    ramp.color_ramp.elements[0].position = 0.0
    ramp.color_ramp.elements[0].color = _rgba(c_horizon)
    ramp.color_ramp.elements[1].position = 1.0
    ramp.color_ramp.elements[1].color = _rgba(c_top)
    nt.links.new(ramp.outputs["Color"], bg.inputs["Color"])
    bg.inputs["Strength"].default_value = 1.0
    nt.links.new(bg.outputs["Background"], out.inputs["Surface"])


# ----------------------------------------------------------------------------
# FLOORS
# ----------------------------------------------------------------------------
def retro_checker_floor(c1, c2, reflect=0.35, cell=1.0, size=200):
    """Infinite reflective checkerboard at z=0."""
    bpy.ops.mesh.primitive_plane_add(size=size, location=(0, 0, 0))
    obj = bpy.context.active_object
    obj.name = "RetroFloor"
    mat = bpy.data.materials.new("checker"); mat.use_nodes = True
    nt = mat.node_tree
    bsdf = _principled(mat)
    chk = nt.nodes.new("ShaderNodeTexChecker")
    chk.inputs["Color1"].default_value = _rgba(c1)
    chk.inputs["Color2"].default_value = _rgba(c2)
    chk.inputs["Scale"].default_value = max(1.0, size / (cell * 8))
    nt.links.new(chk.outputs["Color"], bsdf.inputs["Base Color"])
    # low roughness dielectric -> Fresnel reflection like POV reflection 0.35
    _set(bsdf, max(0.02, 0.18 * (1 - reflect)), "Roughness")
    _set(bsdf, 0.0, "Metallic")
    obj.data.materials.append(mat)
    return obj


def retro_grid_floor(grid_color, base_color, cell=1.0, size=200):
    """ReBoot-style glowing grid floor (emissive lines on a dark base)."""
    obj = retro_checker_floor(grid_color, base_color, reflect=0.25, cell=cell, size=size)
    mat = obj.data.materials[0]
    bsdf = _principled(mat)
    _set(bsdf, _rgba(grid_color), "Emission Color", "Emission")
    _set(bsdf, 0.6, "Emission Strength")
    return obj


# ----------------------------------------------------------------------------
# MATERIALS
# ----------------------------------------------------------------------------
def retro_chrome(tint=(0.85, 0.88, 0.95)):
    mat = bpy.data.materials.new("chrome"); mat.use_nodes = True
    b = _principled(mat)
    _set(b, _rgba(tint), "Base Color")
    _set(b, 1.0, "Metallic")
    _set(b, 0.03, "Roughness")
    return mat


def retro_glass(tint=(0.2, 0.9, 0.6)):
    mat = bpy.data.materials.new("glass"); mat.use_nodes = True
    b = _principled(mat)
    _set(b, _rgba(tint), "Base Color")
    _set(b, 0.0, "Metallic")
    _set(b, 0.0, "Roughness")
    _set(b, 1.0, "Transmission Weight", "Transmission")
    _set(b, 1.5, "IOR")
    return mat


def retro_plastic(base=(0.9, 0.12, 0.12)):
    mat = bpy.data.materials.new("plastic"); mat.use_nodes = True
    b = _principled(mat)
    _set(b, _rgba(base), "Base Color")
    _set(b, 0.0, "Metallic")
    _set(b, 0.18, "Roughness")          # hard, glossy hotspot
    _set(b, 0.7, "Specular IOR Level", "Specular")
    return mat


# ----------------------------------------------------------------------------
# OBJECTS  (POV-style x, depth, height -> Blender x, y, z)
# ----------------------------------------------------------------------------
def _loc(p):
    return (p[0], p[1], p[2])


def retro_sphere(loc, radius, material):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=radius, location=_loc(loc),
                                          segments=64, ring_count=32)
    o = bpy.context.active_object
    bpy.ops.object.shade_smooth()
    o.data.materials.append(material)
    return o


def retro_box(loc, size, material):
    bpy.ops.mesh.primitive_cube_add(size=size, location=_loc(loc))
    o = bpy.context.active_object
    o.data.materials.append(material)
    return o


def retro_torus(loc, major, minor, material, rot_deg=(0, 0, 0)):
    bpy.ops.mesh.primitive_torus_add(location=_loc(loc),
                                     major_radius=major, minor_radius=minor)
    o = bpy.context.active_object
    o.rotation_euler = tuple(math.radians(a) for a in rot_deg)
    bpy.ops.object.shade_smooth()
    o.data.materials.append(material)
    return o


def retro_cone(loc, radius, depth, material):
    bpy.ops.mesh.primitive_cone_add(radius1=radius, depth=depth, location=_loc(loc))
    o = bpy.context.active_object
    o.data.materials.append(material)
    return o


# ----------------------------------------------------------------------------
# TERRAIN  — fractal landscape via Displace modifier (isosurface equivalent)
# ----------------------------------------------------------------------------
def retro_fractal_terrain(height=8.0, scale_xz=22.0, loc=(0, 30, 0),
                          extent=120, material=None):
    """Rolling fractal terrain pushed into the background."""
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=200, y_subdivisions=200,
                                    size=extent, location=_loc(loc))
    o = bpy.context.active_object
    o.name = "RetroTerrain"
    tex = bpy.data.textures.new("terrain_noise", type="DISTORTED_NOISE")
    tex.noise_scale = scale_xz / 12.0
    mod = o.modifiers.new("displace", type="DISPLACE")
    mod.texture = tex
    mod.strength = height
    mod.mid_level = 0.0
    bpy.ops.object.shade_smooth()
    o.data.materials.append(material or retro_terrain_material())
    return o


def retro_terrain_material():
    """Earthy -> rock -> snow gradient keyed to height (Z)."""
    mat = bpy.data.materials.new("terrain"); mat.use_nodes = True
    nt = mat.node_tree
    b = _principled(mat)
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    sep = nt.nodes.new("ShaderNodeSeparateXYZ")
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    mapr = nt.nodes.new("ShaderNodeMapRange")
    nt.links.new(geo.outputs["Position"], sep.inputs[0])
    nt.links.new(sep.outputs["Z"], mapr.inputs["Value"])
    mapr.inputs["From Min"].default_value = -1.0
    mapr.inputs["From Max"].default_value = 9.0
    nt.links.new(mapr.outputs["Result"], ramp.inputs["Fac"])
    cr = ramp.color_ramp
    cr.elements[0].position = 0.0;  cr.elements[0].color = (0.30, 0.22, 0.12, 1)
    cr.elements[1].position = 1.0;  cr.elements[1].color = (0.97, 0.97, 1.0, 1)
    mid = cr.elements.new(0.45); mid.color = (0.25, 0.35, 0.15, 1)
    rock = cr.elements.new(0.72); rock.color = (0.45, 0.40, 0.38, 1)
    nt.links.new(ramp.outputs["Color"], b.inputs["Base Color"])
    _set(b, 0.85, "Roughness")
    return mat


# ----------------------------------------------------------------------------
# LIGHTING
# ----------------------------------------------------------------------------
def retro_sun(direction=(-0.6, 0.7, -0.4), color=(1.0, 0.92, 0.78), energy=4.0):
    """Key sun from `direction` (POV-style x,up,depth) + soft blue fill."""
    d = Vector((direction[0], direction[2], direction[1]))  # POV->Blender
    bpy.ops.object.light_add(type="SUN", location=(d * 50))
    sun = bpy.context.active_object
    sun.data.energy = energy
    sun.data.color = color[:3]
    sun.data.angle = math.radians(2.0)
    sun.rotation_euler = (-d).to_track_quat("Z", "Y").to_euler()
    # soft fill
    bpy.ops.object.light_add(type="SUN", location=(-d * 50 + Vector((0, 0, 20))))
    fill = bpy.context.active_object
    fill.data.energy = energy * 0.25
    fill.data.color = (0.35, 0.42, 0.60)
    fill.rotation_euler = (d).to_track_quat("Z", "Y").to_euler()
    return sun


# ----------------------------------------------------------------------------
# CAMERAS
# ----------------------------------------------------------------------------
def _aim_camera(cam, loc, target):
    cam.location = _loc(loc)
    direction = Vector(_loc(target)) - Vector(_loc(loc))
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def retro_camera(loc, target, lens_angle=50):
    bpy.ops.object.camera_add()
    cam = bpy.context.active_object
    cam.data.lens_unit = "FOV"
    cam.data.angle = math.radians(lens_angle)
    _aim_camera(cam, loc, target)
    bpy.context.scene.camera = cam
    return cam


def retro_orbit_camera(orbit_radius, cam_height, target, frames=72, lens_angle=50):
    """Camera orbiting `target`, keyframed over `frames` for animation."""
    bpy.ops.object.camera_add()
    cam = bpy.context.active_object
    cam.data.lens_unit = "FOV"
    cam.data.angle = math.radians(lens_angle)
    bpy.context.scene.camera = cam
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = frames
    tx, ty, tz = _loc(target)
    for f in range(1, frames + 1):
        a = 2 * math.pi * (f - 1) / frames
        loc = (tx + orbit_radius * math.sin(a), ty - orbit_radius * math.cos(a),
               cam_height)
        _aim_camera(cam, loc, target)
        cam.keyframe_insert("location", frame=f)
        cam.keyframe_insert("rotation_euler", frame=f)
    return cam


# ----------------------------------------------------------------------------
# RENDER
# ----------------------------------------------------------------------------
def retro_render_still(out_path, samples=None):
    scene = bpy.context.scene
    if samples:
        scene.cycles.samples = samples
    import os
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)


def retro_render_anim(out_dir, samples=None):
    scene = bpy.context.scene
    if samples:
        scene.cycles.samples = samples
    import os
    os.makedirs(out_dir, exist_ok=True)
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = os.path.join(out_dir, "f")
    bpy.ops.render.render(animation=True)
