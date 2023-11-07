# /mnt/sdwebui_public/ecs_versions/ecs_init.sh  # 记得chmod +x /mnt/sdwebui_public/ecs_versions/ecs_init.sh 
echo "ecs init inner start"
cd /home; rm -rf stable-diffusion-webui; mkdir -p stable-diffusion-webui
echo "ecs init inner end"