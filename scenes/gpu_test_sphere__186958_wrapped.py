import sys
sys.path.append("/home/Artur/projects/bottube-feverdream/lib")
from retro90s_blender import *
retro_reset()
retro_orbit_camera(orbit_radius=15, cam_height=5, target=(0,0,0), frames=1)
exec(open("/home/Artur/projects/bottube-feverdream/scenes/gpu_test_sphere__186958.py").read())
