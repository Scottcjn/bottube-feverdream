import subprocess
import os

def test():
    out_file = "test_gpu_out.mp4"
    prompt = "test sphere"
    
    print(f"Running make_video_gpu.sh for '{prompt}'...")
    # We override the NODE env or argument via a wrapper if needed, 
    # but render_gpu.sh takes it as 3rd arg.
    # Since make_video_gpu.sh calls render_gpu.sh without the 3rd arg, 
    # it uses the default 192.168.0.106.
    # I will patch make_video_gpu.sh temporarily to use 'local'.
    
    with open("make_video_gpu.sh", "r") as f:
        content = f.read()
    
    content = content.replace('"$HERE/render_gpu.sh" "$WRAPPER" "$FRAMES"', '"$HERE/render_gpu.sh" "$WRAPPER" "$FRAMES" "local"')
    
    with open("make_video_gpu.sh", "w") as f:
        f.write(content)
        
    try:
        subprocess.run(["./make_video_gpu.sh", prompt, out_file, "1", "1"], check=True)
        if os.path.exists(out_file):
            print("SUCCESS: mp4 produced")
        else:
            print("FAIL: no mp4 produced")
    except Exception as e:
        print(f"FAILED with error: {e}")

if __name__ == "__main__":
    test()
