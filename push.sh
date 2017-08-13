cd "$(DIRNAME "$0")"
git pull
git add *
read msg
git commit -m "$msg"
git push
