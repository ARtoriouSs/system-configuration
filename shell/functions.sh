# open with default application
o() {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    [ -z "$1" ] && xdg-open . || xdg-open $@
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    [ -z "$1" ] && open . || open $@
  fi
}

# open tmux session for current project
tp() {
  tmux has-session -t "project"
  if [ $? != 0 ]; then
    tmux new-session -d -s "project" -n "project" -c $PROJECTS/$CURRENT_PROJECT
    tmux split-window -h -c $PROJECTS/$CURRENT_PROJECT
    tmux resize-pane -R 20
    tmux split-window -v -c $PROJECTS/$CURRENT_PROJECT
    tmux resize-pane -U 10
    tmux select-pane -t 0
    tmux split-window -v -c $PROJECTS/$CURRENT_PROJECT
    tmux resize-pane -U 10

    tmux new-window -n "editor" -c $PROJECTS/$CURRENT_PROJECT "$EDITOR"

    tmux next-window -t "project"
    tmux select-pane -t 1

    tmux send-keys -t "project:0.0" "rs" Enter
    tmux send-keys -t "project:0.1" "cowsay Hello!" Enter
    tmux send-keys -t "project:0.2" "gst -i" Enter
    tmux send-keys -t "project:0.3" "rc" Enter
  fi
  tmux -2 attach-session -t "project"
}

# open default tmux session in current directory
th() {
  local directory=$(basename $PWD)
  tmux has-session -t "$directory"
  if [ $? != 0 ]; then
    tmux new-session -d -s "$directory" -n "$directory"
    tmux split-window -h

    tmux new-window -n "editor" "$EDITOR"

    tmux next-window -t "$directory"
    tmux select-pane -t 0

    tmux send-keys -t "${directory}:0.0" "cowsay Hello!" Enter
    tmux send-keys -t "${directory}:0.1" "gst" Enter
  fi
  tmux -2 attach-session -t "$directory"
}

# kill current directory tmux session
tk() {
  local session=$([ -z "$1" ] && echo $(basename $PWD) || echo $1)
  tmux has-session -t "$session"
  [ $? = 0 ] && tmux kill-session -t "$session"
}
alias tka="tmux kill-server" # kill all tmux sessions along with a server

# generate ctags
tags() {
  local git_dir="`git rev-parse --git-dir`"
  trap 'rm -f "$git_dir/$$.tags"' EXIT

  if [ "$1" = "--rails" ]; then # when rails add gem paths
    # use regex to remove warnings from bundle output
    ctags -R --tag-relative=yes --languages=ruby,javascript --exclude=.git --exclude=log -f $git_dir/$$.tags . $(bundle list --paths | awk '/^\/home/ { print $0 }')
  else
    ctags -R --tag-relative=yes --languages=ruby,javascript --exclude=.git -f $git_dir/$$.tags
  fi
  mv "$git_dir/$$.tags" "$git_dir/tags"
}

# display linux 256 colors
color-list() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolor%-5i\x1b[0m" $i
    if ! (( ($i + 1) % 8 )); then
      echo
    fi
  done
}

# cd to $PROJECTS and farther
alias cdc="cdp $CURRENT_PROJECT"
alias cdt="cdp test"
cdp() {
  cd $PROJECTS/$1
}

# clean $PROJECTS/test directory
clear-test() {
  rm -rf $PROJECTS/test
  mkdir $PROJECTS/test
}

# copy to system clipboard
clip() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    pbcopy < $@
  elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    xclip -sel clip < $@
  fi
}

# remove all docker containers
drmall() {
  docker rm -f $(docker ps -aq)
}

# run redis in docker in a background
redis-up() {
  if [ "$1" = "--docker" ] || [ "$1" = "-d" ]
  then
    docker run -d -p 6379:6379 redis
  else
    redis-server --daemonize yes
  fi
}

# kill redis whether in system process or in docker
kill-redis() {
  ps aux | grep redis-server | awk '{ print $2; exit }' | xargs kill -9
  docker ps | grep redis | awk '{ print $1 }' | xargs docker rm -f
}

# kill server on specified port (3000 by default)
kill-s() {
  [ -z "$1" ] && PORT=3000 || PORT=$1
  lsof -i tcp:$PORT | grep -v 'chrome' | awk 'FNR > 1 {print $2}' | xargs kill -9
}

# generate rails migration and quote all args as name
alias migr="gen-migration"
gen-migration() {
  local IFS='_'
  bundle exec rails generate migration "$*"
}

# rollback rails migrations
rollback() {
  [ -z "$1" ] && STEP=1 || STEP=$1
  bundle exec rails db:rollback STEP=$STEP
}

alias rr="search-routes"
search-routes() {
  if [ -z "$1" ]; then
    bundle exec rails routes
  else
    bundle exec rails routes | $GREP_TOOL $@
  fi
}

