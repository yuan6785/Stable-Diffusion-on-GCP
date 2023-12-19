# /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_init.sh  # 记得chmod +x /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_init.sh 
echo "ecs init inner start"
cd /home; rm -rf stable-diffusion-webui; mkdir -p stable-diffusion-webui
cd /home; rm -rf ComfyUI; mkdir -p ComfyUI
echo "ecs init inner end"