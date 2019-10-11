export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$HOME/.rbenv/bin:$PATH

if [[ "$OSTYPE" == "darwin"* ]]; then
    export "PATH=/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

export EDITOR=vim
export WORK_EDITOR=code
export SSH_KEY_PATH=~/.ssh/id_rsa
export EMAIL="artoriousso@gmail.com"
export TODO_REMOTE_URL="git@github.com:ARtoriouSs/todo.git"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    export FILE_MANAGER="nemo" # "nautilus"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export FILE_MANAGER="open"
fi

# directories and files access
export MY_FOLDER=$HOME/my_folder
export PROJECTS=$HOME/my_folder/projects
export DESKTOP=$HOME/Desktop
export TODO=~/todo.yml