# git status function with interactive option for running in separate tmux tab
alias gst="status"
status() {
  local project=$(basename $PWD)
  local lockfile=~/git_status_interactive_for_$project.lock
  if [ "$1" = "--interactive" ] || [ "$1" = "-i" ]; then
    trap "rm -f $lockfile" SIGINT
    while sleep 0.2s; do
      touch $lockfile
      DIFF=$(diff $lockfile <(colored_status))
      if [[ "$DIFF" != "" && $DIFF != "1do/n<" ]]; then
        clear
        printf "git status for $(tput setaf 208)$project$(tput sgr0):\n"
        colored_status
        echo "$(colored_status)" > $lockfile
      fi
    done
  else
    colored_status
  fi
}

# colored_status that will not display status if interactive status lockfile exists for current pwd (for funcitons)
locked_status() {
  if [ ! -f ~/git_status_interactive_for_$(basename $PWD).lock ]; then
    colored_status
  fi
}

# colored `git status --short`
colored_status() {
  git status --porcelain | awk '{
    split($0, chars, "")
    index_bit = chars[1]
    tree_bit = chars[2]
    green = "\033[92m"
    yellow = "\033[93m"
    red = "\033[91m"
    violet = "\033[95m"
    white = "\033[0m"
    $1=""

    if (index_bit == "?" && tree_bit == "?")
        output = "  " violet index_bit tree_bit "  " $0 white
    else if (index_bit == "!" && tree_bit == "!")
        output = "  " index_bit tree_bit "  " $0
    else if ((index_bit == "U" || tree_bit == "U") || (index_bit == "A" && tree_bit == "A") || (index_bit == "D" && tree_bit == "D"))
        output = "  " red index_bit tree_bit "  " $0 white
    else {
        output = "  " green index_bit

        if (tree_bit == "D")
            output = output red tree_bit white "  "
        else
            output = output yellow tree_bit white "  "

        if (index_bit != " ") {
            output = output green $0 white
        } else {
            if (tree_bit == "D")
                output = output red $0 white
            else
                output = output yellow $0 white
        }
    }

    print output
  }'
}

# git stash file or all files if no args specified
stash() {
  if [ -z "$1" ]; then
    git stash
  else
    git stash push "$@"
  fi
  locked_status
}

# git stash pop given stash or last one if no args specified
pop() {
  git stash pop --quiet $@
  locked_status
}

# git add files or all files if no args specified
alias ga="add"
add() {
  if [ -z "$1" ]; then
    git add --all
  else
    git add "$@"
  fi
  locked_status
}

# git reset file or all files if no args specified
reset() {
  if [ -z "$1" ]; then
    echo "Type 'y' to reset working tree to $(git rev-parse --short HEAD)"
    read key
    if [ "$key" = "y" ]; then
      git reset HEAD --hard
      rm -rf $(git status --short)
    else
      echo "Aborted"
    fi
  else
    git checkout -- $@ &> /dev/null

    # check if there is untracked files in args and remove them
    local untracked="$(git ls-files . --exclude-standard --others)"
    for record in $(echo $untracked); do
      for arg in "$@"; do
        if [ "$arg" = "$record" ]; then
          rm -rf $record
        fi
      done
    done
  fi
  locked_status
}
# reset without confirmation
freset() {
  if [ -z "$1" ]; then
    git reset HEAD --hard
    rm -rf $(git status --short)
  else
    git checkout -- $@ &> /dev/null

    # check if there is untracked files in args and remove them
    local untracked="$(git ls-files . --exclude-standard --others)"
    for record in $(echo $untracked); do
      for arg in "$@"; do
        if [ "$arg" = "$record" ]; then
          rm -rf $record
        fi
      done
    done
  fi
  locked_status
}

# remove file from index or all files if no args specified
alias grh="index"
index() {
  git reset -q HEAD $@
  locked_status
}

# commit and quote all args as message
alias gcm="commit"
commit() {
  git commit -v -m "$*"
  locked_status
}

alias gcan="amend-no-edit"
amend-no-edit() {
  git commit --amend --no-edit
  locked_status
}

# push current branch to origin
alias forsepush="push --force-with-lease"
alias fpush="push --force-with-lease"
push() {
  current=$(git branch | grep '\*' | awk '{print $2}')
  git push $@ origin "${current}"
}

# pull current branch from origin
pull() {
  current=$(git branch | grep '\*' | awk '{print $2}')
  git pull origin "${current}"
  locked_status
}

# clone repo from github
alias get="clone-my"
clone-my() {
  git clone git://github.com/$GITHUB_USERNAME/$1.git $2
}

# ignore without .gitignore
ignore() {
  git update-index --assume-unchanged $@
}

no-ignore() {
  git update-index --no-assume-unchanged $@
}

grem() {
  if [ -z "$1" ]; then
    git remote -v
  else
    git remote "$@"
    git remote -v
  fi
}
