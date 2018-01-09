#!/bin/bash

count=`ps aux | grep -i $$ | grep -ciE "(/| |da)sh[ ]+$0"`
if [ $count -gt 0 ]; then
  echo "usage:"
  echo "  bash $0"
  exit 0
fi

ENV_BIN=$(cd `dirname $BASH_SOURCE`&& /bin/pwd)
ENV_PATH=$(cd $ENV_BIN/.. && /bin/pwd)

uid=$(id -u)

func_sudo_env()
{
  if [ $uid -ne 0 ]; then
    SUDO=sudo
  fi

  # keep user env and add customized env path to sudo secure_path variable
  env_reset_found=`sudo cat /etc/sudoers | grep -c "env_reset"`
  if [ $env_reset_found -gt 0 ]; then
    $SUDO sed -E -i 's/\!*env_reset/!env_reset/g' /etc/sudoers
  else
    set +H
    $SUDO bash -c 'echo -e "Defaults\t!env_reset" >> /etc/sudoers'
    set -H
  fi

  secure_path_found=`$SUDO cat /etc/sudoers | grep -c secure_path`
  if [ $secure_path_found -gt 0 ]; then
    path_found=`$SUDO cat /etc/sudoers | grep -c $ENV_BIN`
    if [ $path_found -eq 0 ]; then
      ENV_BIN_ESCAPE=${ENV_BIN//\//\\\/}
      $SUDO sed -i "s/secure_path=\"/secure_path=\"$ENV_BIN_ESCAPE:/g" /etc/sudoers
    fi
  fi
}

func_bash_env()
{
  lsla=`tail -n1 ~/.bashrc | cut -d' ' -f3`
  if [ "$lsla" = "-la" ]; then
    echo "already setup bash env, jump to next step..."
    return
  fi

  echo -e "\nsource $ENV_PATH/config.env" >> ~/.bashrc
  echo -e "\nalias ll='ls -l --color=auto'" >> ~/.bashrc
  echo -e "alias la='ls -la --color=auto'" >> ~/.bashrc
}

# setup vim plugin environment
func_vimenv_setup() {
  VIM_PATH=$ENV_PATH/vim
  vimrc=`readlink $HOME/.vimrc`

  if [ "$vimrc" = "$VIM_PATH/.vimrc" ]; then
    echo "already setup vim env, jump to next step..."
    return
  fi

  # universal-ctags dependency
  echo "Please check the universal-ctags dependency..."
  echo "You can install the dependency by running:"
  echo "sudo apt-get install -y libyaml-dev libxml2-dev libseccomp-dev libjansson-dev python-docutils"

  $SUDO cp $ENV_BIN/ctags $ENV_BIN/readtags /usr/bin/

  # each user should use himself vim config
  ln -sf $VIM_PATH/.vimrc $HOME/.vimrc

  # to avoid vim uses default.vim configuration
  if [ ! -e $HOME/.vimrc ]; then
    touch $HOME/.vimrc
  fi
}

func_fzf_setup() {
  FZF_PATH=$ENV_PATH/fzf

  cp -r $FZF_PATH ~/.fzf
  ~/.fzf/install --all
}

func_sudo_env
func_bash_env
func_vimenv_setup
func_fzf_setup
