#!/bin/bash
# 
# Functions for setting up app frontend

#######################################
# Install node packages for frontend
# Arguments: None
#######################################
frontend_node_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/torresticket/frontend
  npm install --force
EOF
 
  sleep 2
}

#######################################
# Set frontend environment variables
# Arguments: None
#######################################
frontend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Ensure idempotency
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  sudo su - deploy << EOF
  cat <<[-]EOF > /home/deploy/torresticket/frontend/.env
REACT_APP_BACKEND_URL=${backend_url}
REACT_APP_ENV_TOKEN=210897ugn217204u98u8jfo2983u5
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=9999999
REACT_APP_FACEBOOK_APP_ID=1005318707427295
REACT_APP_NAME_SYSTEM=torresticket
REACT_APP_VERSION="1.0.0"
REACT_APP_PRIMARY_COLOR=$#fffff
REACT_APP_PRIMARY_DARK=2c3145
REACT_APP_NUMBER_SUPPORT=51997059551
SERVER_PORT=3333
WDS_SOCKET_PORT=0
[-]EOF
EOF

  # Execute the substitution commands
  sudo su - deploy <<EOF
  cd /home/deploy/torresticket/frontend

  BACKEND_URL=${backend_url}

  sed -i "s|https://autoriza.dominio|\$BACKEND_URL|g" \$(grep -rl 'https://autoriza.dominio' .)
EOF

  sleep 2
}


#######################################
# Start pm2 for frontend
# Arguments: None
#######################################
frontend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/torresticket/frontend
  pm2 start server.js --name torresticket-frontend
  pm2 save
EOF

  sleep 2
}

#######################################
# Set up nginx for frontend
# Arguments: None
#######################################
frontend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  frontend_hostname=$(echo "${frontend_url/https:\/\/}")

  sudo su - root << EOF

  cat > /etc/nginx/sites-available/torresticket-frontend << 'END'
server {
  server_name $frontend_hostname;

  location / {
    proxy_pass http://127.0.0.1:3333;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END

  ln -s /etc/nginx/sites-available/torresticket-frontend /etc/nginx/sites-enabled
EOF

  sleep 2
}


system_unzip() {
  print_banner
  printf "${WHITE} 💻 Fazendo unzip torresticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  unzip "${PROJECT_ROOT}"/torresticket.zip
EOF

  sleep 2
}


move_torresticket_files() {
  print_banner
  printf "${WHITE} 💻 Movendo arquivos do torresticket...${GRAY_LIGHT}"
  printf "\n\n"
 
  sleep 2

  sudo su - root <<EOF


  sudo rm -r /home/deploy/torresticket/frontend/torresticket
  sudo rm -r /home/deploy/torresticket/frontend/package.json
  sudo rm -r /home/deploy/torresticket/backend/torresticket
  sudo rm -r /home/deploy/torresticket/backend/package.json
  sudo rm -rf /home/deploy/torresticket/frontend/node_modules
  sudo rm -rf /home/deploy/torresticket/backend/node_modules

  sudo mv /root/torresticket/frontend/torresticket /home/deploy/torresticket/frontend
  sudo mv /root/torresticket/frontend/package.json /home/deploy/torresticket/frontend
  sudo mv /root/torresticket/backend/torresticket /home/deploy/torresticket/backend
  sudo mv /root/torresticket/backend/package.json /home/deploy/torresticket/backend
  sudo rm -rf /root/torresticket
  sudo apt update
  sudo apt install ffmpeg

EOF
  sleep 2
}


frontend_conf1() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Ensure idempotency
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  sudo su - root <<EOF
  cd /home/deploy/torresticket/frontend

  BACKEND_URL=${backend_url}

  sed -i "s|https://autoriza.dominio|\$BACKEND_URL|g" \$(grep -rl 'https://autoriza.dominio' .)
EOF

  sleep 2
}

frontend_node_dependencies1() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/torresticket/frontend
  npm install --force
EOF

  sleep 2
}

frontend_restart_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/torresticket/frontend
  pm2 stop all

  pm2 start all
EOF

  sleep 2
}  

backend_node_dependencies1() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/torresticket/backend
  npm install --force
EOF

  sleep 2
}

backend_db_migrate1() {
  print_banner
  printf "${WHITE} 💻 Executando db:migrate...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/torresticket/backend
  npx sequelize db:migrate

EOF

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/torresticket/backend
  npx sequelize db:migrate
  
EOF

  sleep 2
}

backend_restart_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
    cd /home/deploy/torresticket/backend
    pm2 stop all
    sudo rm -rf /root/sistema_completo
EOF

  sleep 2

  sudo su - <<EOF
    usermod -aG sudo deploy

    grep -q "^deploy ALL=(ALL) NOPASSWD: ALL$" /etc/sudoers || echo "deploy ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    echo "deploy ALL=(ALL) NOPASSWD: ALL" | EDITOR='tee -a' visudo
EOF

  sudo su - deploy <<EOF
    pm2 start all
EOF

  sleep 2
}